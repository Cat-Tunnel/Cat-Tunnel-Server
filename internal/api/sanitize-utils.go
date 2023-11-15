package api

import (
	"fmt"
	"strconv"
)

// sanitizeDeviceID converts a device from a query paramter string to
// a valid deviceID.
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

// sanatizeWhiskerBody makes sure that all of the submitted information about
// a whisker is valid data.
func sanitizeWhiskerBody(body whiskerBody) (whiskerBody, error) {

	// BatteryLevel must be between 0 and 100
	if body.Batterylevel < 0 || body.Batterylevel > 100 {
		return body, fmt.Errorf("battery level must be between 0 and 100")
	}

	// Body is returned here in case we want to manipulate the body
	// later as part of the sanitization.
	return body, nil
}
