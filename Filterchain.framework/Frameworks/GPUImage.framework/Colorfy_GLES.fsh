varying highp vec2 textureCoordinate;
  
uniform sampler2D inputImageTexture;
uniform highp float slider;
//uniform highp float time;
uniform highp float amplitude;
//uniform highp float randNum;
 
mediump vec3 hueGradient(mediump float t, highp vec2 cc) {
//      cc = mod(vec2(cc+vec2(slider)), slider);
  mediump vec3 pX = abs(fract(t*cc.x + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
  pX = clamp(pX - 1.0, 0.0, 1.0);
  
  mediump vec3 pY = abs(fract(t*cc.y + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
  pY = clamp(pY - 1.0, 0.0, 1.0);
  
  mediump vec3 result = (pX+pY)*vec3(0.5);
  return result;
}
 
void main()
{
  highp vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
  lowp vec4 originalColor = texture2D(inputImageTexture, uv);
  uv.x += (originalColor.r+originalColor.g+originalColor.b) * 0.33332*amplitude;
  highp vec4 outputColor = vec4(hueGradient(slider, uv), 1.0);
      
//      outputColor*=originalColor; // Standalone mode
  gl_FragColor = outputColor;
}

