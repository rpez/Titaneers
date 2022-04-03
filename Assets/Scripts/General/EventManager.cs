using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventManager : MonoBehaviour
{
    public static event Action<float> FreezeFrame;
    public static void OnFreezeFrame(float time) => FreezeFrame?.Invoke(time);
}
