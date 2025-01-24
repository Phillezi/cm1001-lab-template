# CM1001 lab template

## Overview

This repo contains scripts to setup a lab from the template for the course.

## Setup

Below are the scripts that can be run to create a new lab project from the template. Run them in the directory that you want the lab project to be created in, the script will create a new folder for the project with the name you provide.

> [!NOTE]  
> Make sure to replace the parameters to your need.

### MacOS / Linux

To setup the lab template on mac or linux run the following command in your preffered terminal emulator.

```bash
curl -fsSL https://raw.githubusercontent.com/Phillezi/cm1001-lab-template/main/scripts/apply.sh | sh -s your-lab-name-here
```

If you dont have setup your `git config user.name` or it isnt accurate you can provide firstname and lastname explicitly as arguments.

```bash
curl -fsSL https://raw.githubusercontent.com/Phillezi/cm1001-lab-template/main/scripts/apply.sh | sh -s your-lab-name-here firstname lastname
```


Check what it does [here](https://github.com/Phillezi/cm1001-lab-template/tree/main/scripts/apply.sh).

### Windows

To setup the template on windows run the following command in powershell.

```powershell
powershell -c "irm https://raw.githubusercontent.com/Phillezi/cm1001-lab-template/main/scripts/apply.ps1 | iex; apply.ps1 'your-lab-name-here'"
```

If you dont have setup your `git config user.name` or it isnt accurate you can provide firstname and lastname explicitly as arguments.

```powershell
powershell -c "irm https://raw.githubusercontent.com/Phillezi/cm1001-lab-template/main/scripts/apply.ps1 | iex; apply.ps1 'your-lab-name-here' 'firstname' 'lastname'"
```

Check what it does [here](https://github.com/Phillezi/cm1001-lab-template/tree/main/scripts/apply.ps1).
