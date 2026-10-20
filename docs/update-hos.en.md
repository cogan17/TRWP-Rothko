# 🔄 Update HyperOS Without Losing Data

[← Back to README](../README.en.md) · <img src="https://flagcdn.com/24x18/id.png" width="22" alt=""> [Bahasa Indonesia](update-hos.md)

When a HyperOS update arrives, TWRP and root usually **disappear with it**. This is the **safe** way to update — your data stays intact, with no risky restore.

---

## ✅ The safe way (recommended)

This way your data **carries over by itself**, so there is **no manual `/data` restore** (and no risk of conflicts):

1. **Back up first** — data, personal files, **and** the `boot`/`init_boot`/`vendor_boot` partitions. See [Backup](backup.en.md). This is your safety net.
2. **[Go back to stock](kembali-ke-stok.en.md)** first (remove TWRP/root) — OTAs often **fail** while partitions are still modified.
3. **Take the OTA from Settings → do NOT wipe.** An OTA does **not** erase `/data`, so your apps and data stay.
4. **Install TWRP + root again** (the version matching the new HyperOS).

> 💡 The point: let the OTA carry your data. A manual restore is the last resort.

---

## ⚠️ Don't restore an old `/data` backup onto a different HyperOS version

This is the mistake that most often breaks phones. A full `/data` restore is **only safe onto the SAME OS version**.

Why it conflicts: `/data` contains **system data** (`/data/system`) holding the **lock-screen and encryption keys** (pattern/PIN), tied to the old HyperOS build and the security chip. Restored onto a new HyperOS, the typical symptoms are:

- 🔒 Pattern/PIN **rejected**, data **fails to decrypt**.
- 💥 Settings / SystemUI **force-closes**, or a **bootloop**.

---

## If you must move data between versions

Not the full `/data`. Split it:

| Kind | How | Safe? |
|---|---|---|
| **Personal files** (photos, Download, documents) | copy normally via MTP / File Manager | ✅ always safe |
| **Apps + their data** | use an app backup: **Swift Backup** / **Neo Backup** | ✅ safe (doesn't touch system data) |
| **Full `/data` (.win)** | TWRP restore | ⛔ only onto the same OS version |

---

## The trap that surprises people

TWRP's **"Data"** backup **does NOT include photos / internal storage by default** (`/data/media`). So if you only back up "Data", **your photos are not backed up.** Tick internal storage too, or copy it manually via MTP.

> **Golden rule:** OTA without wipe = data safe automatically. Restore `/data` = only onto the same OS version.
