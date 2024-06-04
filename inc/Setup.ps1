if (-not (Get-Module -Name Mailozaurr -ListAvailable)) {
    Install-Module -Name Mailozaurr -Scope CurrentUser -Force
}