using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetShaderCenter : MonoBehaviour
{
    public Material rainbowMaterial;

	// Update is called once per frame
	void Update ()
    {
        rainbowMaterial.SetVector("_Center", transform.position);
	}
}
