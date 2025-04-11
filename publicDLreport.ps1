## Function to generate a report for public distribution lists
## This function retrieves all public distribution groups and their members, filtering based on the provided email domains.
Function publicDLreport {
    param(
        [string[]]$Domains=@(),
        [switch]$Silent,
        [switch]$showExternalOnly,
        [switch]$onpremEX
    )

    # Connect to Exchange Online and skips if -onpremEX switch is found
    if ($onpremEX -eq $false) {
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
        try {
            $exchSessions = (Get-ConnectionInformation | Where-Object {$_.name -like "*ExchangeOnline*"})
            if ($exchSessions.count -lt 1) {
                Connect-ExchangeOnline
            } else {
                Write-Host "Already connected to Exchange Online." -ForegroundColor Green
            }
        } catch {
            Write-Host "Error connecting to Exchange Online: $_" -ForegroundColor Red
            Write-Host "If using on-premises Exchange, then rerun use -onPremEX switch" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "Skipping Exchange Online connection as -onPremEX is provided." -ForegroundColor Cyan
    }

    # Gather domains to consider internal for report
    if (($Domains.count -lt 1) -or ($Domains[0].length -lt 1)) {
        try {
            $Domains = ((Read-host "Type in a comma-separated list of your email domains, IE domain1.com,domain2.com") -replace ('@|"| ',"")).split(",")
        } catch {
            Write-Host "Error reading domains input: $_" -ForegroundColor Red
            return
        }
    }

    # Get all distribution groups that are public
    try {
        $public_groups = Get-DistributionGroup | Where-Object {$_.RequireSenderAuthenticationEnabled -eq $false}
    } catch {
        Write-Host "Error retrieving public distribution groups: $_" -ForegroundColor Red
        return
    }

    # Get all public distribution groups members
    $public_groups | ForEach-Object {
        if (!($silent)) { Write-Host "Processing group: $($_.name)" -ForegroundColor Cyan}
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
