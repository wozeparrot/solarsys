#define WLR_USE_UNSTABLE

#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/render/Renderer.hpp>

#include "EdgeGlow.hpp"

HANDLE PHANDLE = nullptr;

static CHyprSignalListener g_windowOpenListener;
static CFunctionHook*       g_pDrawHook = nullptr;

// Hook for IHyprRenderer::draw(WP<IPassElement>, const CRegion&)
// Intercepts our CGlowPassElement since 0.54.0 removed virtual draw() from IPassElement
typedef void (*tDrawOrigFn)(void*, WP<IPassElement>, const CRegion&);

static void hookRendererDraw(void* thisptr, WP<IPassElement> element, const CRegion& damage) {
    if (element && element->type() == EK_UNKNOWN &&
        std::string_view(element->passName()) == "CGlowPassElement") {
        auto* glow = static_cast<CGlowPassElement*>(element.get());
        glow->m_data.deco->render(
            g_pHyprRenderer->m_renderData.pMonitor.lock(),
            glow->m_data.a);
        return;
    }
    ((tDrawOrigFn)g_pDrawHook->m_original)(thisptr, std::move(element), damage);
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string HASH = __hyprland_api_get_hash();

    if (HASH != __hyprland_api_get_client_hash()) {
        HyprlandAPI::addNotification(PHANDLE, "[edge-glow] version mismatch! reinstall the plugin.",
                                     CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[edge-glow] version mismatch");
    }

    // Hook the renderer's pass element dispatch to handle our custom element
    auto fns = HyprlandAPI::findFunctionsByName(PHANDLE, "draw");
    for (auto& fn : fns) {
        if (fn.demangled.contains("IPassElement") && fn.demangled.contains("IHyprRenderer")) {
            g_pDrawHook = HyprlandAPI::createFunctionHook(PHANDLE, fn.address, (void*)&hookRendererDraw);
            g_pDrawHook->hook();
            break;
        }
    }

    if (!g_pDrawHook) {
        HyprlandAPI::addNotification(PHANDLE, "[edge-glow] failed to hook renderer draw!",
                                     CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
    }

    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:range", Hyprlang::INT{24});
    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:power", Hyprlang::FLOAT{2.0});
    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:alpha", Hyprlang::FLOAT{0.8});

    g_windowOpenListener = Event::bus()->m_events.window.open.listen([](PHLWINDOW pWindow) {
        HyprlandAPI::addWindowDecoration(PHANDLE, pWindow, makeUnique<CEdgeGlow>(pWindow));
    });

    for (auto& w : g_pCompositor->m_windows) {
        if (!w->m_isMapped)
            continue;
        HyprlandAPI::addWindowDecoration(PHANDLE, w, makeUnique<CEdgeGlow>(w));
    }

    HyprlandAPI::addNotification(PHANDLE, "[edge-glow] loaded OK!",
                                 CHyprColor{0.2, 1.0, 0.2, 1.0}, 5000);

    return {"edge-glow", "Per-pixel window edge glow", "woze", "1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    g_windowOpenListener.reset();
    Log::logger->log(Log::INFO, "[edge-glow] Plugin unloaded");
}
