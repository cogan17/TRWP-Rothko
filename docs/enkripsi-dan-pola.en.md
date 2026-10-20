# 🔐 Encryption & Pattern

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](enkripsi-dan-pola.md)

The phone's data is encrypted (FBE). TWRP needs **the same pattern/password** as your lock screen to open it.

---

## Unlocking the data

When TWRP starts, it asks for your pattern:

- **Main user (0):** draw the **same pattern** as your lock screen — **once, carefully**. If it's right, Download/DCIM show up right away.
- **XSpace / Second Space (999):** a separate profile with **its own password**. Enter it if you use it; otherwise **skip** — the main data stays unlocked.

## Changed your pattern? TWRP follows automatically

If you change the pattern in Android, TWRP will ask for the **new pattern** (the old one no longer works). Confirmed working on this phone.

> Still, **test once** after changing the pattern (enter TWRP, try the new pattern), after backing up important data.

## ⚠️ Don't retry the pattern over and over

Repeated wrong attempts can trigger a **temporary lockout** (gatekeeper throttling). Once is enough if you're sure. If it fails, [collect logs](masalah-dan-log.en.md) — don't keep trying.

---

## Why is this tricky on this phone? (short version)

HyperOS keeps the main key in **Weaver** (an NXP security chip) that recovery can't access, but it also stores a **Gatekeeper** protector for the same pattern. TWRP uses that Gatekeeper path. Technical details: [Developer notes](../arsip/developer.md#4-hyperos-lskf-weaver-aktif-gatekeeper-cadangan) (Indonesian).
