#include <string_view>
#include <vector>

#include "ll/api/event/EventBus.h"
#include "ll/api/event/client/ClientExitLevelEvent.h"
#include "ll/api/event/client/ClientJoinLevelEvent.h"
#include "ll/api/input/KeyRegistry.h"
#include "ll/api/mod/NativeMod.h"
#include "ll/api/mod/RegisterHelper.h"
#include "mc/client/game/IClientInstance.h"
#include "mc/client/player/LocalPlayer.h"
#include "mc/world/actor/player/AbilitiesIndex.h"

class FlyPremiumMod final {
public:
    static FlyPremiumMod& instance() {
        static FlyPremiumMod mod;
        return mod;
    }

    bool load() { return true; }

    bool enable() {
        auto mod = ll::mod::NativeMod::current();
        if (!mod) return false;

        auto& key = ll::input::KeyRegistry::getInstance().getOrCreateKey("fly-toggle", {'X'});
        if (!key.isValid()) {
            mod->getLogger().error("Could not register the X key binding.");
            return false;
        }

        key.registerButtonDownHandler([this](::FocusImpact, ::IClientInstance& client) {
            toggleFlight(client);
        });

        auto& events = ll::event::EventBus::getInstance();
        events.emplaceListener<ll::event::ClientJoinLevelEvent>(
            [this](ll::event::ClientJoinLevelEvent& event) {
                resetTracking();
                event.player().sendMessage("[Fly Premium] World loaded. Press X to toggle flight.");
            }
        );
        events.emplaceListener<ll::event::ClientExitLevelEvent>(
            [this](ll::event::ClientExitLevelEvent&) {
                resetTracking();
            }
        );

        mod->getLogger().info("Fly Premium loaded. Press X in a world to toggle flight.");
        return true;
    }

    bool disable() {
        restoreOriginalAbilities();
        if (auto mod = ll::mod::NativeMod::current()) {
            mod->getLogger().info("Fly Premium disabled; original abilities restored when available.");
        }
        return true;
    }

    bool unload() {
        return disable();
    }

private:
    LocalPlayer* mTrackedPlayer = nullptr;
    bool mFlyEnabled = false;
    bool mOriginalMayFly = false;
    bool mOriginalFlying = false;

    void toggleFlight(::IClientInstance& client) {
        auto* player = client.getLocalPlayer();
        if (!player) {
            if (auto mod = ll::mod::NativeMod::current()) {
                mod->getLogger().warn("X ignored: local player is not ready yet.");
            }
            return;
        }

        if (player != mTrackedPlayer) {
            resetTracking();
            mTrackedPlayer = player;
            mOriginalMayFly = player->getAbilities().getBool(AbilitiesIndex::MayFly);
            mOriginalFlying = player->getAbilities().getBool(AbilitiesIndex::Flying);
        }

        if (!mFlyEnabled) {
            player->setAbility(AbilitiesIndex::MayFly, true);
            player->setAbility(AbilitiesIndex::Flying, true);
            mFlyEnabled = true;
            player->sendMessage("[Fly Premium] Flight: ON");
            return;
        }

        player->setAbility(AbilitiesIndex::Flying, mOriginalFlying);
        player->setAbility(AbilitiesIndex::MayFly, mOriginalMayFly);
        mFlyEnabled = false;
        player->sendMessage("[Fly Premium] Flight: OFF");
    }

    void restoreOriginalAbilities() {
        if (mTrackedPlayer && mFlyEnabled) {
            mTrackedPlayer->setAbility(AbilitiesIndex::Flying, mOriginalFlying);
            mTrackedPlayer->setAbility(AbilitiesIndex::MayFly, mOriginalMayFly);
        }
        resetTracking();
    }

    void resetTracking() {
        mTrackedPlayer = nullptr;
        mFlyEnabled = false;
        mOriginalMayFly = false;
        mOriginalFlying = false;
    }
};

LL_REGISTER_MOD(FlyPremiumMod, FlyPremiumMod::instance());
