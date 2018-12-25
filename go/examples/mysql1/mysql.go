package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	fmt.Println("Go MySQL Totorial")

	// Need to start mysqld and create database test and table pet
	// 1. qfs_meta ( make test-start to lauch sql)
	// 2. follow mysql reference/tutorial to create database and table
	// 3. source /home/jim/go/src/github.com/jimhuaang/mysql/user_db.sql to create tables
	db, err := sql.Open("mysql", "yunify:zhu88jie@tcp(127.0.0.1:3706)/test")

	if err != nil {
		fmt.Println(err)
		log.Fatal(err)
	}

	err = db.Ping()
	if err != nil {
		fmt.Println(err)
		log.Fatal(err)
	}

	var (
		name  string
		owner string
	)

	// Fetching data
	rows, err := db.Query("select name, owner from pet where name like '%w%'")

	if err != nil {
		log.Fatal(err)
	}

	defer rows.Close()

	for rows.Next() {
		err := rows.Scan(&name, &owner)

		if err != nil {
			log.Fatal(err)
		}

		log.Println(name, owner)
	}

	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}

	stmt, err := db.Prepare("insert userinfo set username=?, departname=?, created=?")
	checkErr(err)

	res, err := stmt.Exec("jim", "storage", "2017-04-30")
	checkErr(err)
	id, err := res.LastInsertId()
	checkErr(err)

	fmt.Println(id)

	res, err = stmt.Exec("jim1", "storage1", "2018-08-08")
	checkErr(err)

	id1, err := res.LastInsertId()
	fmt.Println(id1)
	checkErr(err)

	stmt, err = db.Prepare("update userinfo set username=? where uid=?")
	checkErr(err)

	res, err = stmt.Exec("jimupdate", id)
	checkErr(err)

	affect, err := res.RowsAffected()
	checkErr(err)

	fmt.Println(affect)

	rows, err = db.Query("select * from userinfo")
	checkErr(err)

	for rows.Next() {
		var uid int
		var username, departname, created string
		err = rows.Scan(&uid, &username, &departname, &created)
		checkErr(err)

		fmt.Println(uid, " ", username, " ", departname, " ", created)
	}

	stmt, err = db.Prepare("delete from userinfo where uid=?")
	checkErr(err)

	res, err = stmt.Exec(id)
	checkErr(err)

	affect, err = res.RowsAffected()
	checkErr(err)
	fmt.Println(affect)

	res, err = stmt.Exec(id1)
	checkErr(err)

	affect, err = res.RowsAffected()
	checkErr(err)
	fmt.Println(affect)

	defer db.Close()
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}
