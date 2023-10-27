return @"
<div id="billy">
    <p>The current time is $(Get-Date)</p>
    <img src="/assets/gated.png" alt="why" />
    <button hx-post="/unclick"
        hx-trigger="click"
        hx-target="#billy"
        hx-swap="outerHTML"
    >
        Hide Bill Gates Please
    </button>
</div>
"@