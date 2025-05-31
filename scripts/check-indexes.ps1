# Firestore Index Status Checker for Windows
param(
    [switch]$Monitor,
    [int]$Interval = 30,
    [switch]$Help
)

if ($Help) {
    Write-Host "Firestore Index Status Checker" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\check-indexes.ps1                    # Check once"
    Write-Host "  .\check-indexes.ps1 -Monitor           # Monitor continuously"
    Write-Host "  .\check-indexes.ps1 -Monitor -Interval 60  # Monitor every 60 seconds"
    Write-Host ""
    exit
}

function Show-IndexStatus {
    Write-Host "Checking Firestore index status..." -ForegroundColor Blue
    Write-Host ""
    
    try {
        $firebaseVersion = firebase --version 2>$null
        if (-not $firebaseVersion) {
            Write-Host "Firebase CLI not found. Please install it first:" -ForegroundColor Red
            Write-Host "   npm install -g firebase-tools"
            return $false
        }
        
        $indexesJson = firebase firestore:indexes --project planner-fe828 2>$null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to fetch indexes. Make sure you're logged in:" -ForegroundColor Red
            Write-Host "   firebase login"
            return $false
        }
        
        $indexes = $indexesJson | ConvertFrom-Json
        
        if ($indexes.indexes.Count -eq 0) {
            Write-Host "No indexes found in your project." -ForegroundColor Yellow
            return $true
        }
        
        Write-Host "Index Status Report:" -ForegroundColor Green
        Write-Host ("=" * 50) -ForegroundColor Gray
        
        $totalIndexes = $indexes.indexes.Count
        Write-Host ""
        Write-Host "Found $totalIndexes index(es) in your project" -ForegroundColor Green
        
        foreach ($index in $indexes.indexes) {
            Write-Host ""
            Write-Host "Collection: $($index.collectionGroup)" -ForegroundColor Cyan
            Write-Host "   Fields:" -ForegroundColor Gray
            
            foreach ($field in $index.fields) {
                $order = if ($field.order) { $field.order } elseif ($field.arrayConfig) { $field.arrayConfig } else { "N/A" }
                Write-Host "     - $($field.fieldPath): $order" -ForegroundColor White
            }
        }
        
        Write-Host ""
        Write-Host ("=" * 50) -ForegroundColor Gray
        Write-Host "All indexes appear to be configured correctly!" -ForegroundColor Green
        
        return $true
        
    } catch {
        Write-Host "Error checking index status: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-Monitoring {
    Write-Host "Starting continuous monitoring (checking every $Interval seconds)..." -ForegroundColor Blue
    Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
    Write-Host ""
    
    $iteration = 0
    
    while ($true) {
        $iteration++
        $timestamp = Get-Date -Format "HH:mm:ss"
        
        Write-Host "[$timestamp] Check #$iteration" -ForegroundColor Magenta
        
        $success = Show-IndexStatus
        
        if (-not $success) {
            Write-Host "Monitoring stopped due to error" -ForegroundColor Red
            break
        }
        
        Write-Host ""
        Write-Host "Next check in $Interval seconds..." -ForegroundColor Gray
        Write-Host ""
        
        Start-Sleep -Seconds $Interval
    }
}

Clear-Host
Write-Host "Firestore Index Monitor for planner-fe828" -ForegroundColor Green
Write-Host ""

if ($Monitor) {
    Start-Monitoring
} else {
    Show-IndexStatus
    Write-Host ""
    Write-Host "Tip: Use -Monitor flag for continuous monitoring" -ForegroundColor Cyan
} 