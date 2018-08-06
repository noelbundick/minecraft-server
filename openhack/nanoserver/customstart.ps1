$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if((Get-ChildItem C:\data -Force | Select-Object -First 1 | Measure-Object).Count -eq 0)
{
   echo "Empty data volume detected. Populating with default world"
   cp -r C:\default\* C:\data
}

. C:\minecraft\start.ps1