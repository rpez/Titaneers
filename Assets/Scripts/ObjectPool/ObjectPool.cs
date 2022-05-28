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
    public int Size { get => _size; }

    public ObjectPoolUnit InitiateFromObjectPool(Vector3 position, Quaternion rotation, Transform parent = null)
    {
        if (_units.Count > 0)
            foreach (ObjectPoolUnit unit in _units)
            {
                if (!unit.Active)
                {
                    unit.transform.position = position;
                    unit.transform.rotation = rotation;
                    unit.transform.SetParent(parent);
                    unit.Activate();
                    return unit;
                }
            }
        if (_units.Count >= _size) return null;
        GameObject obj = Instantiate(_unitObject, position, rotation, parent);
        ObjectPoolUnit newUnit = obj.GetComponent<ObjectPoolUnit>();
        if (!newUnit)
            newUnit = obj.AddComponent<ObjectPoolUnit>();
        _units.Add(newUnit);
        return newUnit;
    }

    private void Recycle(ObjectPoolUnit deactiveUnit)
    {
        deactiveUnit.transform.SetParent(transform);
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
