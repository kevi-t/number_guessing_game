#!/bin/bash

# Define PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if username exists in the database
USER_STATS=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_STATS ]]; then
  # If user does not exist
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert the new user into the database
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, NULL)"
else
  # If user exists, extract the stats
  GAMES_PLAYED=$(echo $USER_STATS | cut -d'|' -f1)
  BEST_GAME=$(echo $USER_STATS | cut -d'|' -f2)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Initialize guess count
GUESSES=0

# Start guessing loop
while true; do
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  # Check if the guess is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment guess count
  GUESSES=$((GUESSES + 1))

  # Compare guess with secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    # Correct guess
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update user stats in the database
$PSQL "UPDATE users SET games_played = games_played + 1, best_game = COALESCE(LEAST(best_game, $GUESSES), $GUESSES) WHERE username='$USERNAME'"

