#!/bin/bash

# Ensure that the script exits if any command fails
set -e

# Define color codes
BLUE='\033[34m'
NC='\033[0m' # No Color

# Function to display usage information
usage() {
    echo -e "${BLUE}Usage: $0 {run|check|logs} [-a] [-c] [-p] [-b <branch_name>] [-out]"
    echo "  run    Perform Git operations: add, commit, and/or push"
    echo "  check  Display the status of the repository"
    echo "  logs   Display commit logs; use -out to save to vcs.log"
    echo "  -a     Add all changes"
    echo "  -c     Commit changes"
    echo "  -p     Push changes"
    echo "  -b     Specify branch name (if not provided, the current active branch will be used)"
    echo "  -out   Save commit logs to vcs.log${NC}"
    exit 1
}

# Check the first argument and remove it from the list
command=$1
shift # Shift the arguments to remove the command from the list

case $command in
run)
    # Parse command line arguments for 'run'
    add_changes=false
    commit_changes=false
    push_changes=false
    branch_name=""

    while getopts ":acpb:" opt; do
        case $opt in
        a)
            add_changes=true
            ;;
        c)
            commit_changes=true
            ;;
        p)
            push_changes=true
            ;;
        b)
            branch_name="$OPTARG"
            ;;
        \?)
            echo -e "${BLUE}Invalid option -$OPTARG${NC}" >&2
            usage
            ;;
        :)
            echo -e "${BLUE}Option -$OPTARG requires an argument.${NC}" >&2
            usage
            ;;
        esac
    done

    # Get the current branch name if not provided
    if [ -z "$branch_name" ]; then
        branch_name=$(git symbolic-ref --short HEAD)
    fi

    # Add changes
    if $add_changes; then
        git add .
        echo -e "${BLUE}All changes have been added.${NC}"
    fi

    # Commit changes
    if $commit_changes; then
        # Check for unstaged changes
        unstaged_changes=$(git status --porcelain | grep '^[ MADRC]')

        if [ -z "$unstaged_changes" ]; then
            echo -e "${BLUE}No changes to commit.${NC}"
            exit 0
        fi

        # Create a commit message with the names of each unstaged change
        commit_message=""
        while IFS= read -r line; do
            file_name=$(echo "$line" | awk '{print $2}')
            commit_message+="$(echo "$line" | awk '{print $1}') $file_name\n"
        done <<<"$unstaged_changes"

        # Commit changes with the generated message
        git commit -m "$(echo -e "$commit_message")"
        echo -e "${BLUE}Changes have been committed.${NC}"
    fi

    # Push changes
    if $push_changes; then
        git push origin "$branch_name"
        echo -e "${BLUE}Changes have been pushed to branch '$branch_name'.${NC}"
    fi
    ;;
check)
    # Display the status of the repository
    echo -e "${BLUE}$(git status)${NC}"
    ;;
logs)
    # Parse command line arguments for 'logs'
    output_to_file=false

    while getopts ":out" opt; do
        case $opt in
        out)
            output_to_file=true
            ;;
        \?)
            echo -e "${BLUE}Invalid option -$OPTARG${NC}" >&2
            usage
            ;;
        :)
            echo -e "${BLUE}Option -$OPTARG requires an argument.${NC}" >&2
            usage
            ;;
        esac
    done

    # Get the commit logs
    commit_logs=$(git log --oneline)

    if $output_to_file; then
        # Save commit logs to vcs.log
        echo "$commit_logs" >vcs.log
        if [ $? -eq 0 ]; then
            echo -e "${BLUE}Commit logs have been saved to vcs.log.${NC}"
        else
            echo -e "${BLUE}Failed to save commit logs to vcs.log.${NC}"
        fi
    else
        echo -e "${BLUE}$commit_logs${NC}"
    fi
    ;;
*)
    usage
    ;;
esac
