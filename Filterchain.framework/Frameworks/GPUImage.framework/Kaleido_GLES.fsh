varying lowp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform lowp vec2 uScreenResolution;

uniform lowp float fractionalWidthOfPixel;
uniform lowp float aspectRatio;

void main(void)
{
    highp vec2 uv = gl_FragCoord.xy;
    
    
    //highp float a = 0.00008 + ( 0.135 * 0.01);
    highp float a = 0.00008 + (fractionalWidthOfPixel * 0.01);
    
    for (lowp float i = 1.0; i < 3.0; i += 1.0) {
        
        uv = vec2(sin(a)*uv.y - cos(a)*uv.x, sin(a)*uv.x + cos(a)*uv.y);
        uv = vec2(abs(fract(uv) - 0.5));
        
        a *= i;
        a -= i;
    }
    
    gl_FragColor = texture2D(inputImageTexture, uv);
}
