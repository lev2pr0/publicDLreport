[README.md]#https://github.com/lev2pr0/publicDLreport/blob/main/README.md)
## Function to generate a report for public distribution lists
## This function retrieves all public distribution groups and their members, filtering based on the provided email domains.
Function publicDLreport {
    param(
        [string[]]$Domains = @(),
        [switch]$showExternalOnly,
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
            Write-Host "If using on-premise Exchange, then rerun using -onPremEX switch" -ForegroundColor Red
            return
        }
        } else { # Skip Exchange Online session check and connection
        Write-Host "Skipping Exchange Online connection as -onPremEX is provided." -ForegroundColor Cyan
    }

    # Gather domains to consider internal for report
    if (($Domains.count -lt 1) -or ($Domains[0].length -lt 1)) {    
        $Domains = ((Read-host "Type in a comma-separated list of your email domains, IE domain1.com,domain2.com") -replace ('@|"| ','')) -split ","
    }

    # Validate domains
    $Domains = $Domains | Where-Object { $_ -match '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' }
    if ($Domains.count -lt 1) {
        Write-Host "No valid domains provided. Exiting." -ForegroundColor Red
        return
    }

    # Get all distribution groups that are public
    try {
        $public_groups = Get-DistributionGroup | Where-Object {$_.RequireSenderAuthenticationEnabled -eq $false}
    } catch {
        Write-Host "Error retrieving public distribution group: $($_.Name): $_" -ForegroundColor Red
        return
    }

    # Get members of each public distribution group
    $results = @()
    $public_groups | ForEach-Object {
        Write-host "Processing members of $($_.name)" -ForegroundColor Cyan
        try {
        $members = Get-DistributionGroupMember -Identity $_.name
        foreach ($member in $members) {
            try { # Get recipient details for each member
                $recipient = Get-Recipient -Identity $member.name
                $recipientDomain = ($recipient.PrimarySmtpAddress -split "@")[1]
                # Report only external members if -showExternalOnly is specified
                if ($showExternalOnly) {
                    $filtered = $recipient | Where-Object { $Domains -notcontains $recipientDomain } 
                    $results += [PSCustomObject]@{
                        PrimarySmtpAddress = $filtered.PrimarySmtpAddress
                        Organization = "External"
                        GroupEmail = $_.PrimarySmtpAddress
                        GroupType = $_.RecipientTypeDetails
                    }
                } else { # Report all members
                    $results += [PSCustomObject]@{
                        PrimarySmtpAddress = $recipient.PrimarySmtpAddress
                        Organization = if ($recipientDomain -contains $Domains) { "Internal" } else { "External" }
                        GroupEmail = $_.PrimarySmtpAddress
                        GroupType = $_.RecipientTypeDetails
                        }
                    }
            }
         catch { # Handle errors for each member
                Write-Host "Error retrieving recipient details for member $($member.name): $_" -ForegroundColor Yellow
                }
        }
    } catch { # Handle errors for each group
            Write-Host "Error processing group $($_.name): $_" -ForegroundColor Red
            }
}

    # Export results to CSV
    try {
        $results | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Report exported to $OutputPath" -ForegroundColor Green
    } catch { # Handle errors during export
        Write-Host "Error exporting results to CSV: $_" -ForegroundColor Red
    }
}
