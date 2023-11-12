package main

import (
	"github.com/gin-gonic/gin"

	"cat-tunnel-server/internal/api"
)

func registerRoutes() {
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	router.GET("/devices", api.NotImplemented)
	router.GET("/commands", api.NotImplemented)
	router.GET("/whiskers", api.GetWhiskers)
	router.GET("/configurations", api.NotImplemented)
	router.Run("localhost:4000")
}

func main() {
	registerRoutes()
}
