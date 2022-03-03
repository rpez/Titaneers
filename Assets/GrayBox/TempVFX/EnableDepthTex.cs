using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class EnableDepthTex : MonoBehaviour
{
    private void OnEnable()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }
}
