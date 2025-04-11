## Function to generate a report for public distribution lists
## This function retrieves all public distribution groups and their members, filtering based on the provided email domains.
Function publicDLreport {
    param(
        [string[]]$Domains=@(),
        [switch]$Silent,
        [switch]$showExternalOnly,
        [switch]$skipEXOCheck,
        [switch]$onpremEX
    )

    ## Connect to Exchange Online and skips if -onpremEX switch is found
    ## The switch -skipEXOCheck is used to keep check for Exchange 
    if (-not $onpremEX) {
        $exchSessions = (Get-ConnectionInformation | Where-Object {$_.name -like "*ExchangeOnline*"})
        if (($exchSessions.count -lt 1) -or ($skipEXOCheck)) {
            Connect-ExchangeOnline
        } else {
            Write-Host "Exchange Online session detected. If you encounter any issues, rerun this command with the -skipEXOCheck switch."
        }
    } else {
        Write-Host "Skipping Exchange Online session and connection as -onPremEX is provided." -ForegroundColor Cyan
    }

    ## Gather domains to consider internal for script (the -onpremEX switch start here after last write-host above)
    if (($Domains.count -lt 1) -or ($Domains[0].length -lt 1)) {
        $Domains = ((Read-host "Type in a comma-separated list of your email domains, IE domain1.com,domain2.com") -replace ('@|"| ','')).split(",")
    }

    ## Get all distribution groups that are public (RequireSenderAuthenticationEnabled = false)
    $public_groups = Get-DistributionGroup | Where-Object {$_.RequireSenderAuthenticationEnabled -eq $false}

    ## Get all public distribution groups members
    $public_groups | ForEach-Object {
        if (!($silent)) { Write-host "`n`nShowing members for $($_.name)" -ForegroundColor Cyan }
        $members = Get-DistributionGroupMember -Identity $_.name
        foreach ($member in $members) {
            if ($showExternalOnly) {
                Get-Recipient -Identity $member.name | Select-Object name, PrimarySmtpAddress | Where-Object {$_.primarysmtpaddress.split("@")[1] -notin $Domains}
            } else {
                Get-Recipient -Identity $member.name | Select-Object name, PrimarySmtpAddress, @{name = "InternalExternal"; expression = {if ($_.primarysmtpaddress.split("@")[1] -notin $Domains){"External"}else{"Internal"}}}
            }
        }
    }
}
