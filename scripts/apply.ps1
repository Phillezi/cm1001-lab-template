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
}

function Remove-GitRepo {
    Remove-Item -Recurse -Force .git
}

function Setup-Venv {
    param (
        [string]$LAB_NAME
    )
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

function Get-UserInfo {
    param (
        [string]$LAB_NAME,
        [string]$FIRSTNAME,
        [string]$LASTNAME
    )

    if (-not $FIRSTNAME -or -not $LASTNAME) {
        $FULLNAME = git config --get user.name
        if ($FULLNAME) {
            $NAME_PARTS = $FULLNAME -split ' '
            $FIRSTNAME = $NAME_PARTS[0]
            $LASTNAME = $NAME_PARTS[1]
        }
        
        if (-not $FIRSTNAME) {
            $FIRSTNAME = Read-Host "Enter your first name"
        }

        if (-not $LASTNAME) {
            $LASTNAME = Read-Host "Enter your last name"
        }
    }

    if (-not $LAB_NAME) {
        $LAB_NAME = Read-Host "Enter the project name"
    }

    if (-not $LAB_NAME -or -not $FIRSTNAME -or -not $LASTNAME) {
        Write-Host "Lab name, firstname, and lastname all have to be provided." -ForegroundColor Red
        exit 1
    }

    return @{
        LAB_NAME  = $LAB_NAME
        FIRSTNAME = $FIRSTNAME
        LASTNAME  = $LASTNAME
    }
}

Check-Dependencies
$UserInfo = Get-UserInfo -LAB_NAME $LAB_NAME -FIRSTNAME $FIRSTNAME -LASTNAME $LASTNAME

git clone --depth=1 --branch=template https://github.com/Phillezi/cm1001-lab-template.git
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to clone repository" -ForegroundColor Red
    exit 1
}

Rename-Item -Path "cm1001-lab-template" -NewName "$($UserInfo.LAB_NAME)"
cd "$($UserInfo.LAB_NAME)"
Remove-GitRepo

Rename-Item -Path "firstname_lastname_assingment_X.ipynb" -NewName "$($UserInfo.FIRSTNAME)_$($UserInfo.LASTNAME)_$($UserInfo.LAB_NAME).ipynb"

(Get-Content "$($UserInfo.FIRSTNAME)_$($UserInfo.LASTNAME)_$($UserInfo.LAB_NAME).ipynb") -replace "Name Author 1", "$($UserInfo.FIRSTNAME) $($UserInfo.LASTNAME)" | Set-Content "$($UserInfo.FIRSTNAME)_$($UserInfo.LASTNAME)_$($UserInfo.LAB_NAME).ipynb"
(Get-Content "$($UserInfo.FIRSTNAME)_$($UserInfo.LASTNAME)_$($UserInfo.LAB_NAME).ipynb") -replace "Assignment 1", "$($UserInfo.LAB_NAME)" | Set-Content "$($UserInfo.FIRSTNAME)_$($UserInfo.LASTNAME)_$($UserInfo.LAB_NAME).ipynb"
(Get-Content README.md) -replace "Assignment X", "$($UserInfo.LAB_NAME)" | Set-Content README.md

Setup-Venv -LAB_NAME $UserInfo.LAB_NAME
Open-VSCode
