#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Pedir nombre de usuario
echo "Enter your username:"
read username

# Verificar si el usuario existe
USER_INFO=$($PSQL "SELECT * FROM players WHERE name = '$username'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  # Inicializar el nuevo jugador en la base de datos
  INSERT_PLAYER=$($PSQL "INSERT INTO players (name) VALUES ('$username')")
else
  # Mostrar información del usuario
  GAMES_PLAYED=$(echo $USER_INFO | cut -d '|' -f 2)
  BEST_GAME=$(echo $USER_INFO | cut -d '|' -f 3)
  echo "Welcome back, $username! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
GUESS=0
TRIES=0

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  read GUESS
  TRIES=$((TRIES + 1))

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Actualizar el número de juegos jugados
UPDATE_GAMES=$($PSQL "UPDATE players SET games_played = games_played + 1 WHERE name = '$username'")

# Actualizar el mejor juego si el número de intentos es menor
if [[ $BEST_GAME -eq 0 || $TRIES -lt $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game = $TRIES WHERE name = '$username'")
fi
