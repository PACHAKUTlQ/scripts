set VT_ICON="~\Pictures\icons\Virustotal.ico"

:: Create the registry key
reg add "HKEY_CLASSES_ROOT\*\shell\Check Virustotal" /ve /d "Check Virustotal" /f

:: Create the command to run PowerShell script
reg add "HKEY_CLASSES_ROOT\*\shell\Check Virustotal\command" /ve /d "powershell.exe -Command \"Start-Process https://www.virustotal.com/gui/file/$((Get-FileHash -Path '%1' -Algorithm SHA256).Hash)\"" /f

:: Set the icon
reg add "HKEY_CLASSES_ROOT\*\shell\Check Virustotal" /v "Icon" /t REG_SZ /d "%VT_ICON%" /f
