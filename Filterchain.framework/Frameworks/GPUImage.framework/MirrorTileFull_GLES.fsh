// Note: Take a look at the updateWithSliderValue callback in G8FilterMirrorTileFull.m

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform highp float fractionalWidthOfPixel;
uniform highp float scale;
uniform highp float amplitude;
 
void main(void)
{
    highp vec2 p = textureCoordinate;
    highp vec4 original = texture2D (inputImageTexture, p);
    
    p.x = mod(p.x, fractionalWidthOfPixel);
    p.y = mod(p.y, fractionalWidthOfPixel);
    p = vec2(scale,scale)*p;
    highp vec4 tiled = texture2D(inputImageTexture, p);

    highp vec4 outputColor = mix(tiled, original, amplitude);
    gl_FragColor = outputColor;
}
