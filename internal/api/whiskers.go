package api

import (
	"cat-tunnel-server/internal/db"
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetWhiskers(c *gin.Context) {
	whiskersFromDB, err := db.GetAllWhiskers(1)
	if err != nil {
		c.IndentedJSON(http.StatusInternalServerError, nil)
		return
	}

	c.IndentedJSON(http.StatusOK, whiskersFromDB)
}
