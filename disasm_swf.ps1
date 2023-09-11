param (
    [Parameter(mandatory=$true)][string] $src
)

function PrintMessage {
    param ([string]$message)
    Write-Output ''
    Write-Output "----------------------------------------------"
    Write-Output $message
    Write-Output "----------------------------------------------"
}

if (git status --porcelain | Where {$_ -match 'sas4_asasm/'}) {
    Write-Warning "There are unstaged changes in sas4_asasm/, which may be overwritten when disassembling the swf. Are you sure you want to proceed?" -WarningAction Inquire
}

$asasmPath = "sas4_asasm"
$swfName = (Get-ChildItem $src).BaseName
$oldAbcPath = Join-Path -Path (Split-Path $src) -ChildPath ($swfName + "-0.abc")
PrintMessage -message "Exporting bytecode from swf"

try {
    abcexport $src
    Move-Item -Path $oldAbcPath "."
} catch {
    Write-Error "Failed to export bytecode"
    Exit
}

Rename-Item ($swfName + "-0.abc") "sas4.abc"
PrintMessage -message "Removing current .asasm files"
[void](Remove-Item -Recurse -Force $asasmPath)
PrintMessage -message "Disassembling bytecode"

rabcdasm sas4.abc
if ($LASTEXITCODE -ne 0) {
    Remove-Item "sas4.abc"
    Write-Error "Bytecode disassembly failed"
    Exit
}

Rename-Item "sas4" $asasmPath
Remove-Item "sas4.abc"

PrintMessage -message "Done"