#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;


uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;
out float grave;
out vec2 texCoord1;
out float player;

float slim() {
    return 1. - sign(length(texture(Sampler0, vec2(54. / 64., 20. / 64.)).rgb));
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, normalize(Normal), Color);

    texCoord1 = UV0;
    player = 0.;
    vec2 modifiedUV = UV0;
    if (textureSize(Sampler0, 0).x != 64) {
        grave = 0.0;
    } else if (gl_VertexID / 48 == 1) {
        int y = gl_VertexID % 24;
        if (y < 16 || y > 19) {
            grave = -1.0;
        } else {
            grave = 1.0;
        }
    } else {
        grave = 0.;
        int x = gl_VertexID / 24 % 14;
        int i = gl_VertexID % 12;
        float slim = slim();
        if (slim == 1.) {
            //vertexColor = vec4(1., 1., 0., 1.);
        }
        int m0=x%2,m=m0+1;
        if (x == 4 || x == 5) {
            float v = UV0.y/.25;
            if (v<.75)v*=.5;
            float u = UV0.x*2.-m0;
            if (slim == 1.) {
                if (u < 12.0 / 32.0) {
                    u *= 8./7.;
                } else if (u > 20.0 / 32.0 && u < 28.0 / 32.) {
                    u = (i==0||i==3?10.:11.)/14.;
                }
                u *= (14.0 / 64.0);
            } else {
                u *= (16.0 / 64.0);
            }
            modifiedUV = vec2(
                u + (40.0 / 64.0),
                v * (16.0 / 64.0) + m*.25);
        } else if (x == 6 || x == 7) {
            if (x == 6 && UV0.x > 0.5) {
                player = 1.;
            }
            float v = UV0.y/.25;
            if (v<.75)v*=.5;
            float u = UV0.x*2.-m0;
            if (slim == 1.) {
                if (u < 12.0 / 32.0) {
                    u *= 8./7.;
                } else if (u > 20.0 / 32.0 && u < 28.0 / 32.) {
                    u = (i==0||i==3?10.:11.)/14.;
                }
                u *= (14.0 / 64.0);
            } else {
                u *= (16.0 / 64.0);
            }
            modifiedUV = vec2(
                u + ((32.0 + m0*16.) / 64.0),
                v * (16.0 / 64.0) + 48./64.);
        } else if (x == 8 || x == 9) {
            float v0 = UV0.y / (16.0 / 64.0);
            if (v0 < 0.75) {
                v0 *= 0.5;
            }
            float v1 = (x == 8 ? UV0.x : UV0.x - .5) / (32.0 / 64.0);
            if (v1 < 12.0 / 32.0) {
                v1 /= 12./8.;
            } else if (v1 > 20.0 / 32.0 && v1 < 28.0 / 32.) {
                v1 /= 9./8.;
            }
            if (x == 8) {
                // body
                modifiedUV = vec2(
                    v1 * (24.0 / 64.0) + (16.0 / 64.0),
                    v0 * (16.0 / 64.0) + (16.0 / 64.0));
            } else {
                // body hat layer
                modifiedUV = vec2(
                    v1 * (24.0 / 64.0) + (16.0 / 64.0),
                    v0 * (16.0 / 64.0) + (32.0 / 64.0));
            }
        } else if (x == 10 || x == 11) {
            float v0 = UV0.y / (16.0 / 64.0);
            if (v0 < 0.75) {
                v0 *= 0.5;
            }
            if (x == 10) {
                // right leg
                modifiedUV = vec2(
                    UV0.x / (32.0 / 64.0) * (16.0 / 64.0) + (0.0 / 64.0),
                    v0 * (16.0 / 64.0) + (16.0 / 64.0));
            } else {
                // right leg hat layer
                modifiedUV = vec2(
                    (UV0.x - 32.0 / 64.0) / (32.0 / 64.0) * (16.0 / 64.0) + (0.0 / 64.0),
                    v0 * (16.0 / 64.0) + (32.0 / 64.0));
            }
        } else if (x == 12 || x == 13) {
            float v0 = UV0.y / (16.0 / 64.0);
            if (v0 < 0.75) {
                v0 *= 0.5;
            }
            if (x == 12) {
                // left leg
                modifiedUV = vec2(
                    UV0.x / (32.0 / 64.0) * (16.0 / 64.0) + (16.0 / 64.0),
                    v0 * (16.0 / 64.0) + (48.0 / 64.0));
            } else {
                // left leg hat layer
                modifiedUV = vec2(
                    (UV0.x - 32.0 / 64.0) / (32.0 / 64.0) * (16.0 / 64.0) + (0.0 / 64.0),
                    v0 * (16.0 / 64.0) + (48.0 / 64.0));
            }
        }
    }

    vertexDistance = fog_distance(Position, FogShape);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = modifiedUV;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
