#!/bin/bash
DATA_DIR=~/RMS_data
CONFIG_DIR=$DATA_DIR/config
LOG_DIR=$DATA_DIR/logs
STATIONS_DIRS=$(find $CONFIG_DIR/* -maxdepth 0 -type d)

SLEEP_INTERVAL=15
STATION_COUNT=0
SLEEP_CURRENT=0

if [ ! -d "$CONFIG_DIR" ];
then
    echo "Config dir $CONFIG_DIR not found. Please map the folder $DATA_DIR." 
    exit 1
fi

source ~/vRMS/bin/activate
cd ~/source/RMS

# switch to another branch
if [[ -v GIT_BRANCH ]];
then
    git checkout $GIT_BRANCH
fi

echo Checking for RMS updates...
Scripts/RMS_Update.sh

mkdir -p ~/RMS_data/logs/

# Start a tmux session for each station 
for station in $STATIONS_DIRS; do
    DIR=$station
    STATION_ID=$(basename $station)

    echo Starting RMS session for $STATION_ID in $((SLEEP_CURRENT=SLEEP_INTERVAL*STATION_COUNT)) seconds.
    tmux kill-session -t $STATION_ID 2> /dev/null
    tmux new -s $STATION_ID -d \
        "echo "Waiting..."; sleep $SLEEP_CURRENT; \
        python -m RMS.StartCapture --config $DIR/$STATION_ID.config --data_dir ~/RMS_data/$STATION_ID | \
        tee $LOG_DIR/$STATION_ID.stdout"
    ((STATION_COUNT=STATION_COUNT+1))
done

cd /maestro
echo Starting maestro web service...
sleep 15
tmux new -s www -d "flask run --host=0.0.0.0"

cd
/bin/bash
exit 0
