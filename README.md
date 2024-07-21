# VCS Script
## Overview
This bash script automates several Git operations, including adding changes, committing, pushing, checking the repository status, and displaying commit logs. The script provides a set of options to perform specific tasks, ensuring efficient workflow management in a Git repository.

## Usage
```bash
./script_name.sh {run|check|logs} [-a] [-c] [-p] [-b <branch_name>] [-out]
run: Perform Git operations: add, commit, and/or push.
check: Display the status of the repository.
logs: Display commit logs; use -out to save to vcs.log.
Options
-a: Add all changes.
-c: Commit changes.
-p: Push changes.
-b: Specify branch name (if not provided, the current active branch will be used).
-out: Save commit logs to vcs.log.
```
## Functions
usage()
Displays usage information and exits the script.

Script Logic
Set Script to Exit on Error:

```bash
set -e
```
## Define Color Codes:

```bash
BLUE='\033[34m'
NC='\033[0m' # No Color
```
## Usage Function:


```bash
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
```
## Command Parsing:

```bash
command=$1
shift
Case: run
```

## Parse Arguments:
```bash
Copy code
add_changes=false
commit_changes=false
push_changes=false
branch_name=""

while getopts ":acpb:" opt; do
    case $opt in
    a) add_changes=true ;;
    c) commit_changes=true ;;
    p) push_changes=true ;;
    b) branch_name="$OPTARG" ;;
    \?) usage ;;
    :) usage ;;
    esac
done
```
## Get Current Branch:
```bash
if [ -z "$branch_name" ]; then
    branch_name=$(git symbolic-ref --short HEAD)
fi
```
## Add Changes:

```bash

if $add_changes; then
    git add .
    echo -e "${BLUE}All changes have been added.${NC}"
fi
```
## Commit Changes:

```bash
if $commit_changes; then
    unstaged_changes=$(git status --porcelain | grep '^[ MADRC]')
    if [ -z "$unstaged_changes" ]; then
        echo -e "${BLUE}No changes to commit.${NC}"
        exit 0
    fi
    commit_message=""
    while IFS= read -r line; do
        file_name=$(echo "$line" | awk '{print $2}')
        commit_message+="$(echo "$line" | awk '{print $1}') $file_name\n"
    done <<<"$unstaged_changes"
    git commit -m "$(echo -e "$commit_message")"
    echo -e "${BLUE}Changes have been committed.${NC}"
fi
```

## Push Changes:

```bash
if $push_changes; then
    git push origin "$branch_name"
    echo -e "${BLUE}Changes have been pushed to branch '$branch_name'.${NC}"
fi
```
## Case: check
Displays the status of the repository:

```bash
Copy code
echo -e "${BLUE}$(git status)${NC}"
```
## Case: logs
Parse Arguments:

```bash
output_to_file=false

while getopts ":out" opt; do
    case $opt in
    out) output_to_file=true ;;
    \?) usage ;;
    :) usage ;;
    esac
done
```
## Get Commit Logs:

```bash
commit_logs=$(git log --oneline)
if $output_to_file; then
    echo "$commit_logs" >vcs.log
    if [ $? -eq 0 ]; then
        echo -e "${BLUE}Commit logs have been saved to vcs.log.${NC}"
    else
        echo -e "${BLUE}Failed to save commit logs to vcs.log.${NC}"
    fi
else
    echo -e "${BLUE}$commit_logs${NC}"
fi
```
## Default Case
Displays usage information if an invalid command is provided:

```bash
usage
```