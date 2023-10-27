return @"
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>PowerShell & HTMX</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script>$(Get-Content -Path "$PSScriptRoot\..\assets\htmx.min.js" -Raw)</script>
        <style>$(Get-Content -Path "$PSScriptRoot\..\assets\style.css" -Raw)</style>
    </head>
    <body>
        <h1>👋 Welcome to PowerShell</h1>
        <p>
            $($PSVersionTable | Select-Object PSVersion, PSEdition, Platform, OS | ConvertTo-Html -Fragment)
        </p>
        <p>
            Why? Why not... just host the browser in PowerShell as well.</br>
            And sprinkle in some HTMX for good measure.
        </p>
        <button hx-post="/click"
            hx-trigger="click"
            hx-swap="outerHTML"
        >
            Raise some shell!
        </button>
    </body>
</html>
"@