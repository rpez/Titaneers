Shader "Hidden/Shader/Sobel"
{
    Properties
    {
        // This property is necessary to make the CommandBuffer.Blit bind the source texture to _MainTex
        _MainTex("Main Texture", 2DArray) = "grey" {}
    }

    HLSLINCLUDE

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/FXAA.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/PostProcessing/Shaders/RTUpscale.hlsl"
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/NormalBuffer.hlsl"

    struct Attributes
    {
        uint vertexID : SV_VertexID;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float2 texcoord   : TEXCOORD0;
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings Vert(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
        output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
        output.texcoord = GetFullScreenTriangleTexCoord(input.vertexID);
        return output;
    }

    // List of properties to control your post process effect
    float _Intensity;
    float4 _Color;
    float _Thickness;
    float _DepthMultiplier;
    float _DepthBias;
    float _NormalMultiplier;
    float _NormalBias;
    TEXTURE2D_X(_MainTex);

    // for float
    float Sobel_Basic(float s00, float s10, float s20,
                      float s01,            float s21,
                      float s02, float s12, float s22)
    {
        float x =  s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;
        float y = -s00 - 2 * s01 - s02 + s20 + 2 * s21 + s22;

        return sqrt(x * x + y * y);
    }

    // for float
    float Sobel_Scharr(float s00, float s10, float s20,
                       float s01,            float s21,
                       float s02, float s12, float s22)
    {
        float x = -3 * s00 - 10 * s01 - 3 * s02 + 3 * s20 + 10 * s21 + 3 * s22;
        float y =  3 * s00 + 10 * s01 + 3 * s02 - 3 * s20 - 10 * s21 - 3 * s22;

        return sqrt(x * x + y * y);
    }

    // for float3
    float Sobel_Basic(float3 s00, float3 s10, float3 s20,
                      float3 s01,             float3 s21,
                      float3 s02, float3 s12, float3 s22)
    {
        float3 x =  s00 + 2 * s01 + s02 - s20 - 2 * s21 - s22;
        float3 y = -s00 - 2 * s01 - s02 + s20 + 2 * s21 + s22;

        return sqrt(dot(x, x) + dot(y, y));
    }

    // for float3
    float Sobel_Scharr(float3 s00, float3 s10, float3 s20,
                       float3 s01,             float3 s21,
                       float3 s02, float3 s12, float3 s22)
    {
        float3 x = -3 * s00 - 10 * s01 - 3 * s02 + 3 * s20 + 10 * s21 + 3 * s22;
        float3 y =  3 * s00 + 10 * s01 + 3 * s02 - 3 * s20 - 10 * s21 - 3 * s22;

        return sqrt(dot(x, x) + dot(y, y));
    }

    float SampleSobelDepth(float2 uv, float offsetU, float offsetV)
    {
        float s00 = SampleCameraDepth(uv + float2(-offsetU,  offsetV));
        float s10 = SampleCameraDepth(uv + float2(       0,  offsetV));
        float s20 = SampleCameraDepth(uv + float2( offsetU,  offsetV));

        float s01 = SampleCameraDepth(uv + float2(-offsetU,        0));
        float s11 = SampleCameraDepth(uv + float2(       0,        0));
        float s21 = SampleCameraDepth(uv + float2( offsetU,        0));

        float s02 = SampleCameraDepth(uv + float2(-offsetU, -offsetV));
        float s12 = SampleCameraDepth(uv + float2(       0, -offsetV));
        float s22 = SampleCameraDepth(uv + float2( offsetU, -offsetV));

        return Sobel_Scharr(abs(s00 - s11), abs(s10 - s11), abs(s20 - s11),
                            abs(s01 - s11),                 abs(s21 - s11),
                            abs(s02 - s11), abs(s12 - s11), abs(s22 - s11));
    }

    float3 SampleWorldNormal(float2 uv)
    {
        if (SampleCameraDepth(uv) <= 0) return float3(0, 0, 0);

        NormalData normalData;
        DecodeFromNormalBuffer(uv * _ScreenSize.xy, normalData);

        return normalData.normalWS;
    }

    float SampleSobelNormal(float2 uv, float offsetU, float offsetV)
    {
        float3 s00 = SampleWorldNormal(uv + float2(-offsetU,  offsetV));
        float3 s10 = SampleWorldNormal(uv + float2(       0,  offsetV));
        float3 s20 = SampleWorldNormal(uv + float2( offsetU,  offsetV));

        float3 s01 = SampleWorldNormal(uv + float2(-offsetU,        0));
        float3 s11 = SampleWorldNormal(uv + float2(       0,        0));
        float3 s21 = SampleWorldNormal(uv + float2( offsetU,        0));

        float3 s02 = SampleWorldNormal(uv + float2(-offsetU, -offsetV));
        float3 s12 = SampleWorldNormal(uv + float2(       0, -offsetV));
        float3 s22 = SampleWorldNormal(uv + float2( offsetU, -offsetV));

        return Sobel_Scharr(abs(s00 - s11), abs(s10 - s11), abs(s20 - s11),
                            abs(s01 - s11),                 abs(s21 - s11),
                            abs(s02 - s11), abs(s12 - s11), abs(s22 - s11));
    }

    float4 CustomPostProcess(Varyings input) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

        // Note that if HDUtils.DrawFullScreen is used to render the post process, use ClampAndScaleUVForBilinearPostProcessTexture(input.texcoord.xy) to get the correct UVs

        float3 sourceColor = SAMPLE_TEXTURE2D_X(_MainTex, s_linear_clamp_sampler, input.texcoord).xyz;

        float3 offsetU = _Thickness / _ScreenSize.x;
        float3 offsetV = _Thickness / _ScreenSize.y;

        float sobelDepth = SampleSobelDepth(input.texcoord.xy, offsetU, offsetV);
        sobelDepth = pow(abs(saturate(sobelDepth)) * _DepthMultiplier, _DepthBias);

        float sobelNormal = SampleSobelNormal(input.texcoord.xy, offsetU, offsetV);

        float outlineIntensity = saturate(max(sobelDepth, sobelNormal));

        // Apply outlines on color
        float3 color = lerp(sourceColor, _Color, outlineIntensity * _Intensity);

        //return float4(sobelDepth, sobelDepth, sobelDepth, 1);
        //return float4(sobelNormal, sobelNormal, sobelNormal, 1);
        return float4(color, 1);
    }

    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "HDRenderPipeline" }
        Pass
        {
            Name "Sobel"

            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
                #pragma fragment CustomPostProcess
                #pragma vertex Vert
            ENDHLSL
        }
    }
    Fallback Off
}
