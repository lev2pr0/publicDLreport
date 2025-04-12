# Public Distribution List Report

## Purpose 

Microsoft currently provides limited reporting on providing insights into Public Distribution Lists. Given the potential risks associated with external senders posing as threat actors (phishing, whaling, and other social engineering tactics) or compromised business partners (business email compromise attacks), a proactive approach to risk management is essential. This script is designed to automate the generation of a report of members for Distribution Lists open to external senders in Microsoft 365’s Exchange Online or on-premises Exchange servers.
<br></br>
For further reporting capabilities, refer to the [Mailbox Forward Report](https://github.com/lev2pr0/mailboxforwardreport) feature, which enables the retrieval of reports encompassing all user and shared mailboxes with forwarding SMTP addresses configured.
<br></br>

<p align="center" 
 
 **Support?** Buy me coffee ☕️ via [Paypal](https://www.paypal.com/donate/?business=E7G9HLW2WPV22&no_recurring=1&item_name=Empowering+all+to+achieve+success+through+technology.%0A&currency_code=USD)

</p>

## Installation 

<img src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExOGlmcmhqeWZkejFnZHV3MnU2MTIxYjczNW9ldTJmdm1leDdsaXR4YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/vR1dPIYzQmkRzLZk2w/giphy.gif" width="200" height="200" />

<br></br>
## Parameters 

```powershell
-OutputPath
```
Allows the user to specify the location of the exported CSV file.

---

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
-Domains
```
Specifies the email domains to be used for filtering external members. This parameter accepts a comma-separated list of domains. If not provided, the script will prompt for input.

---

```powershell
-onpremEX
```
Skips the connection to Exchange Online sessions entirely for Exchange Management Shell. Use this switch if you want to use for Exchange On-Premise.

<br></br>
## Usage Examples

### Run the function to generate a report for public distribution lists for Exchange On-Premise examples
```powershell
FILL WITH OUTPATH EXAMPLE
```
```powershell
./publicDLreport.ps1 -Domains "domain1.com,domain2.com" -onpremEX
```
```powershell
./publicDLreport.ps1 -Domains "domain1.com,domain2.com" -onpremEX -showExternalOnly
```

---

### Run the function to generate a report for public distribution lists for Exchange Online examples
```powershell
FILL WITH OUTPATH EXAMPLE
```
```powershell
./publicDLreport.ps1 -Domains "domain1.com,domain2.com"
```
```powershell
./publicDLreport.ps1 -Domains "domain1.com,domain2.com" -showExternalOnly
```

<br></br>
## Screenshot of report imported in Excel

<img src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExOGlmcmhqeWZkejFnZHV3MnU2MTIxYjczNW9ldTJmdm1leDdsaXR4YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/vR1dPIYzQmkRzLZk2w/giphy.gif" width="200" height="200" />

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

<br></br>
## Contributing

<img src="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExOGlmcmhqeWZkejFnZHV3MnU2MTIxYjczNW9ldTJmdm1leDdsaXR4YyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/vR1dPIYzQmkRzLZk2w/giphy.gif" width="200" height="200" />

<br></br>
## License

[MIT License](https://choosealicense.com/licenses/mit/)
