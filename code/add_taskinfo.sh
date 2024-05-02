#!/bin/bash

# Loop through all directories matching the pattern
for dir in /ZPOOL/data/projects/SRPAL-DataInBrief/bids/sub-*/func/; do
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
            tsv_file="${dir}${sub_id}_task-${task}_run-${i}_events.tsv"
            filename="${sub_id}_task-${task}_run-${i}_events.json"
            
            # Check if the TSV file exists
            if [ -f "$tsv_file" ]; then
                touch "${dir}${filename}"
                echo "Created ${dir}${filename}"
                
                # Print the JSON content based on the task
                case $task in
                    trust)
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
                        ;;
                    sharedreward)
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
                        ;;
                    doors)
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
        "Units": "s"
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
        "Description": "Group of door selected by participant",
        "Levels": {
            "D": "The image selected was of a door in group D",
            "S": "The image selected was of a door in group S"
        }
    },
    "image_left": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file."
    },
    "image_right": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file."
    }
}
EOF
                        ;;
                    socialdoors)
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
        "Units": "s"
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
        "Description": "Gender of image selected by participant",
        "Levels": {
            "M": "The image selected was of a male",
            "F": "The image selected was of a female"
        }
    },
    "image_left": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file."
    },
    "image_right": {
        "LongName": "Stimulus filename",
        "Description": "Relative path of stimulus image file."
    }
}
EOF
                        ;;
                    ugr)
                        cat <<EOF > "${dir}${filename}"
{
    "trial_type": {
        "LongName": "Trial Type",
        "Description": "Type of trial",
        "Levels": {
            "cue_social": "The participant is playing the current round with a stranger.",
            "cue_social_low": "The participant is playing the current round with a stranger who was endowed 16 dollars.",
            "cue_social_high": "The participant is playing the current round with a stranger who was endowed 32 dollars.",
            "cue_nonsocial": "The participant is playing the current round with the computer.",
            "cue_nonsocial_low": "The participant is playing the current round with the computer who was endowed 16 dollars.",
            "cue_nonsocial_high": "The participant is playing the current round with the computer who was endowed 32 dollars.",
            "dec_accept": "The participant accepted the offer.",
            "dec_reject": "The participant rejected the offer.",
            "dec_choice": "Participant decision during choice phase.",
            "dec_nonsocial_choice": "Participant decision during nonsocial choice phase.",
            "dec_nonsocial_low": "Participant is playing the current round with the computer that was endowed 16 dollars.",
            "dec_nonsocial_high": "Participant is playing the current round with the computer that was endowed 32 dollars.",
            "dec_nonsocial_accept": "Participant accepted the offer while playing with the computer.",
            "dec_nonsocial_accept_low": "Participant accepted the offer during the current round with the computer that was endowed 16 dollars.",
            "dec_nonsocial_accept_high": "Participant accepted the offer during the current round with the computer that was endowed 32 dollars.",
            "dec_nonsocial_reject": "Participant rejected the offer during the current round with the computer.",
            "dec_nonsocial_reject_low": "Participant rejected the offer during the current round with the computer that was endowed 16 dollars.",
            "dec_nonsocial_reject_high": "Participant rejected the offer during the current round with the computer that was endowed 32 dollars.",
            "dec_social_choice": "Participant decision during social choice phase.",
            "dec_social_low": "Participant decision during nonsocial choice phase with the stranger that was endowed 16 dollars.",
            "dec_social_high": "Participant decision during nonsocial choice phase with the stranger that was endowed 32 dollars.",
            "dec_social_accept": "Participant accepted the offer while playing with the stranger.",
            "dec_social_accept_low": "Participant accepted the offer during the current round with the stranger that was endowed 16 dollars.",
            "dec_social_accept_high": "Participant accepted the offer during the current round with the stranger that was endowed 32 dollars.",
            "dec_social_reject": "Participant rejected the offer during the current round with the stranger.",
            "dec_social_reject_low": "Participant rejected the offer during the current round with the stranger that was endowed 16 dollars.",
            "dec_social_reject_high": "Participant rejected the offer during the current round with the stranger that was endowed 32 dollars."
        }
    },
    "Endowment": {
        "LongName": "Endowment",
        "Description": "Funds given to the proposer before making an offer to the participant.",
        "Levels": {
            "16": "The proposer was given 16 dollars.",
            "32": "The proposer was given 32 dollars."
        }
    },
    "Endowment_pmod": {
        "LongName": "Endowment Parametrically Modulated",
        "Description": "Should not be used, endowement parametrically modulated."
    },
    "Decision": {
        "LongName": "Decision",
        "Description": "The dollar amount that the participant accepted from the offer.",
        "Levels": {
            "0": "The participant rejected the offer.",
            "1": "The participant accepted one dollar.",
            "2": "The participant accepted two dollars.",
            "3": "The participant accepted theree dollars.",
            "4": "The participant accepted four dollars.",
            "8": "The participant accepted eight dollars.",
            "16": "The participant accepted sixteen dollars."
        }
    },
    "Decision_pmod": {
        "LongName": "Decision -- Parametrically modulated",
        "Description": "The proportion of fairness of the offer that was accepted."
    },
    "Offer_pmod": {
        "LongName": "Offer -- Parametrically modulated",
        "Description": "The proportion of fairness of the offer that was given."
    }
}
EOF
                        ;;
                esac
            else
                echo "Skipping ${dir}${filename} because ${tsv_file} does not exist"
            fi
        done
    done
done
