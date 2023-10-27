if($null -eq $global:UnclickCount) {
    $global:UnclickCount = 1
} else {
    $global:UnclickCount++
}

if($global:UnclickCount -gt 10) {
    return @"
<div id="billy">
    <p>
        The current time is $(Get-Date)
    </p>
    Ok fine.
    <p>
        You've tried to hide bill gates $($global:UnclickCount) times.
    </p>
</div>
"@
}

return @"
<div id="billy">
    <p>
        The current time is $(Get-Date)
    </p>
    <img src="/assets/gated.png" alt="why" />
    <p>
        You've tried to hide bill gates $($global:UnclickCount) times.
    </p>
    <button hx-post="/unclick"
        hx-trigger="click"
        hx-target="#billy"
        hx-swap="outerHTML"
    >
        Hide Bill Gates Please Again
    </button>
</div>
"@