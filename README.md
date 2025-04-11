# Public Distribution List Report

This script is designed to automate the process of generating a report of members for public distribution lists (DLs) in Exchange Online or On-premises Exchange.

## Installation

### Run via local path of script to create function in PowerShell or Exchange Management Shell (EMS) session
```powershell
./publicDLreport.ps1
```

<br></br>
## Parameters 


```powershell
-Silent
```
Suppresses output to the console. Use this switch to run the script without displaying any information.

---

```powershell
-showExternalOnly
```
Shows only external members of the distribution lists. Use this switch to filter the report to include only external members.

---

```powershell
-skipEXOCheck
```
Skips the check for an existing Exchange Online session. Use this switch if you want to run the script without checking for an active session.

---

```powershell
-Domains
```
Specifies the email domains to be used for filtering external members. This parameter accepts a comma-separated list of domains. If not provided, the script will prompt for input.

---

```powershell
-onpremEX
```
Skips the check for Exchange Online sessions entirely for Exchange Management Shell. Use this switch if you want to use for Exchange On-Premises.

<br></br>
## Usage Examples

### Run the function to generate a report for public distribution lists for On-premises Exchange examples
```powershell
publicDLreport -Domains "domain1.com,domain2.com" -onpremEX
```
```powershell
publicDLreport -Domains "domain1.com,domain2.com" -onpremEX -showExternalOnly
```

---

### Run the function to generate a report for public distribution lists for Exchange Online examples
```powershell
publicDLreport -Domains "domain1.com,domain2.com"
```
```powershell
publicDLreport -Domains "domain1.com,domain2.com" -showExternalOnly
```

---

### Run the function to generate a report for public distribution lists with silent output to .csv for Exchange Online
```powershell
publicDLreport -Silent -Domains "domain1.com,domain2.com" | Export-Csv -Path "C:\Temp\PublicDLreport.csv" -NoTypeInformation
```
```powershell
publicDLreport -Silent -Domains "domain1.com,domain2.com" -showExternalOnly | Export-Csv -Path "C:\Temp\PublicDLreport.csv" -NoTypeInformation
```
---

### Run the function to generate a report for public distribution lists with silent output to .csv for On-premises Exchange
```powershell
publicDLreport -Silent -Domains "domain1.com,domain2.com" -onpremEX | Export-Csv -Path "C:\Temp\PublicDLreport.csv" -NoTypeInformation
```
```powershell
publicDLreport -Silent -Domains "domain1.com,domain2.com" -onpremEX -showExternalOnly | Export-Csv -Path "C:\Temp\PublicDLreport.csv" -NoTypeInformation
```
<br></br>
## NOTES

### Exchange Online Prerequisites to Run: 


Install Exchange Online Powershell module
```powershell
Install-Module ExchangeOnlineManagement -Force
```
**Please Note:** Only use for first time accessing Exchange Online via Powershell on local machine
<br></br>

### Warning
-- The  ```-onpremEX``` switch is required when running function in Exchange Management Shell


-- Always test the script in a non-production environment first.


-- Review the script's code and understand its functionality before execution.


-- The script may require specific permissions or elevated privileges to run correctly.


-- The script's behavior may vary depending on the system configuration and environment.

---

<br></br>
## Contributing

<img src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExOGlmcmhqeWZkejFnZHV3MnU2MTIxYjczNW9ldTJmdm1leDdsaXR4YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/vR1dPIYzQmkRzLZk2w/giphy.gif" width="200" height="200" />

<br></br>
## License

[MIT License](https://choosealicense.com/licenses/mit/)
