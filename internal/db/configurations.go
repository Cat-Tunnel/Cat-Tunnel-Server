package db

import (
	"fmt"

	"github.com/lib/pq"
)

const deleteConfigurationQuery string = `
	CALL delete_configuration($1);
`

const updateConfigurationQuery string = `
	CALL update_device_configuration($1, $2, $3, $4, $5, $6, $7);
`

func CreateConfiguration(
	configurationID int32,
	name string,
	brightness int32,
	screenTimeout int32,
	applicationIDs []int32,
	networkIDs []int32,
	feedingTimes []string,

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
		pq.Array(feedingTimes),
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
