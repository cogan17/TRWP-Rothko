// SPDX-License-Identifier: Apache-2.0
// Link-only probe: never installed or run on the device.
// Include the standalone prototype until it has a public header.
#include "WeaverAidl.cpp"

int main() {
    rothko::crypto::WeaverAidl adapter;
    // The Verify reference is intentionally unreachable at runtime. Keeping
    // its address in a volatile function pointer makes its read path part of
    // the link graph without attempting any Weaver credential operation.
    using VerifyMethod = rothko::crypto::WeaverReadResult (
        rothko::crypto::WeaverAidl::*)(int32_t, const std::vector<uint8_t>&);
    VerifyMethod volatile verify_reference = &rothko::crypto::WeaverAidl::Verify;
    (void)verify_reference;

    // This target must NOT be executed: recovery HAL availability is unknown.
    const bool connected = adapter.Connect();
    if (!connected) return 1;
    aidl::android::hardware::weaver::WeaverConfig config;
    return adapter.GetConfig(&config) ? 0 : 1;
}
