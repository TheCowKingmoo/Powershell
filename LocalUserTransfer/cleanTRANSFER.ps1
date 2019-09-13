
[string]$actualDriveLetter = Get-Location

$sourcePath = $actualDriveLetter + "TRANSFER"


$sourceFolders = Get-ChildItem -Path $sourcePath -Name

#Write-Output $sourceFolders

foreach ( $item in $sourceFolders )  {

  $targetItem = $sourcePath + "\" + $item 
  Remove-Item -path $targetItem -Recurse

}
##Remove-Item -path