# Bash Database Management Script

This Bash script provides a simple command-line interface for managing databases and tables. It allows users to create, list, delete databases, create tables, and perform various operations on tables within databases.

## Table of Contents

- [Usage](#usage)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [How to Run](#how-to-run)
- [Example](#example)

## Usage

This script provides a menu-driven interface that allows users to perform the following actions:

1. Create a new database.
2. List existing databases.
3. Connect to a specific database and perform operations on tables.
4. Delete a database.

## Features

- Database creation and deletion.
- Table creation, deletion, and manipulation.
- User-friendly menu-driven interface.
- Input validation for data integrity.

## Prerequisites

- Bash (Bourne Again SHell) should be installed on your system.

## How to Run

1. Clone the repository:

   ```bash
   git clone https://github.com/MahmoudDabbous/bashdb
   cd bashdb


2. Run the script:

    ./dbms.sh


3. Follow the on-screen instructions to navigate through the menu and perform actions.



## Example

### Creating a Database, Connecting, Creating, and inserting into a table

#### Step 1: Creating a Database

```bash
./dbms.sh

1. Create DB
2. List DB
3. Connect to specific DB
4. Delete DB
5. Exit

Enter your choice: 1

Name of the database: mydatabase

```


#### Step 2: Connecting to the Database and Creating a Table

```bash
Enter your choice: 3

Choose database to connect to: mydatabase

1. Create Table
2. List Tables
3. Drop Table
4. Insert into table
5. Select from table
6. Delete from table
7. Update table
8. Exit

Enter your choice: 1

Name of the table: mytable

Enter columns names and types (one line per column)

> id:Number
> name:Text

type "exit" when you finish entering columns
> exit

Set the primary key (enter colName)
> id
Primary key set to id

mytable created successfully.


```



#### Step 3: Inserting data into a table

```bash
Enter your choice: 4

Enter table name: mytable

Enter values for id name  (separated by spaces): 

1 Mahmoud

Data inserted successfully.


```
