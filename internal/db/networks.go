/*
The networks database stores all of the conneciton info for any network
that a device can potentially be assigned.
*/

package db

import "fmt"

const updateNetworkQuery string = `
	CALL upsert_network($1, $2, $3, $4, $5);
`

const deleteNetworkQuery string = `
	CALL delete_network($1);
`

const getNetworksQuery string = `
	SELECT * FROM get_all_networks();
`

// UpdateNetwork sets up a network to be available to apply to device configuration.
func UpdateNetwork(id int32, name string, ssid string, password string, autoConnect bool) error {

	// Execute the query and capture the return value.
	_, err := GetDB().Exec(insertDeviceQuery, id, name, ssid, password, autoConnect)
	if err != nil {
		// Handle errors, such as no rows in the result set or any other issues.
		return fmt.Errorf("error executing query: %w", err)
	}

	// Return the deviceID
	return nil
}

// DeleteNetwork removes the network from all associated configurations. If the network is
// added again it will need to be reassigned.
func DeleteNetwork(id int32) error {

	// Execute the query and capture the return value.
	_, err := GetDB().Exec(deleteDeviceQuery, id)
	if err != nil {
		// Handle errors, such as no rows in the result set or any other issues.
		return fmt.Errorf("error executing query: %w", err)
	}

	// Return the deviceID
	return nil
}

func GetNetworks() ([]Network, error) {

	// Networks must be an empty array if no values are found
	networks := make([]Network, 0)

	// This will download all networks
	rows, err := GetDB().Query(getNetworksQuery)
	if err != nil {
		// Return early if query execution fails for any reason.
		return nil, fmt.Errorf("error reading from database: %w", err)
	}

	defer rows.Close() // Ensure rows are closed after function execution.

	// Loop through each network and append to the networks variable.
	for rows.Next() {

		var newNetwork Network

		err := rows.Scan(
			&newNetwork.NetworkID,
			&newNetwork.Name,
			&newNetwork.SSID,
			&newNetwork.Password,
			&newNetwork.AutoConnect,
		)
		if err != nil {
			// Return early if the response from the query doesn't match
			// the expected format.
			return nil, fmt.Errorf("database not setup correctly: %w", err)
		}

		// Hide the password from the response
		newNetwork.Password = ""

		networks = append(networks, newNetwork)
	}

	err = rows.Err()
	if err != nil {
		// Return early with an error if the connection breaks before all of the
		// data has been read into the return array.
		return nil, fmt.Errorf("connection lost early: %w", err)
	}

	// Return an array of networks
	return networks, nil
}
