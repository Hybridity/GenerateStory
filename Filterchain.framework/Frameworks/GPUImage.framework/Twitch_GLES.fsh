varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform highp float slider;
uniform highp float time;

void main()
{
    highp vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
    highp float time = (mod(time, 0.11)+0.8)*slider;
    uv.x += mod(time,0.01+mod(time, sin(uv.y*10.0)/10.0*slider+0.01));
    uv.y += 0.01+mod(time, sin(uv.x*7.0)/10.0*slider+0.01);
       
    highp vec4 color = texture2D(inputImageTexture, uv);
    gl_FragColor = color;
}