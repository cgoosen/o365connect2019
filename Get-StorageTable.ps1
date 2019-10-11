# Requires AZ* Modules to be installed

Connect-AzAccount

#Azure Storage info
$Acc = Get-AzStorageAccount -ResourceGroupName Demo -Name chrisdemo
$Ctx = $Acc.Context
$TableNames = Get-AzStorageTable -Context $Ctx
