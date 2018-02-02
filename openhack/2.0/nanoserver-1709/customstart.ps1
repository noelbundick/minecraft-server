$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if((Get-ChildItem G:\ -Force | Select-Object -First 1 | Measure-Object).Count -eq 0)
{
   echo "Empty data volume detected. Populating with default world"
   cp -r C:\default\* G:
}

Start-Job -ScriptBlock {
  while((Select-String -Pattern 'RCON running' -Path C:\minecraft\minecraft.out) -eq $null) { Write-Output "nothing"; Start-Sleep -Seconds 1 }
  rcon-cli --host 127.0.0.1 --port 25575 --password cheesesteakjimmys ban b973ece7-93e7-477e-a69a-d22554953e89
} | Out-Null

pwsh -File C:\minecraft\start.ps1 | Tee-Object C:\minecraft\minecraft.out