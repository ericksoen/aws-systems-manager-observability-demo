# popTopItem removes the top item from the file path and returns an array
# of the comma-separated values 
function popTopItem([string] $path) {
    $content = Get-Content -Path $path -First 1
    $remainingContent = Get-Content -Path $path | select -Skip 1
    Set-Content -Path $path -Value $remainingContent
    
    return $content.Split(",")
}

# finishItem removes the top item from the stack and then logs the common trace properties and context
# to stdout
function finishItem([string] $path) {
    $tokens = popTopItem($path)
    $context = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($tokens[4]))
    $asObject = ConvertFrom-Json $context
    $startTime = [int64]$tokens[3]
    
    $asObject | Add-Member -MemberType NoteProperty -Name "traceId" -Value $tokens[0]
    $asObject | Add-Member -MemberType NoteProperty -Name "id" -Value $tokens[1]  
    $asObject | Add-Member -MemberType NoteProperty -Name "parentId" -Value $tokens[2]
    $asObject | Add-Member -MemberType NoteProperty -Name "startTime" -Value $startTime
    $asObject | Add-Member -MemberType NoteProperty -Name "name" -Value $tokens[5]
    $currentTime = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()

    $asObject | Add-Member -MemberType NoteProperty -Name "durationMs" -Value ($currentTime - $startTime)
    Write-Host ($asObject | ConvertTo-Json)
    
}

# addNewItem intializes a new trace if no context exists at the specified path
# or propagates the existing context onto the current span
function addNewItem([string] $path, [string] $name, [PSObject] $context) {
    $startTime = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()

    $id = New-Guid
    $parentId = ""
    $traceId = ""

    if ($context) {
        $bar = ConvertTo-Json $context
        $base64 = [System.Text.Encoding]::UTF8.GetBytes($bar)
        $base64 = [System.Convert]::ToBase64String($base64)
    }

    # Propgate some values like the parent child relationship
    # and trace context from the previous span.
    # TODO: There's no easy way if we want to add some new shared context to all future
    # traces AND inherit trace context from the prior span
    $content = Get-Content -Path $path -First 1    
    if (-not ([string]::IsNullOrEmpty($content))) {
        $tokens = $content.Split(",")
        $traceId = $tokens[0]
        $parentId = $tokens[1]
        $base64 = $tokens[4]
    }
    else {
        $traceId = New-Guid
    }

    $additionalLines = Get-Content $path
    $topLine = "$traceId,$id,$parentId,$startTime,$base64,$name"
    Set-Content -Path $path -Value $topLine
    Add-Content -Path $path -Value $additionalLines
}