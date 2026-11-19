# Actualiza la pagina de redireccion con la URL vigente del tunel y la publica.
# Uso: se ejecuta despues de iniciar la app, o cuando cambie la URL del tunel.
$ErrorActionPreference = 'Stop'
$base = 'F:\Natalia IA\00_META\Apps\CuerpoMente'
$log = Join-Path $base 'logs\tunnel.log'
$carpeta = 'C:\Users\SOPORTE\Enlace-Fijo'

$linea = Select-String -Path $log -Pattern 'https://[a-z0-9-]+\.trycloudflare\.com' -ErrorAction SilentlyContinue | Select-Object -Last 1
if (-not $linea) { throw 'No se encontro URL del tunel en logs\tunnel.log' }
$url = $linea.Matches[0].Value

$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="0; url=$url">
<title>Natalia IA — Cuerpo y Mente</title>
<style>body{font:16px system-ui;background:#0f1419;color:#e7edf3;text-align:center;padding:60px}a{color:#5aa9ff}</style>
</head>
<body>
<h1>Cuerpo y Mente</h1>
<p>Redirigiendo a la aplicacion...</p>
<p><a href="$url">Entrar manualmente</a></p>
</body>
</html>
"@
Set-Content -Path (Join-Path $carpeta 'index.html') -Value $html -Encoding utf8

$g = 'C:\Program Files\Git\cmd\git.exe'
& $g -C $carpeta add index.html
& $g -C $carpeta commit -m 'Actualizar URL del tunel' 2>&1 | Out-Null
& $g -C $carpeta push origin main 2>&1 | Out-Null
"Enlace fijo actualizado a: $url"
