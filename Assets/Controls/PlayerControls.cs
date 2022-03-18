//------------------------------------------------------------------------------
// <auto-generated>
//     This code was auto-generated by com.unity.inputsystem:InputActionCodeGenerator
//     version 1.1.1
//     from Assets/Controls/PlayerControls.inputactions
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public partial class @PlayerControls : IInputActionCollection2, IDisposable
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
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Jump"",
                    ""type"": ""Button"",
                    ""id"": ""60962344-76d4-45c9-b454-f27be304440d"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Crouch"",
                    ""type"": ""Button"",
                    ""id"": ""ba96a410-53a2-4616-a735-febd2ce4f138"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Booster"",
                    ""type"": ""Button"",
                    ""id"": ""59d4ba46-ac8d-4d7a-a6cb-1bb656d92998"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""TimeSlow"",
                    ""type"": ""Button"",
                    ""id"": ""7c2d1c78-2fdf-40c7-9356-732393b0a53e"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Fire"",
                    ""type"": ""Button"",
                    ""id"": ""68f19d12-07e8-4b29-bb8e-6d138d98b16b"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Grappling"",
                    ""type"": ""Button"",
                    ""id"": ""601555d3-2a47-4c80-87ca-d669a4e96fea"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Zoom"",
                    ""type"": ""PassThrough"",
                    ""id"": ""3caa9df3-4b9f-4fae-8da9-6e89ba2e6bac"",
                    ""expectedControlType"": ""Axis"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
                },
                {
                    ""name"": ""Restart"",
                    ""type"": ""Button"",
                    ""id"": ""e4b5efce-1bea-4549-bf69-7b542ea34dce"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """",
                    ""initialStateCheck"": false
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
                    ""groups"": """",
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
                    ""groups"": """",
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
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""98b9441b-3436-4914-ab4c-0829e367c20b"",
                    ""path"": ""<Keyboard>/f"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""TimeSlow"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""e7e014c5-9fde-402d-9abc-e4fb4565c269"",
                    ""path"": ""<Keyboard>/leftCtrl"",
                    ""interactions"": ""Press(behavior=2)"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Crouch"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""fb0d44aa-65d2-48f1-92c9-4d1121d25bbb"",
                    ""path"": ""<Keyboard>/leftShift"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Booster"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""23f0332e-be81-4eb9-9fa3-2c1c366bd541"",
                    ""path"": ""<Mouse>/leftButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Fire"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""bf76bb2e-323f-4fdb-838c-5ababcc63e68"",
                    ""path"": ""<Mouse>/rightButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Grappling"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""966a49b6-b03f-4990-b056-c4cdc4634a43"",
                    ""path"": ""<Mouse>/scroll/y"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Zoom"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""ed4e2a93-14ef-412b-bb96-92ea8bc5628b"",
                    ""path"": ""<Keyboard>/r"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Restart"",
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
        m_GroundMovement_Crouch = m_GroundMovement.FindAction("Crouch", throwIfNotFound: true);
        m_GroundMovement_Booster = m_GroundMovement.FindAction("Booster", throwIfNotFound: true);
        m_GroundMovement_TimeSlow = m_GroundMovement.FindAction("TimeSlow", throwIfNotFound: true);
        m_GroundMovement_Fire = m_GroundMovement.FindAction("Fire", throwIfNotFound: true);
        m_GroundMovement_Grappling = m_GroundMovement.FindAction("Grappling", throwIfNotFound: true);
        m_GroundMovement_Zoom = m_GroundMovement.FindAction("Zoom", throwIfNotFound: true);
        m_GroundMovement_Restart = m_GroundMovement.FindAction("Restart", throwIfNotFound: true);
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
    public IEnumerable<InputBinding> bindings => asset.bindings;

    public InputAction FindAction(string actionNameOrId, bool throwIfNotFound = false)
    {
        return asset.FindAction(actionNameOrId, throwIfNotFound);
    }
    public int FindBinding(InputBinding bindingMask, out InputAction action)
    {
        return asset.FindBinding(bindingMask, out action);
    }

    // GroundMovement
    private readonly InputActionMap m_GroundMovement;
    private IGroundMovementActions m_GroundMovementActionsCallbackInterface;
    private readonly InputAction m_GroundMovement_Move;
    private readonly InputAction m_GroundMovement_Jump;
    private readonly InputAction m_GroundMovement_Crouch;
    private readonly InputAction m_GroundMovement_Booster;
    private readonly InputAction m_GroundMovement_TimeSlow;
    private readonly InputAction m_GroundMovement_Fire;
    private readonly InputAction m_GroundMovement_Grappling;
    private readonly InputAction m_GroundMovement_Zoom;
    private readonly InputAction m_GroundMovement_Restart;
    public struct GroundMovementActions
    {
        private @PlayerControls m_Wrapper;
        public GroundMovementActions(@PlayerControls wrapper) { m_Wrapper = wrapper; }
        public InputAction @Move => m_Wrapper.m_GroundMovement_Move;
        public InputAction @Jump => m_Wrapper.m_GroundMovement_Jump;
        public InputAction @Crouch => m_Wrapper.m_GroundMovement_Crouch;
        public InputAction @Booster => m_Wrapper.m_GroundMovement_Booster;
        public InputAction @TimeSlow => m_Wrapper.m_GroundMovement_TimeSlow;
        public InputAction @Fire => m_Wrapper.m_GroundMovement_Fire;
        public InputAction @Grappling => m_Wrapper.m_GroundMovement_Grappling;
        public InputAction @Zoom => m_Wrapper.m_GroundMovement_Zoom;
        public InputAction @Restart => m_Wrapper.m_GroundMovement_Restart;
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
                @Crouch.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnCrouch;
                @Crouch.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnCrouch;
                @Crouch.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnCrouch;
                @Booster.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnBooster;
                @Booster.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnBooster;
                @Booster.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnBooster;
                @TimeSlow.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnTimeSlow;
                @TimeSlow.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnTimeSlow;
                @TimeSlow.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnTimeSlow;
                @Fire.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnFire;
                @Fire.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnFire;
                @Fire.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnFire;
                @Grappling.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnGrappling;
                @Grappling.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnGrappling;
                @Grappling.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnGrappling;
                @Zoom.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnZoom;
                @Zoom.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnZoom;
                @Zoom.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnZoom;
                @Restart.started -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnRestart;
                @Restart.performed -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnRestart;
                @Restart.canceled -= m_Wrapper.m_GroundMovementActionsCallbackInterface.OnRestart;
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
                @Crouch.started += instance.OnCrouch;
                @Crouch.performed += instance.OnCrouch;
                @Crouch.canceled += instance.OnCrouch;
                @Booster.started += instance.OnBooster;
                @Booster.performed += instance.OnBooster;
                @Booster.canceled += instance.OnBooster;
                @TimeSlow.started += instance.OnTimeSlow;
                @TimeSlow.performed += instance.OnTimeSlow;
                @TimeSlow.canceled += instance.OnTimeSlow;
                @Fire.started += instance.OnFire;
                @Fire.performed += instance.OnFire;
                @Fire.canceled += instance.OnFire;
                @Grappling.started += instance.OnGrappling;
                @Grappling.performed += instance.OnGrappling;
                @Grappling.canceled += instance.OnGrappling;
                @Zoom.started += instance.OnZoom;
                @Zoom.performed += instance.OnZoom;
                @Zoom.canceled += instance.OnZoom;
                @Restart.started += instance.OnRestart;
                @Restart.performed += instance.OnRestart;
                @Restart.canceled += instance.OnRestart;
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
        void OnCrouch(InputAction.CallbackContext context);
        void OnBooster(InputAction.CallbackContext context);
        void OnTimeSlow(InputAction.CallbackContext context);
        void OnFire(InputAction.CallbackContext context);
        void OnGrappling(InputAction.CallbackContext context);
        void OnZoom(InputAction.CallbackContext context);
        void OnRestart(InputAction.CallbackContext context);
    }
}
