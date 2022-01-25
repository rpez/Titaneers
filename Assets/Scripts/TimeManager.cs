using System.Collections;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    private bool m_timeScaled;

    private float m_defaultFixedDeltaTime;
    private float m_scaleLength;

    private PostProcessingManager m_PPManager;

    private void Awake()
    {
        m_defaultFixedDeltaTime = Time.fixedDeltaTime;
        m_PPManager = GameObject.Find("Volumes").GetComponent<PostProcessingManager>();
    }

    private void Update()
    {
        if (m_timeScaled)
        {
            Time.timeScale += (1f / m_scaleLength) * Time.unscaledDeltaTime;
            if (Time.timeScale >= 1f)
            {
                m_timeScaled = false;
                Time.timeScale = 1f;
                Time.fixedDeltaTime = m_defaultFixedDeltaTime;
                m_PPManager.SetTimeSlowEffect(false);
            }
        }
    }

    public void ApplyTimeScale(float scale, float length)
    {
        Time.timeScale = scale;
        Time.fixedDeltaTime = Time.timeScale * 0.02f;

        m_scaleLength = length;
        m_timeScaled = true;

        m_PPManager.SetTimeSlowEffect(true);
    }
}
