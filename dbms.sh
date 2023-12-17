#!/bin/bash
PS3="Enter your choice: "
OPTIONS=("Create DB" "List DB" "Connect to specific DB" "Delete DB" "Exit")
ROOT="./databases"

mkdir -p "$ROOT"

function CreateDB() {
    read -p "Name of the database: " NameDB
    if [ -e "$ROOT/$NameDB" ]; then
        echo "$NameDB already exists in the database directory."
    # elif [ "$NameDB" -eq "" ]; then
    #     echo "Name can't be empty."
    else
        mkdir -p "$ROOT/$NameDB"
        echo "$NameDB created successfully."
    fi
}

function ListDB() {
    if [ -z "$(ls $ROOT)" ]; then
        echo "No DB was found"
    else
        ls "$ROOT"
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


function ConnectDB() {

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
            break 2
            ;;
        *)
            echo "Invalid command"
            ;;
        esac
    done

}

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

