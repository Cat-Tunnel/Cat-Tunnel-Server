/*
The configuration api is used to store and retrieve all of the information
needed to setup a device. The configuration should fully describe the
desired state of the device.
*/

package api

import (
	"cat-tunnel-server/internal/db"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// deviceConfiguration stores all of the information needed to setup a device
type deviceConfigurationBody struct {
	ConfigurationID   int32    // the unique identifier
	Name              string   // human readable reference (not a unique id)
	Brightness        int32    // 0-100 percent brightness
	ScreenTimeout     int32    // milliseconds
	ApplicationIDs    []int32  // reference the applications api
	NetworkIDs        []int32  // reference the networks api
	DailyFeedingTimes []string // hh:mm:ss UTC
}

// Network tells the device how to connect to each network
type Network struct {
	NetworkID   int    `json:"networkID"`
	Name        string `json:"name"`
	SSID        string `json:"ssid"`
	Password    string `json:"password"`
	AutoConnect bool   `json:"autoConnect"`
}

// Application is the information needed to download an apk
type Application struct {
	ApplicationID int    `json:"applicationID"`
	Name          string `json:"name"`
	APK           string `json:"apk"`
}

// deviceConfiguration is a struct that represents the full set of data including the
// details of the linked data.
type ConfigurationDetails struct {
	ConfigurationID   int           `json:"configurationID"`
	Name              string        `json:"name"`
	Brightness        int           `json:"brightness"`
	ScreenTimeout     int           `json:"screenTimeout"`
	Networks          []Network     `json:"networks"`
	Applications      []Application `json:"applications"`
	DailyFeedingTimes []string      `json:"feedingTimes"`
}

// The data returned from the database is in snake case and it should be returned in
// camel case notation before being returned.
func buildConfigurationReturn(dbReturn db.ConfigurationDetails) ConfigurationDetails {
	var configurationReturn ConfigurationDetails

	configurationReturn.ConfigurationID = dbReturn.ConfigurationID
	configurationReturn.Name = dbReturn.Name
	configurationReturn.Brightness = dbReturn.Brightness
	configurationReturn.Brightness = dbReturn.Brightness
	configurationReturn.ScreenTimeout = dbReturn.ScreenTimeout
	configurationReturn.DailyFeedingTimes = dbReturn.DailyFeedingTimes
	configurationReturn.Networks = make([]Network, 0)
	configurationReturn.Applications = make([]Application, 0)

	for _, network := range dbReturn.Networks {
		newNetwork := Network{
			NetworkID:   network.NetworkID,
			Name:        network.Name,
			SSID:        network.SSID,
			Password:    network.Password,
			AutoConnect: network.AutoConnect,
		}
		configurationReturn.Networks = append(configurationReturn.Networks, newNetwork)
	}

	for _, application := range dbReturn.Applications {
		newApplication := Application{
			ApplicationID: application.ApplicationID,
			Name:          application.Name,
			APK:           application.APK,
		}
		configurationReturn.Applications = append(configurationReturn.Applications, newApplication)
	}

	return configurationReturn
}

// UpdateConfiguration adds the configuration to the database or updates it if
// it already exists.
func UpdateConfiguration(c *gin.Context) {
	var body deviceConfigurationBody

	configurationID, err := sanitizeConfigurationID(c.Param("configurationid"))
	if err != nil {
		// Return early if the request does not submit a valid configuration id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "ConfigurationID is required and must be a valid number."})
		return
	}

	err = c.BindJSON(&body)
	if err != nil {
		// Return early if the request body is not formatted correctly.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The request body was not formatted correctly."})
		return
	}

	body, err = sanitizeConfiguration(body)
	if err != nil {
		// Return early if there is invalid configuration data.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "The configuration is invalid."})
		return
	}

	err = db.CreateConfiguration(
		configurationID,
		body.Name,
		body.Brightness,
		body.ScreenTimeout,
		body.ApplicationIDs,
		body.NetworkIDs,
		body.DailyFeedingTimes,
	)
	if err != nil {
		// Return early if there was any error writing to the database.
		fmt.Println(err)
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error writing to the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}

// DeleteConfiguration permenantly removes a configuration from the database
func DeleteConfiguration(c *gin.Context) {

	configurationID, err := sanitizeConfigurationID(c.Param("configurationid"))
	if err != nil {
		// Return early if the request does not submit a valid configuration id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "ConfigurationID is required and must be a valid number."})
		return
	}

	err = db.DeleteConfiguration(configurationID)
	if err != nil {
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error deleting configuration from the database."})
		return
	}

	c.JSON(http.StatusOK, nil)
}

// GetConfigurations returns all of the data including things like application and network details.
func GetConfiguration(c *gin.Context) {

	configurationID, err := sanitizeConfigurationID(c.Param("configurationid"))
	if err != nil {
		// Return early if the request does not submit a valid configuration id.
		c.JSON(http.StatusBadRequest,
			errorResponse{Message: "ConfigurationID is required and must be a valid number."})
		return
	}

	configurationReturn, err := db.GetConfiguration(configurationID)
	if err != nil {
		fmt.Println(err)
		// Return early if there was any error reading from the database.
		c.JSON(http.StatusInternalServerError,
			errorResponse{Message: "There was an error reading from the database."})
		return
	}

	c.JSON(http.StatusOK, buildConfigurationReturn(configurationReturn))
}
