/*
    MIT License

    Copyright (c) 2020 DaniDevy

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

// Some stupid rigidbody based movement by Dani
// Modified by rpez 2022

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{

    [Header("Assign in editor")]
    public Transform PlayerCamera;
    public Transform Orientation;
    public GameObject PlayerAvatar;
    public Animator Animator;
    public GrapplingGun Grapple;

    [Header("Layers")]
    public LayerMask GroundLayer;

    [Header("Movement")]
    public float MouseSensitivity = 3;
    public float MoveSpeed = 4500;
    public float MaxSpeed = 20;
    public float CounterMovementForce = 0.175f;
    public float MaxSlopeAngle = 35f;

    [Header("Sliding")]
    public float SlideLandingBoost = 10f;
    public float SlideForce = 400;
    public float SlideCounterMovement = 0.2f;

    [Header("Dashing")]
    public float DashStrength = 20f;
    public float DashTime = 0.3f;
    public float DashSpeedBoost = 2f;
    public int MaxDashCharges = 2;
    public float DashCooldown = 3f;

    [Header("Jumping")]
    public float JumpForce = 550f;
    public float AirResistance = 0.1f;

    [Header("Time slow")]
    public float SlowAmount = 0.1f;

    // Player state booleans
    private bool _grounded;
    private bool _readyToJump = true;
    private bool _slowTime;
    private bool _jumping, _sprinting, _crouching, _dashing;

    // Other references
    private Rigidbody _rigidbody;
    private TimeManager _timeManager;
    private CapsuleCollider _collider;

    // Other variables
    private PlayerControls _controls;
    private PlayerControls.GroundMovementActions _controlMapping;
    private Vector2 _horizontalInput;
    private float _xInput, _yInput;
    private float _xRotation;
    private float _minMovementThreshold = 0.1f;
    private float _targetXRotation;

    private int _currentDashCharges;
    private float _currentDashCdTime;
    private Vector3 _dashDirection;

    private float _jumpCooldown = 0.25f;

    private float _crouchHeight = 1f;
    private float _playerHeight;
    private Vector3 _crouchCameraOffset = new Vector3(0f, -1f, 0f);
    private Vector3 _crouchCameraPosition;
    private Vector3 _defaultCameraPostion;

    private Vector3 _normalVector = Vector3.up;
    private Vector3 _wallNormalVector;

    private Coroutine _groundCancel;

    // Collects the floor surfaces touched last frame, used for detecting from which surface player jumps/falls
    private List<GameObject> _floorContactsLastFrame = new List<GameObject>();

    private void OnEnable()
    {
        _controls.Enable();
    }

    private void OnDestroy()
    {
        _controls.Disable();
    }

    void Awake()
    {
        _controls = new PlayerControls();
        _controlMapping = _controls.GroundMovement;
        _rigidbody = GetComponent<Rigidbody>();
    }

    void Start()
    {
        _collider = GetComponent<CapsuleCollider>();
        _playerHeight = _collider.height;
        _defaultCameraPostion = PlayerCamera.localPosition;
        _crouchCameraPosition = _defaultCameraPostion - _crouchCameraOffset;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        _timeManager = GameObject.Find("TimeManager").GetComponent<TimeManager>();
        _currentDashCharges = MaxDashCharges;
    }


    private void FixedUpdate()
    {
        Movement();
    }

    private void Update()
    {
        MyInput();
        Look();
        Animate();
    }

    /// <summary>
    /// Find user input. Should put this in its own class but im lazy
    /// </summary>
    private void MyInput()
    {
        _controlMapping.Move.performed += context => _horizontalInput = context.ReadValue<Vector2>();
        _xInput = _horizontalInput.x;
        _yInput = _horizontalInput.y;
        _controlMapping.Jump.performed += _ => _jumping = true;
        _controlMapping.Dash.performed += _ =>
        {
            if (!_dashing) StartCoroutine(Dash());
        };
        _controlMapping.TimeSlow.performed += _ =>
        {
            _slowTime = !_slowTime;
            _timeManager.ToggleTimeScale(SlowAmount, _slowTime);
        };
        _controlMapping.Crouch.performed += _ => _crouching = true;

        //Crouching
        if (_controlMapping.Crouch.WasPressedThisFrame())
            StartCrouch();
        if (_controlMapping.Crouch.WasReleasedThisFrame())
            StopCrouch();
    }

    private void StartCrouch()
    {
        _collider.height = _crouchHeight;
        PlayerCamera.localPosition = _crouchCameraPosition;
        //transform.position = new Vector3(transform.position.x, transform.position.y - 0.5f, transform.position.z);
        if (_rigidbody.velocity.magnitude > 0.5f)
        {
            if (_grounded)
            {
                _rigidbody.AddForce(Orientation.transform.forward * SlideForce);
            }
        }
    }

    private void StopCrouch()
    {
        _collider.height = _playerHeight;
        PlayerCamera.localPosition = _defaultCameraPostion;
        _crouching = false;
        transform.position = new Vector3(transform.position.x, transform.position.y + 0.5f, transform.position.z);
    }

    private void Movement()
    {

        //Extra gravity
        _rigidbody.AddForce(Vector3.down * Time.deltaTime * 10);

        //Find actual velocity relative to where player is looking
        Vector2 mag = FindVelRelativeToLook();
        float xMag = mag.x, yMag = mag.y;

        //Counteract sliding and sloppy movement
        CounterMovement(_xInput, _yInput, mag);

        //If holding jump && ready to jump, then jump
        if (_readyToJump && _jumping) Jump();

        //Set max speed
        float maxSpeed = this.MaxSpeed;

        if (_dashing)
        {
            transform.Translate(_dashDirection * DashStrength * Time.unscaledDeltaTime);
        }
        else
        {
            //If speed is larger than maxspeed, cancel out the input so you don't go over max speed
            if (_xInput > 0 && xMag > maxSpeed) _xInput = 0;
            if (_xInput < 0 && xMag < -maxSpeed) _xInput = 0;
            if (_yInput > 0 && yMag > maxSpeed) _yInput = 0;
            if (_yInput < 0 && yMag < -maxSpeed) _yInput = 0;

            //Some multipliers
            float multiplier = 1f, multiplierV = 1f;

            // Movement in air
            if (!_grounded)
            {
                multiplier = 0.5f;
                multiplierV = 0.5f;
            }

            // Movement while sliding
            if (_grounded && _crouching) multiplierV = 0f;

            //Apply forces to move player
            _rigidbody.AddForce(Orientation.transform.forward * _yInput * MoveSpeed * Time.deltaTime * multiplier * multiplierV);
            _rigidbody.AddForce(Orientation.transform.right * _xInput * MoveSpeed * Time.deltaTime * multiplier);
        }

        //If sliding down a ramp, add force down so player stays grounded and also builds speed
        if (_crouching && _grounded && _readyToJump)
        {
            _rigidbody.AddForce(Vector3.down * Time.deltaTime * 3000);
            return;
        }

        if (_currentDashCharges < MaxDashCharges)
        {
            _currentDashCdTime += Time.deltaTime;
            if (_currentDashCdTime >= DashCooldown)
            {
                _currentDashCharges += 1;
                _currentDashCdTime = 0;
            }
        }
    }

    private void Jump()
    {
        if (_grounded && _readyToJump)
        {
            _readyToJump = false;

            //Add jump forces
            _rigidbody.AddForce(Vector2.up * JumpForce * 1.5f);
            _rigidbody.AddForce(_normalVector * JumpForce * 0.5f);

            //If jumping while falling, reset y velocity.
            Vector3 vel = _rigidbody.velocity;
            if (_rigidbody.velocity.y < 0.5f)
                _rigidbody.velocity = new Vector3(vel.x, 0, vel.z);
            else if (_rigidbody.velocity.y > 0)
                _rigidbody.velocity = new Vector3(vel.x, vel.y / 2, vel.z);

            Invoke(nameof(ResetJump), _jumpCooldown);
        }
    }

    private IEnumerator Dash()
    {
        if (_currentDashCharges > 0)
        {
            _xInput = _horizontalInput.x;
            _yInput = _horizontalInput.y;

            _dashDirection = Orientation.transform.forward * _yInput + Orientation.transform.right * _xInput;
            if (_dashDirection.magnitude < 0.01f)
            {
                yield break; // Workaround fix because sometimes the input is 0 for whatever reason
            }

            _dashing = true;
            _currentDashCharges--;

            Vector3 vel = _rigidbody.velocity;
            _rigidbody.velocity = Vector3.zero;
            _rigidbody.useGravity = false;
            _dashDirection.Normalize();
            float angle = Vector3.Angle(_dashDirection, vel);

            yield return new WaitForSecondsRealtime(DashTime * Time.unscaledDeltaTime);

            _dashing = false;
            // Keep momentum if dash is towards relatively same direction
            _rigidbody.velocity = angle <= 100f ? vel : Vector3.zero;
            _rigidbody.AddForce(_dashDirection * DashSpeedBoost, ForceMode.Impulse);
            _rigidbody.useGravity = true;
        }
    }

    private void ResetJump()
    {
        _readyToJump = true;
    }

    private void Look()
    {
        float mouseX = 0, mouseY = 0;

        if (Mouse.current != null)
        {
            var delta = Mouse.current.delta.ReadValue();// / 15.0f;
            mouseX += delta.x;
            mouseY += delta.y;
        }

        mouseX *= MouseSensitivity * Time.unscaledDeltaTime;
        mouseY *= MouseSensitivity * Time.unscaledDeltaTime;

        //Find current look rotation
        Vector3 rot = PlayerCamera.transform.localRotation.eulerAngles;
        _targetXRotation = rot.y + mouseX;

        //Rotate, and also make sure we dont over- or under-rotate.
        _xRotation -= mouseY;
        _xRotation = Mathf.Clamp(_xRotation, -90f, 90f);

        //Perform the rotations
        PlayerCamera.transform.localRotation = Quaternion.Euler(_xRotation, _targetXRotation, 0);
        Orientation.transform.localRotation = Quaternion.Euler(0, _targetXRotation, 0);
    }

    private void CounterMovement(float x, float y, Vector2 mag)
    {
        // If dashing, no forces affect the player
        if (_dashing) return;

        // If airborne
        if (!_grounded || _jumping)
        {
            float horizontalSpeed = new Vector3(_rigidbody.velocity.x, 0f, _rigidbody.velocity.z).magnitude;
            if (!Grapple.IsGrappling() && horizontalSpeed >= _minMovementThreshold)
            {
                Vector3 vecx = new Vector3(-_rigidbody.velocity.x, 0f, -_rigidbody.velocity.z) * AirResistance;
                _rigidbody.AddForce(vecx);
            }

            return;
        }

        // Slow down sliding
        if (_crouching)
        {
            _rigidbody.AddForce(MoveSpeed * Time.deltaTime * -_rigidbody.velocity.normalized * SlideCounterMovement);
            return;
        }

        // Counter movement
        if (Math.Abs(mag.x) > _minMovementThreshold && Math.Abs(x) < 0.05f
            || (mag.x < -_minMovementThreshold && x > 0) || (mag.x > _minMovementThreshold && x < 0))
        {
            _rigidbody.AddForce(MoveSpeed * Orientation.transform.right * Time.deltaTime * -mag.x * CounterMovementForce);
        }
        if (Math.Abs(mag.y) > _minMovementThreshold && Math.Abs(y) < 0.05f
            || (mag.y < -_minMovementThreshold && y > 0) || (mag.y > _minMovementThreshold && y < 0))
        {
            _rigidbody.AddForce(MoveSpeed * Orientation.transform.forward * Time.deltaTime * -mag.y * CounterMovementForce);
        }

        // Limit diagonal running. This will also cause a full stop if sliding fast and un-crouching, so not optimal.
        if (Mathf.Sqrt((Mathf.Pow(_rigidbody.velocity.x, 2) + Mathf.Pow(_rigidbody.velocity.z, 2))) > MaxSpeed)
        {
            float fallspeed = _rigidbody.velocity.y;
            Vector3 n = _rigidbody.velocity.normalized * MaxSpeed;
            _rigidbody.velocity = new Vector3(n.x, fallspeed, n.z);
        }
    }

    private void Animate()
    {
        if (_rigidbody.velocity.magnitude > 0.1f && _grounded)
        {
            Animator.Play("Run");
        }
        else if(!_grounded)
        {
            Animator.Play("Grappling");
        }
        else
        {
            Animator.Play("Idle");
        }
        PlayerAvatar.transform.eulerAngles = new Vector3(
            PlayerAvatar.transform.eulerAngles.x,
            PlayerCamera.eulerAngles.y,
            PlayerAvatar.transform.eulerAngles.z);
    }

    /// <summary>
    /// Find the velocity relative to where the player is looking
    /// Useful for vectors calculations regarding movement and limiting movement
    /// </summary>
    /// <returns></returns>
    public Vector2 FindVelRelativeToLook()
    {
        float lookAngle = Orientation.transform.eulerAngles.y;
        float moveAngle = Mathf.Atan2(_rigidbody.velocity.x, _rigidbody.velocity.z) * Mathf.Rad2Deg;

        float u = Mathf.DeltaAngle(lookAngle, moveAngle);
        float v = 90 - u;

        float magnitude = new Vector2(_rigidbody.velocity.x, _rigidbody.velocity.z).magnitude;
        float yMag = magnitude * Mathf.Cos(u * Mathf.Deg2Rad);
        float xMag = magnitude * Mathf.Cos(v * Mathf.Deg2Rad);

        return new Vector2(xMag, yMag);
    }

    private bool IsFloor(Vector3 v)
    {
        float angle = Vector3.Angle(Vector3.up, v);
        return angle < MaxSlopeAngle;
    }

    /// <summary>
    /// Handle ground detection
    /// </summary>
    private void OnCollisionStay(Collision other)
    {
        //Make sure we are only checking for walkable layers
        int layer = other.gameObject.layer;
        if (GroundLayer != (GroundLayer | (1 << layer))) return;

        //Iterate through every collision in a physics update
        for (int i = 0; i < other.contactCount; i++)
        {
            Vector3 normal = other.contacts[i].normal;

            List<GameObject> newCollisions = new List<GameObject>();

            //FLOOR
            if (IsFloor(normal))
            {
                newCollisions.Add(other.gameObject);
                if (!_grounded)
                {
                    _grounded = true;
                    if (_crouching)
                    {
                        // If landing on a floor, boost slide
                        _rigidbody.AddForce(MoveSpeed * Orientation.transform.forward * Time.deltaTime * SlideLandingBoost);
                    }
                }
                if (_jumping) _jumping = false;
                _normalVector = normal;
            }

            if (newCollisions.Count > 0) _floorContactsLastFrame = newCollisions;
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (_floorContactsLastFrame.Contains(collision.gameObject))
        {
            _floorContactsLastFrame.Remove(collision.gameObject);
            if (_floorContactsLastFrame.Count <= 0)
            {
                if (_groundCancel != null)
                {
                    StopCoroutine(_groundCancel);
                }
                _groundCancel = StartCoroutine(CancelGrounded());
            }
        }
    }

    private IEnumerator CancelGrounded()
    {
        yield return new WaitForSeconds(0.4f);
        _grounded = false;
        _groundCancel = null;
    }
}