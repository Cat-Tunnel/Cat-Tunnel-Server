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

type networkBody struct {
	NetworkID   int32  `json:"networkID"`
	Name        string `json:"name"`
	Ssid        string `json:"ssid"`
	Password    string `json:"password"`
	AutoConnect bool   `json:"autoConnect"`
}

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

	// Convert to camel case
	networksReturnObject := make([]networkBody, 0)

	for _, dbNetwork := range networksFromDB {
		newNetwork := networkBody{
			NetworkID:   int32(dbNetwork.NetworkID),
			Name:        dbNetwork.Name,
			Ssid:        dbNetwork.SSID,
			Password:    "",
			AutoConnect: dbNetwork.AutoConnect,
		}

		networksReturnObject = append(networksReturnObject, newNetwork)
	}

	c.JSON(http.StatusOK, networksReturnObject)
}

// UpdateNetwork stages a new network or updates on if it exists
func UpdateNetwork(c *gin.Context) {

	var body networkBody

	err := c.BindJSON(&body)
	if err != nil {
		// Return early if the request body is not formatted correctly.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The request body was not formatted correctly."})
		return
	}

	networkID, err := sanitizeNetworkID(c.Param("networkid"))
	if err != nil {
		// Return early if the request does not submit a valid network id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "NetworkID is required and must be a valid number."})
		return
	}

	err = db.UpdateNetwork(
		networkID,
		body.Name,
		body.Ssid,
		body.Password,
		body.AutoConnect,
	)
	if err != nil {
		fmt.Println(err)
		// Return early if there was any error writing to the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error writing to the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}

// DeleteNetwork removes the network and unlinks it from configurations.
// If the network is added again it will have to be re-applied to the configuration.
func DeleteNetwork(c *gin.Context) {

	networkID, err := sanitizeNetworkID(c.Param("networkid"))
	if err != nil {
		// Return early if the request does not submit a valid network id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "NetworkID is required and must be a valid number."})
		return
	}

	err = db.DeleteNetwork(networkID)
	if err != nil {
		// Return early if there was any error writing to the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error writing to the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}
