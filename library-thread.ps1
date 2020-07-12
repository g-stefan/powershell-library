# 
#  Library Thread
# 
#  Copyright (c) 2020 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

$null = Add-Type -PassThru -TypeDefinition @"
using System;
using System.Threading;
using System.Text;
using System.Runtime.InteropServices;

namespace Library {
	public class Thread {

		public static void SleepMilliseconds(int millisecondsTimeout) {
			System.Threading.Thread.Sleep(millisecondsTimeout);
		}

	}
}
"@

$threadInfoIndicator = @("|","/","-","\")

function sleepWithInfoAndCode {

Param (
	[Parameter(Mandatory=$true, Position=0)]
	$message,

	[Parameter(Mandatory=$true, Position=1)]
	$seconds,

	[Parameter(Mandatory=$true, Position=2)]
	$speed,

	[parameter(Mandatory=$true, Position=3)]
	$scriptblock
)

	$count = $seconds*$speed-1;
	$milliSeconds = [int](1000/$speed)

	for($index = 0; $index -lt $count; ++$index) {

		Invoke-Command -ScriptBlock $scriptblock

		write-host -NoNewline -ForegroundColor WHITE "`r"
		write-host -NoNewline -ForegroundColor WHITE $message
		write-host -NoNewline -ForegroundColor WHITE " "
		write-host -NoNewline -ForegroundColor BLUE $threadInfoIndicator[$index % $threadInfoIndicator.length]
		write-host -NoNewline -ForegroundColor WHITE " " ("" + ([int]($index / $speed)+1) + "/" + $seconds)

		[Library.Thread]::SleepMilliseconds($milliSeconds)
	}

	write-host -NoNewline -ForegroundColor WHITE "`r"
	write-host -NoNewline -ForegroundColor WHITE (" " * 32)
	write-host -NoNewline -ForegroundColor WHITE "`r"
}

