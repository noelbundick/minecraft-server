$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if((Get-ChildItem G:\ -Force | Select-Object -First 1 | Measure-Object).Count -eq 0)
{
   echo "Empty data volume detected. Populating with default world"
   cp -r C:\default\* G:
}

. C:\minecraft\start.ps1