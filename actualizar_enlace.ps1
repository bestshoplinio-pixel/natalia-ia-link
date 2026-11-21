# Actualiza url.json SOLO si la URL del tunel cambio.
# La pagina index.html es fija y lee url.json: la direccion del navegador
# nunca cambia (nunca se muestra la URL temporal de trycloudflare).
$ErrorActionPreference = 'Stop'

$base = 'F:\Natalia IA\00_META\Apps\CuerpoMente\logs'
$carpeta = 'C:\Users\SOPORTE\Enlace-Fijo'
$destino = Join-Path $carpeta 'url.json'
$logPropio = Join-Path $carpeta 'actualizaciones.log'
$g = 'C:\Program Files\Git\cmd\git.exe'

function Escribir($texto) {
    $linea = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $texto
    Add-Content -Path $logPropio -Value $linea -Encoding utf8
    Write-Output $texto
}

try {
    $url = ''
    foreach ($f in @((Join-Path $base 'tunnel.log'), (Join-Path $base 'tunnel-error.log'))) {
        if (Test-Path $f) {
            $m = Select-String -Path $f -Pattern 'https://[a-z0-9-]+\.trycloudflare\.com' -ErrorAction SilentlyContinue | Select-Object -Last 1
            if ($m) { $url = $m.Matches[0].Value }
        }
    }
    if (-not $url) { Escribir 'AVISO: sin URL de tunel; no se cambio nada'; exit 0 }

    $actual = ''
    if (Test-Path $destino) { $actual = Get-Content $destino -Raw -Encoding utf8 }
    if ($actual -match [regex]::Escape($url)) {
        Escribir "Sin cambios: url.json ya apunta a $url"
        exit 0
    }

    # UTF-8 sin BOM (el BOM rompe JSON.parse en el navegador)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($destino, ('{"url":"' + $url + '"}'), $utf8)

    $eap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $g -C $carpeta add url.json 2>&1 | Out-Null
        & $g -C $carpeta commit -m 'Actualizar URL del tunel' 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            & $g -C $carpeta push origin main 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Escribir "url.json actualizado a $url" }
            else { Escribir 'AVISO: cambio local hecho, pero fallo el push' }
        } else {
            Escribir 'AVISO: no se pudo hacer commit'
        }
    } finally {
        $ErrorActionPreference = $eap
    }
} catch {
    Escribir ('AVISO: ' + $_.Exception.Message)
}
