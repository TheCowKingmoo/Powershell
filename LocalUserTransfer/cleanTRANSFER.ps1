
[string]$actualDriveLetter = Get-Location

$sourcePath = $actualDriveLetter + "TRANSFER"


$sourceFolders = Get-ChildItem -Path $sourcePath -Name

#Write-Output $sourceFolders

foreach ( $item in $sourceFolders )  {


  $targetItem = $sourcePath + "\" + $item 

  $output = "Deleting " + $targetItem
  Write-Output $output
  Get-ChildItem -Path $targetItem -Recurse | Remove-Item -force -recurse

}

Remove-Item "TRANSFER" -force -recurse

##Remove-Item -path

