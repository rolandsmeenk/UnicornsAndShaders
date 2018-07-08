Shader "_Shaders/unicorn"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Base Color", Color) = (0.0, 0.0, 0.0)
		_SecondaryColor("Outer Color", Color) = (0.0, 0.0, 0.0)
		_TransitionWidth("Transition Width", Range(0.1, 100)) = 0
		_TransitionOffset("Transition Offset", Range(-100, 800)) = 0
	}
	SubShader
	{
		Cull Off

		Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
		Blend One OneMinusSrcAlpha // Premultiplied transparency
		//Blend One One // Additive
		//Blend OneMinusDstColor One // Soft Additive
		//Blend DstColor Zero // Multiplicative
		//Blend DstColor SrcColor // 2x Multiplicative

		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal: NORMAL;
				float angle : COLOR0;
				
				float2 uv : TEXCOORD0;
				float3 world: TEXCOORD1;
				fixed3 worldSpaceViewDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _SecondaryColor;
			float _TransitionOffset;
			float _TransitionWidth;
			
			v2f vert (appdata v)
			{
				v2f o;

				//v.vertex.y += 10 * sin(0.1 *  v.vertex.x + _Time.z);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldSpaceViewDir = WorldSpaceViewDir(v.vertex);
				o.normal = mul(unity_ObjectToWorld, fixed4(v.normal, 0.0)).xyz;
				o.world = v.vertex;
				o.angle = dot(normalize(o.worldSpaceViewDir), normalize(o.normal));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// 1: fixed color
			//	return fixed4(0,1,0,1);
			//return _Color;

				// 2: headlight
			//		fixed angle = dot(normalize(i.worldSpaceViewDir), normalize(i.normal));
//				return fixed4(i.angle, i.angle, i.angle, 1);

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) + _Color;

				float alpha = smoothstep(_TransitionOffset + _TransitionWidth, _TransitionOffset - _TransitionWidth, i.world.y +  5 * sin(0.2 * i.world.x + 2 * _Time.w));

				fixed rim = 1.0 - saturate(i.angle);

				rim += (1 - alpha);

				col.rgb *= saturate(lerp(fixed3(1,1,1), _SecondaryColor, pow(rim, 2)));
				//col.rgb += fixed3(1, 0, 1) * pow(rim, 2);
				
				if (alpha == 0)
				{
					//discard;
				}

				return fixed4(col.xyz * alpha, alpha);
			}
			ENDCG
		}
	}
}
