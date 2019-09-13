
$ciscoFile = '"cisco.msi"'

$ciscoArgs = @(
    "/i"
    $ciscoFile
    "/q"
    "/norestart"
    )



##Silent Install of Chrome
Start-Process msiexec.exe -ArgumentList $ciscoArgs -Wait


