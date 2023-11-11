package main

import (
	"github.com/gin-gonic/gin"

	"cat-tunnel-server/internal/api"
)

func registerRoutes() {
	router := gin.Default()
	router.GET("/devices", api.NotImplemented)
	router.GET("/commands", api.NotImplemented)
	router.GET("/whiskers", api.NotImplemented)
	router.GET("/configurations", api.NotImplemented)
	router.Run("localhost:4000")
}

func main() {
	registerRoutes()
}
