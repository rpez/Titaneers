using System.Collections;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    public AnimationCurve m_transitionCurveIn;
    public AnimationCurve m_transitionCurveOut;

    private bool m_inTransition;
    private bool m_outTransition;

    private float m_targetScale;
    private float m_defaultFixedDeltaTime;

    private PostProcessingManager m_PPManager;

    private float m_currentTime;

    private void Awake()
    {
        m_defaultFixedDeltaTime = Time.fixedDeltaTime;
        m_PPManager = GameObject.Find("Volumes").GetComponent<PostProcessingManager>();
    }

    private void Update()
    {
        m_currentTime += Time.unscaledDeltaTime;

        if (m_inTransition)
        {
            float amount = m_transitionCurveIn.Evaluate(m_currentTime);
            Time.timeScale = 1f + amount * (m_targetScale - 1f);
            Time.fixedDeltaTime = Time.timeScale * 0.02f;
            m_PPManager.SetTimeSlowEffectWeight(amount);

            if (Time.timeScale <= m_targetScale)
            {
                m_inTransition = false;
                Time.timeScale = m_targetScale;
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
            }
        }
        if (m_outTransition)
        {
            float amount = m_transitionCurveOut.Evaluate(m_currentTime);
            Time.timeScale = amount;
            Time.fixedDeltaTime = Time.timeScale * 0.02f;
            m_PPManager.SetTimeSlowEffectWeight(1f - amount);

            if (Time.timeScale >= 1f)
            {
                m_outTransition = false;
                Time.timeScale = 1f;
                Time.fixedDeltaTime = m_defaultFixedDeltaTime;
                
            }
        }
    }

    public void ToggleTimeScale(float scale, bool active)
    {
        m_inTransition = active;
        m_outTransition = !m_inTransition;
        m_targetScale = scale;

        m_currentTime = 0;
    }
}
