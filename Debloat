#Requires -RunAsAdministrator
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   WINDOWS 11 DEBLOAT (SAFE MODE - DEFENDER AKTYWNY)      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. PUNKT PRZYWRACANIA SYSTEMU
Write-Host "[1/6] Tworzenie punktu przywracania systemu..." -ForegroundColor Yellow
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "Przed_Debloatem_Win11" -RestorePointType "MODIFY_SETTINGS"

# 2. OPTYMALIZACJA SVCHOST (Kluczowe dla zejścia w okolice 60 procesów!)
# Łączy usługi systemowe w grupy (jak w Windows 7/8) zamiast tworzyć osobny proces dla każdej z nich.
Write-Host "[2/6] Grupowanie procesów svchost.exe (optymalizacja RAM)..." -ForegroundColor Green
$ramKB = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value $ramKB -Type DWord

# 3. WYŁĄCZANIE TELEMETRII I ŚLEDZENIA (Rejestr)
Write-Host "[3/6] Wyłączanie telemetrii i reklam w systemie..." -ForegroundColor Green
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord

# Wyłączenie aplikacji w tle (Background Apps)
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord

# 4. ZATRZYMANIE ZBĘDNYCH USŁUG (Defender pozostaje nietknięty!)
Write-Host "[4/6] Wyłączanie zbędnych usług systemowych..." -ForegroundColor Green
$services = @(
    "DiagTrack",          # Telemetria Windows
    "dmwappushservice",   # Routing wiadomości WAP
    "SysMain",            # Superfetch (często powoduje skoki użycia dysku/CPU)
    "WSearch",            # Windows Search (indeksowanie plików w tle)
    "Spooler",            # Bufor wydruku (usuń z listy, jeśli używasz drukarki!)
    "Fax",                # Obsługa faksu
    "MapsBroker",         # Pobrane mapy offline
    "WerSvc",             # Raportowanie błędów Windows
    "WalletService",      # Portfel Microsoft
    "RetailDemo",         # Tryb demonstracyjny sklepu
    "XblAuthManager",     # Xbox Live Auth Manager (usuń z listy, jeśli używasz Game Pass!)
    "XblGameSave",        # Xbox Live Game Save
    "XboxNetApiSvc",      # Xbox Live Networking
    "XboxGipSvc",         # Xbox Accessory Management
    "RemoteRegistry",     # Zdalny rejestr (zwiększa bezpieczeństwo)
    "TermService"         # Pulpit zdalny
)

foreach ($svc in $services) {
    if (Get-Service -Name $svc) {
        Stop-Service -Name $svc -Force
        Set-Service -Name $svc -StartupType Disabled
        Write-Host "  -> Wyłączono: $svc" -ForegroundColor DarkGray
    }
}

# 5. USUWANIE ZBĘDNYCH APLIKACJI UWP (Bloatware)
Write-Host "[5/6] Usuwanie wbudowanego bloatware'u..." -ForegroundColor Green
$bloatware = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.SkypeApp",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "MicrosoftTeams",
    "Clipchamp.Clipchamp"
)

foreach ($app in $bloatware) {
    Get-AppxPackage -AllUsers -Name $app | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online
    Write-Host "  -> Usunięto aplikację: $app" -ForegroundColor DarkGray
}

# 6. CZYSZCZENIE HARMONOGRAMU ZADAŃ (Scheduled Tasks)
Write-Host "[6/6] Wyłączanie zadań telemetrycznych w tle..." -ForegroundColor Green
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
)

foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskName $task | Out-Null
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " GOTOWE! Uruchom ponownie komputer, aby zastosować zmiany." -ForegroundColor Yellow
Write-Host " Windows Defender pozostał aktywny i chroni system." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
