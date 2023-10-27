Import-Module "$PSScriptRoot\modules\WebView2.psm1" -Force
Import-Module "$PSScriptRoot\modules\Server.psm1" -Force

$webviewVersion = "1.0.2088.41"
$webviewCacheLocation = Join-Path $PSScriptRoot "cache"
$webviewInstallLocation = Join-Path $PSScriptRoot "packages"
$webServerContentLocation = Join-Path $PSScriptRoot "content"
$requestLogLocation = Join-Path $PSScriptRoot "requests.log"

Install-WebView2 -InstallLocation $webviewInstallLocation -LoaderLocation $PSScriptRoot -Version $webviewVersion
try {
    $job = Start-Server -ContentRoot $webServerContentLocation -Port 8080 -LogFile $requestLogLocation
    Start-WebView2 -InstallLocation $webviewInstallLocation -WebViewCacheLocation $webviewCacheLocation -Url "http://localhost:8080/"
} finally {
    Stop-Server -Job $job
}