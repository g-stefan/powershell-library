# 
#  Library USB Storage Info
# 
#  Copyright (c) 2020-2021 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

function updateUSBHubLabels {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$UsbStorageInfo,
 
	[Parameter(Mandatory=$true, Position=1)]
	$FileCSVLabels,

	[Parameter(Mandatory=$true, Position=2)]
	$FileCSVInfoOutput
)

$hubLabels = Import-Csv -Path $FileCSVLabels

#
# Set info hub label
#

foreach ($key in $UsbStorageInfo.Keys) {
	foreach ($hubInfo in $hubLabels) {
		if($UsbStorageInfo[$key].HubID -eq $hubInfo.HubID) {
			$UsbStorageInfo[$key].Hub = $hubInfo.Label
			break
		}
		if($UsbStorageInfo[$key].HubID -eq $hubInfo.HubID2) {
			$UsbStorageInfo[$key].Hub = $hubInfo.Label
			break
		}
	}
}

$UsbStorageInfo.GetEnumerator() | %{$_.Value} | Export-Csv -Path $FileCSVInfoOutput -NoTypeInformation

$UsbStorageInfo

}

#
#
#

function getUSBHubLabelList {
Param (
	[Parameter(Mandatory=$true, Position=0)]
	$FileCSVLabels
)

$usbHUBList = get-wmiobject -class "Win32_PnPEntity" | where-object {$_.PNPClass -eq "USB"}

$hubLabels = Import-Csv -Path $FileCSVLabels

$usbHubLabel = @()

foreach ($usbHub in $usbHUBList) {
	foreach ($hubInfo in $hubLabels) {
		if($usbHub.PNPDeviceID -eq $hubInfo.HubID) {
			$usbHubLabel += @{
				"HubID" = $hubInfo.HubID;
				"Label" = $hubInfo.Label;
			}
			break
		}
		if($usbHub.PNPDeviceID -eq $hubInfo.HubID2) {
			$usbHubLabel += @{
				"HubID" = $hubInfo.HubID2;
				"Label" = $hubInfo.Label;
			}
			break
		}
	}
}

$usbHubLabel
}

