# PowerShell script for setting up the lab project

function Check-Dependencies {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "git is not installed. Please install git"
        exit 1
    }

    if (-not (Get-Command sed -ErrorAction SilentlyContinue)) {
        Write-Host "sed is not installed. Please install sed"
        exit 1
    }
}

function Get-UserInfo {
    $FULLNAME = git config --get user.name
    if (-not $FULLNAME) {
        $FULLNAME = Read-Host "Enter your full name (firstname lastname)"
    }
    $NAME_PARTS = $FULLNAME -split " "
    $FIRSTNAME = $NAME_PARTS[0]
    $LASTNAME = $NAME_PARTS[1]

    if (-not $FIRSTNAME) {
        $FIRSTNAME = Read-Host "Enter your first name"
    }
    if (-not $LASTNAME) {
        $LASTNAME = Read-Host "Enter your last name"
    }

    $GLOBALS:LAB_NAME = Read-Host "Enter the project name"
}

function Remove-GitRepo {
    Remove-Item -Recurse -Force .git
}

function Setup-Venv {
    $pythonCmd = (Get-Command python -ErrorAction SilentlyContinue).Source
    if (-not $pythonCmd) {
        $pythonCmd = (Get-Command python3 -ErrorAction SilentlyContinue).Source
    }
    if (-not $pythonCmd) {
        Write-Host "Python is not installed. Please install Python"
        Write-Host "Skipping venv setup"
    } else {
        & $pythonCmd -m venv $LAB_NAME
        "$LAB_NAME" | Out-File -Append .gitignore
        # idk if this works on windows?
        Write-Host "run `".\$LAB_NAME\Scripts\Activate`" to activate it."
    }
}

function Open-VSCode {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code .
    } else {
        Write-Host "Could not find VSCode. Is it installed and the 'code' command set up?"
    }
}

Check-Dependencies
Get-UserInfo

git clone --depth=1 --branch=template https://github.com/Phillezi/cm1001-lab-template.git

Rename-Item cm1001-lab-template $LAB_NAME

Set-Location $LAB_NAME

Remove-GitRepo

Rename-Item "firstname_lastname_assignment_X.ipynb" "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"

(Get-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb") -replace "Name Author 1", "$FIRSTNAME $LASTNAME" | Set-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"
(Get-Content "README.md") -replace "Assignment X", "$LAB_NAME" | Set-Content "README.md"

Setup-Venv
Open-VSCode
