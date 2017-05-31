varying lowp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform lowp float fractionalWidthOfPixel;

// based on GPUImage issue #1110
void main(void)
{
    mediump vec2 p = textureCoordinate;
    
    if (p.x > fractionalWidthOfPixel) {
        p.x = 1.0 - p.x;
    }
    
    lowp vec4 outputColor = texture2D (inputImageTexture, p);
    gl_FragColor = outputColor;
}
