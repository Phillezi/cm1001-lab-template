param (
    [string]$LAB_NAME,
    [string]$FIRSTNAME,
    [string]$LASTNAME
)

function Check-Dependencies {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "git is not installed. Please install git" -ForegroundColor Red
        exit 1
    }
    if (-not (Get-Command Move-Item -ErrorAction SilentlyContinue)) {
        Write-Host "mv (Move-Item) is not available. Please install coreutils" -ForegroundColor Red
        exit 1
    }
}

function Get-UserInfo {
    if (-not $FIRSTNAME -or -not $LASTNAME) {
        $FULLNAME = git config --get user.name
        if ($FULLNAME) {
            $NAME_PARTS = $FULLNAME -split ' '
            $FIRSTNAME = $NAME_PARTS[0]
            $LASTNAME = $NAME_PARTS[1]
        }
        if (-not $FIRSTNAME) { $FIRSTNAME = Read-Host "Enter your first name" }
        if (-not $LASTNAME) { $LASTNAME = Read-Host "Enter your last name" }
    }
    if (-not $LAB_NAME) {
        $LAB_NAME = Read-Host "Enter the project name"
    }
    if (-not $LAB_NAME -or -not $FIRSTNAME -or -not $LASTNAME) {
        Write-Host "Lab name, firstname, and lastname all have to be provided." -ForegroundColor Red
        exit 1
    }
}

function Remove-GitRepo {
    Remove-Item -Recurse -Force .git
}

function Setup-Venv {
    $PYTHON_CMD = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $PYTHON_CMD) { $PYTHON_CMD = Get-Command python -ErrorAction SilentlyContinue }
    if (-not $PYTHON_CMD) {
        Write-Host "Python is not installed. Please install Python." -ForegroundColor Yellow
        Write-Host "Skipping venv setup"
    } else {
        & $PYTHON_CMD -m venv $LAB_NAME
        Add-Content .gitignore $LAB_NAME
        Write-Host "run`n`t.\$LAB_NAME\Scripts\Activate" -ForegroundColor Green
    }
}

function Open-VSCode {
    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Host "Could not find VSCode. Is it installed and the 'code' command set up?" -ForegroundColor Yellow
    } else {
        code .
    }
}

Check-Dependencies
Get-UserInfo

git clone --depth=1 --branch=template https://github.com/Phillezi/cm1001-lab-template.git
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to clone repository" -ForegroundColor Red
    exit 1
}

Move-Item cm1001-lab-template $LAB_NAME
Set-Location $LAB_NAME
Remove-GitRepo

Move-Item firstname_lastname_assingment_X.ipynb "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"

(Get-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb") -replace "Name Author 1", "$FIRSTNAME $LASTNAME" | Set-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"
(Get-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb") -replace "Assignment 1", "$LAB_NAME" | Set-Content "${FIRSTNAME}_${LASTNAME}_${LAB_NAME}.ipynb"
(Get-Content README.md) -replace "Assignment X", "$LAB_NAME" | Set-Content README.md

Setup-Venv
Open-VSCode