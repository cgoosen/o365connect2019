[CmdletBinding()]
Param
([object]$WebhookData)

$VerbosePreference = 'continue'

#Collect properties of WebhookData
$WebhookName     =     $WebHookData.WebhookName
$WebhookHeaders  =     $WebHookData.RequestHeader
$WebhookBody     =     $WebHookData.RequestBody

#Collect individual headers. Input converted from JSON.
$From = $WebhookHeaders.From
$Input = (ConvertFrom-Json -InputObject $WebhookBody)

$FirstName = $Input.FirstName
$SendTo = $Input.SendTo
$ToNumber = $Input.ToNumber

$ScriptVersion = "1.0"
$TimeStamp = Get-Date -Format g

# Get creds that are stored in Automation Account
$SMTPCreds = Get-AutomationPSCredential -Name "SMTPCreds"
$AzCreds = Get-AutomationPSCredential -Name "AZCreds"
$FTPCreds = Get-AutomationPSCredential -Name 'FTPCreds'
Connect-AzureAD -Credential $AzCreds

#SMTP Credentials
$SMTPU = $SMTPCreds.UserName
$SMTPP = $SMTPCreds.GetNetworkCredential().Password
#WebApp Credentials
$FTPUser = $FTPCreds.UserName
$FTPPass = $FTPCreds.GetNetworkCredential().Password

#Function for sending email - used free tier SendGrid account in Azure. $SendTo email address is gathered from Form
function Send-Report{
 $Msg = New-Object Net.Mail.MailMessage
 $Smtp = New-Object Net.Mail.SmtpClient("smtp.sendgrid.net","25")
 $Smtp.Credentials = New-Object System.Net.NetworkCredential("$SMTPU","$SMTPP")
 $Msg.From = "Report Automation <{your-sendgrid-user}@azure.com>"
 $Msg.To.Add("$SendTo")
 $Msg.Subject = "Office 365 License Report - $TimeStamp"
 $Msg.Body = $HTML
 $Msg.IsBodyHTML = $true
 $Smtp.Send($Msg)
}

#Calculate Licenses
$E3 = Get-AzureADSubscribedSku | Where {$_.SkuId -eq "6fd2c87f-b296-42f0-b197-1e91e994b900"}
$E3Total = $E3.PrepaidUnits.Enabled
$E3Used = $E3.ConsumedUnits
$E3LicensePercent = $E3Used / $E3Total *100
$E3LicensePercent = [math]::Round($E3LicensePercent,0)
$E5 = Get-AzureADSubscribedSku | Where {$_.SkuId -eq "c7df2760-2c81-4ef7-b578-5b5392b571df"}
$E5Total = $E5.PrepaidUnits.Enabled
$E5Used = $E5.ConsumedUnits
$E5LicensePercent = $E5Used / $E5Total *100
$E5LicensePercent = [math]::Round($E5LicensePercent,0)
$EMS = Get-AzureADSubscribedSku | Where {$_.SkuId -eq "b05e124f-c7cc-45a0-a6aa-8cf78c946968"}
$EMSTotal = $EMS.PrepaidUnits.Enabled
$EMSUsed = $EMS.ConsumedUnits
$EMSLicensePercent = $EMSUsed / $EMSTotal *100
$EMSLicensePercent = [math]::Round($EMSLicensePercent,0)

#Build Report
#HTML built using Bootstrap - Documentation here: https://getbootstrap.com/docs/4.3/getting-started/introduction/
$HTML = @"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <title>Contoso Office 365 License Dashboard</title>
  </head>
  <body>
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <div class="container-fluid">
  <div class="row" style="margin-top:20px;">
    <div class="col text-center">
      <h2>Contoso Office 365 License Dashboard</h2>
    </div>
  </div>
  </div>
  <div class="row" style="margin-top:25px;">
  <div class="col-2"></div>
    <div class="col-8">
    <div class="progress" style="height: 40px;">
      <div class="progress-bar bg-success" role="progressbar" style="width: $E3LicensePercent%;" aria-valuenow="$E3LicensePercent" aria-valuemin="0" aria-valuemax="100">E3 Usage: $E3LicensePercent%</div>
    </div>
    </div>
    </div>
    <div class="col-2"></div>
    <div class="row" style="margin-top:25px;">
    <div class="col-2"></div>
    <div class="col-8">
    <div class="progress" style="height: 40px;">
      <div class="progress-bar bg-danger" role="progressbar" style="width: $E5LicensePercent%;" aria-valuenow="$E5LicensePercent" aria-valuemin="0" aria-valuemax="100">E5 Usage: $E5LicensePercent%</div>
    </div>
    </div>
    </div>
    <div class="col-2"></div>
    <div class="row" style="margin-top:25px;">
    <div class="col-2"></div>
    <div class="col-8">
    <div class="progress" style="height: 40px;">
      <div class="progress-bar bg-danger" role="progressbar" style="width: $EMSLicensePercent%;" aria-valuenow="$EMSLicensePercent" aria-valuemin="0" aria-valuemax="100">EM+S E5 Usage: $EMSLicensePercent%</div>
    </div>
    </div>
  </div>
  <div class="col-2"></div>
  <div class="row" style="margin-top:50px;">
    <div class="col-4">
    </div>
     <div class="col-4">
      <div class="alert alert-dark" role="alert" align="center">
        Last update: $TimeStamp UTC
      </div>
       </div>
        <div class="col-4">
      </div>
     </div>
    </div>
  </body>
</html>
"@

#Build XML reponse file
#Documentation here: https://www.twilio.com/docs/voice/twiml/say
$XML = @"
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say>Hello $FirstName, your licensing report is complete and will be emailed to you shortly. You have consumed $E3Used E3 licenses, $E5Used E5 licenses and $EMSUsed EMS licenses. Thank you</Say>
  <Say language="nl-NL">Hallo $FirstName, uw licentierapport is voltooid en zal binnenkort naar u worden gemaild. U hebt $E3Used E3-licenties, $E5Used E5-licenties en $EMSUsed EMS-licenties verbruikt. Dank u</Say>
  <Play>https://demo.twilio.com/docs/classic.mp3</Play>
</Response>
"@

$Path = $env:TEMP
$File = "response.xml"
$Path = $Path + "\" + $File
$XML | Set-Content $Path -force -Encoding UTF8

$LocalFile = $Path
$APIUrl = 'https://{your-site}.scm.azurewebsites.net/api/vfs/site/wwwroot/response.xml'

#Uses VFS API to upload file to Webapp - Documentation here: https://github.com/projectkudu/kudu/wiki/REST-API
#API Request to upload file
Invoke-RestMethod -Uri $APIUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -UserAgent $userAgent -Method PUT -InFile $LocalFile -ContentType "multipart/form-data"

#Uses Twilio service for making the voice call - See: www.twilio.com
#Documentation here: https://www.twilio.com/docs/usage/tutorials/how-to-make-http-basic-request-twilio-powershell
#Create auth creds for Twilio API call.
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $FTPUser, $FTPPass)))
$userAgent = "powershell/1.0"

#You Twilio account info - Set as variables in Automation Account
$TwilioSid = Get-AutomationVariable -Name 'TwilioKey'
$TwilioToken = Get-AutomationVariable -Name 'TwilioToken'
$TwilioUrl = Get-AutomationVariable -Name 'TwilioUrl'

#These could also be set as variables in the Automation Account
$FromNumber = '{Your-Twilio-Number}'
$ResponseURL = 'https://{your-site}.azurewebsites.net/response.xml'

# Twilio API endpoint and POST params
$Params = @{ To = $ToNumber; From = $FromNumber; Url = $ResponseURL }

# Create a credential object for HTTP basic auth
$TwilioPass = $TwilioToken | ConvertTo-SecureString -asPlainText -Force
$TwilioCred = New-Object System.Management.Automation.PSCredential($TwilioSid, $TwilioPass)

#Twilio API request
Invoke-WebRequest $TwilioUrl -Method Post -Credential $TwilioCred -Body $Params -UseBasicParsing

#Send email report
Send-Report
