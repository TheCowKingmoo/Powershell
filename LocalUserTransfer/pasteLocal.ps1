# Program To Copy Important Local User info 


[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'LocalPaste'
$msg   = 'Enter the AD account being copied'

$userName = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

$regFile = "*.reg"

if( ( Test-Path "C:\Users\$userName" ) -eq $false )  {

  Write-Output "Error, $userName does not exist on machine"
  Exit

}

$sourceRootFolder = ":\TRANSFER"

$driveArray = (Get-PSDrive).Name
$check = $false
$drivePathFound = $false
              

foreach( $drive in $driveArray )  {

  $drivePath = $drive + $sourceRootFolder

  if( (Test-Path $drivePath) -eq $true )  {

    $drivePathFound = $true
    $actualDrivePath = $drivePath
    break
  
  }  ##end if
  
}  ##end drive loop

if( ($drivePathFound) -eq $false )  {
  
  Write-Output "Exiting, could not find the path to source TRANSFER folder"
  exit
  
}  ##error check if

$sourcePath = $actualDrivePath + "\" + $userName

$sourceFolders = Get-ChildItem -Path $sourcePath -Name

$destPathFirst = "C:\Users\$userName"

$j = 0
foreach( $folder in $sourceFolders )  {
   
  $actualSourcePath = $sourcePath + "\" + $folder    

  if( $folder -eq $regFile )  {
    
    $output = "Action:" + $j + " Registry Importing " + $actualSourcePath
    Write-Output $output
    reg import $actualSourcePath
  
  }  else  {

    $output = "Action:" + $j + " Copying " + $actualSourcePath + " to " + $actualDestPath
    Write-Output $output
    $actualDestPath = $destPathFirst

  
    Copy-Item $actualSourcePath -Destination $actualDestPath -Recurse -Force
  
  }
  $j = $j + 1

} 

Write-Output "Program is Finished Coping"