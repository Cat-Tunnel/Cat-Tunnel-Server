package db

import (
	"encoding/json"
	"fmt"

	"github.com/lib/pq"
)

const deleteConfigurationQuery string = `
	CALL delete_configuration($1);
`

const updateConfigurationQuery string = `
	CALL update_device_configuration($1, $2, $3, $4, $5, $6, $7);
`

const getConfigurationQuery string = `
	SELECT * FROM get_full_configuration($1);
`

// Network tells the device how to connect to each network
type Network struct {
	NetworkID   int    `json:"network_id"`
	Name        string `json:"name"`
	SSID        string `json:"ssid"`
	Password    string `json:"password"`
	AutoConnect bool   `json:"auto_connect"`
}

// Application is the information needed to download an apk
type Application struct {
	ApplicationID int    `json:"application_id"`
	Name          string `json:"name"`
	APK           string `json:"apk"`
}

// ConfigurationDetails includes the full device setup structure
type ConfigurationDetails struct {
	ConfigurationID   int           `json:"configuration_id"`
	Name              string        `json:"configuration_name"`
	Brightness        int           `json:"brightness"`
	ScreenTimeout     int           `json:"screen_timeout"`
	Networks          []Network     `json:"networks"`
	Applications      []Application `json:"applications"`
	DailyFeedingTimes []string      `json:"feeding_times"`
}

func CreateConfiguration(
	configurationID int32,
	name string,
	brightness int32,
	screenTimeout int32,
	applicationIDs []int32,
	networkIDs []int32,
	dailyFeedingTimes []string,

) error {

	// Store the configuration in the database
	_, err := GetDB().Exec(
		updateConfigurationQuery,
		configurationID,
		name,
		brightness,
		screenTimeout,
		pq.Array(applicationIDs),
		pq.Array(networkIDs),
		pq.Array(dailyFeedingTimes),
	)
	if err != nil {
		// Handle errors, such as no rows in the result set or any other issues.
		return fmt.Errorf("error executing query: %w", err)
	}

	// Return the deviceID
	return nil
}

// DeleteConfiguration removes a configuration with a specific ID.
func DeleteConfiguration(configurationID int32) error {

	// Remove the specified configuration
	_, err := GetDB().Exec(
		deleteConfigurationQuery,
		configurationID,
	)

	if err != nil {
		fmt.Println(err)
		// Return an error if query execution fails for any reason.
		return fmt.Errorf("error executing query: %w", err)
	}

	return nil
}

// GetConfiguration returns everything a device needs to know to set itself up
func GetConfiguration(configurationID int32) (ConfigurationDetails, error) {
	var configurationDetailsReturn ConfigurationDetails

	// These variables are used when parsing out the json from the database.
	// JSON returns are used so that we can avoid making multiple queries.
	var (
		networksJSON          []byte
		applicationsJSON      []byte
		dailyFeedingTimesJSON []byte
	)

	// Download the configuration
	row := GetDB().QueryRow(getConfigurationQuery, configurationID)

	err := row.Scan(
		&configurationDetailsReturn.ConfigurationID,
		&configurationDetailsReturn.Name,
		&configurationDetailsReturn.Brightness,
		&configurationDetailsReturn.ScreenTimeout,
		&networksJSON,
		&applicationsJSON,
		&dailyFeedingTimesJSON,
	)
	if err != nil {
		// Return early if query execution fails for any reason.
		return configurationDetailsReturn, fmt.Errorf("database not setup correctly: %w", err)
	}

	err = json.Unmarshal(networksJSON, &configurationDetailsReturn.Networks)
	if err != nil {
		// Return early if networks are not formatted correctly
		return configurationDetailsReturn, fmt.Errorf("network return not setup correctly: %w", err)
	}

	err = json.Unmarshal(applicationsJSON, &configurationDetailsReturn.Applications)
	if err != nil {
		// Return early if networks are not formatted correctly
		return configurationDetailsReturn, fmt.Errorf("network return not setup correctly: %w", err)
	}

	err = json.Unmarshal(dailyFeedingTimesJSON, &configurationDetailsReturn.DailyFeedingTimes)
	if err != nil {
		// Return early if networks are not formatted correctly
		return configurationDetailsReturn, fmt.Errorf("network return not setup correctly: %w", err)
	}

	return configurationDetailsReturn, nil
}
