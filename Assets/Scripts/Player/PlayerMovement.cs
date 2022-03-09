﻿/*
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
using UnityEngine.SceneManagement;

public class PlayerMovement : MonoBehaviour
{
    [Header("Assign in editor")]
    public Transform PlayerCamera;
    public Transform Orientation;
    public GameObject PlayerAvatar;
    public Animator Animator;
    public GrapplingGun Grapple;
    public GameObject DashVFX;

    [Header("Layers")]
    public LayerMask GroundLayer;

    [Header("Movement")]
    public float MouseSensitivity = 3;
    public float MoveSpeed = 4500;
    public float MaxSpeed = 20;
    public float CounterMovementForce = 0.175f;
    public float MaxSlopeAngle = 35f;
    public float ResitanceThreshold = 200f;
    public float AirResistance = 500f;

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

    [Header("Time slow")]
    public float SlowScale = 0.1f;
    public float MaxSlowTime = 2f;
    public float ChargeDelay = 0.5f;

    [Header("Zooming")]
    public float ZoomIncrement = 1f;

    [Header("Explosion")]
    public float ExplosionShakingRange = 20f;

    // Player state booleans
    private bool _grounded;
    private bool _readyToJump = true;
    private bool _slowTime;
    private bool _jumping, _sprinting, _crouching, _dashing, _pulling;
    private bool _timeSlowChargeDelayed;

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
    private float _scrollingInput;

    private int _currentDashCharges;
    private float _currentDashCdTime;
    private Vector3 _dashDirection;

    private float _jumpCooldown = 0.25f;

    private float _crouchHeight = 1f;
    private float _playerHeight;
    private Vector3 _crouchCameraOffset = new Vector3(0f, -1f, 0f);
    private Vector3 _crouchCameraPosition;
    private Vector3 _defaultCameraPostion;

    private float _currentSlowTime;

    private Vector3 _normalVector = Vector3.up;
    private Vector3 _wallNormalVector;

    private Coroutine _groundCancel;

    // Grapple reel in
    private GameObject _target;
    private Action _onReachtarget;
    private Vector3 _pullVelocity;

    // Collects the floor surfaces touched last frame, used for detecting from which surface player jumps/falls
    private List<GameObject> _floorContactsLastFrame = new List<GameObject>();

    public void StartPullTowards(GameObject target, Action onEnd)
    {
        _target = target;
        _onReachtarget = onEnd;
        _pullVelocity = _rigidbody.velocity;
        _rigidbody.velocity = Vector3.zero;
        _rigidbody.useGravity = false;
        _pulling = true;
    }

    private void AttackImpact()
    {
        GameObject hitEffect = GameObject.Instantiate(DashVFX, transform.position, Quaternion.identity);
        hitEffect.transform.localScale = hitEffect.transform.localScale * 10f;
        Destroy(hitEffect, 5f);

        _rigidbody.velocity = -_pullVelocity + Vector3.up * _pullVelocity.magnitude;
        _rigidbody.useGravity = true;
        _pulling = false;

        _onReachtarget.Invoke();
    }

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
        _currentSlowTime = MaxSlowTime;
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
        UpdateCooldowns();
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
            SetTimeSlow(!_slowTime);
        };

        //Restart
        _controlMapping.Restart.performed += _ => SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    private void Movement()
    {
        if (_pulling)
        {
            Vector3 distance = _target.transform.position - transform.position;
            transform.Translate(distance.normalized * _pullVelocity.magnitude * Time.deltaTime, Space.World);
            if (distance.magnitude < 5f)
            {
                AttackImpact();
            } 
            return;
        }

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
            Vector3 xz = new Vector3(_rigidbody.velocity.x, 0f, _rigidbody.velocity.z).normalized;
            _rigidbody.AddForce(xz * DashStrength, ForceMode.Force);
        }
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

        //If sliding down a ramp, add force down so player stays grounded and also builds speed
        if (_crouching && _grounded && _readyToJump)
        {
            _rigidbody.AddForce(Vector3.down * Time.deltaTime * 3000);
            return;
        }
    }

    private void UpdateCooldowns()
    {
        if (_currentDashCharges < MaxDashCharges)
        {
            _currentDashCdTime += Time.deltaTime;
            if (_currentDashCdTime >= DashCooldown)
            {
                _currentDashCharges += 1;
                _currentDashCdTime = 0;
            }
        }

        if (!_slowTime && !_timeSlowChargeDelayed && _currentSlowTime < MaxSlowTime)
        {
            _currentSlowTime += Time.unscaledDeltaTime;
        }
        else if (_slowTime && _currentSlowTime <= 0f)
        {
            SetTimeSlow(false);
        }
        else if (_slowTime)
        {
            _currentSlowTime -= Time.unscaledDeltaTime;
        }
    }

    private void SetTimeSlow(bool active)
    {
        if (!_slowTime && _currentSlowTime <= 0.0) return;
        _slowTime = active;
        _timeManager.ToggleTimeScale(SlowScale, _slowTime);
        if (!_slowTime)
        {
            _timeSlowChargeDelayed = true;
            StartCoroutine(Delay(ChargeDelay, () => _timeSlowChargeDelayed = false));
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
            _dashing = true;
            _currentDashCharges--;

            GameObject vfx =  GameObject.Instantiate(DashVFX, Orientation.transform);
            Destroy(vfx, 5f);

            _xInput = _horizontalInput.x;
            _yInput = _horizontalInput.y;
            _dashDirection = Orientation.transform.forward * _yInput + Orientation.transform.right * _xInput;

            if (Vector3.Angle(_dashDirection, _rigidbody.velocity) >= 50f)
            {
                _rigidbody.velocity = _dashDirection * _rigidbody.velocity.magnitude * 0.3f;
            }

            yield return new WaitForSecondsRealtime(DashTime * Time.unscaledDeltaTime);

            _dashing = false;
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
        _xRotation = Mathf.Clamp(_xRotation, -85f, 85f);

        //Perform the rotations
        PlayerCamera.transform.localRotation = Quaternion.Euler(_xRotation, _targetXRotation, 0);
        Orientation.transform.localRotation = Quaternion.Euler(_xRotation, _targetXRotation, 0);
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
                // Start applying air resistance after velocity exceeds 100
                // Cap the resitance at AirResistance
                float resistance = (_rigidbody.velocity.magnitude - ResitanceThreshold) * 0.005f;
                if (resistance < 0f) return;
                if (resistance > 1f) resistance = 1f;
                _rigidbody.AddForce(-resistance * _rigidbody.velocity.normalized * AirResistance);
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
            Orientation.eulerAngles.y,
            PlayerAvatar.transform.eulerAngles.z);
    }

    /// <summary>
    /// Find the velocity relative to where the player is looking
    /// Useful for vectors calculations regarding movement and limiting movement
    /// </summary>
    /// <returns></returns>
    private Vector2 FindVelRelativeToLook()
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
        yield return new WaitForSeconds(.0f);
        _grounded = false;
        _groundCancel = null;
    }

    private IEnumerator Delay(float delay, Action callback)
    {
        yield return new WaitForSeconds(delay);
        callback.Invoke();
    }
}