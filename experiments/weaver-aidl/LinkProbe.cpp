// SPDX-License-Identifier: Apache-2.0
// Link-only probe: never installed or run on the device.
// Include the standalone prototype until it has a public header.
#include "WeaverAidl.cpp"

int main() {
    rothko::crypto::WeaverAidl adapter;
    // Force references to the AIDL and Binder methods into the link graph.
    // This target must NOT be executed: recovery HAL availability is unknown.
    const bool connected = adapter.Connect();
    if (!connected) return 1;
    aidl::android::hardware::weaver::WeaverConfig config;
    return adapter.GetConfig(&config) ? 0 : 1;
}
