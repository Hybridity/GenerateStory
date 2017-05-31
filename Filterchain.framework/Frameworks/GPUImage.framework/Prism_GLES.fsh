varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;
uniform highp float XoffsetValue;

highp float rand_state = 0.5;

void main()
{
    highp vec4 textureColor;
    highp vec4 outputColor;
    highp vec2 offset = vec2(XoffsetValue,0.0);
    
    textureColor = texture2D(inputImageTexture, textureCoordinate + offset);
    outputColor.r = textureColor.r;
    
    textureColor = texture2D(inputImageTexture, textureCoordinate - offset);
    outputColor.g = textureColor.g;
    
    textureColor = texture2D(inputImageTexture, textureCoordinate);
    outputColor.b = textureColor.b;
    
    gl_FragColor = vec4(outputColor.rgb, textureColor.a);
}
