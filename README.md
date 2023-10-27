# PwshHtmx

I wanted to tinker with HTMX and thought PowerShell was the least appropriate backend for it. So here we are.  
This is a simple demo of HTMX in PowerShell. It's not meant to be a full-fledged web framework, just a proof of concept.

## Usage

> **Warning**  
> No warranty, this is pretty 💩  
> Only tested on Windows. It might work on Linux/MacOS but I haven't tried.

```powershell
.\Run.ps1
```

## What

This sparks up a WebView2 portal on windows to expose the PowerShell HTTP server so it looks kind of like a GUI.  
It uses a basic WPF window to host the WebView2 control and a PowerShell HTTP server in a background job to serve the content.  
Content is in a folder `content/pages` and is loaded by the web server as `{{PAGE}}.{{METHOD}}.ps1` (e.g. `testing.get.ps1` would be executed for the route `GET /testing`), they're just vanilla PowerShell files that return text content so you can do whatever with them.

https://github.com/ShaunLawrie/PwshHtmx/assets/13159458/1989bbe9-e87f-48fb-a463-879ce504a0c7
