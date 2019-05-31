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
    $remotes = New-Object 'System.Collections.Generic.List[string]'
    Push-Location repos:\
    Get-ChildItem | Select-Object -ExpandProperty name | ForEach-Object {
        $remotes.Add((& git "--git-dir=./$_/.git" config --get remote.origin.url))   
    }
    Pop-Location
    return $remotes
}

Write-Output "`r`n*********************** Get-Remotes *** to see the origin of your git repos. ***********************`r`n"

Copy-Item $profile -destination ./LaptopBuddy -Force

function Publish-Buddy {
    Get-Remotes | Out-File repos:\LaptopBuddy\repoList.txt -Force
    Push-Location repos:\LaptopBuddy
    if ((git ls-files) -notcontains "$($($profile).Split('\') | Select-Object -Last 1)") {
        git add "$($($profile).Split('\') | Select-Object -Last 1)"
    }

    if ((git ls-files) -notcontains 'repoList.txt') {
        git add ./repoList.txt
    }
    git stage .
    git commit -m 'Updated pwsh profile.'
    git push
    Pop-Location
}

Write-Output "`r`n*********************** Publish-Buddy *** to push profile updates and other local config to remote ***********************`r`n"