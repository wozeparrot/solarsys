#define WLR_USE_UNSTABLE

#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/debug/log/Logger.hpp>

#include "EdgeGlow.hpp"

HANDLE PHANDLE = nullptr;

static std::vector<SP<HOOK_CALLBACK_FN>> g_callbacks;

static void onNewWindow(void* self, SCallbackInfo& info, std::any data) {
    auto pWindow = std::any_cast<PHLWINDOW>(data);
    HyprlandAPI::addWindowDecoration(PHANDLE, pWindow, makeUnique<CEdgeGlow>(pWindow));
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

    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:range", Hyprlang::INT{24});
    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:power", Hyprlang::FLOAT{2.0});
    HyprlandAPI::addConfigValue(PHANDLE, "plugin:edge-glow:alpha", Hyprlang::FLOAT{0.8});

    g_callbacks.push_back(HyprlandAPI::registerCallbackDynamic(PHANDLE, "openWindow", onNewWindow));

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
    g_callbacks.clear();
    Log::logger->log(Log::INFO, "[edge-glow] Plugin unloaded");
}
