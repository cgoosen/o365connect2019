#Script assumes you are already connected to Azure AD using V2 (AAD) module
#HTML built using Bootstrap - Documentation here: https://getbootstrap.com/docs/4.3/getting-started/introduction/

$TimeStamp = Get-Date -Format g

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

$File = "index.html"
$HTML | Set-Content $File -force -Encoding UTF8
