#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Pedir nombre de usuario
echo "Enter your username:"
read username

# Verificar si el usuario existe
user_info=$($PSQL "SELECT * FROM players WHERE name = '$username'")

if [[ -z $user_info ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  # Inicializar el nuevo jugador en la base de datos
  insert_player=$($PSQL "INSERT INTO players (name) VALUES ('$username')")
else
  # Mostrar información del usuario
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
  tries=$((tries + 1))

  if ! [[ $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $guess -gt $secret_number ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $guess -lt $secret_number ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $tries tries. The secret number was $secret_number. Nice job!"

# Actualizar el número de juegos jugados
update_games=$($PSQL "UPDATE players SET games_played = games_played + 1 WHERE name = '$username'")

# Actualizar el mejor juego si el número de intentos es menor
if [[ $best_game -eq 0 || $tries -lt $best_game ]]
then
  update_best_game=$($PSQL "UPDATE players SET best_game = $tries WHERE name = '$username'")
fi
