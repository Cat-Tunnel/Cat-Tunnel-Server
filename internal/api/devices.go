/*
The devices api stores the information needed to identify a device.
*/

package api

import (
	"cat-tunnel-server/internal/db"
	"net/http"

	"github.com/gin-gonic/gin"
)

// newDeviceBody is the required fields needed to register a new device
type newDeviceBody struct {
	Model 		 string
	Manufacturer string
}

type deviceCreationResponse struct {
	Message string
	DeviceID int32
}

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
// PostDevice will create a new device registration
func PostDevice(c *gin.Context) {

	var body newDeviceBody

	err := c.BindJSON(&body)
	if err != nil {
		// Return early if the request body is not formatted correctly.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The request body was not formatted correctly."})
		return
	}

	deviceID, err := db.CreateDevice(body.Model, body.Manufacturer)
	if err != nil {
		// Return early if there was any error writing to the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error writing to the database."})
		return
	}

	c.JSON(http.StatusOK, 
		deviceCreationResponse{Message: "The device was created", DeviceID: deviceID})
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
