#Script assumes you are already connected to Azure AD using V2 (AAD) module
#HTML built using Bootstrap - Documentation here: https://getbootstrap.com/docs/4.3/getting-started/introduction/
#Uses Google charts for the guages - Documentation here: https://developers.google.com/chart/interactive/docs/examples

$TimeStamp = Get-Date -Format g

#Calculate Licenses
$E3 = Get-AzureADSubscribedSku | Where {$_.SkuId -eq "c7df2760-2c81-4ef7-b578-5b5392b571df"}
$E3Total = $E3.PrepaidUnits.Enabled
$E3Used = $E3.ConsumedUnits
$E3LicensePercent = $E3Used / $E3Total *100
$E3LicensePercent = [math]::Round($E3LicensePercent,0)
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
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
       google.charts.load('current', {'packages':['gauge']});
       google.charts.setOnLoadCallback(drawChart);

       function drawChart() {

         var data = google.visualization.arrayToDataTable([
           ['Label', 'Value'],
           ['E3', $E3LicensePercent],
           ['EMS', $EMSLicensePercent]
         ]);

         var options = {
           redFrom: 90, redTo: 100,
           yellowFrom:75, yellowTo: 90,
           minorTicks: 5
         };

         var chart = new google.visualization.Gauge(document.getElementById('chart_div'));

         chart.draw(data, options);
         }
       </script>
  </head>
  <body>
  <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
  <script type="text/javascript">
    `$(document).ready(function(){
        `$('[data-toggle="tooltip"]').tooltip();
    });
  </script>
    <div class="container-fluid">
  <div class="row" style="margin-top:20px;">
    <div class="col text-center">
      <h2>Contoso Office 365 License Dashboard</h2>
    </div>
  </div>
  </div>
  <div class="row" style="margin-top:25px;">
    <div class="col">
      <div class="card" align="center">
        <div id="chart_div" style="display: block; margin: 0 auto;"></div>
        <div class="card-body">
        <h6 class="card-title text-center">License Usage (%)</h6>
        <button type="button" class="btn btn-secondary" data-toggle="tooltip" data-placement="bottom" title="E3: $E3Used consumed of $E3Total. EMS: $EMSUsed consumed of $EMSTotal.">More Info</button>
      </div>
     </div>
    </div>
  </div>
  <div class="row" style="margin-top:10px;">
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
