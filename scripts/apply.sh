#!/bin/env sh

LAB_NAME=$1
FIRSTNAME=$2
LASTNAME=$3

check_dependencies() {
    if ! command -v git >/dev/null; then
        echo "git is not installed. Please install git"
        exit 1
    fi

    if ! command -v sed >/dev/null; then
        echo "sed is not installed. Please install sed"
        exit 1
    fi

    if ! command -v mv >/dev/null; then
        echo "mv is not installed. Please install mv"
        exit 1
    fi
}

get_user_info() {
    if [[ -z "$FIRSTNAME" || -z "$LASTNAME" ]]; then
        FULLNAME=$(git config --get user.name)
        FIRSTNAME=$(echo "$FULLNAME" | awk '{print $1}')
        LASTNAME=$(echo "$FULLNAME" | awk '{print $2}')

        if [ -z "$FIRSTNAME" ]; then
            read -p "Enter your first name: " FIRSTNAME
        fi

        if [ -z "$LASTNAME" ]; then
            read -p "Enter your last name: " LASTNAME
        fi
    fi

    if [ -z "$LAB_NAME" ]; then
        read -p "Enter the project name: " LAB_NAME
    fi

    if [[ -z "$LAB_NAME" || -z "$FIRSTNAME" || -z "$LASTNAME" ]]; then
        echo "Lab name, firstname, and lastname all have to be provided."
        exit 1
    fi
}

# needs to be run inside the cloned git repo
rm_git_repo() {
    rm -rf .git
}

setup_venv() {
    PYTHON_CMD=$(command -v python3 || command -v python )
    if [ -z "$PYTHON_CMD" ]; then
        echo "Python is not installed. Please install Python"
        echo "Skipping venv setup"
    else
        "$PYTHON_CMD" -m venv "$LAB_NAME"
        echo "$LAB_NAME" >> .gitignore
        echo -e "run\n\tsource ./$LAB_NAME/bin/activate\nTo activate it.\n"
    fi
}

open_vscode() {
    if ! command -v code >/dev/null; then
        echo "Could not find VSCode. Is it installed and the 'code' command set up?"
    else
        code .
    fi
}

check_dependencies

get_user_info

git clone --depth=1 --branch=template https://github.com/Phillezi/cm1001-lab-template.git || {
    echo "Failed to clone repository"
    exit 1
}

mv cm1001-lab-template "$LAB_NAME"

cd "$LAB_NAME" || {
    echo "Failed to enter project directory"
    exit 1
}

rm_git_repo

mv firstname_lastname_assingment_X.ipynb "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"

sed -i "s/Name Author 1/$FIRSTNAME $LASTNAME/" "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"
sed -i "s/Assignment 1/$LAB_NAME/" "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"
sed -i "s/Assignment X/$LAB_NAME/" README.md

setup_venv

open_vscode
