/*
The networks api is used to stage networks that can be applied to
a device configuration.
*/

package api

import (
	"cat-tunnel-server/internal/db"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetNetworks returns the details of every network. Passwords are excluded.
func GetNetworks(c *gin.Context) {

	networksFromDB, err := db.GetNetworks()
	if err != nil {
		fmt.Println(err)
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error reading from the database."})
		return
	}

	c.JSON(http.StatusOK, networksFromDB)
}
