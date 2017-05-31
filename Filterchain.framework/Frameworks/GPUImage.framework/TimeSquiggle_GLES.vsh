attribute vec4 position;
attribute vec4 inputTextureCoordinate;
varying vec2 textureCoordinate;
                                                                      
uniform lowp float slider;
uniform highp float time;
                                                                  
void main()
{
    vec4 np = position;
    np.z = 0.8;
    np.x += sin( (np.y +0.25) * 24.0*slider)*0.3;
    np.y += sin( (np.x +0.45) * 24.0*slider)*0.3;
    np.x *= 1.45;
    np.y *= 1.45;
    
    textureCoordinate = inputTextureCoordinate.xy;
    gl_Position = np;
}
