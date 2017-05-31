varying lowp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform lowp vec2 uScreenResolution;
uniform lowp float fractionalWidthOfPixel;
 
void main(void)
{
    mediump vec2 p = textureCoordinate;
    
    p.x = mod(p.x, fractionalWidthOfPixel);
    p.y = mod(p.y, fractionalWidthOfPixel);
    
    lowp vec4 outputColor = texture2D (inputImageTexture, p);
    gl_FragColor = outputColor;
}
