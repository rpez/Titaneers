// GENERATED AUTOMATICALLY FROM 'Assets/PlayerControls.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @PlayerControls : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @PlayerControls()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""PlayerControls"",
    ""maps"": [
        {
            ""name"": ""GroundMovement"",
            ""id"": ""471df96e-16a5-4f22-9b84-5c2fd124ba7f"",
            ""actions"": [
                {
                    ""name"": ""Move"",
                    ""type"": ""PassThrough"",
                    ""id"": ""e154679e-22c2-46e6-9370-d2888e345813"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Jump"",
                    ""type"": ""Button"",
                    ""id"": ""60962344-76d4-45c9-b454-f27be304440d"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""2D Vector"",
                    ""id"": ""9592b7f5-9926-4c94-a53c-e1463d68b74e"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""27e77f5b-e737-42fe-aadf-f1c852f01d62"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""controls"",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""cdfa7835-a6e0-4c3b-a4d9-060044e8a9e4"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""e43adf6d-b8a8-4c2e-9112-72a77df0a258"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""controls"",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""1064148d-c56b-4cf7-b269-a47a54a9a822"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Move"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""6ce51457-52f9-4048-ac0d-e2f50b887c14"",
                    ""path"": ""<Keyboard>/space"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""controls"",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": [
        {
            ""name"": ""controls"",
            ""bindingGroup"": ""controls"",
            ""devices"": [
                {
                    ""devicePath"": ""<Keyboard>"",
                    ""isOptional"": false,
                    ""isOR"": false
                },
                {
                    ""devicePath"": ""<Mouse>"",
                    ""isOptional"": false,
                    ""isOR"": false
                }
            ]
        }
    ]
}");
        // GroundMovement
        m_GroundMovement = asset.FindActionMap("GroundMovement", throwIfNotFound: true);
        m_GroundMovement_Move = m_GroundMovement.FindAction("Move", throwIfNotFound: true);
        m_GroundMovement_Jump = m_GroundMovement.FindAction("Jump", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // GroundMovement
    private readonly InputActionMap m_GroundMovement;
    private IGroundMovementActions m_GroundMovementActionsCallbackInterface;
    private readonly InputAction m_GroundMovement_Move;
    private readonly InputAction m_GroundMovement_Jump;
    public struct GroundMovementActions
    {
        private @PlayerControls m_Wrapper;
        public GroundMovementActions(@PlayerControls wrapper) { m_Wrapper = wrapper; }
        public InputAction @Move => m_Wrapper.m_GroundMovement_Move;
        public InputAction @Jump => m_Wrapper.m_GroundMovement_Jump;
        public InputActionMap Get() { return m_Wrapper.m_GroundMovement; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(GroundMovementActions set) { return set.Get(); }
        public void SetCallbacks(IGroundMovementActions instance)
        {
            if (m_Wrapper.m_GroundMovementActionsCallbackInterface != null)
            {
                @Move.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnMove;
                @Move.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnMove;
                @Move.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnMove;
                @Jump.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnJump;
                @Jump.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnJump;
                @Jump.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnJump;
            }
            m_Wrapper.m_GroundMovementActionsCallbackInterface = instance;
            if (instance != null)
            {
                @Move.started += instance.OnMove;
                @Move.performed += instance.OnMove;
                @Move.canceled += instance.OnMove;
                @Jump.started += instance.OnJump;
                @Jump.performed += instance.OnJump;
                @Jump.canceled += instance.OnJump;
            }
        }
    }
    public GroundMovementActions @GroundMovement => new GroundMovementActions(this);
    private int m_controlsSchemeIndex = -1;
    public InputControlScheme controlsScheme
    {
        get
        {
            if (m_controlsSchemeIndex == -1) m_controlsSchemeIndex = asset.FindControlSchemeIndex("controls");
            return asset.controlSchemes[m_controlsSchemeIndex];
        }
    }
    public interface IGroundMovementActions
    {
        void OnMove(InputAction.CallbackContext context);
        void OnJump(InputAction.CallbackContext context);
    }
}
