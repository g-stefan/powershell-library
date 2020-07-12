# 
#  Library USB Storage Info
# 
#  Copyright (c) 2020 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

. $PSScriptRoot\library-setup-api.ps1

function getUSBSticksInfo {

#
# Get Device List
#

$usbstorDeviceList = get-wmiobject -class "Win32_USBControllerDevice" | %{[wmi]($_.Dependent)} | where-object {$_.Service -eq "USBSTOR"}
$diskList = get-wmiobject -class "Win32_USBControllerDevice" | %{[wmi]($_.Dependent)} | where-object {$_.PNPClass -eq "DiskDrive"}

$usbStorageInfo=@{}

foreach ($usbstorDevice in $usbstorDeviceList) {
	$deviceID = $usbstorDevice.PNPDeviceID
	$deviceLocation = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\$deviceID" -Name LocationInformation -ErrorAction SilentlyContinue
	if($deviceLocation) {
		$serialNumber = ($deviceID -split "\\")[-1]
		foreach ($disk in $diskList) {
			if($disk.PNPDeviceID.Contains($serialNumber)) {
				$deviceLocationInfo = ($deviceLocation.LocationInformation -split "\.")
				$portNumber = ($deviceLocationInfo[0] -split "#")[1] -as [int]
				$hubNumber = ($deviceLocationInfo[1] -split "#")[1] -as [int]
				$parentID = [SetupAPI.DeviceManager]::getParent($disk.PNPDeviceID)
				if($parentID) {
					$parentHUBID = [SetupAPI.DeviceManager]::getParent($parentID)
					if($parentHUBID) {
						$info = new-object -typename psobject -property @{
							"Name" = $disk.Name;
							"SerialNumber" = $serialNumber;
							"PNPDeviceID" = $disk.PNPDeviceID;
							"HubNumber" = $hubNumber;
							"HubPort" = $portNumber;
							"HubID" = $parentHUBID;
							"Hub" = "Unknown";
							"DeviceID" = "Unknwon";
							"DriveLetter" = "Unknwon";
						}
						$usbStorageInfo.Add($disk.PNPDeviceID, $info)
					}
				}
			}
		}
	}
}

#
# Set Drive Info
#

$diskList = get-wmiobject -class "Win32_DiskDrive" | Select-Object –Property * | where-object {$_.InterfaceType -eq "USB"}
foreach ($disk in $diskList) {
	foreach ($key in $usbStorageInfo.Keys) {
		if($usbStorageInfo[$key].PNPDeviceID -eq $disk.PNPDeviceID) {
			$usbStorageInfo[$key].DeviceID = $disk.DeviceID
		}
	}
}

#
# Set Drive Letter
#

$logicalDiskList = get-wmiobject -class "Win32_LogicalDisk"
foreach ($logicalDisk in $logicalDiskList) {
	$deviceID = $logicalDisk.GetRelated("Win32_DiskPartition").GetRelated("Win32_DiskDrive").DeviceID
	foreach ($key in $usbStorageInfo.Keys) {
		if($usbStorageInfo[$key].DeviceID -eq $deviceID) {
			$usbStorageInfo[$key].DriveLetter = $logicalDisk.DeviceID
		}
	}
}

#
#
#

$usbStorageInfo

}

#
#
#
