varying lowp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform lowp float fractionalWidthOfPixel;
uniform lowp float aspectRatio;

 
void main(void)
{
    mediump vec2 p = textureCoordinate;
    lowp float midPoint = 0.5;
    
    p.y = mod(p.y, fractionalWidthOfPixel/**midPoint*/);
    
    lowp vec4 outputColor = texture2D (inputImageTexture, p);
    gl_FragColor = outputColor;
}
