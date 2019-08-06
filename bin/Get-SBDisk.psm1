function Get-SBDisk {

#Requires -Version 2





<# 

 .SYNOPSIS

  Function to get disk information including block (allocation unit) size



 .DESCRIPTION

  Function to get disk information including block (allocation unit) size

  Function returns information on all fixed disks (Type 3)

  Function will fail to return computer disk information if:

    - Target computer is offline or name is misspelled

    - Function/script is run under an account with no read permission on the target computer

    - WMI services not running on the target computer

    - Target computer firewall or AntiVirus blocks WMI or RPC calls



 .PARAMETER ComputerName

  The name or IP address of computer(s) to collect disk information on

  Default value is local computer name



 .EXAMPLE

  Get-SBDisk 

  Returns fixed disk information of local computer



 .EXAMPLE

  Get-SBDisk computer1, 192.168.19.26, computer3 -Verbose

  Returns fixed disk information of the 3 listed computers

  The 'verbose' parameter will display a message if the target computer cannot be reached



 .OUTPUTS

  The script returns a PS Object with the following properties:

    ComputerName

    DriveLetter

    'BlockSize(KB)'

    'Size(GB)'

    'Free(GB)'

    'Free(%)'

    FileSystem

    Compressed

    VolumeName

    Description



 .LINK

  https://superwidgets.wordpress.com/2017/01/09/powershell-script-to-get-disk-information-including-block-size/



 .NOTES

  Function by Sam Boutros - v1.0 - 9 January, 2017

#>



    [CmdletBinding(ConfirmImpact='Low')] 

    Param(

        [Parameter(Mandatory=$false,

                   ValueFromPipeLine=$true,

                   ValueFromPipeLineByPropertyName=$true,

                   Position=0)]

            [String[]]$ComputerName = $env:COMPUTERNAME

    )





    $Result = @()

    foreach ($Computer in $ComputerName) {

        try {

            Get-WmiObject -ComputerName $Computer -Class Win32_logicaldisk -ErrorAction Stop | where { $_.DriveType -eq 3 } | % {

                $Query = "SELECT BlockSize FROM Win32_volume WHERE DriveLetter ='$($_.DeviceID)'"

                $Splatt = @{

                    ComputerName    = $Computer

                    DriveLetter     = $_.DeviceID

                    'BlockSize(KB)' =  (Get-WmiObject -ComputerName $Computer -Query $Query).Blocksize/1KB

                    Description     = $_.Description

                    FileSystem      = $_.FileSystem

                    'Size(GB)'      = '{0:N0}' -f ($_.Size/1GB)

                    'Free(GB)'      = '{0:N0}' -f ($_.FreeSpace/1GB)

                    'Free(%)'       = '{0:N0}' -f ($_.FreeSpace/$_.Size*100)

                    Compressed      = $_.Compressed

                    VolumeName      = $_.VolumeName

                }

                $Result += New-Object -TypeName PSObject -Property $Splatt

            }

        } catch {

            Write-Verbose "Unable to read disk information from computer $Computer"

        }

    }

    $Result | select ComputerName, DriveLetter, 'BlockSize(KB)', 'Size(GB)', 'Free(GB)', 'Free(%)', FileSystem, Compressed, VolumeName, Description

}