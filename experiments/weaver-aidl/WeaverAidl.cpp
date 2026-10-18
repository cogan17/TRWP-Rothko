// SPDX-License-Identifier: Apache-2.0
// Experimental, standalone Weaver AIDL v2 adapter for Rothko TWRP.
// Not wired into libvold or recovery. Build/runtime validation required.
#include <aidl/android/hardware/weaver/IWeaver.h>
#include <aidl/android/hardware/weaver/WeaverConfig.h>
#include <aidl/android/hardware/weaver/WeaverReadResponse.h>
#include <aidl/android/hardware/weaver/WeaverReadStatus.h>
#include <android/binder_manager.h>
#include <android/binder_auto_utils.h>
#include <cstdint>
#include <cstddef>
#include <android/binder_status.h>
#include <memory>
#include <vector>

namespace rothko::crypto {
namespace aw = aidl::android::hardware::weaver;

enum class WeaverResult {
    kSuccess,
    kUnavailable,
    kInvalidInput,
    kIncorrectKey,
    kThrottled,
    kFailed,
};

struct WeaverReadResult {
    WeaverResult status = WeaverResult::kFailed;
    std::vector<uint8_t> value;
    int64_t timeout_ms = 0;
};

class WeaverAidl {
public:
    bool Connect() {
        service_.reset();
        constexpr char kService[] = "android.hardware.weaver.IWeaver/default";
        // Nonblocking lookup: do not hang recovery if service is absent.
        ndk::SpAIBinder binder(AServiceManager_checkService(kService));
        if (!binder.get()) return false;
        service_ = aw::IWeaver::fromBinder(binder);
        return service_ != nullptr;
    }

    bool GetConfig(aw::WeaverConfig* config) {
        return service_ && config && service_->getConfig(config).isOk()
            && config->slots > 0 && config->keySize > 0 && config->valueSize > 0;
    }

    WeaverReadResult Verify(int32_t slot, const std::vector<uint8_t>& key) {
        WeaverReadResult result;
        aw::WeaverConfig config;
        if (!service_) {
            result.status = WeaverResult::kUnavailable;
            return result;
        }
        if (!GetConfig(&config)) return result;
        if (slot < 0 || slot >= config.slots ||
            key.size() != static_cast<size_t>(config.keySize)) {
            result.status = WeaverResult::kInvalidInput;
            return result;
        }

        aw::WeaverReadResponse response;
        const auto call = service_->read(slot, key, &response);
        if (!call.isOk()) {
            // Some HAL implementations return status as a service-specific
            // binder exception rather than a populated response.
            if (call.getExceptionCode() == EX_SERVICE_SPECIFIC) {
                switch (call.getServiceSpecificError()) {
                    case aw::IWeaver::STATUS_INCORRECT_KEY:
                        result.status = WeaverResult::kIncorrectKey;
                        return result;
                    case aw::IWeaver::STATUS_THROTTLE:
                        result.status = WeaverResult::kThrottled;
                        return result;
                    default:
                        return result;
                }
            }
            return result;
        }

        result.timeout_ms = response.timeout > 0 ? response.timeout : 0;
        switch (response.status) {
            case aw::WeaverReadStatus::OK:
                if (response.timeout == 0 &&
                    response.value.size() == static_cast<size_t>(config.valueSize)) {
                    result.status = WeaverResult::kSuccess;
                    result.value.assign(response.value.begin(), response.value.end());
                }
                break;
            case aw::WeaverReadStatus::INCORRECT_KEY:
                result.status = WeaverResult::kIncorrectKey;
                break;
            case aw::WeaverReadStatus::THROTTLE:
                result.status = WeaverResult::kThrottled;
                break;
            default:
                break;
        }
        return result;
    }

private:
    std::shared_ptr<aw::IWeaver> service_;
};

}  // namespace rothko::crypto
