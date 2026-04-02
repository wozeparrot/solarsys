#pragma once

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>
#include <hyprland/src/render/pass/PassElement.hpp>
#include <hyprland/src/helpers/signal/Signal.hpp>

class CEdgeGlow : public IHyprWindowDecoration {
  public:
    CEdgeGlow(PHLWINDOW pWindow);
    virtual ~CEdgeGlow();

    SDecorationPositioningInfo              getPositioningInfo() override;
    void                                    onPositioningReply(const SDecorationPositioningReply& data) override;
    void                                    draw(PHLMONITOR, float const& a) override;
    eDecorationType                         getDecorationType() override;
    void                                    updateWindow(PHLWINDOW) override;
    void                                    damageEntire() override;
    eDecorationLayer                        getDecorationLayer() override;
    uint64_t                                getDecorationFlags() override;

    void                                    render(PHLMONITOR, float const& a);

  private:
    void                                    updateSubsurfaceListeners();

    PHLWINDOWREF                            m_pWindow;
    std::vector<CHyprSignalListener>        m_subsurfaceCommitListeners;
    CBox                                    m_lastDamageBox;
    bool                                    m_wasGlowing = false;
};

// Pass element for the glow effect — dispatched via hooked IHyprRenderer::draw()
class CGlowPassElement : public IPassElement {
  public:
    struct SGlowData {
        CEdgeGlow* deco = nullptr;
        float      a    = 1.0f;
    };

    CGlowPassElement(const SGlowData& data) : m_data(data) {}
    virtual ~CGlowPassElement() = default;

    virtual bool             needsLiveBlur() override { return false; }
    virtual bool             needsPrecomputeBlur() override { return false; }
    virtual bool             disableSimplification() override { return true; }
    virtual const char*      passName() override { return "CGlowPassElement"; }
    virtual ePassElementType type() override { return EK_UNKNOWN; }

    SGlowData m_data;
};
