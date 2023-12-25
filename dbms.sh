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

function InsertIntoTable() {
  read -p "Enter table name: " tableName

  if [ -z "$tableName" ]; then
    echo "Table name cannot be empty."
  elif [ -e "$ROOT/$1/$tableName.data" ]; then

    metaFilePath="$ROOT/$1/$tableName.meta"
    columns=$(cut -d':' -f1 "$metaFilePath" | tr '\n' ' ')
    types=$(cut -d':' -f2 "$metaFilePath" | tr '\n' ' ')
    primaryKey=$(awk -F':' '/PRIMARY_KEY/{print $1}' "$metaFilePath")

    echo "Enter values for $columns (separated by spaces): "
    read -a values

    if [ ${#values[@]} -eq "$(wc -l <"$metaFilePath")" ]; then
      valid=true
      for i in "${!values[@]}"; do
        colType=$(echo "$types" | cut -d' ' -f$(($i + 1)))
        if [ "$colType" = "Number" ]; then
          if ! [[ ${values[$i]} =~ ^[0-9]+$ ]]; then
            echo "Expected type: $colType for column $(($i + 1))"
            valid=false
            break
          fi
        elif [ "$colType" = "Bool" ]; then
          if [ "${values[$i]}" != "true" ] && [ "${values[$i]}" != "false" ]; then
            echo "Expected type: $colType for column ${columns[$i]}"
            valid=false
            break
          fi
        fi
      done

      if [ "$valid" = true ]; then
        PrimaryKeyLoc=$(echo "$columns" | tr -s ' ' '\n' | grep -n "^$primaryKey$" | cut -d':' -f1)
        PrimaryKeyValue=${values[$((PrimaryKeyLoc - 1))]}
        if grep -q "^$PrimaryKeyValue " "$ROOT/$1/$tableName.data"; then
          echo "Primary key '$PrimaryKeyValue' already exists."
        else
          echo "${values[*]}" >>"$ROOT/$1/$tableName.data"
          echo "Data inserted successfully."
        fi
      fi
    else
      echo "Incorrect number of values entered. Expected: $(wc -l <"$metaFilePath")"
    fi
  else
    echo "$tableName doesn't exist in the database $1."
  fi
}

function Update() {
  read -p "Enter table name: " tableName

  if [ -z "$tableName" ]; then
    echo "Table name cannot be empty."
  elif [ -e "$ROOT/$1/$tableName.data" ]; then

    metaFilePath="$ROOT/$1/$tableName.meta"
    columns=$(cut -d':' -f1 "$metaFilePath" | tr '\n' ' ')
    types=$(cut -d':' -f2 "$metaFilePath" | tr '\n' ' ')
    primaryKey=$(awk -F':' '/PRIMARY_KEY/{print $1}' "$metaFilePath")

    read -p "Enter the $primaryKey value for the row to update: " primaryKeyValue
    old=$(grep -w "$primaryKeyValue" "$ROOT/$1/$tableName.data")

    if grep -q "^$primaryKeyValue " "$ROOT/$1/$tableName.data"; then
      echo "Enter updated values for $columns (separated by spaces): "
      read -a newValues

      if [ ${#newValues[@]} -eq "$(wc -l <"$metaFilePath")" ]; then
        valid=true
        for i in "${!newValues[@]}"; do
          colType=$(echo "$types" | cut -d' ' -f$(($i + 1)))
          if [ "$colType" = "Number" ]; then
            if ! [[ ${newValues[$i]} =~ ^[0-9]+$ ]]; then
              echo "Expected type: $colType for column $(($i + 1))"
              valid=false
              break
            fi
          elif [ "$colType" = "Bool" ]; then
            if [ "${newValues[$i]}" != "true" ] && [ "${newValues[$i]}" != "false" ]; then
              echo "Expected type: $colType for column ${columns[$i]}"
              valid=false
              break
            fi
          fi
        done

        if [ "$valid" = true ]; then
          PrimaryKeyLoc=$(echo "$columns" | tr -s ' ' '\n' | grep -n "^$primaryKey$" | cut -d':' -f1)
          PrimaryKeyValue2=${newValues[$((PrimaryKeyLoc - 1))]}
          sed -i "/$primaryKeyValue/d" "$ROOT/$1/$tableName.data"

          if grep -q "^$PrimaryKeyValue2 " "$ROOT/$1/$tableName.data"; then
            echo "Primary key '$PrimaryKeyValue2' already exists."
            echo "${old[*]}" >>"$ROOT/$1/$tableName.data"
          else
            echo "${newValues[*]}" >>"$ROOT/$1/$tableName.data"
            echo "Data updated successfully."
          fi
        fi
      else
        echo "Incorrect number of values entered. Expected: $(wc -l <"$metaFilePath")"
      fi
    else
      echo "Primary key '$primaryKeyValue' not found."
    fi
  else
    echo "$tableName doesn't exist in the database $1."
  fi
}

function FillMetaTable() {
  local metaFilePath="$ROOT/$1.meta"
  touch "$metaFilePath"

  echo "Available types: Text, Number, Bool"
  echo "Example input: colName:Text"

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

    echo "Set the primary key (enter colName)."
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

function SelectFromTableByColumn() {

  read -p "Enter column names (separated by spaces): " columnNamesInput

  columnNumbers=$(grep -wnE "$(echo "$columnNamesInput" | tr ' ' '|')" "$ROOT/$1/$tableName.meta" | cut -d':' -f1 | tr '\n' ',' | sed 's/,$//')

  if [ -z "$columnNumbers" ]; then
    echo "Columns not found in the table."
  else
    echo "$columnNamesInput"
    cut -d' ' -f"$columnNumbers" "$ROOT/$1/$tableName.data"
  fi
}
function SelectFromTableByRecord() {

  read -p "Enter $primaryKey value to retrieve the record: " primaryKeyValue

  if [ -z "$primaryKeyValue" ]; then
    echo "Primary key value cannot be empty."
  elif grep -qw "$primaryKeyValue" "$ROOT/$1/$tableName.data"; then
    awk -F':' '{print $1}' "$ROOT/$1/$tableName.meta" | tr '\n' ' '
    echo ""
    grep -w "$primaryKeyValue" "$ROOT/$1/$tableName.data"
  else
    echo "Record with $primaryKey '$primaryKeyValue' not found in $tableName."
  fi

}
function Select() {
  read -p "Enter table name: " tableName

  if [ -z "$tableName" ]; then
    echo "Table name cannot be empty."
  elif [ -e "$ROOT/$1/$tableName.data" ]; then
    OPTIONS=("Display the whole Table" "Select By Column" "Select By PK" "Exit Select Menu")

    select choice in "${OPTIONS[@]}"; do

      case "$REPLY" in
        1)
          echo "Displaying entire table:"
          awk -F':' '{print $1}' "$ROOT/$1/$tableName.meta" | tr '\n' ' '
          echo ""
          cat "$ROOT/$1/$tableName.data"
          echo ""
          ;;
        2)
          SelectFromTableByColumn "$1"
          ;;
        3)
          SelectFromTableByRecord "$1"
          ;;
        4)
          break
          ;;
        *)
          echo "Invalid characters in the name."
          ;;

        esac
      done
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

function DeleteFromTable() {
  read -p "Enter table name: " tableName
  if [ -z "$tableName" ]; then
    echo "Table name cannot be empty."
  elif [ -e "$ROOT/$1/$tableName.data" ]; then
    metaFilePath="$ROOT/$1/$tableName.meta"
    primaryKey=$(awk -F':' '/PRIMARY_KEY/{print $1}' "$metaFilePath")

    read -p "Enter $primaryKey value to delete: " Value

    if grep -qw "$Value" "$ROOT/$1/$tableName.data"; then
      sed -i "/$Value/d" "$ROOT/$1/$tableName.data"
      echo "Data with $primaryKey '$Value' deleted from $tableName."
    else
      echo "Data with $primaryKey '$Value' not found in $tableName."
    fi
  else
    echo "$tableName doesn't exist in the database $1."
  fi
}

function ConnectDB() {
  read -p "Choose database to connect to: " NameDB

  if [[ -z "$NameDB" ]]; then
    echo "Please select database"
  else
    if [ -e "$ROOT/$NameDB" ]; then

      OPTIONS=("Create Table" "List Tables" "Drop Table" "Insert into table" "Select from table" "Delete from table" "Update table" "Exit")

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
            InsertIntoTable "$NameDB"
            ;;
          5)
            Select "$NameDB"
              ;;
            6)
              DeleteFromTable "$NameDB"
              ;;
            7)
              Update "$NameDB"
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
