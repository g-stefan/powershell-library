# 
#  Library Setup API
# 
#  Copyright (c) 2020-2022 Grigore Stefan <g_stefan@yahoo.com>
#  Created by Grigore Stefan <g_stefan@yahoo.com>
# 
#  MIT License (MIT) <http://opensource.org/licenses/MIT>
# 
#  Version 1.0.0 2020-07-09
#

#
# Setup API
#

$cp = New-Object CodeDom.Compiler.CompilerParameters 
$cp.CompilerOptions = "/unsafe"
$null = $cp.ReferencedAssemblies.Add([object].Assembly.Location)
$null = $cp.ReferencedAssemblies.Add([psobject].Assembly.Location)

$null = Add-Type -PassThru -CompilerParameters $cp -TypeDefinition @"
using System;
using System.Text;
using System.Runtime.InteropServices;

namespace SetupAPI {
	public class DeviceManager {

		[DllImport("setupapi.dll", ExactSpelling = true, SetLastError=true, CharSet = CharSet.Unicode)]
		unsafe internal static extern int CM_Locate_DevNodeW(ref int dnDevInst, string pDeviceID, int ulFlags);

		[DllImport("setupapi.dll", SetLastError=true)]
		unsafe internal static extern int CM_Get_Parent(ref int dnDevInstParent, int dnDevInst, int ulFlags);

		[DllImport("setupapi.dll", SetLastError=true)]
		unsafe internal static extern int CM_Get_Device_ID_Size(ref int ulLen, int dnDevInst, int ulFlags);

		[DllImport("setupapi.dll", ExactSpelling = true, SetLastError=true, CharSet = CharSet.Unicode)]
		unsafe internal static extern int CM_Get_Device_IDW(int dnDevInst,IntPtr Buffer, int BufferLen, int ulFlags);

		public static string getParent(string device) {
			int dnDevInst;
			int dnDevInstParent;
			int bufferLen;

			dnDevInst = 0;
			dnDevInstParent = 0;
			bufferLen = 0;

			if(CM_Locate_DevNodeW(ref dnDevInst, device, 0)!=0) {
				return null;
			};
			if(CM_Get_Parent(ref dnDevInstParent, dnDevInst, 0)!=0) {
				return null;
			};
			if(CM_Get_Device_ID_Size(ref bufferLen, dnDevInstParent, 0)!=0) {
				return null;
			};
			IntPtr ptrBuffer = Marshal.AllocHGlobal(bufferLen*2+4);
			if(CM_Get_Device_IDW(dnDevInstParent, ptrBuffer, bufferLen, 0)!=0) {
				Marshal.FreeHGlobal(ptrBuffer);
				return null;
			};
			Marshal.WriteIntPtr(ptrBuffer,bufferLen*2,IntPtr.Zero);
			string parent = Marshal.PtrToStringAuto(ptrBuffer);
			Marshal.FreeHGlobal(ptrBuffer);
			return parent;
		}

	}
}
"@
