
@echo off
chcp 65001 >nul

if "%~1"=="" (
echo Uso: %~nx0 "1. Muestra todos los empleados"
exit /b 1
)

set "pregunta=%~1"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ((Get-Content '%~f0' -Raw -Encoding UTF8) -replace '(?s).*?#BEGIN_PS1', '')"
exit /b %errorlevel%

#BEGIN_PS1
$apiKey = "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"
$pregunta = $env:pregunta

$contexto = "Rol: Administrador Oracle experto. Resuelve ejercicios SQL del esquema HR. Instrucciones: Devuelve UNICAMENTE codigo SQL valido. CERO texto adicional, ni antes ni despues. CERO formato markdown."

$promptCompleto = $contexto + "nnPregunta del usuario: " + $pregunta

$bodyObj = @{
model = "google/gemma-3-4b-it:free"
messages = @(
@{ role = "user"; content = $promptCompleto }
)
}

$bodyJson = $bodyObj | ConvertTo-Json -Depth 5 -Compress

$tempFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($tempFile, $bodyJson, [System.Text.Encoding]::UTF8)

$url = "https://openrouter.ai/api/v1/chat/completions"

$response = & curl.exe -s -X POST $url -H "Content-Type: application/json" -H "Authorization: Bearer $apiKey" -d "@$tempFile"

Remove-Item $tempFile

try {
$json = $response | ConvertFrom-Json
if ($json.choices) {
Write-Host "n$($json.choices[0].message.content)n"
} else {
Write-Host "Respuesta de error de la API:"
Write-Host $response
}
} catch {
Write-Host "Error leyendo la respuesta de curl:"
Write-Host $response
}