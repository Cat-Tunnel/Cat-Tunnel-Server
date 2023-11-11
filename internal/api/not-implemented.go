package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type notImplementedResponse struct {
	Message string
}

var defaultResponse = notImplementedResponse{
	Message: "NOT YET IMPLEMENTED",
}

func NotImplemented(c *gin.Context) {
	c.IndentedJSON(http.StatusNotFound, defaultResponse)
}
