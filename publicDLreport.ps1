#README.md(https://github.com/lev2pr0/publicDLreport/blob/main/README.md)
## Function to generate a report for public distribution lists
## This function retrieves all public distribution groups and their members, filtering based on the provided email domains.
Function publicDLreport {
    param(
        [string[]]$Domains = @(),
        [switch]$onpremEX,
        [string]$OutputPath = "PublicDLReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" # Default output path
    )

    # Connect to Exchange Online and skips if -onpremEX switch is found
    if (-not $onpremEX) {
        Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
        try { # Check for existing Exchange Online sessions
        $exchSessions = (Get-ConnectionInformation | Where-Object {$_.name -like "*ExchangeOnline*"})
            if ($exchSessions.count -lt 1) { # Connect to Exchange Online if no existing session
                Connect-ExchangeOnline
            } else { # Confirm existing connection to Exchange Online
                Write-Host "Already connected to Exchange Online." -ForegroundColor Green
            }
        } catch { # Handle errors connecting to Exchange Online
            Write-Host "Error connecting to Exchange Online: $_" -ForegroundColor Red
            Write-Host "If using Exchange Management Shell on Exchange Server, then rerun using -onpremEX switch" -ForegroundColor Red
            Write-Host "Exiting script." -ForegroundColor Red
            return
        }
    } else { # Skip Exchange Online session check and connection
    Write-Host "Skipping Exchange Online connection as -onpremEX is provided." -ForegroundColor Cyan
        }

    # Gather domains to consider internal for report
    if (($Domains.count -lt 1) -or ($Domains[0].length -lt 1)) {    
        $Domains = ((Read-host "Type in a comma-separated list of your email domains, IE domain1.com,domain2.com") -replace ('@|"| ','')) -split ","
    }

    # Validate domains
    $Domains = $Domains | Where-Object { $_ -match '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' }
    if ($Domains.count -lt 1) {
        Write-Host "No valid domains provided." -ForegroundColor Red
        Write-Host "Please provide a valid domain list in the format: domain1.com,domain2.com" -ForegroundColor Red
        Write-Host "Exiting script." -ForegroundColor Red
        return
    }

    # Get all distribution groups that are public
    try {
        $public_groups = Get-DistributionGroup | Where-Object {$_.RequireSenderAuthenticationEnabled -eq $false}
    } catch {
        Write-Host "Error retrieving public distribution group: $($_.PrimarySmtpAddress): $_" -ForegroundColor Red
        return
    }

    # Get members of each public distribution group
    $results = @()
    $public_groups | ForEach-Object {
        Write-host "Processing members of $($_.PrimarySmtpAddress)" -ForegroundColor Cyan
        $members = Get-DistributionGroupMember -Identity $_.name
        foreach ($member in $members) {
             # Get recipient details for each member
                $recipient = Get-Recipient -Identity $member.name
                if ($null -ne $recipient) {
                    $recipientDomain = ($recipient.PrimarySmtpAddress -split "@")[1]
                    $results += [PSCustomObject]@{
                        PrimarySmtpAddress = $recipient.PrimarySmtpAddress
                        Organization = if ($recipientDomain -in $Domains) { "Internal" } else { "External" }
                        GroupEmail = $_.PrimarySmtpAddress
                        GroupType = $_.RecipientTypeDetails
                    }
                } else {
                    Write-Host "Recipient not found for member $($member.name)" -ForegroundColor Yellow
                }
            }
        }
         
    # Export results to CSV
    if ($results.Count -gt 0) {
        try {
            $results | Export-Csv -Path $OutputPath -NoTypeInformation
            Write-Host "Report exported to $OutputPath" -ForegroundColor Green
        } catch {
            Write-Host "Error exporting results to CSV: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "No results to export." -ForegroundColor Yellow
    }
}
