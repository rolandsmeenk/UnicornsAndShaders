Shader "_Shaders/rainbow"
{
	Properties
	{
		_Center("Center", Vector) = (0,0,0,0)
		_Radius("Radius", Range(0, 10)) = 0.5
		_Width("Width", Range(0, 2)) = 0.5
		_MainTex("Texture", 2D) = "white" {}
	}
		

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float4 _Center;
			float _Radius;
			float _Width;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 world : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			fixed3 mod(fixed3 x, fixed3 y)
			{
				return x - y * floor(x / y);
			}

			float linearStep(float a, float b, float t)
			{
				return saturate((t - a) / (b - a));
			}

			fixed3 HUEtoRGB(in float H)
			{
				float R = abs(H * 6 - 3) - 1;
				float G = 2 - abs(H * 6 - 2);
				float B = 2 - abs(H * 6 - 4);
				return saturate(float3(R, G, B));
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.world = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed d = distance(i.world, _Center);

				_Radius = mod(_Time.y * .5, 6.0);
				
				// 1: Fixed clamp
				//fixed t = 0;
				//if (d < _Radius)
				//{
				//	t = 1;
				//}

				fixed t = linearStep(_Radius + _Width, _Radius - _Width, d);

				// 2: gradient 
				//fixed t = smoothstep(_Radius + _Width, _Radius - _Width, d);

				// 3: gradient out
				//t *= smoothstep(_Radius - 3 * _Width, _Radius - _Width, d);

				float3 color = HUEtoRGB(t-0.15);
				//fixed3 color = tex2D(_MainTex, float2(t, 0.5)).rgb;

				float alpha = smoothstep(_Radius - 1.1 * _Width, _Radius - _Width, d);
				alpha *= smoothstep(_Radius + _Width, _Radius + 0.9 * _Width, d);
				color *= alpha;	

				return fixed4(color, alpha);
			}
			ENDCG
		}
	}
}
