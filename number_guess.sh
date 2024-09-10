#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get username
echo -e "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT * FROM users WHERE username ILIKE '$USERNAME' ")

# not found
if [[ -z $USER ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # add user to database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else 
  # username exists
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi


# guess
SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=1
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
echo -e "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # if not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
  else
    # Lower
    if (( GUESS < SECRET_NUMBER )); then
      echo "It's higher than that, guess again:"
    # Greater
    elif (( GUESS > SECRET_NUMBER )); then
      echo "It's lower than that, guess again:"
    # Correct
    else
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      # Save input as best_game if lower than best_game
      EXISTING_BEST=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
      if [[ $EXISTING_BEST = 0 ]]; then
        ADD_GUESS_COUNT=$($PSQL "UPDATE users SET best_game = CAST($GUESS_COUNT AS INTEGER) WHERE username = '$USERNAME'")
      elif [[ $EXISTING_BEST > $GUESS_COUNT ]]; then
        ADD_GUESS_COUNT=$($PSQL "UPDATE users SET best_game = CAST($GUESS_COUNT AS INTEGER) WHERE username = '$USERNAME'")
      #else
        #ADD_GUESS_COUNT=$($PSQL "UPDATE users SET best_game = CAST($GUESS_COUNT AS INTEGER) WHERE username = '$USERNAME'")
      fi
      break
    fi
  fi
  # Increment guess count
  (( GUESS_COUNT++ ))
done
# Add game count
(( GAMES_PLAYED++ ))
UPDATE_GAME_COUNT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")