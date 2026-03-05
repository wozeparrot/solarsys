#pragma once

#include <string>

inline const std::string GLOW_VERT = R"(#version 300 es
    uniform mat3 proj;
    in vec2 posAttrib;
    in vec2 texAttrib;
    out vec2 v_texcoord;

    void main() {
        gl_Position = vec4((proj * vec3(posAttrib, 1.0)).xy, 0.0, 1.0);
        v_texcoord = texAttrib;
    }
)";

// %s is replaced with extension pragma, %s with sampler type
// All spatial uniforms are in pixel space for correct rounding on non-square windows
inline const std::string GLOW_FRAG_TEMPLATE = R"(#version 300 es
    %s
    precision highp float;
    in vec2 v_texcoord;

    uniform %s tex;
    uniform vec2 glowSize;    // glow box size in pixels
    uniform vec2 winTL;       // window top-left within glow box (pixels)
    uniform vec2 winBR;       // window bottom-right within glow box (pixels)
    uniform float range;      // glow range in pixels
    uniform float power;
    uniform float rounding;   // corner rounding in pixels
    uniform float alpha;

    layout(location = 0) out vec4 fragColor;

    float sdRoundBox(vec2 p, vec2 b, float r) {
        vec2 q = abs(p) - b + vec2(r);
        return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
    }

    void main() {
        // work in pixel space for correct aspect ratio
        vec2 pos = v_texcoord * glowSize;
        vec2 center = glowSize * 0.5;
        vec2 halfSize = (winBR - winTL) * 0.5;

        float dist = sdRoundBox(pos - center, halfSize, rounding);

        // inside window or outside glow range
        if (dist <= 0.0 || dist > range)
            discard;

        // nearest point on the ROUNDED rectangle edge (not just the rectangle)
        vec2 relPos = pos - center;
        vec2 absRel = abs(relPos);
        vec2 cornerThreshold = halfSize - vec2(rounding);
        vec2 winSize = winBR - winTL;

        vec2 nearest;
        if (rounding > 0.0 && absRel.x > cornerThreshold.x && absRel.y > cornerThreshold.y) {
            // corner region: project onto the rounding arc
            vec2 cornerCenter = center + sign(relPos) * cornerThreshold;
            vec2 toPoint = pos - cornerCenter;
            float len = length(toPoint);
            vec2 dir = len > 0.001 ? toPoint / len : vec2(1.0, 0.0);
            nearest = cornerCenter + dir * rounding;
        } else {
            // straight edge: clamp to rectangle
            nearest = clamp(pos, winTL, winBR);
        }

        // direction inward from the edge
        vec2 inward = center - nearest;
        float inwardLen = length(inward);
        vec2 inwardDir = inwardLen > 0.001 ? inward / inwardLen : vec2(0.0);

        // weighted average of 3 samples inward (skip exact edge pixels)
        vec2 p1 = nearest + inwardDir * 2.0;
        vec2 p2 = nearest + inwardDir * 4.0;
        vec2 p3 = nearest + inwardDir * 6.0;

        vec2 uv1 = (clamp(p1, winTL, winBR) - winTL) / winSize;
        vec2 uv2 = (clamp(p2, winTL, winBR) - winTL) / winSize;
        vec2 uv3 = (clamp(p3, winTL, winBR) - winTL) / winSize;

        vec4 edgeColor = texture(tex, uv1) * 0.5
                       + texture(tex, uv2) * 0.33
                       + texture(tex, uv3) * 0.17;

        float falloff = pow(1.0 - dist / range, power);
        // use edge alpha; texture is premultiplied so scale rgb by our falloff only
        float fa = falloff * alpha;
        fragColor = vec4(edgeColor.rgb * fa, edgeColor.a * fa);
    }
)";

inline std::string glowFragSource(bool external) {
    char buf[4096];
    if (external) {
        snprintf(buf, sizeof(buf), GLOW_FRAG_TEMPLATE.c_str(),
                 "#extension GL_OES_EGL_image_external_essl3 : require",
                 "samplerExternalOES");
    } else {
        snprintf(buf, sizeof(buf), GLOW_FRAG_TEMPLATE.c_str(), "", "sampler2D");
    }
    return std::string(buf);
}
