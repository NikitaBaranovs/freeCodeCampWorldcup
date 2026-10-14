#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


EMPTY_TABLE=$($PSQL "TRUNCATE TABLE games, teams")
# the map of teams
declare -A teams

echo "INSERT INTO teams(team_id, name) VALUES" > team_insert.txt
echo "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES" > game_insert.txt
IFS="," 

while read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do
  if [[ $YEAR != year ]]
  then 
    echo "$WINNER $OPPONENT"
    if [[ -n "${teams["$WINNER"]}" ]]
    then
      WINNER_ID=${teams["$WINNER"]}
    else
      WINNER_ID=$(( ${#teams[@]} + 1))
      teams["$WINNER"]=$WINNER_ID
    fi 

    if [[ -n "${teams["$OPPONENT"]}" ]]
    then
      OPPONENT_ID=${teams["$OPPONENT"]}
    else
      OPPONENT_ID=$(( ${#teams[@]} + 1))
      teams["$OPPONENT"]=$OPPONENT_ID
    fi 

    echo "($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)," >> game_insert.txt
  fi

done < games.csv

echo ${#teams[@]}
for team in ${!teams[@]}
do
  echo "(${teams[$team]}, '$team')," >> team_insert.txt
done
IFS=" "

truncate -s-2 team_insert.txt
echo -e "\n" >> team_insert.txt
INSERT_TEAMS=$($PSQL "$(cat team_insert.txt)")

truncate -s-2 game_insert.txt
echo -e "\n" >> game_insert.txt
INSERT_GAMES=$($PSQL "$(cat game_insert.txt)")

#TODO:
#REMOVE Temporary comand files
