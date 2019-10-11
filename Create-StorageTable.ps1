#Azure Storage info
$AzureEndpoint = 'https://{you-storage-account}.table.core.windows.net/'
$AzureSAS = "{you-sas}"
$AzureRequestHeaders = @{
		"x-ms-date"=(Get-Date -Format r);
		"x-ms-version"="2016-05-31";
		"Accept-Charset"="UTF-8";
		"DataServiceVersion"="3.0;NetFx";
		"MaxDataServiceVersion"="3.0;NetFx";
		"Accept"="application/json;odata=nometadata"}

#Import list of email addresses from text file. File contains 1 address per line. Table names cannot contain invalid chars.

$InputData = Get-Content demo.txt

Foreach ($User in $InputData) {
    $UserTable = $User.Split("@")[0]
    $UserURI = $AzureEndpoint + $UserTable + "/" + $AzureSAS
    try {
    $UserTableExists = Invoke-WebRequest -Method GET -Uri $UserURI -Headers $AzureRequestHeaders
    $UserTableExists = $UserTableExists.StatusCode
    }
    catch {
          $UserTableExists = $_.Exception.Response.StatusCode.Value__
        }
    If ($UserTableExists -ne "200"){
      $TableRequestBody = ConvertTo-Json -InputObject @{
              "TableName"=$UserTable}
      $EncodedTableRequestBody = [System.Text.Encoding]::UTF8.GetBytes($TableRequestBody)
      $TableURI = $AzureEndpoint + 'Tables/' + $AzureSAS
      Invoke-WebRequest -Method POST -Uri $TableURI -Headers $AzureRequestHeaders -Body $EncodedTableRequestBody -ContentType "application/json"
    }
  }
