// This connection is good enough for testing
// TODO: This needs to be more robust in the future

package db

import (
	"database/sql"
	"errors"
	"fmt"

	_ "github.com/lib/pq"
)

// Fill this in with your own data for now
const (
	host     = "localhost"
	port     = 5432
	user     = "postgres"
	password = "postgres"
	dbname   = "postgres"
)

var dbConn *sql.DB

func init() {
	connect()
}

func connect() {

	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
		"password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		fmt.Println(err)
		panic(errors.New("failed to connect to the database"))
	}

	dbConn = db

	err = db.Ping()
	if err != nil {
		fmt.Println(err)
		panic(errors.New("database connection test failed"))
	}
}

func GetDB() *sql.DB {
	return dbConn
}
