function Install-WebView2 {
    param (
        [Parameter(Mandatory)]
        [string] $Version,
        [Parameter(Mandatory)]
        [string] $InstallLocation,
        [Parameter(Mandatory)]
        [string] $LoaderLocation
    )

    if($null -eq $IsWindows -or -not $IsWindows) {
        Write-Warning "WebView2 is only supported on Windows"
        return
    }

    $libPath = Join-Path $installLocation "Microsoft.Web.WebView2"

    if(Test-Path $libPath) {
        Write-Host "Package is already installed at $libPath"
        return
    }

    Write-Host "Setting up package directory"
    New-Item -Path $installLocation -ItemType "Directory" -Force | Out-Null
    Remove-Item "$installLocation\*" -Recurse -Force

    Write-Host "Downloading Microsoft.Web.WebView2 version $Version"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/$Version" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

    Copy-Item -Path (Join-Path $libPath "runtimes\win-x64\native\WebView2Loader.dll") -Destination $LoaderLocation -Force
}

function Start-WebView2 {
    param (
        [Parameter(Mandatory)]
        [string] $InstallLocation,
        [Parameter(Mandatory)]
        [string] $WebviewCacheLocation,
        [Parameter(Mandatory)]
        [string] $Url
    )

    if($null -eq $IsWindows -or -not $IsWindows) {
        Write-Warning "WebView2 is only supported on Windows, opening default browser instead"
        Start-Process $Url -Wait
    }
    
    Add-Type -AssemblyName PresentationFramework
    Add-Type -Path (Join-Path $InstallLocation "Microsoft.Web.WebView2\lib\netcoreapp3.0\Microsoft.Web.WebView2.Core.dll")
    Add-Type -Path (Join-Path $InstallLocation "Microsoft.Web.WebView2\lib\netcoreapp3.0\Microsoft.Web.WebView2.Wpf.dll")

    # Set up WebView2 environment
    $env:WEBVIEW2_USER_DATA_FOLDER = $WebviewCacheLocation
    New-Item -ItemType Directory $env:WEBVIEW2_USER_DATA_FOLDER -Force | Out-Null

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:wv2="clr-namespace:Microsoft.Web.WebView2.Wpf;assembly=Microsoft.Web.WebView2.Wpf"
        Title="HTMX"
        Height="1000"
        Width="1000"
>
    <DockPanel>
        <wv2:WebView2 Name="webView" Source="$Url" />
    </DockPanel>
</Window>
"@

    # Read XAML
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Show XAML window
    $null = $window.ShowDialog()
}