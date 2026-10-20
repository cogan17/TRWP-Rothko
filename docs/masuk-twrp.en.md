# 🔑 Enter TWRP

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](masuk-twrp.md)

There are two ways into TWRP. Both are safe.

---

## Option 1 — Buttons (from a powered-off phone)

1. Turn the phone fully off.
2. Hold **Volume Up + Power** together.
3. When the Mi logo appears, **release Power** but keep holding **Volume Up** a little longer, until TWRP opens.

## Option 2 — Termux (needs root, fastest)

Phone already rooted (KernelSU)? Just run:

```sh
su -c 'reboot recovery'
```

(KernelSU asks for root permission for Termux the first time — **Allow** it.)

---

## ⚠️ Don't use "reboot recovery" while TWRP is misbehaving

`reboot recovery` writes a **BCB** flag to the `misc` partition. If TWRP crashes, the phone can **bootloop** into it over and over. With a working TWRP this is safe — TWRP clears the flag when it starts. Technical details: [Developer notes → Entering recovery](../arsip/developer.md#8-masuk-recovery) (Indonesian).

To leave TWRP → **Reboot → System**.
