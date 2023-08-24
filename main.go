package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"path"
	"regexp"
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

	cid := path.Base(r.URL.Path)
	if !isPossiblyCID(cid) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(fmt.Sprintf("Invalid pathname: %s", r.URL.Path)))
		return
	}
	ipfsGatewayHost, _ := os.LookupEnv("IPFS_GATEWAY_HOST")

	ipfsURL := fmt.Sprintf("%s/ipfs/%s", ipfsGatewayHost, cid)
	resp, err := http.Get(ipfsURL)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		_, _ = w.Write([]byte(fmt.Sprintf("Failed to fetch IPFS URL: %s", ipfsURL)))
		return
	}

	defer resp.Body.Close()

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

func isPossiblyCID(possibleCID string) bool {
	cidRegex := regexp.MustCompile(`Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,}`)
	return cidRegex.MatchString(possibleCID)
}
