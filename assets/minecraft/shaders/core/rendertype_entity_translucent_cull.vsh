#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform float GameTime;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 shadeColor;
out vec4 lightMapColor;
flat out float finish;
out float alphaOffset;
out vec4 normal;

mat3 rotateX(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat3(1., 0., 0.,
    0., c, s,
    0., -s, c
  );
}

mat3 rotateY(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat3(c, 0., -s,
    0., 1., 0.,
    s, 0., c
  );
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.);
    overlayColor = vec4(1.);
    shadeColor = Color;
    finish = 0.;
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    alphaOffset = 0.;
    vec2 uv0 = UV0;
    if (Color.xyz == vec3(253. / 255., 1., 1.) && (ProjMat[2][3] != 0.)) {
        shadeColor = vec4(0.);
        vertexColor = vec4(-1.);
        lightMapColor = vec4(1.);
    } else if (Color.xyz == vec3(254. / 255., 1., 1.)) {
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
        lightMapColor = vec4(1.);
    } else if (Color.xy == vec2(254. / 255., 254. / 255.)) {
        float brightness = (lightMapColor.x + lightMapColor.y + lightMapColor.z) / 3.;
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
        lightMapColor = vec4(1.);
        alphaOffset = max((brightness - .5) * 2. - (1. - Color.z) / 32., 0.);
    } else if (Color.xyz == vec3(254., 107., 107.) / 255.) {
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
        lightMapColor = vec4(1.);
        overlayColor = texelFetch(Sampler1, ivec2(0, 3), 0);
    } else if (Color.xyz == vec3(1., 254. / 255., 1.)) {
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
    } else if (Color.xz == vec2(1.) && Color.y < 1.) {
        float y = floor(Color.y * 255.);
        shadeColor = vec4(1.);
        vertexColor = mod(y, 2.) == 1. ? vec4(1.) : minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, vec4(1.));
        lightMapColor = mod(y, 2.) == 1. ? vec4(1.) : lightMapColor;
        finish = floor(y / 2.) + 1.;
    } else if (Color.xyz == vec3(1., 252. / 255., 252. / 255.)) {
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
        lightMapColor = vec4(1.);
        finish = -1.;
    } else if (Color.xyz == vec3(2. / 255., 252. / 255., 252. / 255.)) {
        shadeColor = vec4(1.);
        vertexColor = vec4(vec3(1.), 1.);
        lightMapColor = vec4(1.);
        int id = gl_VertexID % 4;
        float x0 = 0., y0 = 0.;
        if (id == 0) {
            x0 = -1.;
            y0 = 1.;
        } else if (id == 1) {
            x0 = -1.;
            y0 = -1.;
        } else if (id == 2) {
            x0 = 1.;
            y0 = -1.;
        } else if (id == 3) {
            x0 = 1.;
            y0 = 1.;
        }
        mat3 rot =  rotateY(-2.7) * rotateX(.8);
        vec3 offset = (rot * vec3(0., 0., -400.)) + rot * (150. * vec3(x0, y0, 0.));
        gl_Position = ProjMat * ModelViewMat * vec4(offset, 1.);
        finish = -2.;
        uv0 = vec2(x0, y0) * .5 + .5;
    } else if (Color.xyz == vec3(1. / 255., 0., 3. / 255.) || Color.xyz == vec3(1. / 255., 0., 4. / 255.)) {
        shadeColor = vec4(1.);
        vertexColor = vec4(1.);
        lightMapColor = vec4(1.);
        int id = gl_VertexID % 4;
        float x0 = (id == 2 || id == 3) ? 1. : -1.;
        float y0 = (id == 0 || id == 3) ? 1. : -1.;
        gl_Position = vec4(x0, y0, 0.001, 1.);
        finish = Color.xyz == vec3(1. / 255., 0., 4. / 255.) ? -4. : -3.;
        uv0 = vec2(x0, y0) * .5 + .5;
    } else if (Color.xyz == vec3(251. / 255.)) {
        shadeColor = vec4(0.);
        vertexColor = vec4(0.);
        lightMapColor = vec4(0.);
    } else {
        vec4 col = Color;
        if (Color.xy == vec2(1.) && Color.z < 1. && Color.z >= 240. / 255.) {
            col = vec4(ProjMat[2][3] != 0.);
            shadeColor = vec4(vec3(mix((floor(Color.z * 255.) - 241.) / 12., 1., col.x)), col.x);
        } else if (Color.xyz == vec3(255., 107., 107.) / 255.) {
            col = vec4(1.);
            shadeColor = col;
            overlayColor = texelFetch(Sampler1, ivec2(0, 3), 0);
        }
        vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, col);
    }
    vertexDistance = fog_distance(Position, FogShape);
    texCoord0 = uv0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
