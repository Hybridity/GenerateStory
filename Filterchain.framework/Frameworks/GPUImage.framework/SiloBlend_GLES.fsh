 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float slider;
 uniform highp float aspectRatio;
 
 void main(void)
{
    highp float phase= slider*2.5;
    highp float levels= 8.;
    highp vec4 tx = texture2D(inputImageTexture, textureCoordinate);
    highp vec4 x=tx;
    
    x = mod(x + phase, 1.);
    x = floor(x*levels);
    x = mod(x,2.);
    
    gl_FragColor= vec4(vec3(x), tx.a)*tx;
}
