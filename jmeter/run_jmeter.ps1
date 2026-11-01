param(
    [Parameter(Position=0)][string]$JmxFile = "Test Plan.jmx",
    [Parameter(Position=1)][string]$OutputDir = "output_test_1"
)

# Percorso esatto di JMeter su Windows
$JmeterCmd = "C:\Users\chiar\Downloads\apache-jmeter-5.6.3\apache-jmeter-5.6.3\bin\jmeter.bat"

# Verifica eseguibile JMeter
if (-not (Test-Path -Path $JmeterCmd)) {
    Write-Host "Errore: jmeter.bat non trovato nel percorso specificato: $JmeterCmd" -ForegroundColor Red
    exit 1
}

# Controllo file JMX
if (-not (Test-Path -Path $JmxFile)) {
    Write-Host "Errore: File JMX '$JmxFile' non trovato!" -ForegroundColor Red
    exit 1
}

# Creazione cartella di output se mancante
if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$MetaFile = Join-Path $OutputDir "metadata.txt"
if (-not (Test-Path -Path $MetaFile)) {
    New-Item -ItemType File -Path $MetaFile | Out-Null
}

# Rilevamento hardware Windows
$CpuInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
$CpuModel = $CpuInfo.Name
$CpuCores = "$($CpuInfo.NumberOfCores) Core ($($CpuInfo.NumberOfLogicalProcessors) Threads)"

$TotalMemBytes = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
$TotalMem = "$([Math]::Round($TotalMemBytes / 1GB, 2)) GB"

$OsInfo = (Get-CimInstance Win32_OperatingSystem).Caption

# Estrazione parametri dal file JMX
$JmxContent = Get-Content -Path $JmxFile -Raw

$ThreadsList  = [regex]::Matches($JmxContent, '(?<=<intProp name="ThreadGroup\.num_threads">)\d+') | ForEach-Object { $_.Value }
$RampUpList   = [regex]::Matches($JmxContent, '(?<=<intProp name="ThreadGroup\.ramp_time">)\d+')   | ForEach-Object { $_.Value }
$DurationList = [regex]::Matches($JmxContent, '(?<=<longProp name="ThreadGroup\.duration">)\d+')  | ForEach-Object { $_.Value }
$DelayList    = [regex]::Matches($JmxContent, '(?<=<longProp name="ThreadGroup\.delay">)\d+')     | ForEach-Object { $_.Value }

# Estrazione endpoint HTTP univoci
$Endpoints = [regex]::Matches($JmxContent, '(?<=<stringProp name="HTTPSampler\.path">).*?(?=</stringProp>)') |
             ForEach-Object { $_.Value } | Sort-Object -Unique

# Esecuzione JMeter
$StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ResultsJtl = Join-Path $OutputDir "results.jtl"
$ReportDir  = Join-Path $OutputDir "report"

Write-Host "Esecuzione JMeter in corso su '$JmxFile'..." -ForegroundColor Cyan
& $JmeterCmd -n -t $JmxFile -l $ResultsJtl
$EndTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Generazione report HTML
Write-Host "Generazione del report HTML..." -ForegroundColor Cyan
& $JmeterCmd -g $ResultsJtl -o $ReportDir

# Salvataggio metadati
$Metadata = @"

System Metadata
-------------------------
CPU Model:      $CpuModel
CPU Cores:      $CpuCores
Total Memory:   $TotalMem
OS:             $OsInfo

JMeter Test Metadata
-------------------------
Start time:  $StartTime
End time:    $EndTime
JMX file:    $JmxFile

Thread Groups:
-------------------------
"@

for ($i = 0; $i -lt $ThreadsList.Count; $i++) {
    $tgNum = $i + 1
    $Metadata += "`nTG$tgNum -> threads: $($ThreadsList[$i]), ramp-up:$($RampUpList[$i]), duration: $($DurationList[$i]), delay:$($DelayList[$i])"
}

$Metadata += @"

Endpoints used:
-------------------------
$($Endpoints -join "`n")
"@

Add-Content -Path $MetaFile -Value $Metadata

Write-Host "`nTest completato con successo!" -ForegroundColor Green
Write-Host "Report generato in: $OutputDir\report\index.html"
Write-Host "Metadati salvati in: $MetaFile"