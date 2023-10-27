# This is a super insecure web server that is only meant for tinkering purposes.
function Start-Server {
    param (
        [Parameter(Mandatory)]
        [string] $ContentRoot,
        [Parameter(Mandatory)]
        [string] $LogFile,
        [Parameter(Mandatory)]
        [int] $Port
    )

    $prefix = "http://localhost:$Port/"

    $job = Start-Job -ScriptBlock {

        $http = [System.Net.HttpListener]::new()
        $http.Prefixes.Add($using:prefix)
        $http.Start()

        try {
            while ($http.IsListening) {
                $contextTask = $http.GetContextAsync()
                while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { }
                $context = $contextTask.GetAwaiter().GetResult()

                Write-Output "Received request $($context.Request.HttpMethod) $($context.Request.RawUrl)" | Tee-Object -FilePath $using:LogFile -Append

                try {
                    # Assets
                    if($context.Request.RawUrl -like '/assets/*') {
                        $extension = (Split-Path $context.Request.RawUrl -Extension) -replace "\."
                        $contentType = switch ($extension) {
                            ".css" { "text/css" }
                            ".js" { "text/javascript" }
                            ".png" { "image/png" }
                            default { "text/plain" }
                        }
                        $image = [System.IO.File]::ReadAllBytes("$using:contentRoot$($context.Request.RawUrl)")
                        $context.Response.ContentType = $contentType
                        $context.Response.ContentLength64 = $image.Length
                        $context.Response.OutputStream.Write($image, 0, $image.Length)
                        $context.Response.OutputStream.Close()
                        Write-Output "Rendered $($context.Request.RawUrl)" | Tee-Object -FilePath $using:LogFile -Append
                        continue
                    }

                    # Controllers
                    $method = $context.Request.HttpMethod.ToLower()
                    if($context.Request.RawUrl -eq '/') {
                        $page = "index"
                    } else {
                        $page = $context.Request.RawUrl.ToLower() -replace "^/([^/]+).*$", '$1'
                    }

                    $contentPath = "$using:ContentRoot\pages\$page.$method.ps1"
                    if(Test-Path $contentPath) {
                        $content = & $contentPath
                        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                        $context.Response.ContentLength64 = $buffer.Length
                        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                        $context.Response.OutputStream.Close()
                        Write-Output "Rendered $contentPath" | Tee-Object -FilePath $using:LogFile -Append
                        continue
                    }

                    # Fallback
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes("Not Found '$($context.Request.RawUrl)'")
                    $context.Response.StatusCode = "403"
                    $context.Response.ContentLength64 = $buffer.Length
                    $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $context.Response.OutputStream.Close()
                    Write-Output "Not found: $($context.Request.RawUrl)" | Tee-Object -FilePath $using:LogFile -Append
                } catch {
                    # Errors
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes("Error occurred: $_")
                    $context.Response.StatusCode = "500"
                    $context.Response.ContentLength64 = $buffer.Length
                    $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                    $context.Response.OutputStream.Close()
                    Write-Output "Error occurred: $_ Url: $($context.Request.RawUrl)" | Tee-Object -FilePath $using:LogFile -Append
                }
            }
        }
        finally {
            $http.Stop()
        }
    }

    return $job
}

function Stop-Server {
    param (
        [System.Management.Automation.Job] $Job
    )

    $Job | Receive-Job -ErrorAction SilentlyContinue
    $Job | Stop-Job -ErrorAction SilentlyContinue
    $Job | Remove-Job -ErrorAction SilentlyContinue
}