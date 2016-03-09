using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class iOSKeyboardPatch
{
#if (UNITY_IOS || UNITY_IPHONE) && !UNITY_EDITOR
	[DllImport("__Internal")]
	private static extern void _iOSKeyboardPatch_apply();
	[DllImport("__Internal")]
	private static extern void _iOSKeyboardPatch_revert();
#endif

	public static void Apply()
	{
#if (UNITY_IOS || UNITY_IPHONE) && !UNITY_EDITOR
		_iOSKeyboardPatch_apply();
#endif
	}

	public static void Revert()
	{
#if (UNITY_IOS || UNITY_IPHONE) && !UNITY_EDITOR
		_iOSKeyboardPatch_revert();
#endif
	}
}