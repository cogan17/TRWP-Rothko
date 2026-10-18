// SPDX-License-Identifier: Apache-2.0
// Link-only probe: never installed or run on the device.
// Include the standalone prototype until it has a public header.
#include "WeaverAidl.cpp"

#if !__has_attribute(retain)
#error "The link probe requires compiler support for the retain attribute."
#endif

namespace {
using VerifyMethod = rothko::crypto::WeaverReadResult (
    rothko::crypto::WeaverAidl::*)(int32_t, const std::vector<uint8_t>&);

// 'used' requests compiler emission; 'retain' roots the ELF data section
// against linker garbage collection. Its relocation references Verify without
// invoking it. Confirm the emitted section/relocation and optimized link map
// in an approved build; volatile alone is not an explicit linker-retention rule.
__attribute__((used, retain))
const VerifyMethod verify_reference = &rothko::crypto::WeaverAidl::Verify;
}  // namespace

int main() {
    rothko::crypto::WeaverAidl adapter;
    // This target must NOT be executed: recovery HAL availability is unknown.
    const bool connected = adapter.Connect();
    if (!connected) return 1;
    aidl::android::hardware::weaver::WeaverConfig config;
    return adapter.GetConfig(&config) ? 0 : 1;
}
