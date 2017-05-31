precision highp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture; // Camera/Main texture

uniform float slider;
uniform float time;
uniform float amplitude;
uniform float randNum; // Receives a single random number each frame in range 0.0-1.0
uniform vec3  colorToReplace; // Greenscreen
uniform float thresholdSensitivity;
uniform float smoothing;
uniform float touchX;
uniform float touchY;

float map(vec3 p) {
    float radius = 0.2;
    vec3 q = fract(p) * 2.0 - 1.0;
    return length(q) - radius+0.05*sin(time);
}

float trace(vec3 o, vec3 r) {
    float t = 0.0;
    for (int i = 0; i < 16; ++i) {
        vec3 p = o + r * t;
        float d = map(p);
        t += d * 0.5;
    }
    return t;
}

vec3 spheres(vec2 uv) {
    vec3 r = normalize(vec3(uv, 1.0));
    vec3 o = vec3(1.0, 1.0, 0.4*time+(amplitude*0.2)*time);
    float t = trace(o, r);
    float fog = 1.0/ (1.0 + t * t * 0.1);
    vec3 fc = vec3(fog);
    return fc;
}

void main()
{
    // Get the colours from the textures
    highp vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
    // Get texture coordinates
    highp vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
    
    highp vec2 touchUV = vec2(touchX, touchY);
    //     uv = uv * 2.0 - 1.0;
    //     highp vec3 spheres = trace(uv);
    //     highp vec3 spheres = Spheres(uv);
    uv = uv * 2.0 - 1.0;
    highp vec3 s = spheres(uv);
    
    
    // Set color to replace
    highp float offset = 0.1;
    
    float r = 0.;
    float g = 1.;
    float b = 0.;
    highp vec4 touchedColor = vec4(r, g, b, 1.);
    
    // Set coordinates for colour to replace
    if (uv.x > touchX-offset && uv.y > touchY-offset && uv.x < touchX+offset && uv.y < touchY+offset) {
        r = originalColor.r;
        g = originalColor.g;
        b = originalColor.b;
    }
    touchedColor = texture2D(inputImageTexture, touchUV);
    
    // Chroma key
    float maskY = 0.2989 * touchedColor.r + 0.5866 * touchedColor.g + 0.1145 * touchedColor.b;
    float maskCr = 0.7132 * (touchedColor.r - maskY);
    float maskCb = 0.5647 * (touchedColor.b - maskY);
    
    float Y = 0.2989 * originalColor.r + 0.5866 * originalColor.g + 0.1145 * originalColor.b;
    float Cr = 0.7132 * (originalColor.r - Y);
    float Cb = 0.5647 * (originalColor.b - Y);
    
    // Final mix
    float blendValue = 1.0 - smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
    //
    // Output
    gl_FragColor = max(mix(originalColor, max(vec4(s, 1.0),originalColor*vec4(s, 1.0)), blendValue), originalColor);
    //     gl_FragColor = vec4(s, 1.0);
    
    //     gl_FragColor = vec4(spheres, 1.0);
    //     gl_FragColor = noiseColor+vec4(stars, 1.)+originalColor;
}
