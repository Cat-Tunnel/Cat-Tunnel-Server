/*
The devices api stores the information needed to identify a device.
*/

package api

import (
	"cat-tunnel-server/internal/db"
	"net/http"

	"github.com/gin-gonic/gin"
)

// GetDevices api call responds to the user with an array of devices
func GetDevices(c *gin.Context) {

	devicesFromDB, err := db.GetAllDevices()
	if err != nil {
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error reading from the database."})
		return
	}

	c.JSON(http.StatusOK, devicesFromDB)
}

// DeleteDevice permenantly removes a device from the database
func DeleteDevice(c *gin.Context) {

	deviceID, err := sanitizeDeviceID(c.Param("deviceid"))
	if err != nil {
		// Return early if the request does not submit a valid device id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "DeviceID is required and must be a valid number."})
		return
	}

	err = db.DeleteDevice(deviceID)
	if err != nil {
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error deleting device from the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}
