#Requires -RunAsAdministrator
$ErrorActionPreference = "SilentlyContinue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   WINDOWS 11 RESTORE (PRZYWRACANIE USTAWIEŃ FABRYCZNYCH) " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. PRZYWRACANIE DOMYŚLNEGO SVCHOST
Write-Host "[1/4] Przywracanie domyślnego podziału svchost.exe..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Value 3670016 -Type DWord

# 2. ODBLOKOWANIE PROCESÓW W TLE, WIDŻETÓW I EDGE
Write-Host "[2/4] Przywracanie aplikacji w tle, Widżetów i Edge..." -ForegroundColor Green
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled"
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 0 -Type DWord
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"

# 3. PRZYWRACANIE DOMYŚLNYCH USŁUG SYSTEMOWYCH
Write-Host "[3/4] Przywracanie domyślnych usług systemowych..." -ForegroundColor Green

# Usługi fabrycznie ustawione na Automatyczny (Automatic)
$autoServices = @(
    "DiagTrack",
    "SysMain",
    "WSearch",
    "Spooler",
    "DPS",
    "PcaSvc"
)

foreach ($svc in $autoServices) {
    if (Get-Service -Name $svc) {
        Set-Service -Name $svc -StartupType Automatic
        Start-Service -Name $svc
        Write-Host "  -> Przywrócono (Auto): $svc" -ForegroundColor DarkGray
    }
}

# Usługi fabrycznie ustawione na Ręczny (Manual)
$manualServices = @(
    "dmwappushservice",
    "Fax",
    "MapsBroker",
    "WerSvc",
    "WalletService",
    "RetailDemo",
    "XblAuthManager",
    "XblGameSave",
    "XboxNetApiSvc",
    "XboxGipSvc",
    "RemoteRegistry",
    "TermService",
    "TabletInputService",
    "wisvc",
    "AJRouter",
    "ALG",
    "BDESVC",
    "WdiServiceHost",
    "WdiSystemHost",
    "PhoneSvc",
    "lfsvc",
    "SharedAccess"
)

foreach ($svc in $manualServices) {
    if (Get-Service -Name $svc) {
        Set-Service -Name $svc -StartupType Manual
        Write-Host "  -> Przywrócono (Manual): $svc" -ForegroundColor DarkGray
    }
}

# 4. PRZYWRACANIE ZADAŃ HARMONOGRAMU
Write-Host "[4/4] Włączanie zadań harmonogramu..." -ForegroundColor Green
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
    Enable-ScheduledTask -TaskName $task | Out-Null
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " GOTOWE! Zrestartuj PC, aby przywrócić pełny stan systemu." -ForegroundColor Yellow
Write-Host " Uwaga: Usunięte aplikacje UWP można pobrać z Microsoft Store." -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan
