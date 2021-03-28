# 
#  Library Folder
# 
#  Copyright (c) 2020-2021 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

function folderGetDirectoryListFullNameOneLevelInternal($Folder) {

	$retV = New-Object -TypeName "System.Collections.ArrayList"

	foreach ($item in Get-ChildItem $Folder) {
		if (Test-Path $item.FullName -PathType Container) {
			$retV += $item.FullName
		}
	}

	$retV
} 

function folderGetDirectoryListFullNameOneLevel {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$Folder
)

$folderPath = Resolve-Path $Folder

folderGetDirectoryListFullNameOneLevelInternal (""+$folderPath)
}

#
#
#

function folderIsEmpty {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$Folder
)

$count = 0
foreach ($item in Get-ChildItem (Resolve-Path $Folder)) {
	++$count	
}

($count -eq 0)
}

#
#
#

function folderGetDirectoryListFullNameTwoLevel {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$Folder
)

$folderPath = Resolve-Path $Folder

$folderList = folderGetDirectoryListFullNameOneLevelInternal (""+$folderPath)
$retV = @()
foreach($scan in $folderList) {
	$folderScan = folderGetDirectoryListFullNameOneLevelInternal $scan
	foreach($path in $folderScan) {
		$retV += $path
	}
}

$retV
}

#
#
#
