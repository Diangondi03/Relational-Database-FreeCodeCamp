#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU(){
  if [[ -n $1 ]]
  then
    echo -e "$1\n"
  fi
  echo Welcome to My Salon, how can I help you?
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo "Selected service ID: $SERVICE_SELECTED"
  
  if [[ -z $SERVICE_SELECTED ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_SELECTED")
    echo "Selected service name: $SERVICE_NAME"
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo "Customer name: $CUSTOMER_NAME"
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      echo "Insert customer result: $INSERT_CUSTOMER_RESULT"
    fi

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")
    echo "Customer ID: $CUSTOMER_ID"
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_SELECTED,'$SERVICE_TIME')")
    echo "Insert appointment result: $INSERT_APPOINTMENT_RESULT"

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
