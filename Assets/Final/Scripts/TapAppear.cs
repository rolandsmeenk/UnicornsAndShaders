using HoloToolkit.Unity.InputModule;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TapAppear : MonoBehaviour, IInputClickHandler
{
    public Material unicornMaterial;
    private float target = -100f;
    private float velocity;
    public bool appear;

    // Use this for initialization
    void Start ()
    {
        InputManager.Instance.AddGlobalListener(gameObject);
        unicornMaterial.SetFloat("_TransitionOffset", target);
    }

    protected virtual void OnDestroy()
    {
        if (InputManager.Instance != null)
        {
            InputManager.Instance.RemoveGlobalListener(gameObject);
        }
    }

    // Update is called once per frame
    void Update ()
    {
        float value = Mathf.SmoothDamp(unicornMaterial.GetFloat("_TransitionOffset"), target, ref velocity, 2.0f);
        unicornMaterial.SetFloat("_TransitionOffset", value);
    }

    public void OnInputClicked(InputClickedEventData eventData)
    {
        appear = !appear;
        if (appear)
        {
            target = 600;
        }
        else
        {
            target = -100;
        }
    }

    private void OnValidate()
    {
        if (appear)
        {
            target = 600;
        }
        else
        {
            target = -100;
        }
    }
}
