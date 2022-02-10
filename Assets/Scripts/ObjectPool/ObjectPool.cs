using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectPool : MonoBehaviour
{
    [SerializeField]
    private GameObject _unitObject;
    [SerializeField]
    private int _size;
    private List<ObjectPoolUnit> _units;
    public List<ObjectPoolUnit> Units { get => _units; }

    public ObjectPoolUnit InitiateFromObjectPool(Vector3 position, Quaternion rotation, Transform partent = null)
    {
        if (_units.Count >= _size) return null;
        if (_units.Count > 0)
            foreach (ObjectPoolUnit unit in _units)
            {
                if (!unit.Active)
                {
                    unit.transform.position = position;
                    unit.transform.rotation = rotation;
                    unit.transform.parent = partent;
                    unit.Activate();
                    return unit;
                }
            }
        GameObject obj = Instantiate(_unitObject, position, rotation, partent);
        ObjectPoolUnit newUnit = obj.GetComponent<ObjectPoolUnit>();
        if (!newUnit)
            newUnit = obj.AddComponent<ObjectPoolUnit>();
        _units.Add(newUnit);
        return newUnit;
    }

    private void Recycle(ObjectPoolUnit deactiveUnit)
    {
        deactiveUnit.transform.parent = transform;
        deactiveUnit.transform.position = transform.position;
    }

    private void Start()
    {
        _units = new List<ObjectPoolUnit>();
    }

    private void Update()
    {
        if (_units.Count > 0)
            foreach (ObjectPoolUnit unit in _units)
            {
                if (!unit.Active) Recycle(unit);
            }
    }
}
