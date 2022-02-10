using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FSM : MonoBehaviour
{
    //Editable Parameter
    [SerializeField]
    private State[] states;

    [SerializeField]
    private bool[] conditions;

    [SerializeField]
    private int defaultState;//index

    [System.Serializable]
    private struct Transition
    {
        public int startState;//index
        public int targetState;//index
        public int[] conditions;//indexs
    }

    [SerializeField]
    private Transition[] transitions;

    //Running Parameter
    private int currentState;//index

    private void Update()
    {
        //Behavior
        states[currentState].Behavior();
        
        //Transition
        for(int i=0;i<transitions.Length;i++)
        {
            if(transitions[i].startState==currentState&&Satisified(transitions[i].conditions))
            {
                states[currentState].Exit();
                currentState = transitions[i].targetState;
                states[currentState].Enter();
                break;
            }
        }
    }

    private void FixedUpdate()
    {
        //Physical Behavior
        states[currentState].PhysicalBehavior();
    }

    private bool Satisified(int[] condIndexs)
    {
        for (int i = 0; i < condIndexs.Length; i++)
        {
            if (!conditions[condIndexs[i]]) 
                return false;
        }
        return true;
    }
}
