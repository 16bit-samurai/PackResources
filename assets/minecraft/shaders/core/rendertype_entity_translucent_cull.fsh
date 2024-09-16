#version 150

#moj_import <fog.glsl>

#define TWO_PI (6.283185307)
#define PI (3.141592654)

uniform sampler2D Sampler0;
uniform mat4 ModelViewMat;
uniform vec2 ScreenSize;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 shadeColor;
in vec4 lightMapColor;
flat in float finish;
in float alphaOffset;
in vec4 normal;

out vec4 fragColor;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, -s, s, c);
	return m * v;
}

float noise21(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 4.1414))) * 43758.5453);
}

vec2 noise22(vec2 p) {
    return fract(vec2(noise21(p), noise21(p+232.245)));
}

vec3 noise23(vec2 p) {
    return fract(vec3(noise21(p), noise21(p+232.245), noise21(p+345.768)));
}

const vec3 MAGMA_BASE_1 = vec3(0.25, 0.025, 0.025);
const vec4 MAGMA_OVERLAY_1 = vec4(1., 0., 0., 0.);
const vec3 MAGMA_BRIGHT_1 = vec3(0., 0.3, 0.);
const vec3 MAGMA_MAX_1 = vec3(0.25);

const vec3 MAGMA_BASE_2 = vec3(0.15, 0.05, 0.16) * 1.2;
const vec4 MAGMA_OVERLAY_2 = vec4(0.6, 0., 0.6, 0.);
const vec3 MAGMA_BRIGHT_2 = vec3(0.1, 0.2, 0.15);
const vec3 MAGMA_MAX_2 = vec3(0.1, 0.3, 0.1);

const vec3 MAGMA_BASE_3 = vec3(0.08, 0.15, 0.01) * 1.1;
const vec4 MAGMA_OVERLAY_3 = vec4(0.3, 0.4, 0.1, 0.);
const vec3 MAGMA_BRIGHT_3 = vec3(0.12, 0.18, 0.0);
const vec3 MAGMA_MAX_3 = vec3(0.5, 0.3, 0.);

const vec3 MAGMA_RED = MAGMA_BASE_1;
const vec4 MAGMA_OVERLAY = MAGMA_OVERLAY_1;
const vec3 MAGMA_BRIGHT = MAGMA_BRIGHT_1;
const vec3 MAGMA_MAX = MAGMA_MAX_1;

// const vec3 MAGMA_RED = MAGMA_BASE_2;
// const vec4 MAGMA_OVERLAY = MAGMA_OVERLAY_2;
// const vec3 MAGMA_BRIGHT = MAGMA_BRIGHT_2;
// const vec3 MAGMA_MAX = MAGMA_MAX_2;

// const vec3 MAGMA_RED = MAGMA_BASE_3;
// const vec4 MAGMA_OVERLAY = MAGMA_OVERLAY_3;
// const vec3 MAGMA_BRIGHT = MAGMA_BRIGHT_3;
// const vec3 MAGMA_MAX = MAGMA_MAX_3;

vec4 molten(vec2 p) {
    vec4 col = MAGMA_OVERLAY;
    float column = floor(p.x / 3.);
    float part = mod(p.x, 3.);
    float t = noise21(vec2(column * 63., 0.));
    float where = mod(floor(GameTime * (8000. + floor(t * 8000.))) - floor(t * 24. + abs(part - 1.)) - p.y, 20.);
    if (where < 10. && part < 3.) {
        float b = 1. - where / 10.;
        col.a += b;
        if (b > 0.5) {
            col.rgb += MAGMA_BRIGHT;
        }
        if (b > 0.9) {
            col.rgb += MAGMA_MAX;
        }
    }
    return col;
}

vec3 matrix(vec2 uv, vec3 shade, vec2 dim) {
    uv.y += mod(floor(uv.x / 8.), 2.) * 4.;
    vec2 uv2 = mod(uv, 8.) / 8.;
    vec2 block = uv / 8. - uv2;
    uv2.x += floor(noise21(block + floor(GameTime * (4000. + 200. * floor(8. * noise21(block + 1.67))))) * 10.);
    vec4 letter = texture(Sampler0, (uv2 * 8. + vec2(0., 497.)) / dim);
    vec3 col = letter.rgb * letter.a;
    uv.x -= mod(uv.x, 8.);
    float offset = sin(uv.x * 15.);
    float speed = cos(uv.x * 3.) * .3 + .7;
    float squash = 1.;
    float y = min(fract(-floor(uv.y / 2.) / 18. + GameTime * 1000. * speed + offset), squash) / squash;
    col *= .07 / pow(abs(sin(-0.1+(y)*3.14159/2.2)), 1.25);
    return min(col, vec3(1.)) * shade;
}

vec3 matrixOld(vec2 uv, vec3 shade, vec2 dim) {
    uv.y += mod(floor(uv.x / 8.), 2.) * 4.;
    vec2 uv2 = mod(uv, 8.) / 8.;
    vec2 block = uv / 8. - uv2;
    uv2.x += floor(noise21(block + floor(GameTime * (5000. + 200. * floor(8. * noise21(block + 1.31))))) * 10.);
    vec4 letter = texture(Sampler0, (uv2 * 8. + vec2(0., 497.)) / dim);
    vec3 col = shade * letter.rgb * letter.a;
    uv.x -= mod(uv.x, 8.);
    float offset = sin(uv.x * 15.);
    float speed = cos(uv.x * 3.) * .3 + .7;
    float squash = 1.;
    float y = 1. - fract(floor(uv.y / 2.) / 16. - GameTime * 1000. * speed + offset);
    col *= shade / (y * 20.);
    return col;
}

vec4 flowers(vec2 uv, float size, float s, vec2 dim, vec2 tex) {
    uv /= size;
    uv *= s;
    float column = floor(uv.x / s);
    float tx = fract(uv.x / s) * size;
    vec2 n = noise22(vec2(column, column * 2.3));
    float time = GameTime * (500. + floor(n.x * 8.) * 250.);
    float ct = uv.y - time + n.y * size;
    float t = mod(ct, size);
    float ty = t * (size / s);
    vec2 rot = rotate(vec2(tx, ty) - size / 2., (n.x < .5 ? -1. : 1.) * GameTime * 1000. + column) + size / 2.;
    if (rot.y >= 0. && rot.y < size && rot.x >= 0. && rot.x < size) {
        float shadei = min(mod(floor(n.y * 7.) + floor(ct / size), 7.), 6.);
        vec3 shade0 = texture(Sampler0, vec2(0., 304. + shadei) / dim).rgb;
        vec3 shade1 = texture(Sampler0, vec2(1., 304. + shadei) / dim).rgb;
        vec4 c0 = texture(Sampler0, (rot + tex) / dim);
        vec4 c1 = texture(Sampler0, (rot + tex + vec2(16., 0.)) / dim);
        vec3 v = mix(mix(shade1, shade0, c0.r), c1.rgb, c1.a);
        return vec4(v, min(c0.a + c1.a, 1.));
    }
    return vec4(0.);
}

vec4 texture2D_bilinear(in sampler2D t, in vec2 uv, in vec2 textureSize, in vec2 texelSize) {
    vec2 f = fract( uv * textureSize );
    uv += ( .5 - f ) * texelSize;
    vec4 tl = texture(t, uv);
    vec4 tr = texture(t, uv + vec2(texelSize.x, 0.));
    vec4 bl = texture(t, uv + vec2(0., texelSize.y));
    vec4 br = texture(t, uv + vec2(texelSize.x, texelSize.y));
    vec4 tA = mix( tl, tr, f.x );
    vec4 tB = mix( bl, br, f.x );
    return mix( tA, tB, 1. - (1. - f.y) * (1. - f.y) );
}

vec4 finishRainbow(vec4 rgb, vec2 dim, vec2 uv) {
    float t = GameTime * 1000.;
    float t2 = fract(t);
    float x01 = mod(floor(t), 8.) * 16.;
    float x1 = mod(floor(t) + 1., 8.) * 16.;
    vec4 overlay1 = texture(Sampler0, (mod(uv, 16.) + vec2(x01, 256.)) / dim);
    vec4 overlay2 = texture(Sampler0, (mod(uv, 16.) + vec2(x1, 256.)) / dim);
    vec4 overlay = mix(overlay1, overlay2, t2);
    rgb.rgb *= overlay.rgb;
    return rgb;
}

vec4 finishChrome(vec4 rgb, vec2 dim, vec2 uv) {
    vec3 norm = normalize(normal.xyz);
    
    vec4 blur = texture2D_bilinear(Sampler0, texCoord0, dim, 1. / dim);
    float d0 = (rgb.r + rgb.g + rgb.b) / 3.;
    float d1 = (blur.r + blur.g + blur.b) / 3.;

    norm.xz = rotate(norm.xz, .33 * asin(fract(mod(uv.x, 16.) / 16.)) + (d0 - d1));
    norm.xy = rotate(norm.xy, .33 * asin(fract(mod(uv.y, 16.) / 16.)) + (d0 - d1));

    vec3 ref = normalize(reflect(normalize((ModelViewMat * vec4(0., 0., -1., 0.)).xyz), norm)); 
	vec3 dir = ref / max(max(abs(ref.x), abs(ref.y)), abs(ref.z));
	vec3 absDir = abs(dir);

	vec2 ruv;
	if (absDir.x >= absDir.y && absDir.x > absDir.z) {
		if (dir.x > 0.) {
			ruv = dir.zy * vec2(1., -1.);
		} else {
			ruv = -dir.zy;
		}
	} else if (absDir.y >= absDir.z) {
		if (dir.y > 0.) {
			ruv = dir.xz * vec2(-1., 1.);
		} else {
			ruv = -dir.xz;
		}
	} else {
		if (dir.z > 0.) {
			ruv = -dir.xy;
		} else {
			ruv = dir.xy * vec2(1., -1.);
		}
	}
    vec4 r = texture(Sampler0, (mod((ruv + 1.) * 4., 16.) + vec2(80., 288.)) / dim);
    rgb.rgb = rgb.r * r.rgb;
    return rgb;
}

const vec3 GLITCH_A_1 = vec3(.85, .5, .9);
const vec3 GLITCH_B_1 = vec3(.85, .9, .9);
const vec3 GLITCH_F_1 = vec3(0., 1., 1.);

const vec3 GLITCH_A_2 = vec3(.7, .9, .85);
const vec3 GLITCH_B_2 = vec3(.3, .8, 1.);
const vec3 GLITCH_F_2 = vec3(1., 1.5, 1.5);

const vec3 GLITCH_A_3 = vec3(.4, .3, .9);
const vec3 GLITCH_B_3 = vec3(1., .22, .3);
const vec3 GLITCH_F_3 = vec3(1., 1., 0.);

const vec3 GLTICH_A = GLITCH_A_1;
const vec3 GLTICH_B = GLITCH_B_1;
const vec3 GLTICH_F = GLITCH_F_1;

// const vec3 GLTICH_A = GLITCH_A_2;
// const vec3 GLTICH_B = GLITCH_B_2;
// const vec3 GLTICH_F = GLITCH_F_2;

// const vec3 GLTICH_A = GLITCH_A_3;
// const vec3 GLTICH_B = GLITCH_B_3;
// const vec3 GLTICH_F = GLITCH_F_3;

vec4 finishGlitch(vec4 rgb, vec2 dim, vec2 uv) {
    float time = GameTime * 800.;
    vec2 coord = uv / 2.;
    coord.y += mod(floor(coord.x), 2.) * .5;
    vec2 tile = floor(coord);
    
    float tt = min(1., fract(time) * 6.);
    float t0 = (1. - abs(1. - 2. * tt));
    time += 2. * tile.x * t0;
    vec2 noiseA = noise22(vec2(floor(time) * .9, 3.));
    vec2 noiseB = noise22(vec2(floor(time + 1.) * .9, 3.));
    
    vec2 dir1 = normalize(vec2(.2, -1.));
    vec2 dir2 = normalize(vec2(.3, .4));
    vec2 v1 = mix(rotate(dir1, noiseA.x * 6.28), rotate(dir1, noiseB.x * 6.28), tt);
    vec2 v2 = mix(rotate(dir2, noiseA.y * 6.28), rotate(dir2, noiseB.y * 6.28), tt);

    vec2 v0 = rotate(normalize(vec2(1., .1)), GameTime * 1000.);
    float fo = .8;
    float ps = mod(floor(uv.y - GameTime * 1000. + t0 * .75), 2) * .07;
    vec4 rc = texture(Sampler0, (uv + v0 * fo) / dim);
    vec4 gc = texture(Sampler0, (uv + v1 * fo) / dim);
    vec4 bc = texture(Sampler0, (uv + v2 * fo) / dim);
    float r = mix(GLTICH_A.r, rc.r * GLTICH_B.r, rc.a) - ps * GLTICH_F.r;
    float g = mix(GLTICH_A.g, gc.g * GLTICH_B.g, gc.a) - ps * GLTICH_F.g;
    float b = mix(GLTICH_A.b, bc.b * GLTICH_B.b, bc.a) - ps * GLTICH_F.b;
    return vec4(r, g, b, rgb.a);
}

vec4 finishTile(vec4 rgb, vec2 dim, vec2 uv) {
     // orange
    vec3 DITHER_A_1 = mix(vec3(0xff, 0xca, 0x35)/255., vec3(0xff, 0x55, 0x35)/255., 0.33);
    vec3 DITHER_B_1 = vec3(0xe9, 0x69, 0x2e)/255.;
     // pink
    vec3 DITHER_A_2 = vec3(0xac, 0x42, 0xb6)/255.;
    vec3 DITHER_B_2 = vec3(0xff, 0x77, 0xb6)/255.;
     // green
    vec3 DITHER_A_3 = vec3(0x62, 0xa0, 0x39)/255.;
    vec3 DITHER_B_3 = vec3(0xca, 0xd8, 0x34)/255.;
    // cyan
    vec3 DITHER_A_4 = vec3(0x88, 0xff, 0xaf)/255.;
    vec3 DITHER_B_4 = vec3(0x41, 0x9e, 0x94)/255.;

    vec3 DITHER_A = DITHER_A_1;
    vec3 DITHER_B = DITHER_B_1;

    uv.y += mod(floor(uv.x / 2.), 2.);
    uv /= 2.0;
    float off = abs(floor(uv.x)) + abs(floor(uv.y));
    float time = -GameTime * 600. + off / 16.;
    float local = pow(fract(time), 1.2);
    vec2 coord = fract(uv) * 2. - 1.;
    coord = rotate(coord, time * (0.5 * PI));
    float t = max(0., sign(max(abs(coord.x), abs(coord.y)) - local));
    float t0 = mix(t, 1. - t, mod(floor(time), 2.));
    rgb.rgb = mix(rgb.rgb, min(vec3(1.0), rgb.rgb + vec3(0.1)), t0);
    //rgb.rgb = rgb.r * mix(DITHER_A, DITHER_B, t0);
    return rgb;
}

vec4 finishGalaxy(vec4 rgb, vec2 dim, vec2 uvg, vec2 p2) {
    rgb.rgb *= texture(Sampler0, (mod(uvg - (GameTime * 2000.), 16.) + vec2(0., 288.)) / dim).rgb +
    0.5 * texture(Sampler0, (mod(rotate(mod(p2 - (GameTime * 1000.), 24.), 0.15), 24.) + vec2(112., 288.)) / dim).rgb;
    return rgb;
}

float rand(vec2 c){
	return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float noise(vec2 p, float unit){
	vec2 ij = floor(p/unit);
	vec2 xy = mod(p,unit)/unit;
	xy = .5*(1.-cos(PI*xy));
	float a = rand((ij+vec2(0.,0.)));
	float b = rand((ij+vec2(1.,0.)));
	float c = rand((ij+vec2(0.,1.)));
	float d = rand((ij+vec2(1.,1.)));
	float x1 = mix(a, b, xy.x);
	float x2 = mix(c, d, xy.x);
	return mix(x1, x2, xy.y);
}

vec4 compose(vec4 dst, vec4 src) {
    float a = src.a + dst.a * (1. - src.a);
    return vec4((src.rgb * src.a + dst.rgb * dst.a * (1. - src.a)) / a, a);
}

vec2 wh_c(vec2 p, float f) {
    return vec2(atan(p.y, p.x) / PI, .3 / (1.25 - f));
}

vec2 wh_g(vec2 p, vec2 c, float sd) {
    vec2 g = mix(p * 22., c * 16., max(0., sign(sd)));
    g = rotate(g, -.7);
    g.x -= 31.;
    g = rotate(g, GameTime * (6. * TWO_PI));
    g.x += 31.;
    return g;
}

vec3 wh_bg(vec2 g, float f) {
    return mix(vec3(90./255., 50./255., 100./255.),
        vec3(3./255., 1./255., 7./255.),
        max(0, sqrt(f) - max(.0, noise(g * .1, .25) * -.25 + .3875)));
}

vec4 wh(vec2 uv) {
    vec2 p = uv - vec2(.5);
    float r = noise(normalize(p) + vec2(cos(GameTime * (48. * TWO_PI)), sin(GameTime * (32. * TWO_PI))), .31) * -.05 + .25;
    float sd = length(p) - r;
    float f = clamp(1. - sd / (.5 - r), 0., 1.);
    vec2 c = wh_c(p, f);
    vec2 g = wh_g(p, c, sd);
    vec3 bg = wh_bg(g, f);
    if (c.x - .925 > 0.) {
        bg = mix(bg, wh_bg(wh_g(p, c + vec2(-2., 0.), sd), f), (c.x - .925) / .075);
    }
    float v = noise(floor(g) * 1.1 + 1., .5) - .13;
    vec2 l = rotate(fract(g) - vec2(.5), v * 99.);
    bg = mix(bg, vec3(.25), -sign(min(0., max(v, fract(v * 31.) * .05 - .1 + max(abs(l.x), abs(l.y))))));
    vec4 w = vec4(bg, f * f);
    float t = pow(fract(GameTime * 400.) * 2., 1.3) - .3;
    if (t < .7 && (sd < 0. || t > 0.)) {
        float d = length(rotate(p, fract(sin(floor(GameTime * 400.) * 3.82)) * -PI) * 8. +
            vec2(t * t * -8. - 1.2, 0.)) / ((sqrt(max(0., t)) * .2 + .05));
        if (d < 1.) {
            w = compose(w, vec4(vec3(1.), pow(1. - d, 3.3)));
        }
    }
    float wt = fract(GameTime - .25);
    float blend = clamp(cos(((wt * 2. + (cos(wt * PI) * -.5 + .5)) / 3.) * TWO_PI) * 2. + .5, 0., 1.);
    w.rgb = mix(w.rgb, vec3(0.2, 0.2, 0.5), mix(0., .5, blend));
    w.a *= mix(1., .5, blend);
    return w;
}

void main() {
    vec4 rgb = texture(Sampler0, texCoord0);
    vec4 vCol = vertexColor;
    vec4 sCol = shadeColor;
    if (vCol == vec4(0.) && rgb.xw == vec2(1.)) {
        vCol = vec4(1.);
        sCol = vec4(1.);
        if (shadeColor.x > 1.) {
            rgb = vec4(0.);
        } else {
            if (rgb.y < shadeColor.x) {
                float t = 2. * shadeColor.x;
                rgb = vec4(vec3(t < 1. ? 1. : 2. - t, t < 1. ? t : 1., 0.), 1.);
            } else {
                rgb = vec4(vec3(0.), 1.);
            }
        }
    }
    float rr = sign(abs(rgb.a - 252. / 255.));
    float e = sign(abs(rgb.a - 254. / 255.)) * rr;
    float noshade = sign(abs(rgb.a - 253. / 255.));
    rgb.a = mix(mix(.75, 1., rr), rgb.a, e * noshade);
    rgb.a = max(0., rgb.a - alphaOffset);

    if (finish > 0.) {
        vec2 dim = vec2(textureSize(Sampler0, 0));
        vec2 uv = texCoord0 * dim;
        if (finish == 1.) {
            rgb = finishRainbow(rgb, dim, uv);
        } else if (finish == 2.) {
            // GOLD
            float per = 12000.;
            float x0 = mod(floor(GameTime * per), 30.) * 16.;
            vec4 overlay11 = texture(Sampler0, (mod(uv, 16.) + vec2(x0 + 16., 272.)) / dim);
            rgb.rgb = texture(Sampler0, (vec2(0., 272. + round(.8 * rgb.x * 9. + 0.25) + round(overlay11.a))) / dim).rgb;
        } else if (finish == 3.) {
            // GALAXY
            rgb = finishGalaxy(rgb, dim, uv, uv*2.);
        } else if (finish == 4.) {
            // MAGMA
            vec3 col = MAGMA_RED * 3.;
            vec4 s1 = molten(floor(mod(uv, 128.)));
            //col = mix(col, s1.rgb, s1.a);
            vec4 s2 = molten(floor(mod(uv * 2. + vec2(722., 63.), 128.)));
            //col = mix(col, s2.rgb, s2.a * 0.5);
            
            //col = mix(col, s1.rgb + s2.rgb, (s1.a + s2.a * 0.4));

            vec3 rgbsum = floor((s1.rgb + s2.rgb) * 4. + 0.5) / 4.;
            col = mix(col, rgbsum, (s1.a + s2.a * 0.4));

            rgb.rgb *= col;
        } else if (finish == 5.) {
            // BUBBLES
            vec2 p2 = uv * 1.5;
            p2 = rotate(p2, 0.15);
            vec2 bob = vec2(sin(GameTime * 4000.) * 0.75, 0.);
            vec2 bob1 = vec2(sin(GameTime * 4000. - 1500.) * 0.75, 0.);
            rgb.rgb *=
                texture(Sampler0, (mod(uv, 16.) + vec2(16., 288.)) / dim).rgb +
                texture(Sampler0, (mod(uv * 1.75 - bob + vec2(0., GameTime * 6000.), 16.) + vec2(32., 288.)) / dim).rgb +
                texture(Sampler0, (mod(uv * 1.75 - bob1 + vec2(0., GameTime * 6000. + 3000.), 16.) + vec2(32., 288.)) / dim).rgb +
                texture(Sampler0, (mod(uv * 1.25 - bob + vec2(0., GameTime * 6000.), 16.) + vec2(64., 288.)) / dim).rgb +
                texture(Sampler0, (mod(uv * 1.25 - bob + vec2(12., GameTime * 3000. + 3000.), 16.) + vec2(64., 288.)) / dim).rgb +
                texture(Sampler0, (mod(uv * 1.   - bob1 + vec2(0., GameTime * 8000.), 16.) + vec2(48., 288.)) / dim).rgb;
        } else if (finish == 6.) {
            // FLORAL
            float t = GameTime * 100. + (uv.x + uv.y) / 32.;
            float pct = sin(fract(t) * (3.141593 / 2.));
            pct *= pct;
            float x0 = mod(floor(t), 4.) * 16.;
            float x1 = mod(floor(t) + 1, 4.) * 16.;
            vec3 col0 = texture(Sampler0, (mod(uv, 16.) + vec2(48 + x0, 304.)) / dim).rgb;
            vec3 col1 = texture(Sampler0, (mod(uv, 16.) + vec2(48 + x1, 304.)) / dim).rgb;
            vec3 col = mix(col0, col1, pct);
            vec4 f = flowers(uv, 3., 1., dim, vec2(22., 314.));
            col = mix(col, f.rgb, f.a * 0.75);
            f = flowers(uv, 6., 1., dim, vec2(16., 314.));
            col = mix(col, f.rgb, f.a * 0.8);
            f = flowers(uv, 10., 1., dim, vec2(16., 304.));
            col = mix(col, f.rgb, f.a);
            rgb.rgb *= col;
        } else if (finish == 7.) {
            // MATRIX
            if (true) {
                vec3 shade = vec3(0., 1.0, 0.3);// * 1.2; // 1
                // vec3 shade = vec3(1.0, 0.1, 0.0) * 1.5; // 2
                //vec3 shade = vec3(0.3, 1.2, 1.4); // 2
                vec3 col = matrixOld(uv * 1.5, shade, dim) * .7 +
                    min(matrixOld(uv * 3. - 2., shade, dim) * .5, .25);
                rgb.rgb *= shade * 0.1 * 0.95 + 0.05;
                rgb.rgb += col.rgb;
                rgb.rgb = min(rgb.rgb, vec3(1.));
            } else {
                vec3 shade = vec3(0., 1.0, 0.3)*.15;
                vec3 shade2 = vec3(0., 1.0, 0.3);
                vec3 col = matrix(uv * 4. - 2., shade2, dim) * .45 + matrix((uv - vec2(2., 0.)) * 2., shade2, dim) * .55;
                rgb.rgb = max(rgb.rgb, vec3(0.5));
                rgb.rgb *= shade;
                rgb.rgb += col;
                rgb.rgb = min(rgb.rgb, vec3(1.));
            }
        } else if (finish == 8.) {
            rgb = finishChrome(rgb, dim, uv);
        } else if (finish == 9.) {
            rgb = finishGlitch(rgb, dim, uv);
        } else if (finish == 10.) {
            rgb = finishTile(rgb, dim, uv);
        }
    } else if (floor(finish) == -1.) {
        vec2 size = textureSize(Sampler0, 0);
        rgb = texture2D_bilinear(Sampler0, texCoord0, size, 1. / size);
    } else if (floor(finish) == -2.) {
        rgb = wh(texCoord0);
        noshade = 1.;
        e = 1.;
    }

    if (floor(finish) == -3.) {
        fragColor = vec4(vec3(16.), mix(208., 192., texCoord0.y))/255.;
    } else if (floor(finish) == -4.) {
        fragColor = vec4(vec3(1./255.), 1.);
    } else if (rgb == vec4(0., 1., 1., 1.)) {
        fragColor = vec4(0.);
    } else {
        vec4 color = rgb * mix(sCol, vCol, e * noshade) * ColorModulator;
        if (color.a < .01) {
            discard;
        }
        color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
        color *= mix(vec4(1.), lightMapColor, e);
        fragColor = linear_fog(color, vertexDistance - (1. - e) * 4., FogStart, FogEnd, FogColor);
    }
}
