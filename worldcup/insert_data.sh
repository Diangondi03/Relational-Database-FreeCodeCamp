#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")

declare -A teams

# Read the CSV file and process each line
while IFS=, read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [ "$year" != "year" ]; then
    # Insert unique winner team
    if [ -z "${teams[$winner]}" ]; then
      ($PSQL "INSERT INTO teams(name) VALUES('$winner');")
      teams[$winner]=1
    fi

    # Insert unique opponent team
    if [ -z "${teams[$opponent]}" ]; then
      ($PSQL "INSERT INTO teams(name) VALUES('$opponent');")
      teams[$opponent]=1
    fi

    # Get winner_id and opponent_id
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

    # Insert game data
    ($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")

    echo "Year: $year"
    echo "Round: $round"
    echo "Winner: $winner"
    echo "Opponent: $opponent"
    echo "Winner Goals: $winner_goals"
    echo "Opponent Goals: $opponent_goals"
    echo "----------------------"
  fi
done < /workspace/project/games.csv

# Do not change code above this line. Use the PSQL variable above to query your database.

# Do not change code above this line. Use the PSQL variable above to query your database.
