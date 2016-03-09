using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class Example : MonoBehaviour {

	[SerializeField] private InputField inputField;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void OnChangeMultiLine(bool isOn) {
		if(isOn) {
			inputField.lineType = InputField.LineType.MultiLineNewline;
		} else {
			inputField.lineType = InputField.LineType.SingleLine;
		}
	}

	public void OnPressApplyButton() {
		iOSKeyboardPatch.Apply();
	}

	public void OnPressRevertButton() {
		iOSKeyboardPatch.Revert();
	}
}
