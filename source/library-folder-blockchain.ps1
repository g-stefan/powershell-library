# 
#  Library Folder Blockchain
# 
#  Copyright (c) 2020-2022 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

function folderGetFileList($Folder, $BaseFolder) {

	$retV = New-Object -TypeName "System.Collections.ArrayList"

	foreach ($item in Get-ChildItem $Folder) {

		$fileOrFolder = @{
			"Name" = $item.FullName.substring($BaseFolder.length + 1);
			"Length" = $item.Length;
			"Type" = (&{If(Test-Path $item.FullName -PathType Container) {"Directory"} Else {"File"}})
			"Items" = $null
		}

		if (Test-Path $item.FullName -PathType Container) {
			$fileOrFolder.Items = folderGetFileList $item.FullName $BaseFolder
		}

		$retV += $fileOrFolder

	}

	$retV
} 

function hashTableToString($hashTable, $keyList) {

	$retV = "@{";
	foreach ($key in $keyList) {
		$retV += '"' + $key + '"="' + $hashTable[$key] +'";'
	}
	$retV += "}"

	$retV
}

function sha512String($value) {
	$stringAsStream = [System.IO.MemoryStream]::new()
	$writer = [System.IO.StreamWriter]::new($stringAsStream)
	$writer.write($value)
	$writer.Flush()
	$stringAsStream.Position = 0
	$hash = Get-FileHash -Algorithm SHA512 -InputStream $stringAsStream
	$hash.Hash
}

function sha512File($file) {
	$hash = Get-FileHash -Algorithm SHA512 -Path $file
	$hash.Hash
}

function generateBlockchainBranchHash($blockChain) {

	$branch = New-Object -TypeName "System.Collections.ArrayList"

	foreach($leaf in $blockChain) {
		$leafInfo = $leaf.ChainLink + ":" + $leaf.Branch
		$branch += sha512String $leafInfo
	}

	$leafList = $branch | Sort-Object -CaseSensitive

	$branchHash = ""

	foreach($item in $leafList) {
		$branchHash += ":" + $item
		$branchHash = sha512String $branchHash
	}

	$branchHash		
}

function generateBlockchain($fileAndFolderList) {

	$retV = New-Object -TypeName "System.Collections.ArrayList"

	foreach ($item in $fileAndFolderList) {

		$itemInfo = hashTableToString $item @("Name","Length","Type")
		$itemInfoSHA512 = sha512String $itemInfo
		$itemFileSHA512 = ""
		if($item.Type -eq "File") {
			$itemFileSHA512 = sha512File ($Folder + "\" + $item.Name)
		}
		$chainLinkInfo = $itemInfoSHA512 + ":" + $itemFileSHA512
		$chainLinkSHA512 = sha512String $chainLinkInfo

		$chainLink = @{
			"Name" = $item.Name;
			"Length" = $item.Length;
			"Type" = $item.Type;
			"Items" = $null;
			"ChainLink" = $chainLinkSHA512;
			"Branch" = "";
		}

		if($item.Type -eq "Directory") {
			$chainLink.Items = generateBlockchain $item.Items
			$chainLink.Branch = generateBlockchainBranchHash $chainLink.Items
		}

		$retV += $chainLink
	}

	$retV
}

function generateFolderBlockchain {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$Folder
)

$folderPath = Resolve-Path $Folder
$baseFolder = ("" + $folderPath)
if($baseFolder[-1] -eq "\") {
	$baseFolder = $baseFolder.substring(0,$baseFolder.length - 1)
}

$fileAndFolderList = folderGetFileList (""+$folderPath) (""+$baseFolder)

$blockChain = @{
	"Items" = generateBlockchain($fileAndFolderList)
	"BlockChain" = ""
}

$blockChain.BlockChain = generateBlockchainBranchHash $blockChain.Items

$blockChain
}
