#pragma once

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>
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
    PHLWINDOWREF        m_pWindow;
    CHyprSignalListener m_commitListener;
    CBox                m_lastDamageBox;
    bool                m_wasGlowing = false;
};
