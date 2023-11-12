/*
When a device checks into the server on its check in schedule, it records
a set of metrics at a snapshot in time. These "whiskers" signal the record
of the devices and alert admin tools of any potential problems.
*/

package db

import (
	"fmt"
)

// Whisker represents a single snapshot of key metrics sent from the
// device at a given "sync time".
type Whisker struct {
	WhiskerID    int32
	Batterylevel int16
	StorageUsage int32
	Location     string
}

const getWhiskersQuery string = `
	SELECT whiskerid, 
			batterylevel, 
			storageusage, 
			location 
	FROM GetAllWhiskersForDevice($1)
	ORDER BY synctime ASC
`

const createWhiskerQuery string = `
	CALL InsertNewWhisker($1, $2, $3, $4, $5);
`

// GetAllWhiskers retrieves all whisker metrics from a device by device ID.
// It returns an array of all whiskers sorted by ascending time.
func GetAllWhiskers(deviceID int32) ([]Whisker, error) {
	var (
		whiskerID    int32
		batterylevel int16
		storageUsage int32
		location     string
		whiskers     []Whisker
	)

	// Pull down data from the whiskers database.
	rows, err := GetDB().Query(getWhiskersQuery, deviceID)
	if err != nil {
		// Return early if query execution fails for any reason.
		return nil, fmt.Errorf("error reading from database: %w", err)
	}

	defer rows.Close() // Ensure rows are closed after function execution.

	// Loop through each whisker and append to the "whiskers" return variable.
	for rows.Next() {

		err := rows.Scan(&whiskerID, &batterylevel, &storageUsage, &location)
		if err != nil {
			// Return early if the response from the query doesn't match
			// the expected format.
			return nil, fmt.Errorf("database not setup correctly: %w", err)
		}

		newWhisker := Whisker{
			WhiskerID:    whiskerID,
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
func CreateWhisker(deviceID int32) error {

	// Insert the parameters into the whiskers database
	_, err := GetDB().Exec(createWhiskerQuery, deviceID, "2023-11-12 12:05:00", 11, 2048, "Yard")
	if err != nil {
		// Return an error if query execution fails for any reason.
		return fmt.Errorf("error writing to database: %w", err)
	}

	return nil
}
