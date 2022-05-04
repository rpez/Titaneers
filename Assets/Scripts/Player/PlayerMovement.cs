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
using UnityEngine.VFX;

public class PlayerMovement : MonoBehaviour
{
    [Header("Assign in editor")]
    public Transform PlayerCamera;
    public Transform Orientation;
    public GameObject PlayerAvatar;
    public Animator Animator;
    public GrapplingGun Grapple;
    public GameObject Sword;
    public GameObject SwordTip;
    public HitBox SwordHitbox;
    public float MaxDamage;
    public GameObject DashVFX;
    public GameObject AttackVFX;
    public GameObject ImpactVFX;
    public CameraBehaviour Camera;
    public VisualEffect SwordPower;
    public Material DeathMat;
    public AbilityBase[] Abilities;

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
    public float AirResistanceCoefficient = 0.004f;
    public float AirResistanceRebounce = 0.002f;
    public float AirResistFreeTimeWindow = 0.5f;     // free from air resist after grappling
    public float MinPullVelocity = 20f;
    public float AirExtraGravity = 50f;
    public float MaxPullSpeedScale = 2f;
    public float PullAcceleration = 1.2f;

    public float RotateSpeed = 180f;


    [Header("Sliding")]
    public float SlideLandingBoost = 10f;
    public float SlideForce = 400;
    public float SlideCounterMovement = 0.2f;

    [Header("Boosting")]
    public float BoosterStrength = 20f;
    public float MaxBoostAmount = 5f;
    public float InitBoostRatio = 0.8f;
    public float BoostRechargeCooldown = 1f;
    public float BoostRechargeRate = 0.5f;
    public float BoostRechargeCap = 2f;
    public float BoostPowerUpAmount = 1f;
    public float GrapplePullBoostStrength = 1.1f;
    public float CurrentBoostAmount { get => _currentBoostAmount; }
    public float PowerVFXScaler = 0.05f;

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

    public Vector3 CurrentVelocity { get; private set; }
    public bool IsBoosting { get => _boosting; }

    // Player state booleans
    private bool _grounded;
    private bool _readyToJump = true;
    private bool _slowTime;
    private bool _jumping, _sprinting, _crouching, _boosting, _pulling, _attacking, _recovering, _frozen;
    private bool _rebouncing;
    public bool IsRebouncing { get => _rebouncing; set => _rebouncing = value; }

    public bool IsAttacking { get => _attacking; set => _attacking = value; }

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
    public Vector3 DashDirection { get; private set; }

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
    private Vector3 _velocityBuffer;
    public Vector3 VelocityBuffer { get => _velocityBuffer; }

    // Grapple reel in
    private GameObject _target;
    private Action _onReachtarget;
    private Vector3 _pullVelocity;
    private float _currentPullSpeedScale;
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

        GameObject vfx = GameObject.Instantiate(DashVFX, Orientation.transform);
        vfx.transform.position = Grapple.GunTip.transform.position;
        Destroy(vfx, 5f);
        EventManager.OnFreezeFrame(0.2f);
        _currentPullSpeedScale = 0.2f;
        Camera.NoiseImpulse(15f, 3f, 0.5f);
    }

    public void StopPull()
    {
        if (_pulling == false) return;
        _rigidbody.velocity = _pullVelocity.magnitude * _pullDirection.normalized;
        _rigidbody.useGravity = true;
        _pulling = false;

        if(_onReachtarget!=null)_onReachtarget.Invoke();
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


    private void Freeze(float time)
    {
        StartCoroutine(FreezeCharacter(time));
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
        _currentBoostAmount = MaxBoostAmount * InitBoostRatio;
        _currentSlowTime = MaxSlowTime;

        MainMenu _mainMenu = FindObjectOfType<MainMenu>();
        if (_mainMenu)
        {
            MouseSensitivity = _mainMenu.MouseSensitivity;
            Grapple.Range = _mainMenu.GrapplingRange;
            Destroy(_mainMenu.gameObject);
        }
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
        DashDirection = PlayerCamera.transform.forward * _yInput + PlayerCamera.transform.right * _xInput;

        _controlMapping.Jump.performed += _ => _jumping = true;
        _controlMapping.Booster.performed += _ =>
        {
            if (!_pulling) Boost();
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
            Abilities[0].TriggerAbility();
            //StartAttack();
        }
    }

    private void Movement()
    {
        SwordPower.SetFloat("Strength", Mathf.Max(1f, CurrentVelocity.magnitude * PowerVFXScaler));

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
            transform.Translate(_pullDirection.normalized * _pullVelocity.magnitude * _currentPullSpeedScale * Time.deltaTime, Space.World);
            if (_currentPullSpeedScale < MaxPullSpeedScale && !_boosting)
                _currentPullSpeedScale *= PullAcceleration;

            //if (_boosting) _currentPullSpeedScale *= GrapplePullBoostStrength;

            if (_pullDirection.magnitude < CurrentVelocity.magnitude * Time.deltaTime * 5)
            {
                StopPull();
            } 
            return;
        }
        else
        {
            CurrentVelocity = _rigidbody.velocity;
        }

        if (!_grounded && !_rebouncing && _rigidbody.useGravity)
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
            //Vector3 parallelComponent = Vector3.Project(_rigidbody.velocity, PlayerCamera.transform.forward);
            //_rigidbody.AddForce(PlayerCamera.transform.forward * BoosterStrength);
            if (DashDirection.magnitude < 0.1f) // default direction is current moving direction
                _rigidbody.AddForce(_rigidbody.velocity.normalized * BoosterStrength);
            else
                _rigidbody.AddForce(DashDirection * BoosterStrength);
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
        else if (_currentBoostAmount <= 0f || _pulling)
        {
            CancelBoost();
        }
        else if (!_pulling)
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
        if (_frozen) return;
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
                float coefficient = _rebouncing ? AirResistanceRebounce : AirResistanceCoefficient;
                float ratio = Mathf.Min((Time.time - Grapple.StopTimeStamp) / AirResistFreeTimeWindow, 1.0f);
                float resistance = coefficient * _rigidbody.velocity.magnitude * _rigidbody.velocity.magnitude;
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

        Vector3 targetDirection = CurrentVelocity;
        targetDirection.y = 0;  // freeze z axis
        if (targetDirection.magnitude > 0.1f && !IsRebouncing)
        {
            float rotateStep = RotateSpeed * Time.deltaTime;
            Vector3 newDirection = Vector3.RotateTowards(PlayerAvatar.transform.forward, targetDirection, rotateStep, 0.0f);
            PlayerAvatar.transform.rotation = Quaternion.LookRotation(newDirection);
        }
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

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.relativeVelocity.magnitude >= 10f) _velocityBuffer = collision.relativeVelocity;
        StartCoroutine(Delay(0.2f, () => _velocityBuffer = Vector3.zero));
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
        //Debug.LogFormat("Current Boost {0}", _currentBoostAmount);
    }

    public void OnDeath()
    {
        SkinnedMeshRenderer[] skinMeshRenderers = GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var renderer in skinMeshRenderers)
        {
            renderer.material = DeathMat;
        }
        MeshRenderer[] meshRenderers = GetComponentsInChildren<MeshRenderer>();
        foreach (var renderer in meshRenderers)
        {
            renderer.material = DeathMat;
        }
        StartCoroutine(Dissolve());
        _controlMapping.Grappling.Disable();
        _controlMapping.Jump.Disable();
        _controlMapping.TimeSlow.Disable();
        SetMoveInputActive(false);
        StartCoroutine(FreezeCharacter(3.0f));
        StartCoroutine(Delay(3.0f, () => {
            gameObject.SetActive(false);
        }));

    }

    public void SetMoveInputActive(bool active)
    {
        if (active)
        {
            _controlMapping.Booster.Enable();
            _controlMapping.Move.Enable();
        }
        else
        {
            _controlMapping.Booster.Disable();
            _controlMapping.Move.Disable();
        }
    }

    [SerializeField]
    private float _dissolveTime;
    private IEnumerator Dissolve()
    {
        float timer = 0;
        while (timer < _dissolveTime)
        {
            timer += Time.deltaTime;
            DeathMat.SetFloat("_Progress", timer / _dissolveTime);
            yield return new WaitForEndOfFrame();
        }
    }

}

