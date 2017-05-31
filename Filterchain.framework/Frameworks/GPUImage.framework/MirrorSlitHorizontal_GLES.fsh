varying lowp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform lowp float fractionalWidthOfPixel;
 

void main(void)
{
    mediump vec2 p = textureCoordinate;
    lowp float midPoint = 0.5;
    
    p.x = mod(p.x, fractionalWidthOfPixel/**midPoint*/);
    
    lowp vec4 outputColor = texture2D (inputImageTexture, p);
    gl_FragColor = outputColor;
}
