#!/bin/bash

# Set the PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get the username from the user
echo -e "Enter your username:"
read USERNAME

# Fetch user details from the database
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username ILIKE '$USERNAME'")

# Check if the user is found
if [[ -z $USER ]]; then
  # New user
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert the new user into the database
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  # Returning user
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME <<<"$USER"
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate the secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=0

echo -e "Guess the secret number between 1 and 1000:"

# Start the guessing loop
while true; do
  read GUESS

  # Check if the guess is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "That is not an integer, guess again:"
  else
    ((GUESS_COUNT++))

    # Compare the guess with the secret number
    if ((GUESS < SECRET_NUMBER)); then
      echo "It's higher than that, guess again:"
    elif ((GUESS > SECRET_NUMBER)); then
      echo "It's lower than that, guess again:"
    else
      # Correct guess
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      
      # Update the user's game statistics
      if [[ -z $USER ]]; then
        GAMES_PLAYED=1
        BEST_GAME=$GUESS_COUNT
      else
        ((GAMES_PLAYED++))
        if [[ -z $BEST_GAME || $GUESS_COUNT -lt $BEST_GAME ]]; then
          BEST_GAME=$GUESS_COUNT
        fi
      fi

      # Update the database with new stats
      UPDATE_STATS=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
      
      break
    fi
  fi
done
