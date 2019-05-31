if ((get-module posh-git -ListAvailable).Count -lt 1) {
    Install-Module posh-git -Scope CurrentUser -Force
    Add-PoshGitToProfile -AllHosts
}

if ((Test-Path $Env:USERPROFILE\Documents\repos) -eq $false) {
    New-Item $Env:USERPROFILE\Documents\repos -ItemType Directory
}

New-PSDrive -Name repos -PSProvider Filesystem -Root $Env:USERPROFILE\Documents\repos

push-location repos:

if ((Test-Path LaptopBuddy) -eq $false) {
    git clone https://github.com/zackJKnight/LaptopBuddy.git
}

function Get-Remotes {
    Push-Location repos:\
    Get-ChildItem | Select-Object -ExpandProperty name | ForEach-Object {
        Start-Process git -argumentlist "--git-dir=./$_/.git", config, --get, remote.origin.url -NoNewWindow
    }
    Pop-Location
}

Write-Output "*********************** Get-Remotes *** to see the origin of your git repos. ******************"

Copy-Item $profile -destination ./LaptopBuddy -Force

Push-Location repos:\LaptopBuddy
if((git ls-files) -notcontains "$($($profile).Split('\') | Select-Object -Last 1)"){
    git add .
}
git commit -m 'Updated pwsh profile.'
git push
Pop-Location