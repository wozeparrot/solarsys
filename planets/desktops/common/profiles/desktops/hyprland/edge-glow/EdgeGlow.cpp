#include "EdgeGlow.hpp"

#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/view/Window.hpp>
#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Shader.hpp>
#include <hyprland/src/render/Texture.hpp>
#include <hyprland/src/render/pass/PassElement.hpp>
#include <hyprland/src/protocols/types/SurfaceState.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/debug/log/Logger.hpp>
#include "Shaders.hpp"

extern HANDLE PHANDLE;

// ── Render pass element ──────────────────────────────────────────────────────

class CGlowPassElement : public IPassElement {
  public:
    struct SGlowData {
        CEdgeGlow* deco = nullptr;
        float      a    = 1.0f;
    };

    CGlowPassElement(const SGlowData& data) : m_data(data) {}
    virtual ~CGlowPassElement() = default;

    virtual void draw(const CRegion& damage) override {
        m_data.deco->render(g_pHyprOpenGL->m_renderData.pMonitor.lock(), m_data.a);
    }

    virtual bool        needsLiveBlur() override { return false; }
    virtual bool        needsPrecomputeBlur() override { return false; }
    virtual bool        disableSimplification() override { return true; }
    virtual const char* passName() override { return "CGlowPassElement"; }

  private:
    SGlowData m_data;
};

// ── Shader globals ───────────────────────────────────────────────────────────

static SP<CShader> g_pGlowShader;
static SP<CShader> g_pGlowShaderExt;
static GLuint g_vao      = 0;
static bool   g_compiled = false;

static GLint g_locProj = -1, g_locTex = -1;
static GLint g_locGlowSize = -1, g_locWinTL = -1, g_locWinBR = -1;
static GLint g_locRange = -1, g_locPower = -1, g_locRounding = -1, g_locAlpha = -1;

static GLint g_locProjExt = -1, g_locTexExt = -1;
static GLint g_locGlowSizeExt = -1, g_locWinTLExt = -1, g_locWinBRExt = -1;
static GLint g_locRangeExt = -1, g_locPowerExt = -1, g_locRoundingExt = -1, g_locAlphaExt = -1;

static void ensureShaders() {
    if (g_compiled)
        return;
    g_compiled = true;

    g_pGlowShader = makeShared<CShader>();
    if (!g_pGlowShader->createProgram(GLOW_VERT, glowFragSource(false))) {
        g_pGlowShader.reset();
        return;
    }

    GLuint prog = g_pGlowShader->program();
    g_locProj     = glGetUniformLocation(prog, "proj");
    g_locTex      = glGetUniformLocation(prog, "tex");
    g_locGlowSize = glGetUniformLocation(prog, "glowSize");
    g_locWinTL    = glGetUniformLocation(prog, "winTL");
    g_locWinBR    = glGetUniformLocation(prog, "winBR");
    g_locRange    = glGetUniformLocation(prog, "range");
    g_locPower    = glGetUniformLocation(prog, "power");
    g_locRounding = glGetUniformLocation(prog, "rounding");
    g_locAlpha    = glGetUniformLocation(prog, "alpha");

    g_pGlowShaderExt = makeShared<CShader>();
    if (g_pGlowShaderExt->createProgram(GLOW_VERT, glowFragSource(true))) {
        GLuint progExt = g_pGlowShaderExt->program();
        g_locProjExt     = glGetUniformLocation(progExt, "proj");
        g_locTexExt      = glGetUniformLocation(progExt, "tex");
        g_locGlowSizeExt = glGetUniformLocation(progExt, "glowSize");
        g_locWinTLExt    = glGetUniformLocation(progExt, "winTL");
        g_locWinBRExt    = glGetUniformLocation(progExt, "winBR");
        g_locRangeExt    = glGetUniformLocation(progExt, "range");
        g_locPowerExt    = glGetUniformLocation(progExt, "power");
        g_locRoundingExt = glGetUniformLocation(progExt, "rounding");
        g_locAlphaExt    = glGetUniformLocation(progExt, "alpha");
    } else {
        g_pGlowShaderExt.reset();
    }

    // Create VAO with position + UV VBOs
    const float positions[] = { 0,0, 0,1, 1,0, 1,1 };
    const float uvs[]       = { 0,0, 0,1, 1,0, 1,1 };

    GLint posLoc = glGetAttribLocation(prog, "posAttrib");
    GLint texLoc = glGetAttribLocation(prog, "texAttrib");

    glGenVertexArrays(1, &g_vao);
    glBindVertexArray(g_vao);

    if (posLoc >= 0) {
        GLuint posVbo = 0;
        glGenBuffers(1, &posVbo);
        glBindBuffer(GL_ARRAY_BUFFER, posVbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(positions), positions, GL_STATIC_DRAW);
        glEnableVertexAttribArray(posLoc);
        glVertexAttribPointer(posLoc, 2, GL_FLOAT, GL_FALSE, 0, nullptr);
    }

    if (texLoc >= 0) {
        GLuint uvVbo = 0;
        glGenBuffers(1, &uvVbo);
        glBindBuffer(GL_ARRAY_BUFFER, uvVbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(uvs), uvs, GL_STATIC_DRAW);
        glEnableVertexAttribArray(texLoc);
        glVertexAttribPointer(texLoc, 2, GL_FLOAT, GL_FALSE, 0, nullptr);
    }

    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

// ── IHyprWindowDecoration ────────────────────────────────────────────────────

CEdgeGlow::CEdgeGlow(PHLWINDOW pWindow) : IHyprWindowDecoration(pWindow), m_pWindow(pWindow) {
    auto res = pWindow->resource();
    if (res)
        m_commitListener = res->m_events.commit.listen([this]() { damageEntire(); });
}

CEdgeGlow::~CEdgeGlow() {}

SDecorationPositioningInfo CEdgeGlow::getPositioningInfo() {
    SDecorationPositioningInfo info;
    info.policy         = DECORATION_POSITION_ABSOLUTE;
    info.priority       = 1000;
    info.reserved       = false;
    info.desiredExtents = {{24, 24}, {24, 24}};
    return info;
}

void CEdgeGlow::onPositioningReply(const SDecorationPositioningReply& data) {}

eDecorationType CEdgeGlow::getDecorationType() {
    return DECORATION_CUSTOM;
}

void CEdgeGlow::updateWindow(PHLWINDOW pWindow) {
    damageEntire();
}

void CEdgeGlow::damageEntire() {
    const auto PWINDOW = m_pWindow.lock();
    if (!PWINDOW)
        return;

    static auto PRANGE = CConfigValue<Hyprlang::INT>("plugin:edge-glow:range");
    const int   range = *PRANGE;

    // Use animated position/size so damage tracks resize/move animations
    auto pos = PWINDOW->m_realPosition->value();
    auto siz = PWINDOW->m_realSize->value();
    CBox dmg = {pos.x - range, pos.y - range,
                siz.x + 2 * range, siz.y + 2 * range};
    g_pHyprRenderer->damageBox(dmg);

    // Also damage the previous glow area to clear old artifacts on resize/move
    if (m_lastDamageBox.w > 0 && m_lastDamageBox.h > 0)
        g_pHyprRenderer->damageBox(m_lastDamageBox);

    m_lastDamageBox = dmg;
}

eDecorationLayer CEdgeGlow::getDecorationLayer() {
    return DECORATION_LAYER_BOTTOM;
}

uint64_t CEdgeGlow::getDecorationFlags() {
    return DECORATION_PART_OF_MAIN_WINDOW | DECORATION_NON_SOLID;
}

// draw() enqueues a render pass element — no direct GL here
void CEdgeGlow::draw(PHLMONITOR pMonitor, float const& a) {
    const auto PWINDOW = m_pWindow.lock();
    if (!PWINDOW || !PWINDOW->m_isMapped)
        return;

    auto fs = Desktop::focusState();
    if (!fs || PWINDOW != fs->window()) {
        // Focus moved away — damage glow area once to clear the old glow
        if (m_wasGlowing) {
            m_wasGlowing = false;
            damageEntire();
        }
        return;
    }

    m_wasGlowing = true;

    ensureShaders();
    if (!g_pGlowShader || !g_vao)
        return;

    CGlowPassElement::SGlowData data;
    data.deco = this;
    data.a    = a;
    g_pHyprRenderer->m_renderPass.add(makeUnique<CGlowPassElement>(data));
}

// render() does the actual GL work — called by CGlowPassElement::draw()
void CEdgeGlow::render(PHLMONITOR pMonitor, float const& a) {
    const auto PWINDOW = m_pWindow.lock();
    if (!PWINDOW || !pMonitor)
        return;

    static auto PRANGE = CConfigValue<Hyprlang::INT>("plugin:edge-glow:range");
    static auto PPOWER = CConfigValue<Hyprlang::FLOAT>("plugin:edge-glow:power");
    static auto PALPHA = CConfigValue<Hyprlang::FLOAT>("plugin:edge-glow:alpha");
    const int   range     = *PRANGE;
    const float power     = static_cast<float>(*PPOWER);
    const float glowAlpha = static_cast<float>(*PALPHA);

    // Window box from animated position/size (tracks resize smoothly)
    CBox windowBox = {PWINDOW->m_realPosition->value().x, PWINDOW->m_realPosition->value().y,
                      PWINDOW->m_realSize->value().x, PWINDOW->m_realSize->value().y};

    // Workspace offset
    const auto PWORKSPACE      = PWINDOW->m_workspace;
    const auto WORKSPACEOFFSET = PWORKSPACE && !PWINDOW->m_pinned ? PWORKSPACE->m_renderOffset->value() : Vector2D();

    // Scale window box first (same rounding as the window itself),
    // then expand by scaled range in pixel space
    float scaledRange = range * pMonitor->m_scale;

    CBox glowBox = windowBox;
    glowBox.translate(-pMonitor->m_position + WORKSPACEOFFSET);
    glowBox.translate(PWINDOW->m_floatingOffset);
    glowBox.scale(pMonitor->m_scale).round();
    // expand in pixel space so center matches the window's rounded position
    glowBox.x -= std::round(scaledRange);
    glowBox.y -= std::round(scaledRange);
    glowBox.w += 2 * std::round(scaledRange);
    glowBox.h += 2 * std::round(scaledRange);

    // Apply render modifications (matches window surface rendering pipeline)
    g_pHyprOpenGL->m_renderData.renderModif.applyToBox(glowBox);

    if (glowBox.w < 1 || glowBox.h < 1)
        return;

    // Get window texture
    auto pResource = PWINDOW->resource();
    if (!pResource) {
        static bool s_loggedNoResource = false;
        if (!s_loggedNoResource) {
            Log::logger->log(Log::WARN, "[edge-glow] focused window has null resource()");
            s_loggedNoResource = true;
        }
        return;
    }
    auto tex = pResource->m_current.texture;
    if (!tex) {
        static bool s_loggedNoTexture = false;
        if (!s_loggedNoTexture) {
            Log::logger->log(Log::WARN, "[edge-glow] focused window has null m_current.texture");
            s_loggedNoTexture = true;
        }
        return;
    }

    // Select shader variant
    bool isExternal = (tex->m_type == TEXTURE_EXTERNAL);
    auto& shader    = isExternal ? g_pGlowShaderExt : g_pGlowShader;
    if (!shader)
        return;

    GLuint prog        = shader->program();
    GLint locProj      = isExternal ? g_locProjExt      : g_locProj;
    GLint locTex       = isExternal ? g_locTexExt        : g_locTex;
    GLint locGlowSize  = isExternal ? g_locGlowSizeExt   : g_locGlowSize;
    GLint locWinTL     = isExternal ? g_locWinTLExt      : g_locWinTL;
    GLint locWinBR     = isExternal ? g_locWinBRExt      : g_locWinBR;
    GLint locRange     = isExternal ? g_locRangeExt      : g_locRange;
    GLint locPower     = isExternal ? g_locPowerExt      : g_locPower;
    GLint locRounding  = isExternal ? g_locRoundingExt   : g_locRounding;
    GLint locAlpha     = isExternal ? g_locAlphaExt      : g_locAlpha;

    // Projection matrix
    Mat3x3 matrix   = g_pHyprOpenGL->m_renderData.monitorProjection.projectBox(glowBox, HYPRUTILS_TRANSFORM_NORMAL, glowBox.rot);
    Mat3x3 glMatrix = g_pHyprOpenGL->m_renderData.projection.copy().multiply(matrix);

    // Pixel-space values — derive window bounds from glowBox to avoid rounding mismatch
    float roundingPx = PWINDOW->rounding() * pMonitor->m_scale;
    float roundedRange = std::round(scaledRange);
    float overlap = 2.0f; // pixels of glow extending under window edge
    float winL = roundedRange + overlap;
    float winT = roundedRange + overlap;
    float winR = glowBox.w - roundedRange - overlap;
    float winB = glowBox.h - roundedRange - overlap;

    // Save GL state
    GLint prevProg = 0;
    glGetIntegerv(GL_CURRENT_PROGRAM, &prevProg);
    GLint prevVao = 0;
    glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &prevVao);

    // Bind window texture
    glActiveTexture(GL_TEXTURE0);
    tex->bind();

    glUseProgram(prog);

    // Set uniforms (all spatial values in pixels)
    auto mat = glMatrix.getMatrix();
    glUniformMatrix3fv(locProj, 1, GL_TRUE, mat.data());
    glUniform1i(locTex, 0);
    glUniform2f(locGlowSize, glowBox.w, glowBox.h);
    glUniform2f(locWinTL, winL, winT);
    glUniform2f(locWinBR, winR, winB);
    glUniform1f(locRange, roundedRange);
    glUniform1f(locPower, power);
    glUniform1f(locRounding, roundingPx);
    glUniform1f(locAlpha, glowAlpha * a);

    g_pHyprOpenGL->blend(true);

    glBindVertexArray(g_vao);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Restore GL state
    glBindVertexArray(prevVao);
    glUseProgram(prevProg);
    tex->unbind();
}
