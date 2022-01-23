Shader "clouds_new_fixed"
{
    Properties
    {
        RotateProjection("RotateProjection", Vector) = (1, 0, 0, 90)
        NoiseScale("NoiseScale", Float) = 10
        Vector1_c95cc99e4c034272843e6bfacef0a3b1("CloudSpeed", Float) = 0.1
        Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d("DisplaceScale", Float) = 10
        Vector4_b5940652c3a94aac9781cf4e7d550260("Noise Remap", Vector) = (0, 1, -1, 1)
        Color_b44161e63e39430daaa8e2a2584a31cb("ColorValley", Color) = (0, 0, 0, 0)
        Color_f55043266f0d4b088a36f403bdbac8b0("ColorPeak", Color) = (1, 1, 1, 0)
        Vector1_7e77819a6dea4cfaad7e01fd75e6be22("NoiseHigh", Float) = 0
        Vector1_ea56605910274714a1a958db442d085d("NoiseLow", Float) = 1
        Vector1_7ae51a43abf1466dacafce2746e5e93a("NoisePower", Float) = 1
        Vector1_717c8b67d560401c9cd8624755956b6c("BaseNoiseScale", Float) = 10
        Vector1_2c193f89ae5c43ce9024c9bf267a21b9("BaseNoiseSpeed", Float) = 2
        Vector1_e4fc4179d3a043e6b5b782a354c42ad9("BaseStrength", Float) = 2
        Vector1_3de26397ded1421db21a445ec9f2736f("EmissionStrength", Float) = 2
        Vector1_a4afde6a76954afb820ffe66aed496db("Horizon", Float) = 180
        Vector1_c9156a87c1e14a959642f587f761d824("FresnelPower", Float) = 1
        Vector1_fc45b45c6e864743b40a40d9c411fe5d("FresnelOpacity", Float) = 1
        Vector1_7e59111838124381908cf12b91b1ebfe("FadeDepth", Float) = 1
        Vector1_78c3f3035cf54862a9c621e1d72d64d7("StrengthDIviderByDistance", Float) = 1000
        Vector1_8fd017f881d640c897ff5de158ecf433("MaxStrength", Float) = 1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        // ZWrite is turned on to fix weird polygon artefacts
        // ZWrite Off
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _Property_cc66a95b71e64387a678066c7875102d_Out_0 = Vector1_3de26397ded1421db21a445ec9f2736f;
            float4 _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2;
            Unity_Multiply_float(_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2, (_Property_cc66a95b71e64387a678066c7875102d_Out_0.xxxx), _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_00156841caa944fa9068c24d7cb4794a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _Property_cc66a95b71e64387a678066c7875102d_Out_0 = Vector1_3de26397ded1421db21a445ec9f2736f;
            float4 _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2;
            Unity_Multiply_float(_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2, (_Property_cc66a95b71e64387a678066c7875102d_Out_0.xxxx), _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_00156841caa944fa9068c24d7cb4794a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _Property_cc66a95b71e64387a678066c7875102d_Out_0 = Vector1_3de26397ded1421db21a445ec9f2736f;
            float4 _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2;
            Unity_Multiply_float(_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2, (_Property_cc66a95b71e64387a678066c7875102d_Out_0.xxxx), _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.Emission = (_Multiply_00156841caa944fa9068c24d7cb4794a_Out_2.xyz);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
            float2 interp4 : TEXCOORD4;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp5 : TEXCOORD5;
            #endif
            float4 interp6 : TEXCOORD6;
            float4 interp7 : TEXCOORD7;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp4.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp5.xyz =  input.sh;
            #endif
            output.interp6.xyzw =  input.fogFactorAndVertexLight;
            output.interp7.xyzw =  input.shadowCoord;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp4.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp5.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp6.xyzw;
            output.shadowCoord = input.interp7.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _Property_cc66a95b71e64387a678066c7875102d_Out_0 = Vector1_3de26397ded1421db21a445ec9f2736f;
            float4 _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2;
            Unity_Multiply_float(_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2, (_Property_cc66a95b71e64387a678066c7875102d_Out_0.xxxx), _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Emission = (_Multiply_00156841caa944fa9068c24d7cb4794a_Out_2.xyz);
            surface.Metallic = 0;
            surface.Smoothness = 0.5;
            surface.Occlusion = 1;
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.NormalTS = IN.TangentSpaceNormal;
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // Render State
            Cull Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _Property_cc66a95b71e64387a678066c7875102d_Out_0 = Vector1_3de26397ded1421db21a445ec9f2736f;
            float4 _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2;
            Unity_Multiply_float(_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2, (_Property_cc66a95b71e64387a678066c7875102d_Out_0.xxxx), _Multiply_00156841caa944fa9068c24d7cb4794a_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.Emission = (_Multiply_00156841caa944fa9068c24d7cb4794a_Out_2.xyz);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float3 interp2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.viewDirectionWS = input.interp2.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        half4 RotateProjection;
        float NoiseScale;
        float Vector1_c95cc99e4c034272843e6bfacef0a3b1;
        float Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
        float4 Vector4_b5940652c3a94aac9781cf4e7d550260;
        float4 Color_b44161e63e39430daaa8e2a2584a31cb;
        float4 Color_f55043266f0d4b088a36f403bdbac8b0;
        float Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
        float Vector1_ea56605910274714a1a958db442d085d;
        float Vector1_7ae51a43abf1466dacafce2746e5e93a;
        float Vector1_717c8b67d560401c9cd8624755956b6c;
        float Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
        float Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
        float Vector1_3de26397ded1421db21a445ec9f2736f;
        float Vector1_a4afde6a76954afb820ffe66aed496db;
        float Vector1_c9156a87c1e14a959642f587f761d824;
        float Vector1_fc45b45c6e864743b40a40d9c411fe5d;
        float Vector1_7e59111838124381908cf12b91b1ebfe;
        float Vector1_78c3f3035cf54862a9c621e1d72d64d7;
        float Vector1_8fd017f881d640c897ff5de158ecf433;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Rotate_About_Axis_Degrees_half(half3 In, half3 Axis, half Rotation, out half3 Out)
        {
            Rotation = radians(Rotation);

            half s = sin(Rotation);
            half c = cos(Rotation);
            half one_minus_c = 1.0 - c;
            
            Axis = normalize(Axis);

            half3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                      one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                      one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                    };

            Out = mul(rot_mat,  In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }


        float2 Unity_GradientNoise_Dir_float(float2 p)
        {
            // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
            p = p % 289;
            // need full precision, otherwise half overflows when p > 1
            float x = float(34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
        { 
            float2 p = UV * Scale;
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
            float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
        {
            RGBA = float4(R, G, B, A);
            RGB = float3(R, G, B);
            RG = float2(R, G);
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Absolute_float(float In, out float Out)
        {
            Out = abs(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
        {
            Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
        }

        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A + B;
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_53d7f710923f4e6db095c4971c21cb71_Out_2);
            float _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0 = Vector1_a4afde6a76954afb820ffe66aed496db;
            float _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2;
            Unity_Divide_float(_Distance_53d7f710923f4e6db095c4971c21cb71_Out_2, _Property_0fcd631434944736bcbb21aa5752f6b9_Out_0, _Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2);
            float _Power_1648226a006b49d587652ad934246bde_Out_2;
            Unity_Power_float(_Divide_3ad059cf0f004d33964f055b4a3370ae_Out_2, 3, _Power_1648226a006b49d587652ad934246bde_Out_2);
            float3 _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Power_1648226a006b49d587652ad934246bde_Out_2.xxx), _Multiply_98f0ae529fee4398b51e1ed083112083_Out_2);
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float3 _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2;
            Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxx), _Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2);
            float _Property_302fd29f987042efbc5935811679e9a6_Out_0 = Vector1_9bf7f206a98e45ea8fd3b41fbf2daa5d;
            float _Property_00ae058c3b624415982f706d3d635646_Out_0 = Vector1_78c3f3035cf54862a9c621e1d72d64d7;
            float _Length_66931fe615b9458688365fda6574e05d_Out_1;
            Unity_Length_float3(IN.ObjectSpacePosition, _Length_66931fe615b9458688365fda6574e05d_Out_1);
            float _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2;
            Unity_Divide_float(_Property_00ae058c3b624415982f706d3d635646_Out_0, _Length_66931fe615b9458688365fda6574e05d_Out_1, _Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2);
            float _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0 = Vector1_8fd017f881d640c897ff5de158ecf433;
            float _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3;
            Unity_Clamp_float(_Divide_139ea27e7cae4f3999822e3b1f16cb43_Out_2, 0, _Property_14a75a5e53574fa3bc5b7492ac4ede76_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3);
            float _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2;
            Unity_Multiply_float(_Property_302fd29f987042efbc5935811679e9a6_Out_0, _Clamp_2206efc6e751476a8b1e0f9d06d49cb9_Out_3, _Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2);
            float3 _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2;
            Unity_Multiply_float(_Multiply_80db8b8dc19645bba88a21eadf85a03c_Out_2, (_Multiply_71425fdc15ee4f548f808f268b9e5656_Out_2.xxx), _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2);
            float3 _Add_2529d54b8906481693bbc5d89b0c8217_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_a179697d4bfa4ef2b094cbe28143b871_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2);
            float3 _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            Unity_Add_float3(_Multiply_98f0ae529fee4398b51e1ed083112083_Out_2, _Add_2529d54b8906481693bbc5d89b0c8217_Out_2, _Add_23633a7356034d22a28fa2feadcdce5c_Out_2);
            description.Position = _Add_23633a7356034d22a28fa2feadcdce5c_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _Property_bd533c63e5d44884a71c0dc87ec386de_Out_0 = Color_b44161e63e39430daaa8e2a2584a31cb;
            float4 _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0 = Color_f55043266f0d4b088a36f403bdbac8b0;
            float _Property_622583769ec8487087efbc4db962ad75_Out_0 = Vector1_7e77819a6dea4cfaad7e01fd75e6be22;
            float _Property_9d416baf3242441ca9a2269f25feb81a_Out_0 = Vector1_ea56605910274714a1a958db442d085d;
            half4 _Property_93530f47bdd4456faac5e188b968cba2_Out_0 = RotateProjection;
            half _Split_44c7ee91d7a447309414a09fe3819494_R_1 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[0];
            half _Split_44c7ee91d7a447309414a09fe3819494_G_2 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[1];
            half _Split_44c7ee91d7a447309414a09fe3819494_B_3 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[2];
            half _Split_44c7ee91d7a447309414a09fe3819494_A_4 = _Property_93530f47bdd4456faac5e188b968cba2_Out_0[3];
            half3 _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3;
            Unity_Rotate_About_Axis_Degrees_half(IN.WorldSpacePosition, (_Property_93530f47bdd4456faac5e188b968cba2_Out_0.xyz), _Split_44c7ee91d7a447309414a09fe3819494_A_4, _RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3);
            float _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0 = Vector1_c95cc99e4c034272843e6bfacef0a3b1;
            float _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_99a7fa48f297400ca82b329e339fbd6d_Out_0, _Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2);
            float2 _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_2dbb7cf8a96f498ea8259e69145c753b_Out_2.xx), _TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3);
            float _Property_cf7772f3f459421da01e05b1464cc626_Out_0 = NoiseScale;
            float _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_af3abacc6df94d51af156323ddbcb8c4_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2);
            float2 _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_fca50001454f48348307ff9838703852_Out_3);
            float _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_fca50001454f48348307ff9838703852_Out_3, _Property_cf7772f3f459421da01e05b1464cc626_Out_0, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2);
            float _Add_da0476098e94498681e9f82e471b2efa_Out_2;
            Unity_Add_float(_GradientNoise_84434f213326474db6cff7d5de4c0d29_Out_2, _GradientNoise_b438d79d8dce403bb27639ebb3558f78_Out_2, _Add_da0476098e94498681e9f82e471b2efa_Out_2);
            float _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2;
            Unity_Divide_float(_Add_da0476098e94498681e9f82e471b2efa_Out_2, 2, _Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2);
            float _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1;
            Unity_Saturate_float(_Divide_559bd8dd8cd445ee95d1c830e076afb7_Out_2, _Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1);
            float _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0 = Vector1_7ae51a43abf1466dacafce2746e5e93a;
            float _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2;
            Unity_Power_float(_Saturate_3ac6d98334b24b139d6acb2b94246e31_Out_1, _Property_5a140ba1224a4fea95f6a036af7ed1de_Out_0, _Power_f67e9aaeebf54996bf1b271626d053cf_Out_2);
            float4 _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0 = Vector4_b5940652c3a94aac9781cf4e7d550260;
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_R_1 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[0];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[1];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_B_3 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[2];
            float _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4 = _Property_e96ae157a34747bfbea9c1e9c2e2e020_Out_0[3];
            float4 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4;
            float3 _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5;
            float2 _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_R_1, _Split_7e9e294177384c3d8c48a24277ac7ea0_G_2, 0, 0, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGBA_4, _Combine_b0bab957d9a74f069d481eb5dde2d102_RGB_5, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6);
            float4 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4;
            float3 _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5;
            float2 _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6;
            Unity_Combine_float(_Split_7e9e294177384c3d8c48a24277ac7ea0_B_3, _Split_7e9e294177384c3d8c48a24277ac7ea0_A_4, 0, 0, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGBA_4, _Combine_3af5271609c3403094d5b937cf2a6cb0_RGB_5, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6);
            float _Remap_52665143aa2149d89f0930595dd62e43_Out_3;
            Unity_Remap_float(_Power_f67e9aaeebf54996bf1b271626d053cf_Out_2, _Combine_b0bab957d9a74f069d481eb5dde2d102_RG_6, _Combine_3af5271609c3403094d5b937cf2a6cb0_RG_6, _Remap_52665143aa2149d89f0930595dd62e43_Out_3);
            float _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1;
            Unity_Absolute_float(_Remap_52665143aa2149d89f0930595dd62e43_Out_3, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1);
            float _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3;
            Unity_Smoothstep_float(_Property_622583769ec8487087efbc4db962ad75_Out_0, _Property_9d416baf3242441ca9a2269f25feb81a_Out_0, _Absolute_c43c1b7e99414750809c504949fb8c04_Out_1, _Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3);
            float _Property_bffc4b28d13b4fea870eee783f88071a_Out_0 = Vector1_2c193f89ae5c43ce9024c9bf267a21b9;
            float _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2;
            Unity_Multiply_float(IN.TimeParameters.x, _Property_bffc4b28d13b4fea870eee783f88071a_Out_0, _Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2);
            float2 _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3;
            Unity_TilingAndOffset_float((_RotateAboutAxis_c427b7f27bd94fdda67618dd466199ba_Out_3.xy), float2 (1, 1), (_Multiply_887ccaeba4db484f9e21ea8774ee327c_Out_2.xx), _TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3);
            float _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0 = Vector1_717c8b67d560401c9cd8624755956b6c;
            float _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2;
            Unity_GradientNoise_float(_TilingAndOffset_c74d8431ac034a3c91353ceeeac92dbc_Out_3, _Property_e3608b830a094c9a9ccbadd40939c1aa_Out_0, _GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2);
            float _Property_69d8dd1c72e745f08445551f92ff9270_Out_0 = Vector1_e4fc4179d3a043e6b5b782a354c42ad9;
            float _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2;
            Unity_Multiply_float(_GradientNoise_e97caecab68c4167af831c6665a32d99_Out_2, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2);
            float _Add_b252f28a98874de491f137c57e77c454_Out_2;
            Unity_Add_float(_Smoothstep_ed5acdda74da43338a061a3735bc6d6c_Out_3, _Multiply_c6947a9bea9a46a4a9c9f4d127f1153b_Out_2, _Add_b252f28a98874de491f137c57e77c454_Out_2);
            float _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2;
            Unity_Add_float(1, _Property_69d8dd1c72e745f08445551f92ff9270_Out_0, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2);
            float _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2;
            Unity_Divide_float(_Add_b252f28a98874de491f137c57e77c454_Out_2, _Add_69a4ae9b1c2c44f080be674ec24130cb_Out_2, _Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2);
            float4 _Lerp_07869253016f4c7697500d20b639b9ba_Out_3;
            Unity_Lerp_float4(_Property_bd533c63e5d44884a71c0dc87ec386de_Out_0, _Property_3d5751ba9a894ba7879e58e13afe1c96_Out_0, (_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2.xxxx), _Lerp_07869253016f4c7697500d20b639b9ba_Out_3);
            float _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0 = Vector1_c9156a87c1e14a959642f587f761d824;
            float _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3;
            Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_7739bc17bcc44d24a0e73878cf18d66d_Out_0, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3);
            float _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2;
            Unity_Multiply_float(_Divide_5b0c57a4b455402f91f3b1da0bc845b7_Out_2, _FresnelEffect_491f7f43cf85415593311bba5029d056_Out_3, _Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2);
            float _Property_425e0db78d834020a48a6ab5eae391e5_Out_0 = Vector1_fc45b45c6e864743b40a40d9c411fe5d;
            float _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2;
            Unity_Multiply_float(_Multiply_c6897efa615c4fa0a96847c8cbdfc422_Out_2, _Property_425e0db78d834020a48a6ab5eae391e5_Out_0, _Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2);
            float4 _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2;
            Unity_Add_float4(_Lerp_07869253016f4c7697500d20b639b9ba_Out_3, (_Multiply_3ffd26aeb03441dfa5d3cc68d5bbd4c6_Out_2.xxxx), _Add_ed36602c469246549d83e9ee80d0f7e6_Out_2);
            float _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1);
            float4 _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0 = IN.ScreenPosition;
            float _Split_07d36b55d7394a94a7484005b89115a3_R_1 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[0];
            float _Split_07d36b55d7394a94a7484005b89115a3_G_2 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[1];
            float _Split_07d36b55d7394a94a7484005b89115a3_B_3 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[2];
            float _Split_07d36b55d7394a94a7484005b89115a3_A_4 = _ScreenPosition_285538b610cc47699d6e01c4474bad93_Out_0[3];
            float _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2;
            Unity_Subtract_float(_Split_07d36b55d7394a94a7484005b89115a3_A_4, 1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2);
            float _Subtract_146de87180d847d9afb45c3538f3e898_Out_2;
            Unity_Subtract_float(_SceneDepth_50a48722c9044047b3a8bf1149e2996c_Out_1, _Subtract_54ffa31372b744e5884908dbe0c5faf1_Out_2, _Subtract_146de87180d847d9afb45c3538f3e898_Out_2);
            float _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0 = Vector1_7e59111838124381908cf12b91b1ebfe;
            float _Divide_4800b84a2e344835a6c876112d7601c7_Out_2;
            Unity_Divide_float(_Subtract_146de87180d847d9afb45c3538f3e898_Out_2, _Property_146ab2ded56f4e0980ac337ec70635cc_Out_0, _Divide_4800b84a2e344835a6c876112d7601c7_Out_2);
            float _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1;
            Unity_Saturate_float(_Divide_4800b84a2e344835a6c876112d7601c7_Out_2, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1);
            float _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            Unity_Smoothstep_float(0, 1, _Saturate_5f34370ade1c474092e9a98ee4f934bf_Out_1, _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3);
            surface.BaseColor = (_Add_ed36602c469246549d83e9ee80d0f7e6_Out_2.xyz);
            surface.Alpha = _Smoothstep_f7ded38d6ca5463cbe533530b22337c1_Out_3;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS;
            output.ObjectSpacePosition =         input.positionOS;
            output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
            output.TimeParameters =              _TimeParameters.xyz;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph


            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "ShaderGraph.PBRMasterGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}