#Requires -RunAsAdministrator
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   WINDOWS 11 PROCESS REDUCER (CEL: ~60 PROCESÓW)         " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. PUNKT PRZYWRACANIA SYSTEMU
Write-Host "[1/5] Tworzenie punktu przywracania..." -ForegroundColor Yellow
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "Przed_ReduceProcesses" -RestorePointType "MODIFY_SETTINGS"

# 2. GRUPOWANIE SVCHOST (Największy spadek liczby procesów - ok. 30-40 mniej)
Write-Host "[2/5] Łączenie procesów svchost.exe..." -ForegroundColor Green
$ramKB = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1KB
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value $ramKB -Type DWord

# 3. WYŁĄCZANIE PROCESÓW W TLE (Edge, Widżety, Aplikacje UWP, OneDrive)
Write-Host "[3/5] Blokowanie procesów działających w tle..." -ForegroundColor Green

# Wyłączenie Microsoft Edge Startup Boost i procesów w tle
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled" -Value 0 -Type DWord

# Wyłączenie Widżetów (Widgets.exe / WebView2)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord

# Globalne wyłączenie aplikacji w tle
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord

# Usunięcie OneDrive z autostartu (zostawia pliki, zabija proces w tle)
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive"

# 4. WYŁĄCZANIE NIEPOTRZEBNYCH USŁUG (Defender pozostaje nietknięty!)
Write-Host "[4/5] Zatrzymywanie zbędnych usług systemowych..." -ForegroundColor Green
$servicesToKill = @(
    "DiagTrack",          # Telemetria
    "dmwappushservice",   # WAP Push
    "SysMain",            # Superfetch
    "WSearch",            # Indeksowanie wyszukiwania
    "Spooler",            # Drukarki (usuń tę linijkę, jeśli masz drukarkę!)
    "Fax",                # Faks
    "MapsBroker",         # Mapy offline
    "WerSvc",             # Raportowanie błędów
    "WalletService",      # Portfel
    "RetailDemo",         # Tryb sklepowy
    "XblAuthManager",     # Xbox Auth (usuń, jeśli używasz Xbox Game Pass)
    "XblGameSave",        # Xbox Game Save
    "XboxNetApiSvc",      # Xbox Networking
    "XboxGipSvc",         # Xbox Accessories
    "RemoteRegistry",     # Zdalny rejestr
    "TermService",        # Pulpit zdalny
    "TabletInputService", # Klawiatura dotykowa / pismo odręczne
    "wisvc",              # Program Windows Insider
    "AJRouter",           # AllJoyn Router
    "ALG",                # Application Layer Gateway
    "BDESVC",             # Szyfrowanie dysków BitLocker (usuń, jeśli używasz BitLockera!)
    "DPS",                # Diagnostic Policy Service
    "WdiServiceHost",     # Diagnostic Service Host
    "WdiSystemHost",      # Diagnostic System Host
    "PcaSvc",             # Program Compatibility Assistant
    "PhoneSvc",           # Usługa telefonu
    "lfsvc",              # Geolokalizacja
    "SharedAccess"        # Udostępnianie połączenia internetowego
)

foreach ($svc in $servicesToKill) {
    if (Get-Service -Name $svc) {
        Stop-Service -Name $svc -Force
        Set-Service -Name $svc -StartupType Disabled
        Write-Host "  -> Wyłączono usługę: $svc" -ForegroundColor DarkGray
    }
}

# 5. WYŁĄCZANIE ZADAŃ W TLE (Harmonogram zadań)
Write-Host "[5/5] Czyszczenie aktywnych zadań w tle..." -ForegroundColor Green
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Maps\MapsToastTask",
    "\Microsoft\Windows\Maps\MapsUpdateTask"
)

foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskName $task | Out-Null
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " ZAKOŃCZONO! Zrestartuj PC, aby zobaczyć efekt (~60 proc.)" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
