#!/bin/bash

# Loop through all directories matching the pattern
for dir in /ZPOOL/data/projects/rf1-datapaper-dev/bids/sub-*/func/; do
    # Extract the subject ID from the directory path
    sub_id=$(basename $(dirname "$dir"))
    
    # Create the events JSON file for each task and run
    for task in trust socialdoors doors ugr sharedreward; do
        nruns=2 # Default number of runs
        
        # Adjust the number of runs based on the task
        if [[ "$task" == "socialdoors" || "$task" == "doors" ]]; then
            nruns=1
        fi
        
        # Create the events JSON file for each run of the current task
        for ((i = 1; i <= $nruns; i++)); do
            filename="${sub_id}_task-${task}_run-${i}_events.json"
            touch "${dir}${filename}"
            echo "Created ${dir}${filename}"
            
            # If the task is "trust", print the specified information into the file
            if [[ "$task" == "trust" ]]; then
                cat <<EOF > "${dir}${filename}"
{
    "trust_value": {
        "LongName": "Trust Value", 
        "Description": "The amount that the participant decided to invest in the partner.",
        "Levels": {
            "0": "The participant invested \$0.00",
            "2": "The participant invested \$2.00",
            "4": "The participant invested \$4.00",
            "8": "The participant invested \$8.00"
        }
    },
    "choice": {
        "LongName": "Choice", 
        "Description": "Denotes whether the participant chose to invest the higher or lower value. Choosing to invest \$8 rather than \$2 would result in a response of 'high'.",
        "Levels": {
            "high": "The participant invested the greater amount",
            "low": "The participant invested the lesser amount"
            }
    },
    "cLow": {
        "LongName": "Choice Low", 
        "Description": "The lowest amount the participant is able to invest in the partner for a given trial.",
        "Levels": {
            "0": "The participant invested \$0.00",
            "2": "The participant invested \$2.00",
            "4": "The participant invested \$4.00"
                }
    },
    "cHigh": {
        "LongName": "Choice High", 
        "Description": "The highest amount the participant is able to invest in the partner for a given trial.",
        "Levels": {
            "2": "The participant invested \$2.00",
            "4": "The participant invested \$4.00",
            "8": "The participant invested \$8.00"
        }
    }
}
EOF
            fi

            # If the task is "sharedreward", print the specified information into the file
            if [[ "$task" == "sharedreward" ]]; then
                cat <<EOF > "${dir}${filename}"
{
    "trial_type": {
        "LongName": "Trial Type",
        "Description": "Type of trial",
        "Levels": {
            "stranger_face": "The participant is shown that they will be playing with the stranger.",
            "event_stranger_neutral": "The participant experienced a neutral outcome during the outcome phase with the stranger.",
            "event_stranger_reward": "The participant experienced a reward outcome during the outcome phase with the stranger.",
            "event_stranger_punish": "The participant experienced a punishment outcome during the outcome phase with the stranger.",
            "computer_non-faceclea": "The participant is shown that they will be playing with the computer.",
            "event_computer_neutral": "The participant experienced a neutral outcome during the outcome phase with the computer.",
            "event_computer_reward": "The participant experienced a neutral outcome during the outcome phase with the computer.",
            "event_compter_punish": "The participant experienced a neutral outcome during the outcome phase with the computer.",
            "friend_face": "The participant is shown that they will be playing with the friend.",
            "event_friend_neutral": "The participant experienced a neutral outcome during the outcome phase with the friend.",
            "event_friend_reward": "The participant experienced a neutral outcome during the outcome phase with the friend.",
            "event_friend_punish": "The participant experienced a neutral outcome during the outcome phase with the friend."
        }
    }
}
EOF
            fi

            # If the task is "doors", print the specified information into the file
            if [[ "$task" == "doors" ]]; then
                cat <<EOF > "${dir}${filename}"
{
    "trial_type": {
        "LongName": "Trial Type",
        "Description": "Type of trial",
        "Levels": {
            "decision": "Row signifying the decision phase.",
            "win": "Row signifying the win, occurs after decision phase if participant guessed correctly.",
            "loss": "Row signifying loss, occurs after decision phase if participant guessed incorrectly."
        }
    },
    "rt": {
        "LongName": "Response time after stimulus",
        "Description": "Response time measured in seconds",
        "Units": "s",
        "HED": "Duration/# s"
    },
    "resp": {
        "LongName": "Response",
        "Description": "Orientation of the image that the participant selected.",
        "Levels": {
            "left": "The participant chose the left image.",
            "right": "The participant chose the right image.",
            "n/a": "Occurs during outcome phase."
        }
    },
    "gender": {
        "LongName": "gender",
        "Description": "Image group of door selected",
        "Levels": {
            "D": "The door selected belonged to group D",
            "S": "The door selected belonged to group S"
        }
    },
    "image_left": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file.",
        "HED": "stimuli/Scan-Social_Doors/pictureFolder/doorsLabelled1/#"
    },
    "image_right": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file.",
        "HED": "stimuli/Scan-Social_Doors/pictureFolder/doorsLabelled1/#"
    }
}
EOF
            fi
        done
    done
done
