/*
When a device checks into the server on its check in schedule, it records
a set of metrics at a snapshot in time. These "whiskers" signal the record
of the devices and alert admin tools of any potential problems.
*/

package db

import (
	"fmt"
	"time"
)

// Whisker represents a single snapshot of key metrics sent from the
// device at a given "sync time".
type Whisker struct {
	WhiskerID    int32
	SyncTime     string
	Batterylevel int16
	StorageUsage int32
	Location     string
}

const getWhiskersQuery string = `
	SELECT whisker_id, 
			sync_time,
			battery_level, 
			storage_usage, 
			location 
	FROM get_all_whiskers_for_device($1)
	ORDER BY sync_time ASC
`

const createWhiskerQuery string = `
	CALL insert_new_whisker($1, $2, $3, $4, $5);
`

// GetAllWhiskers retrieves all whisker metrics from a device by device ID.
// It returns an array of all whiskers sorted by ascending time.
func GetAllWhiskers(deviceID int32) ([]Whisker, error) {
	var (
		whiskerID    int32
		syncTime     string
		batterylevel int16
		storageUsage int32
		location     string
	)

	// Whiskers must be an empty array if no values are found
	whiskers := make([]Whisker, 0)

	// Pull down data from the whiskers database.
	rows, err := GetDB().Query(getWhiskersQuery, deviceID)
	if err != nil {
		// Return early if query execution fails for any reason.
		return nil, fmt.Errorf("error reading from database: %w", err)
	}

	defer rows.Close() // Ensure rows are closed after function execution.

	// Loop through each whisker and append to the "whiskers" return variable.
	for rows.Next() {

		err := rows.Scan(&whiskerID, &syncTime, &batterylevel, &storageUsage, &location)
		if err != nil {
			// Return early if the response from the query doesn't match
			// the expected format.
			return nil, fmt.Errorf("database not setup correctly: %w", err)
		}

		newWhisker := Whisker{
			WhiskerID:    whiskerID,
			SyncTime:     syncTime,
			Batterylevel: batterylevel,
			StorageUsage: storageUsage,
			Location:     location,
		}
		whiskers = append(whiskers, newWhisker)
	}

	err = rows.Err()
	if err != nil {
		// Return early with an error if the connection breaks before all of the
		// data has been read into the return array.
		return nil, fmt.Errorf("connection lost early: %w", err)
	}

	// Return an array of whiskers.
	return whiskers, nil
}

// CreateWhisker creates a new whisker
func CreateWhisker(deviceID int32, batteryLevel int16, storageUsed int32, location string) error {

	// Sync time is the time that the whisker was recieved
	syncTime := time.Now().UTC().Format(time.RFC3339)

	// Insert the parameters into the whiskers database
	_, err := GetDB().Exec(
		createWhiskerQuery,
		deviceID,
		syncTime,
		batteryLevel,
		storageUsed,
		location)

	if err != nil {
		fmt.Println(err)
		// Return an error if query execution fails for any reason.
		return fmt.Errorf("error writing to database: %w", err)
	}

	return nil
}
