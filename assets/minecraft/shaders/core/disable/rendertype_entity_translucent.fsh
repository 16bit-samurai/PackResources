#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;
in float grave;
in vec2 texCoord1;
in float player;

out vec4 fragColor;

void main() {
    vec2 uv = texCoord0;
    if (texCoord1.y >= 0.25 || player > 0.) {
        uv = texCoord1;
    }
    vec4 color = texture(Sampler0, uv);
    if (color.a < 0.1) {
        discard;
    }
    vec4 vc = vertexColor;
    if (grave != 0.0 && texCoord0.y < 0.25) {
        if (grave < 0.0) {
            discard;
        }
        vc = vec4(vec3(0.8), 1.0);
        float x = floor(dot(color.rgb, vec3(0.2126, 0.7152, 0.0722)) * 8);
        if (x == 0.) color.rgb = vec3(68., 66., 59.)/255.;
        else if (x == 1.) color.rgb = vec3(76., 78., 70.)/255.;
        else if (x == 2.) color.rgb = vec3(89., 95., 84.)/255.;
        else if (x == 3.) color.rgb = vec3(102., 107., 91.)/255.;
        else if (x == 4.) color.rgb = vec3(114., 117., 107.)/255.;
        else if (x == 5.) color.rgb = vec3(135., 135., 120.)/255.;
        else if (x == 6.) color.rgb = vec3(164., 161., 149.)/255.;
        else color.rgb = vec3(191., 193., 186.)/255.;
    }
    color *= vc * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
