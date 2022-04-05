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
using UnityEngine.SceneManagement;

public class PlayerMovement : MonoBehaviour
{
    [Header("Assign in editor")]
    public Transform PlayerCamera;
    public Transform Orientation;
    public GameObject PlayerAvatar;
    public Animator Animator;
    public GrapplingGun Grapple;
    public GameObject Sword;
    public HitBox SwordHitbox;
    public GameObject DashVFX;
    public GameObject AttackVFX;
    public CameraBehaviour Camera;

    [Header("Layers")]
    public LayerMask GroundLayer;

    [Header("Movement")]
    public float MouseSensitivity = 3;
    public float MoveForce = 90;
    public float MaxGroundSpeed = 50;
    public float MaxAirSpeed = 100;
    public float GroundResistance = 0.175f;
    public float MaxSlopeAngle = 35f;
    public float ResitanceThreshold = 200f;
    public float AirResistanceCoefficient = 10f;
    public float AirResistFreeTimeWindow = 0.5f;     // free from air resist after grappling
    public float MinPullVelocity = 20f;
    public float AirExtraGravity = 50f;
    

    [Header("Sliding")]
    public float SlideLandingBoost = 10f;
    public float SlideForce = 400;
    public float SlideCounterMovement = 0.2f;

    [Header("Boosting")]
    public float BoosterStrength = 20f;
    public float MaxBoostAmount = 5f;
    public float BoostRechargeCooldown = 1f;
    public float BoostRechargeRate = 0.5f;
    public float BoostRechargeCap = 2f;
    public float BoostPowerUpAmount = 1f;
    public float CurrentBoostAmount { get => _currentBoostAmount; }

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

    [Header("Attacking")]
    public float AttackWindup = 0.2f;
    public float AttackTime = 0.5f;
    public float RecoverTime = 0.5f;

    public Vector3 CurrentVelocity { get; private set; }
    public bool IsBoosting { get => _boosting; }

    // Player state booleans
    private bool _grounded;
    private bool _readyToJump = true;
    private bool _slowTime;
    private bool _jumping, _sprinting, _crouching, _boosting, _pulling, _attacking, _recovering, _frozen;
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

    private Vector3 _boostDirection;
    private float _currentBoostAmount;
    private float _currentBoostRechargeTime;

    private float _jumpCooldown = 0.25f;

    private float _crouchHeight = 1f;
    private float _playerHeight;
    private Vector3 _crouchCameraOffset = new Vector3(0f, -1f, 0f);
    private Vector3 _crouchCameraPosition;
    private Vector3 _defaultCameraPostion;

    private float _currentSlowTime;

    private Vector3 _normalVector = Vector3.up;
    private Vector3 _wallNormalVector;

    // Grapple reel in
    private GameObject _target;
    private Action _onReachtarget;
    private Vector3 _pullVelocity;
    private Vector3 _pullDirection;

    // Collects the floor surfaces touched last frame, used for detecting from which surface player jumps/falls
    private List<GameObject> _floorContactsLastFrame = new List<GameObject>();

    public void StartPullTowards(GameObject target, Action onEnd)
    {
        _target = target;
        _onReachtarget = onEnd;
        _pullVelocity = _rigidbody.velocity;
        if (_pullVelocity.magnitude <= MinPullVelocity) _pullVelocity = MinPullVelocity * _pullVelocity.normalized;
        _rigidbody.velocity = Vector3.zero;
        _rigidbody.useGravity = false;
        _pulling = true;
    }

    public void StopPull()
    {
        _rigidbody.velocity = _pullVelocity.magnitude * _pullDirection.normalized;
        _rigidbody.useGravity = true;
        _pulling = false;

        if(_onReachtarget!=null)_onReachtarget.Invoke();
    }

    private void AttackImpact()
    {
        GameObject hitEffect = GameObject.Instantiate(DashVFX, transform.position, Quaternion.identity);
        hitEffect.transform.localScale = hitEffect.transform.localScale * 10f;
        Destroy(hitEffect, 5f);

        if (_pulling) StopPull();

        _rigidbody.velocity = -_rigidbody.velocity + Vector3.up * _rigidbody.velocity.magnitude;

        EventManager.OnFreezeFrame(0.5f);

        Camera.OnAttack();
        Camera.NoiseImpulse(30f, 6f, 0.7f);
    }

    private IEnumerator FreezeCharacter(float time)
    {
        Animator.speed = 0.01f;
        Vector3 velocity = _rigidbody.velocity;
        _rigidbody.velocity = Vector3.zero;
        _frozen = true;

        yield return new WaitForSecondsRealtime(time);

        Animator.speed = 1.0f;
        _rigidbody.velocity = velocity;
        _frozen = false;
    }

    private void StartAttack()
    {
        if (!_attacking && !_recovering)
        {
            _attacking = true;
            Animator.SetInteger("state", 3);
            StartCoroutine(Delay(AttackWindup, AttackDamage));
        }
    }

    private void AttackDamage()
    {
        GameObject vfx = GameObject.Instantiate(AttackVFX, Sword.transform);
        Destroy(vfx, 5f);

        SwordHitbox.gameObject.SetActive(true);
        SwordHitbox.Initialize(CurrentVelocity.magnitude, AttackImpact);

        StartCoroutine(Delay(AttackTime, EndAttack));
    }

    private void EndAttack()
    {
        _attacking = false;
        _recovering = true;
        SwordHitbox.gameObject.SetActive(false);
        Camera.OnAttackEnd();
        StartCoroutine(Delay(RecoverTime, Recover));
    }

    private void Freeze(float time)
    {
        StartCoroutine(FreezeCharacter(time));
    }

    private void Recover()
    {
        _recovering = false;
    }

    private void OnEnable()
    {
        _controls.Enable();
        EventManager.FreezeFrame += Freeze;
    }

    private void OnDisable()
    {
        EventManager.FreezeFrame -= Freeze;
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
        _currentBoostAmount = MaxBoostAmount * 0.2f;
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
        _controlMapping.Booster.performed += _ =>
        {
            Boost();
        };
        if (_controlMapping.Booster.WasReleasedThisFrame())
        {
            CancelBoost();
        };
        _controlMapping.TimeSlow.performed += _ =>
        {
            SetTimeSlow(!_slowTime);
        };

        //Restart
        _controlMapping.Restart.performed += _ => SceneManager.LoadScene(SceneManager.GetActiveScene().name);

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            StartAttack();
        }
    }

    private void Movement()
    {
        if (_frozen)
        {
            _rigidbody.velocity = Vector3.zero;
            return;
        }

        if (_pulling)
        {
            if (_target == null)
            {
                StopPull();
                return;
            }
            _pullDirection = _target.transform.position - transform.position;
            transform.Translate(_pullDirection.normalized * _pullVelocity.magnitude * Time.deltaTime, Space.World);
            if (_pullDirection.magnitude < 5f)
            {
                StopPull();
            } 
            return;
        }
        else
        {
            CurrentVelocity = _rigidbody.velocity;
        }

        if (!_grounded && _rigidbody.useGravity)
            _rigidbody.AddForce(Vector3.down * AirExtraGravity);

        //Find actual velocity relative to where player is looking
        Vector2 mag = FindVelRelativeToLook();
        float xMag = mag.x, yMag = mag.y;

        //Counteract sliding and sloppy movement
        CounterMovement(_xInput, _yInput, mag);

        //If holding jump && ready to jump, then jump
        if (_readyToJump && _jumping) Jump();

        //Set max speed
        float maxSpeed = _grounded ? MaxGroundSpeed : MaxAirSpeed;

        if (_boosting)
        {
            Vector3 parallelComponent = Vector3.Project(_rigidbody.velocity, PlayerCamera.transform.forward);
            _rigidbody.velocity = parallelComponent;
            _rigidbody.AddForce(PlayerCamera.transform.forward * BoosterStrength);
        }
        //If speed is larger than maxspeed, cancel out the input so you don't go over max speed
        if (_xInput > 0 && xMag > maxSpeed) _xInput = 0;
        if (_xInput < 0 && xMag < -maxSpeed) _xInput = 0;
        if (_yInput > 0 && yMag > maxSpeed) _yInput = 0;
        if (_yInput < 0 && yMag < -maxSpeed) _yInput = 0;

        //Some multipliers
        float multiplier = 1f;

        // Movement in air
        if (!_grounded)
        {
            multiplier = 2f;
        }

        //Apply forces to move player
        //not on y axis direction
        Vector3 forward = Orientation.transform.forward;
        Vector3 right = Orientation.transform.right;
        forward.y = 0; forward.Normalize();
        right.y = 0; right.Normalize();
        _rigidbody.AddForce(forward * _yInput * MoveForce * multiplier);
        _rigidbody.AddForce(right * _xInput * MoveForce * multiplier);
        //If sliding down a ramp, add force down so player stays grounded and also builds speed
        if (_crouching && _grounded && _readyToJump)
        {
            _rigidbody.AddForce(Vector3.down * Time.deltaTime * 3000);
            return;
        }
    }

    private void UpdateCooldowns()
    {
        if (!_boosting)
        {
            if (_currentBoostAmount < BoostRechargeCap)
            {
                _currentBoostRechargeTime += Time.deltaTime;
                if (_currentBoostRechargeTime >= BoostRechargeCooldown)
                {
                    _currentBoostAmount += Time.deltaTime * BoostRechargeRate;
                }
            }
        }
        else if (_currentBoostAmount <= 0f)
        {
            CancelBoost();
        }
        else
        {
            _currentBoostAmount -= Time.deltaTime;
            _currentBoostRechargeTime = 0f;
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

    private void Boost()
    {
        if (_currentBoostAmount > 0)
        {
            _boosting = true;
            _rigidbody.useGravity = false;

            GameObject vfx = GameObject.Instantiate(DashVFX, Orientation.transform);
            Destroy(vfx, 5f);
        }
    }   

    private void CancelBoost()
    {
        _boosting = false;
        _rigidbody.useGravity = true;
        _currentBoostRechargeTime = 0f;
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
        //if (_boosting) return;

        // If airborne, Air Resistance F_d = C * v^2
        if (!_grounded || _jumping)
        {
            if (!Grapple.IsGrappling())
            {
                float ratio = Mathf.Min((Time.time - Grapple.StopTimeStamp) / AirResistFreeTimeWindow, 1.0f);
                float resistance = AirResistanceCoefficient * _rigidbody.velocity.magnitude * _rigidbody.velocity.magnitude;
                _rigidbody.AddForce(-resistance * _rigidbody.velocity.normalized * ratio);
            }
            return;
        }

        // Slow down sliding
        if (_crouching)
        {
            _rigidbody.AddForce(MoveForce * -_rigidbody.velocity.normalized * SlideCounterMovement);
            return;
        }

        //// Move resistance
        if (Math.Abs(mag.x) > _minMovementThreshold && Math.Abs(x) < 0.05f)
        {
            _rigidbody.AddForce(MoveForce * Orientation.transform.right * -mag.x * GroundResistance);
        }
        if (Math.Abs(mag.y) > _minMovementThreshold && Math.Abs(y) < 0.05f)
        {
            _rigidbody.AddForce(MoveForce * Orientation.transform.forward * -mag.y * GroundResistance);
        }

        //// Limit diagonal running. This will also cause a full stop if sliding fast and un-crouching, so not optimal.
        //if (Mathf.Sqrt((Mathf.Pow(_rigidbody.velocity.x, 2) + Mathf.Pow(_rigidbody.velocity.z, 2))) > MaxGroundSpeed)
        //{
        //    float fallspeed = _rigidbody.velocity.y;
        //    Vector3 n = _rigidbody.velocity.normalized * MaxGroundSpeed;
        //    _rigidbody.velocity = new Vector3(n.x, fallspeed, n.z);
        //}
    }

    private void Animate()
    {
        // [Note:wesley] Better to use animator with trigger
        if (!_attacking)
        {
            if (_rigidbody.velocity.magnitude > 0.1f && _grounded)
            {
                Animator.SetInteger("state", 1);
            }
            else if (!_grounded)
            {
                Animator.SetInteger("state", 2);
            }
            else
            {
                Animator.SetInteger("state", 0);
            }
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
                        _rigidbody.AddForce(MoveForce * Orientation.transform.forward * SlideLandingBoost);
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
                _grounded = false;
            }
        }
    }

    private IEnumerator Delay(float delay, Action callback)
    {
        yield return new WaitForSeconds(delay);
        callback.Invoke();
    }

    public void OnPowerUpCollected(float amount = 2.0f)
    {
        if (_currentBoostAmount < MaxBoostAmount)
        {
            _currentBoostAmount += amount;
            if (_currentBoostAmount > MaxBoostAmount) _currentBoostAmount = MaxBoostAmount;
        }
        Debug.LogFormat("Current Boost {0}", _currentBoostAmount);
    }
}

