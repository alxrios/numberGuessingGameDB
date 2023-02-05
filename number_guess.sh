#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

PLAY(){
  SECRET_NUM=$((1 + $RANDOM % 1000))
  #echo "SECRET_NUM is $SECRET_NUM"
  FINDED="false"
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESS_ACCOUNT=1
  while [[ $FINDED =~ "false" ]]
  do
    if [[ $GUESS =~ ^[0-9]+$ ]] # input OK is a number
    then
      if [[ $GUESS -lt $SECRET_NUM ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS
        GUESS_ACCOUNT=$(($GUESS_ACCOUNT+1))
      else
        if [[ $GUESS -gt $SECRET_NUM ]]
        then
          echo "It's lower than that, guess again:"
          read GUESS
          GUESS_ACCOUNT=$(($GUESS_ACCOUNT+1))
        else
          FINDED="true"
          # There goes update etc
          GAMES_PLAYED=$(($GAMES_PLAYED+1))
          UPDATE_GAMESN=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$NAME'")
          if [[ $GAMES_PLAYED -gt 1 ]]
          then
            BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
            if [[ $BEST_GAME -gt $GUESS_ACCOUNT ]]
            then
              UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESS_ACCOUNT WHERE username='$NAME'")
            fi
          else
            INSERT_FIRST_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GUESS_ACCOUNT WHERE username='$NAME'")
          fi
          echo "You guessed it in $GUESS_ACCOUNT tries. The secret number was $SECRET_NUM. Nice job!"
        fi
      fi
    else
      echo "That is not an integer, guess again:"
      read GUESS
    fi 
  done
}


echo "Enter your username:"
read NAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
if [[ -z $GAMES_PLAYED ]]
then
  INSERT_NEW_USERNAME=$($PSQL "INSERT INTO users(username, games_played) VALUES('$NAME', 0)")
  echo "Welcome, $NAME! It looks like this is your first time here."
  PLAY
else
  GAMES_PLAYED_F=$(echo $GAMES_PLAYED | sed -r 's/^\t*| *$//g')
  BEST_GAME2=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
  BEST_GAME2_F=$(echo $BEST_GAME2 | sed -r 's/^\t*| *$//g')
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED_F games, and your best game took $BEST_GAME2_F guesses."
  PLAY
fi