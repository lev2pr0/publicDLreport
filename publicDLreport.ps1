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
            $Domains = ((Read-host "Type in a comma-separated list of your email domains, IE domain1.com,domain2.com") -replace ('@|"| ','')) -split ","
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
    $results = @()
    $public_groups | ForEach-Object {
        if (!($Silent)) { Write-host "Processing members of $($_.name)" -ForegroundColor Cyan }
        try {
            $members = Get-DistributionGroupMember -Identity $_.name
            foreach ($member in $members) {
                try {
                    $recipient = Get-Recipient -Identity $member.name
                    if ($showExternalOnly) {
                        $filtered = $recipient | Where-Object { ($_.PrimarySmtpAddress -split "@")[1] -notin $Domains }
                        $results += $filtered | Select-Object name, PrimarySmtpAddress
                    } else {
                        $results += $recipient | Select-Object Name, PrimarySmtpAddress, @{
                            name = "InternalExternal";
                            expression = {
                                if (($_.PrimarySmtpAddress -split "@")[1] -notin $Domains) {
                                    "External"
                                } else {
                                    "Internal"
                                }
                            }
                        }
                    }
                } catch {
                    Write-Host "Error retrieving recipient details for member $($member.name): $_" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "Error processing group $($_.name): $_" -ForegroundColor Red
        }
    }

    # Export results to CSV
    try {
        $results | Export-Csv -Path "PublicDLReport.csv" -NoTypeInformation
        Write-Host "Report exported to PublicDLReport.csv" -ForegroundColor Green
    } catch {
        Write-Host "Error exporting results to CSV: $_" -ForegroundColor Red
    }
}