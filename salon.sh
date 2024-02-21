#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU ()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services order by service_id")
  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    #send to main menu
    MAIN_MENU "Sorry, we don't have any services available right now."
  else
    
    # display available services
    echo -e "\nHere are the services we have available:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  
    # ask for service requested
    echo -e "\nWhich service would you like to choose?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service."
    else
      # get service availability
      SERVICE_AVAILABILITY=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # if not available
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        # send to main menu
        MAIN_MENU "That service is not available."
      else
        # get customer info
        echo -e "\nWhat's your phone number?"   
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name from customers where phone = '$CUSTOMER_PHONE'")
        
        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")        
        fi
        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone = '$CUSTOMER_PHONE'")

        # get requested time
        echo -e "\nWhat time would you like your appointment?"
        read SERVICE_TIME
        if [[ ! $SERVICE_TIME =~ ^[0-9]* ]]
        then
          MAIN_MENU "Time must start with a number."
        fi

        # insert appointment
        INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        # get appointment info
        SERVICE_NAME=$($PSQL "select s1.name from customers as c1 full join appointments as a1 on a1.customer_id = c1.customer_id full join services as s1 on s1.service_id = a1.service_id where a1.service_id = $SERVICE_ID_SELECTED and a1.customer_id = $CUSTOMER_ID and a1.time = '$SERVICE_TIME'")
        # send to main menu
        echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
      fi
    fi
  fi

}



MAIN_MENU
