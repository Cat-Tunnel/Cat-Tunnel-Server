package main

import (
	"github.com/gin-gonic/gin"

	"cat-tunnel-server/internal/api"
)

func registerRoutes() {
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	router.GET("/devices", api.GetDevices)
	router.POST("/devices", api.PostDevice)
	router.DELETE("/devices/:deviceid", api.DeleteDevice)
	router.GET("/commands", api.NotImplemented)
	router.GET("/whiskers", api.GetWhiskers)
	router.POST("/whiskers", api.PostWhiskers)
	router.GET("/configurations/:configurationid", api.GetConfiguration)
	router.PUT("/configurations/:configurationid", api.UpdateConfiguration)
	router.DELETE("/configurations/:configurationid", api.DeleteConfiguration)
	router.Run("localhost:4000")
}

func main() {
	registerRoutes()
}
