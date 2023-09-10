function PrintMessage {
    param ([string]$message)
    Write-Output ''
    Write-Output "----------------------------------------------"
    Write-Output $message
    Write-Output "----------------------------------------------"
}

PrintMessage -message "Cleaning build folder"

$buildPath = "build"
[void](Remove-Item -Recurse -Force $buildPath)
try {
    [void](mkdir $buildPath)
} catch {
    Write-Error "Failed to clean build folder" 
    Exit
}

PrintMessage -message "Assembling .asasm files"

$asasmPath = "sas4_asasm"
$mainAsasmPath = Join-Path -Path $asasmPath -ChildPath "sas4.main.asasm"
$abcPath = Join-Path -Path $asasmPath -ChildPath "sas4.main.abc"

try {
    rabcasm $mainAsasmPath
    Move-Item -Path $abcPath $buildPath
} catch {
    Write-Error "Failed to assemble .asasm files" 
    Exit
}

PrintMessage -message "Building swfs"

$buildAbcPath = Join-Path -Path $buildPath -ChildPath "sas4.main.abc"
$staticSwfPath = "static_swf"
$staticSwfs = Get-ChildItem $staticSwfPath

$numSwfs = ($staticSwfs | Measure-Object).Count
$jobIds = New-Object System.Collections.ArrayList

$staticSwfs | Foreach-Object {
    Copy-Item -Path $_.FullName -Destination $buildPath
    $buildSwfPath = Join-Path -Path $buildPath -ChildPath $_.Name
    Write-Output ("Starting job for " + $_.Name)
    $j = Start-Job -ScriptBlock { 
        $output = & abcreplace $args 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Error: {0}" -f ([string] $output)
        }
    } -Name $_.Name -ArgumentList $buildSwfPath, 0, $buildAbcPath
    [void]$jobIds.Add($j.Id)
}

$failed = $false

for ($i = 0; $i -lt $numSwfs; $i = $i + 1) {
    $job = Wait-Job -Any -Id $jobIds
    [void](Receive-Job -Wait -AutoRemoveJob -Job $job -WriteJobInResults)
    $jobIds.Remove($job.Id)
    if ($job.State -eq "Failed") {
        Get-Job | Stop-Job
        Write-Error ("abcreplace for " + $job.Name + " failed")
        $failed = $true
        break;
    }
}

Remove-Item $buildAbcPath

if ($failed) {
    Write-Error "Failed to build some swfs"
    Exit
}

PrintMessage -message "Done"

