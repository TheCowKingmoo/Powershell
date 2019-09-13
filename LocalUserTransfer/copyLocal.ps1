# Program To Copy Important Local User info 


[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'LocalCopy'
$msg   = 'Enter the AD account being copied'

$userName = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

if( ( Test-Path "C:\Users\$userName" ) -eq $false )  {

  Write-Output "Error, $userName does not exist"
  Exit

}

[string[]] $exludeCopy = @("*.pst", "*.ini" ) 

$destFolder = "\TRANSFER"
$destRootFolder = ":\TRANSFER"

$driveArray = (Get-PSDrive).Name
$check = $false
$drivePathFound = $false


$regSourcePath = "C:\Users\$userName\"
[string[]]$pathArray = 
                "Desktop",
                "Documents",
                "Pictures",
                "Music",
                "Videos",
                "Links",
                "Contacts",
                "AppData\Local\Mozilla",
                "AppData\Local\Google",
                "AppData\Roaming\Microsoft\Signatures",
                "AppData\Roaming\Adobe\Acrobat\DC\Stamps",
                "AppData\Roaming\Adobe\Acrobat\2015\Stamps",
                "\AppData\Local\Cisco\Cisco AnyConnect Secure Mobility Client"
              

[string]$actualDrivePath = Get-Location

if( $actualDrivePath -eq $null )  {
    
  foreach( $drive in $driveArray )  {
  

  $drivePath = $drive + $destRootFolder

  if( (Test-Path $drivePath) -eq $true )  {

    $drivePathFound = $true
    $actualDrivePath = $drivePath
    break
  
  }  ##end if
  
}  ##end drive loop


}  else  {
  
  $actualDrivePath = $actualDrivePath + $destFolder
  $drivePathFound = $true

}

Write-Output $actualDrivePath


if( ($drivePathFound) -eq $false )  {
  
  Write-Output "Exiting, could not find the path to destination TRANSFER folder"
  exit
  
}  ##error check if

$destPath = $actualDrivePath + "\" + $userName

if( (Test-Path $destPath) -eq $false )  {
  
  mkdir $destPath

}  else  {

  Write-Output "destination path exists"

}  ##end ifelse chain

$i = 0
while( $i -lt $pathArray.Count )  {
  
  $actualSourcePath = $regSourcePath + $pathArray[$i]
  $check = Test-Path $actualSourcePath

  if( $check -eq $true )  {
    
    Write-Output "Copying..."
    Write-Output $pathArray[$i]

    if( $pathArray[$i] -eq "AppData\Roaming\Adobe\Acrobat\2015\Stamps" )  {

     $actualDestPath = $destPath + "\AppData\Roaming\Adobe\Acrobat\DC\Stamps"

    }  else  {
    
      $actualDestPath = $destPath + "\" + $pathArray[$i]

    }

    #Write-Output $actualSourcePath
    #Write-Output $actualDestPath

    

    Copy-Item $actualSourcePath -Destination $actualDestPath -Recurse -ErrorAction SilentlyContinue -Exclude $exludeCopy
  
  }  ##end copy if

  $i = $i + 1
}  ##end path loop

Write-Output "Program is Finished Coping"