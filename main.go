package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	_, hostEnvVariableExists := os.LookupEnv("IPFS_GATEWAY_HOST")
	if !hostEnvVariableExists {
		fmt.Println("Error: IPFS_GATEWAY_HOST environment variable not set")
		os.Exit(1)
	}
	_, allowOriginsEnvVariableExists := os.LookupEnv("ALLOW_ORIGINS")
	if !allowOriginsEnvVariableExists {
		fmt.Println("Error: ALLOW_ORIGINS environment variable not set")
		os.Exit(1)
	}

	_, apiKeyEnvVariableExists := os.LookupEnv("API_KEY")
	if !apiKeyEnvVariableExists {
		fmt.Println("Error: API_KEY environment variable not set")
		os.Exit(1)
	}

	router := chi.NewRouter()
	router.Use(middleware.Logger)
	router.Use(middleware.RealIP, middleware.Recoverer, middleware.RedirectSlashes, middleware.RequestID, middleware.CleanPath)

	router.NotFound(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNotFound)
		_, _ = w.Write([]byte("Route does not exist"))
	})

	router.MethodNotAllowed(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusMethodNotAllowed)
		_, _ = w.Write([]byte("Method not allowed"))
	})

	router.Get("/*", handleRequest)
	router.Head("/*", handleRequest)
	router.Options("/*", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	var port = envPortOr("3031")

	log.Fatal(http.ListenAndServe(port, router))
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	authHeader := r.Header.Get("Authorization")

	// if no auth header is set or auth header is empty, return unauthorized
	if authHeader == "" {
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = w.Write([]byte("Unauthorized"))
		return
	}

	API_KEY, _ := os.LookupEnv("API_KEY")

	if authHeader != API_KEY {
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = w.Write([]byte("Unauthorized"))
		return
	}

	ipAddress, err := getIP(r)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte(fmt.Sprintf("Failed to get IP address: %s", err)))
		return
	}

	allowOrigins, _ := os.LookupEnv("ALLOW_ORIGINS")

	// if allowOrigins is set to * then allow all origins
	if allowOrigins == "*" {
		allowOrigins = ipAddress
	}

	if !strings.Contains(allowOrigins, ipAddress) {
		w.WriteHeader(http.StatusForbidden)
		_, _ = w.Write([]byte(fmt.Sprintf("IP address %s is not allowed to access this resource", ipAddress)))
		return
	}
	w.Header().Set("Access-Control-Allow-Origin", "*")

	var cidAndFilePath string
	if strings.Contains(r.URL.Path, "/ipfs/") {
		splitPath := strings.SplitN(r.URL.Path, "/ipfs/", 2)
		if len(splitPath) < 2 {
			w.WriteHeader(http.StatusBadRequest)
			_, _ = w.Write([]byte(fmt.Sprintf("Invalid pathname: %s", r.URL.Path)))
			return
		}
		cidAndFilePath = splitPath[1]
	} else {
		cidAndFilePath = strings.TrimPrefix(r.URL.Path, "/")
	}

	ipfsGatewayHost, _ := os.LookupEnv("IPFS_GATEWAY_HOST")

	ipfsURL := fmt.Sprintf("%s/ipfs/%s", ipfsGatewayHost, cidAndFilePath)

	resp, err := http.Get(ipfsURL)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte(fmt.Sprintf("Failed to fetch IPFS URL: %s", ipfsURL)))
		return
	}

	defer resp.Body.Close()

	buffer := make([]byte, 512)
	_, err = resp.Body.Read(buffer)
	if err != nil && err != io.EOF {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte(fmt.Sprintf("Failed to read IPFS response: %s", err)))
		return
	}

	// Detect the content type
	contentType := http.DetectContentType(buffer)

	// If the content type is text/html but the content starts with <svg, it's probably an SVG file
	if (strings.HasPrefix(string(buffer), "<svg")) || strings.HasSuffix(r.URL.Path, ".svg") {
		contentType = "image/svg+xml"
	}

	// Set the Content-Type header
	w.Header().Set("Content-Type", contentType)

	_, _ = w.Write(buffer)

	_, _ = io.Copy(w, resp.Body)
}

func getIP(r *http.Request) (string, error) {
	ip := r.Header.Get("X-REAL-IP")
	netIP := net.ParseIP(ip)
	if netIP != nil {
		return ip, nil
	}

	ips := r.Header.Get("X-FORWARDED-FOR")
	splitIps := strings.Split(ips, ",")
	for _, ip := range splitIps {
		ip := strings.TrimSpace(ip)
		netIP := net.ParseIP(ip)
		if netIP != nil {
			return ip, nil
		}
	}

	ip, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return "", err
	}
	netIP = net.ParseIP(ip)
	if netIP != nil {
		return ip, nil
	}
	return "", fmt.Errorf("no valid ip found")
}

func envPortOr(port string) string {
	// If `PORT` variable in environment exists, return it
	if envPort := os.Getenv("PORT"); envPort != "" {
		return ":" + envPort
	}
	return ":" + port
}
