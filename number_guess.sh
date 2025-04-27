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
