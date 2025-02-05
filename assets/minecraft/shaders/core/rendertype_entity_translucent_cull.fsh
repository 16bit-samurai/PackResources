#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 rgb = texture(Sampler0, texCoord0);

    // noshade 250
    // emmisive transmission alpha 252
    // transmission alpha 253
    // emmisive alpha 254

    //float noshade = sign(abs(rgb.a - 250. / 255.));
    //float e_transmission = sign(abs(rgb.a - 252. / 255.));
    //float transmission = sign(abs(rgb.a - 253. / 255.));
    float emmisive = sign(abs(rgb.a - 254. / 255.));

    float emmisive_2 = sign(abs(rgb.a - 252. / 255.));
    if (emmisive_2 = 0.0) emmisive = emmisive_2;

    //rgb.a = mix(1., mix(.7, rgb.a, transmission), emmisive);
    //rgb.a = mix(.7, rgb.a, e_transmission);
    rgb.a = mix(1., rgb.a, emmisive);

    //vec4 color = rgb * mix(vec4(1.), vertexColor, mix(1., min(emmisive, e_transmission), noshade)) * ColorModulator;
    vec4 color = rgb * mix(vec4(1.), vertexColor, emmisive) * ColorModulator;
    if (color.a < .01) {
        discard;
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
