#!/bin/bash
PS3="Enter your choice: "
ROOT="./databases"

mkdir -p "$ROOT"

function CreateDB() {
    read -p "Name of the database: " NameDB

    if [ -z "$NameDB" ]; then
        echo "Name can't be empty."
    else
        if [[ "$NameDB" =~ ^[a-zA-Z0-9_]+$ ]]; then
            if [ -e "$ROOT/$NameDB" ]; then
                echo "$NameDB already exists in the database directory."
            else
                mkdir -p "$ROOT/$NameDB"
                echo "$NameDB created successfully."
            fi
        else
            echo "Invalid characters in the name. Only alphanumeric characters and underscores are allowed."
        fi
    fi
}

function ListDB() {
    if [ -z "$(ls $ROOT)" ]; then
        echo "No DB was found"
    else
        ls "$ROOT"
    fi
}

function ListTables() {
    if [ -z "$(find "$ROOT/$1" -name '*.data')" ]; then
        echo "No tables were found"
    else
        ls "$ROOT/$1" | grep '\.data$' | sed 's/\.data$//'
    fi
}

function DeleteDB() {
    read -p "Name of the database: " NameDB

    if [ -z "$NameDB" ]; then
        echo "Name can't be empty."
    elif [ -e "$ROOT/$NameDB" ]; then
        rm -rf "$ROOT/$NameDB"
        echo "$NameDB Deleted Successfully"
    else
        echo "$NameDB Doesn't exist."
    fi
}

function DropTable() {
    read -p "Name of the Table: " table

    if [ -z "$table" ]; then
        echo "Name can't be empty."
    elif [ -e "$ROOT/$1/$table.data" ]; then
        rm "$ROOT/$1/$table".*
        echo "$table Dropped Successfully"
    else
        echo "$table Doesn't exist."
    fi
}

function FillMetaTable() {
    local metaFilePath="$ROOT/$1.meta"
    touch "$metaFilePath"

    echo "Enter columns name and type (e.g., column_name:type), type 'exit' when you're done:"
    echo "Available types: Text, Number, Bool"
    echo "Example input: columnName:Text"

    while true; do
        read -p "> " input

        if [ "$input" == "exit" ]; then
            break
        fi

        colName=$(echo "$input" | cut -d':' -f1)
        colType=$(echo "$input" | cut -d':' -f2)

        case "$colType" in
        "Text" | "Number" | "Bool")
            echo "$colName:$colType" >>"$metaFilePath"
            ;;
        *)
            echo "Invalid type: $colType"
            ;;
        esac
    done

    while true; do

        echo "Set the primary key (enter column name)."
        read -p "> " primaryKey

        if grep -q "^$primaryKey:" "$metaFilePath"; then
            colType=$(grep "^$primaryKey:" "$metaFilePath" | cut -d':' -f2)
            sed -i "s/^$primaryKey:.*/$primaryKey:$colType:PRIMARY_KEY/" "$metaFilePath"
            echo "Primary key set to $primaryKey"
            break
        else
            echo "Column '$primaryKey' does not exist."
        fi
    done
}
function SelectFromTable() {
    read -p "Enter table name: " tableName

    if [ -z "$tableName" ]; then
        echo "Table name cannot be empty."
    elif [ -e "$ROOT/$1/$tableName.data" ]; then
        read -p "Enter column names (separated by spaces): " columnNamesInput

        if [ -z "$columnNamesInput" ]; then
            echo "No columns specified. Displaying all contents of $tableName:"
            cat "$ROOT/$1/$tableName.data"
            echo ""
        else
            columnNumbers=$(grep -wnE "$(echo "$columnNamesInput" | tr ' ' '|')" "$ROOT/$1/$tableName.meta" | cut -d':' -f1 | tr '\n' ',' | sed 's/,$//')

            if [ -z "$columnNumbers" ]; then
                echo "Columns not found in the table."
            else
                cut -d' ' -f"$columnNumbers" "$ROOT/$1/$tableName.data"
            fi
        fi
    else
        echo "$tableName doesn't exist in the database $1."
    fi
}

function CreateTable() {

    read -p "Name of the table: " NameTBL

    if [ -z "$NameTBL" ]; then
        echo "Name can't be empty."
    else
        if [[ "$NameTBL" =~ ^[a-zA-Z0-9_]+$ ]]; then
            if [ -e "$ROOT/$1/$NameTBL" ]; then
                echo "$NameTBL already exists in the Table."
            else
                touch "$ROOT/$1/$NameTBL.data"
                FillMetaTable "$1/$NameTBL"
                echo "$NameTBL created successfully."
            fi
        else
            echo "Invalid characters in the name."
        fi
    fi
}

function ConnectDB() {
    read -p "Choose database to connect to: " NameDB

    if [[ -z "$NameDB" ]]; then
        echo "Please select database"
    else
        if [ -e "$ROOT/$NameDB" ]; then

            OPTIONS=("Create Table" "List Tables" "Drop Table" "Insert" "Select" "Delete" "Update" "Exit")

            select choice in "${OPTIONS[@]}"; do

                case "$REPLY" in
                1)
                    CreateTable "$NameDB"
                    ;;
                2)
                    ListTables "$NameDB"
                    ;;
                3)
                    DropTable "$NameDB"
                    ;;
                4)
                    # TODO: insert tables
                    ;;
                5)
                    SelectFromTable "$NameDB"
                    ;;
                6)
                    # TODO: delete from table
                    ;;
                7)
                    # TODO: Update table
                    ;;
                8)
                    echo "Exiting..."
                    break 2
                    ;;
                *)
                    echo "Invalid command"
                    ;;
                esac
            done
        else
            echo "DB does not exist"
        fi
    fi
}

## Entry Point --------------------------------
OPTIONS=("Create DB" "List DB" "Connect to specific DB" "Delete DB" "Exit")

select choice in "${OPTIONS[@]}"; do

    case "$REPLY" in
    1)
        CreateDB
        ;;
    2)
        ListDB
        ;;
    3)
        ConnectDB
        ;;
    4)
        DeleteDB
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid command"
        ;;
    esac
done
