#ifndef UI_SOFTMASK_INCLUDED
#define UI_SOFTMASK_INCLUDED

sampler2D _SoftMaskTex;
float _Stencil;
float4x4 _GameVP;
float4x4 _GameTVP;
half4 _MaskInteraction;

fixed Approximately(float4x4 a, float4x4 b)
{
	float4x4 d = abs(a - b);
	return step(
		max(d._m00,max(d._m01,max(d._m02,max(d._m03,
		max(d._m10,max(d._m11,max(d._m12,max(d._m13,
		max(d._m20,max(d._m21,max(d._m22,max(d._m23,
		max(d._m30,max(d._m31,max(d._m32,d._m33))))))))))))))),
		0.5);
}

float SoftMaskInternal(float4 clipPos)
{
	half2 view = clipPos.xy/_ScreenParams.xy;

	#if UNITY_UV_STARTS_AT_TOP
		view.y = lerp(view.y, 1 - view.y, step(0, _ProjectionParams.x));
	#endif

	fixed4 mask = tex2D(_SoftMaskTex, view);
	half4 alpha = saturate(lerp(fixed4(1, 1, 1, 1), lerp(mask, 1 - mask, _MaskInteraction - 1), _MaskInteraction));
	return alpha.x * alpha.y * alpha.z * alpha.w;
}

#define SOFTMASK_EDITOR_ONLY(x)
#define SoftMask(clipPos, worldPosition) SoftMaskInternal(clipPos)

#endif // UI_SOFTMASK_INCLUDED
