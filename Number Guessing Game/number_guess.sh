#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing -t -c"

# generate actual number
ACTUAL_NUM=$(( RANDOM % 1000 + 1 ))
# set number guesses
NUMBER_OF_GUESSES=0

MAIN_FN(){

  if [[ $1 ]]
  then
    echo $1
  fi
  # print asking username
  echo "Enter your username:"
  read USERNAME

  if [[ -z $USERNAME ]]
  then
    MAIN_FN "You have to enter an username"
  fi

  # get user id in db
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'");

  # check username in db
  if [[ -z $USER_ID ]]
  then
    # print welcome msg for 1st time user
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # insert new data in db
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # get user id in db
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'");
    GAMES_PLAYED=0
    BEST_GAME=0
  else
    USERNAME_DB=$($PSQL "SELECT username FROM users WHERE user_id = $USER_ID" | sed 's/ //g' );
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID" | sed 's/ //g' );
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID" | sed 's/ //g' );
    
    echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  # run main function
  GAME_FUNCTION
}

GAME_FUNCTION(){
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  # get guess number from input
  if [[ $1 ]]
  then
    echo "$1"
  else
    echo "Guess the secret number between 1 and 1000:"
  fi
  read GUESS_NUM
  
  # check if input is not number
  if [[ ! $GUESS_NUM =~ ^[0-9]+$ ]]
  then
    GAME_FUNCTION "That is not an integer, guess again:"
  else
    # the input is number, check if the numbers is same
    if [[ $ACTUAL_NUM = $GUESS_NUM ]]
    then
      # print message
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $ACTUAL_NUM. Nice job!"

      # add best_game if it is not 0 and few than prev best_game
      PREV_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")

      GAMES_PLAYED=$((GAMES_PLAYED+1))
      if [[ $PREV_BEST_GAME -eq 0 || $NUMBER_OF_GUESSES -lt $PREV_BEST_GAME ]]
      then
        UPDATE_RESULTS=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES, games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
      else
        UPDATE_RESULTS=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")

      fi
    else
      # check if lower or higher
      if [[ $GUESS_NUM -gt $ACTUAL_NUM ]]
      then
        GAME_FUNCTION "It's lower than that, guess again:"
      elif [[ $GUESS_NUM -lt $ACTUAL_NUM ]]
      then
        GAME_FUNCTION "It's higher than that, guess again:"
      fi
    fi
  fi
}

MAIN_FN