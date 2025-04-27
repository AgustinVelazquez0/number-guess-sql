#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Pedir nombre de usuario
echo "Enter your username:"
read username

# Verificar si el usuario existe
user_info=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username = '$username'")

if [[ -z $user_info ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  insert_user=$($PSQL "INSERT INTO users (username) VALUES ('$username')")
else
  games_played=$(echo $user_info | cut -d '|' -f 2)
  best_game=$(echo $user_info | cut -d '|' -f 3)
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

secret_number=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
guess=0
tries=0

while [[ $guess -ne $secret_number ]]
do
  read guess
  if ! [[ $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  tries=$((tries + 1))

  if [[ $guess -gt $secret_number ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $guess -lt $secret_number ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $tries tries. The secret number was $secret_number. Nice job!"

# Actualizar el número de juegos jugados
update_games=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$username'")

# Actualizar el mejor juego si es necesario
best_game_now=$($PSQL "SELECT best_game FROM users WHERE username = '$username'")
if [[ -z $best_game_now || $tries -lt $best_game_now ]]
then
  update_best_game=$($PSQL "UPDATE users SET best_game = $tries WHERE username = '$username'")
fi
