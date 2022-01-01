# 
#  Library String
# 
#  Copyright (c) 2020-2022 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

function centerString($value, $size) {
	if($value.length -gt $size) {
		$value
		return
	}
	
	((" "*([int]($size/2-$value.length/2)))+$value).PadRight($size," ")
}
