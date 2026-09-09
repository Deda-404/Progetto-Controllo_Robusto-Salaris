$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$latexmk = (Get-Command latexmk -ErrorAction Stop).Source
$pdfinfo = (Get-Command pdfinfo -ErrorAction Stop).Source
$pdftotext = (Get-Command pdftotext -ErrorAction Stop).Source

function Build-LatexArtifact {
    param(
        [Parameter(Mandatory = $true)][string]$SourceDirectory,
        [Parameter(Mandatory = $true)][string]$JobName,
        [Parameter(Mandatory = $true)][string]$AuditPath
    )

    Push-Location -LiteralPath $SourceDirectory
    try {
        & $latexmk -C "-jobname=$JobName" main.tex | Out-Null
        & $latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error "-jobname=$JobName" main.tex
        if ($LASTEXITCODE -ne 0) {
            throw "LaTeX compilation failed for $JobName with exit code $LASTEXITCODE"
        }

        $logPath = Join-Path $SourceDirectory "$JobName.log"
        $pdfPath = Join-Path $SourceDirectory "$JobName.pdf"
        $logText = Get-Content -Raw -LiteralPath $logPath
        $fatalPatterns = @(
            'LaTeX Error:',
            'Undefined control sequence',
            'There were undefined references',
            'Reference .* undefined',
            'Citation .* undefined',
            'File .* not found'
        )
        $fatalCount = 0
        foreach ($pattern in $fatalPatterns) {
            $fatalCount += ([regex]::Matches($logText, $pattern)).Count
        }
        $overfullCount = ([regex]::Matches($logText, 'Overfull \\hbox')).Count
        $overfullVBoxCount = ([regex]::Matches($logText, 'Overfull \\vbox')).Count
        $duplicateDestinationCount = ([regex]::Matches($logText, 'destination with the same identifier')).Count
        $pdfText = & $pdftotext $pdfPath -
        $unresolvedTokenCount = ([regex]::Matches(($pdfText -join "`n"), '\?\?')).Count
        $pageLine = (& $pdfinfo $pdfPath | Select-String '^Pages:').Line

        $auditFailed = $fatalCount -ne 0 -or $unresolvedTokenCount -ne 0 -or $duplicateDestinationCount -ne 0 -or $overfullCount -ne 0 -or $overfullVBoxCount -ne 0
        $auditStatus = if ($auditFailed) { 'FAIL' } else { 'PASS' }

        $auditDirectory = Split-Path -Parent $AuditPath
        New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
        @(
            "STATUS=$auditStatus"
            "JOB=$JobName"
            "ERRORS=$fatalCount"
            "UNRESOLVED_REFERENCES=$unresolvedTokenCount"
            "OVERFULL_HBOX=$overfullCount"
            "OVERFULL_VBOX=$overfullVBoxCount"
            "DUPLICATE_DESTINATIONS=$duplicateDestinationCount"
            $pageLine
            "PDF=$pdfPath"
        ) | Set-Content -LiteralPath $AuditPath -Encoding utf8

        if ($auditFailed) {
            throw "LaTeX audit failed for ${JobName}: fatal=$fatalCount unresolved=$unresolvedTokenCount duplicate-destinations=$duplicateDestinationCount overfull-hbox=$overfullCount overfull-vbox=$overfullVBoxCount"
        }

        & $latexmk -c "-jobname=$JobName" main.tex | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "LaTeX cleanup failed for $JobName"
        }
    }
    finally {
        Pop-Location
    }
}

Build-LatexArtifact `
    -SourceDirectory (Join-Path $projectRoot 'report') `
    -JobName 'Progetto_CR_Relazione_finale' `
    -AuditPath (Join-Path $projectRoot 'report/generated/report_latex_audit.txt')

Build-LatexArtifact `
    -SourceDirectory (Join-Path $projectRoot 'presentation') `
    -JobName 'Progetto_CR_Presentazione' `
    -AuditPath (Join-Path $projectRoot 'presentation/generated/presentation_latex_audit.txt')

Write-Host '[PASS] Relazione e presentazione M18 compilate e auditate.'
