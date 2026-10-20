# 🩺 Issues & Logs

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](masalah-dan-log.md)

If something goes wrong, **don't guess** — collect the logs and send them. Logs show exactly where it failed.

---

## Which log script to use?

| Situation | Script | What it collects |
|---|---|---|
| TWRP runs but something's wrong (touch, pattern, mount) | **`3-AMBIL-LOG.bat`** | `recovery.log`, dmesg, logcat, etc. |
| Phone **bootloops** / won't boot | **`4-LOG-BOOTLOOP.bat`** | `console-ramoops-0` (log of the failed boot) + `recovery.log` |

Both save the results to your PC's **`Downloads`** folder, then open the folder automatically.

## For a bootloop — the order matters

`console-ramoops-0` = a record of the last seconds of the failed boot. To keep it intact:
1. **Don't force the phone off** while it bootloops.
2. Enter TWRP straight from the bootloop (**Volume Up + Power**).
3. Only then run `4-LOG-BOOTLOOP.bat`.

## Most useful to send

- `recovery.log` — for almost any TWRP issue.
- `console-ramoops-0` — for bootloops.

---

## Common issues

| Symptom | Likely cause | See |
|---|---|---|
| Bootloop on the Mi logo | broken image / wrong package | [Back to stock](kembali-ke-stok.en.md) |
| "Failed to decrypt" / pattern fails | protector / pattern | [Encryption & Pattern](enkripsi-dan-pola.en.md) |
| Touchscreen doesn't respond | THP touch mode | [Developer notes §6](../arsip/developer.en.md#6-touch-focaltech-starts-in-thp-mode) |
| Download/DCIM empty | data not decrypted yet | unlock with your pattern first |
