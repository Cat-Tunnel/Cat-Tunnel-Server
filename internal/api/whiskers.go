/*
The whiskers api is used to submit a set of key tracking metrics
from the device at a given time. This is used to track device health.
Get whiskers allows an endpoint to view a history of all whiskers.
*/

package api

import (
	"cat-tunnel-server/internal/db"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type whiskerBody struct {
	DeviceID     int32
	Batterylevel int16
	StorageUsage int32
	Location     string
}

type errorResponse struct {
	Message string
}

// GetWhiskers handles getting a list of all whiskers recorded for a device.
func GetWhiskers(c *gin.Context) {

	deviceID, err := sanitizeDeviceID(c.Query("deviceid"))
	if err != nil {
		// Return early if the request does not submit a valid device id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "DeviceID is required and must be a valid number."})
		return
	}

	whiskersFromDB, err := db.GetAllWhiskers(int32(deviceID))
	if err != nil {
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error reading from the database."})
		return
	}

	c.JSON(http.StatusOK, whiskersFromDB)
}

// PostWhiskers submits the provided metrics to the database.
// The sync time is based on the time the request was recieved.
func PostWhiskers(c *gin.Context) {
	var body whiskerBody

	err := c.BindJSON(&body)
	if err != nil {
		// Return early if the request body is not formatted correctly.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The request body was not formatted correctly."})
		return
	}

	// Sanitize the input body here.
	body, err = sanitizeWhiskerBody(body)
	if err != nil {
		// Return early if the request body is not formatted correctly.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The request body was not formatted correctly."})
		return
	}

	err = db.CreateWhisker(
		body.DeviceID,
		body.Batterylevel,
		body.StorageUsage,
		body.Location,
	)
	if err != nil {
		// Return early if there was any error writing to the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error writing to the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}

func sanitizeDeviceID(deviceID string) (int32, error) {
	// DeviceID query parameter is required.
	if deviceID == "" {
		return 0, fmt.Errorf("device id is required")
	}

	// DeviceID must be a 32 bit integer.
	returnValue, err := strconv.ParseInt(deviceID, 10, 32)
	if err != nil {
		return 0, fmt.Errorf("invalid device id: %w", err)
	}

	return int32(returnValue), nil
}

func sanitizeWhiskerBody(body whiskerBody) (whiskerBody, error) {

	// BatteryLevel must be between 0 and 100
	if body.Batterylevel < 0 || body.Batterylevel > 100 {
		return body, fmt.Errorf("battery level must be between 0 and 100")
	}

	// Body is returned here in case we want to manipulate the body
	// later as part of the sanitization.
	return body, nil
}
