$scPath = Split-Path -parent $PSCommandPath
$logFile = "$scPath\..\log\fsmon.log"

Import-Module $scPath\Get-SBDisk
Import-Module $scPath\Splunk-Utils -Force

$diskinfo = Get-SBDisk

Format-Log -obj $diskinfo | Out-File $logFile -Append -Encoding UTF8
$Null = Reset-Log -fileName $logFile -filesize 1mb -logcount 5