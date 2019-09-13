

$assistFile = "C:\Users\djschuurman\Desktop\SupportAssist\SupportAssistInstaller.exe"

$assistArgs = @(
    "/S"
    )

Start-Process -Wait -Filepath $assistFile -ArgumentList $assistArgs -PassThru -NoNewWindow

