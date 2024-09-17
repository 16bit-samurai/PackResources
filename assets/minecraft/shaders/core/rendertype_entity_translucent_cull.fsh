#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 shadeColor;
in vec4 lightMapColor;
in vec4 normal;

out vec4 fragColor;

// isGUI
flat in int isGUI;
flat in int isHand;
in float zpos;

bool roughly_equal(float num1, float num2, float threshold) {
    return abs(num1 - num2) <= threshold;
}

void main() {
    vec4 rgb = texture(Sampler0, texCoord0);

    // noshade 250
    // inHand 251
    // emmisive transmission alpha 252
    // transmission alpha 253
    // emmisive alpha 254
    float noshade = sign(abs(rgb.a - 250. / 255.));
    //float inHand = sign(abs(rgb.a - 251. / 255.));
    float e_transmission = sign(abs(rgb.a - 252. / 255.));
    float transmission = sign(abs(rgb.a - 253. / 255.));
    float emmisive = sign(abs(rgb.a - 254. / 255.));

    rgb.a = mix(1., mix(.7, rgb.a, transmission), emmisive);
    rgb.a = mix(.7, rgb.a, e_transmission);
    //rgb.a = mix(0., rgb.a, inHand);

    vec4 color = rgb * mix(vec4(1.), vertexColor, mix(1., min(emmisive, e_transmission), noshade)) * ColorModulator;
    if (color.a < .01) {
        discard;
    }
    
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0; // Take the alpha from the texture's LOD so it doesn't have any issues (this has hurt me before with VDE)

    // Switch used parts of the texture depending on where the model is displayed
    if (isGUI == 1 && roughly_equal(alpha, 251.0, 0.01)) discard;
        if (isGUI == 0) {
             if (zpos  > 125.0 && roughly_equal(alpha, 251.0, 0.01)) discard;     // Handled as inventory slot
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
