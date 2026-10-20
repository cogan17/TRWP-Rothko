# 🔏 Keaslian & Kredit

[← Kembali ke README](../README.md)

TWRP rothko di repo ini dibangun dan dirilis otomatis oleh GitHub Actions dari **[cogan17/TWRP-14T-PRO](https://github.com/cogan17/TWRP-14T-PRO)**. Setiap file rilis **ditandatangani secara digital**, jadi siapa pun bisa membuktikan asal-usulnya.

> Yang dibuktikan adalah **build/port TWRP untuk rothko** ini dibuat dan dirilis dari repo cogan17. TWRP sendiri adalah karya TeamWin dan para kontributor di [Kredit](#-kredit).

---

## Cara cek keaslian

1. **Halaman bukti:** **[github.com/cogan17/TWRP-14T-PRO/attestations](https://github.com/cogan17/TWRP-14T-PRO/attestations)** — daftar file yang ditandatangani beserta sidik jarinya (sha256).
2. **Lewat GitHub CLI:**
   ```
   gh attestation verify <file> --repo cogan17/TWRP-14T-PRO
   ```
   Hanya file resmi dari repo ini yang lolos.
3. **Di HP** (TWRP → *Advanced → Terminal*):
   - `cat /BUILD-INFO.txt` — repo asal, commit, dan tanggal build.
   - Bandingkan isi partisi dengan sha256 file `.img` di halaman [Releases](https://github.com/cogan17/TWRP-14T-PRO/releases):
     ```
     head -c 67108864 /dev/block/by-name/vendor_boot$(getprop ro.boot.slot_suffix) | sha256sum
     ```
     (`67108864` = ukuran file `.img` dalam byte.)

## Apa yang dibuktikan — dan tidak

| Kalau ada yang… | Hasilnya |
|---|---|
| menyebar ulang file rilis lalu mengaku buatannya | ✅ terbantah — sidik jarinya cocok dengan tanda tangan repo ini |
| mengubah file sedikit (mis. nama di `BUILD-INFO.txt`) | ✅ ketahuan — jadi file lain, tidak lolos verifikasi atas nama repo ini |
| fork repo lalu build sendiri | ✅ tanda tangan mereka menyebut **repo mereka**; riwayat commit bertanggal di repo ini membuktikan siapa yang lebih dulu |
| menyalin kodenya | tidak dicegah (proyek terbuka) — tapi asal-usulnya tetap bisa dibuktikan |

`BUILD-INFO.txt` hanyalah cap yang bisa diedit siapa saja; **tanda tangan digital** itulah buktinya.

---

## 🙏 Kredit

| Siapa | Kontribusi |
|---|---|
| **JonesqPacMan** | Device tree asal rothko ("Initial Release", 21 Sep 2025) — dasar repo ini |
| **Cogan17** | Maintainer: port ke HyperOS 3 / Android 16, dekripsi pola (Gatekeeper), vendor_boot dua-fragmen, sinkron firmware, paket & skrip end user, CI dan rilis |
| **[TeamWin Recovery Project](https://twrp.me)** | TWRP itu sendiri |
| **[minimal-manifest-twrp](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp)** | Manifest sumber build |
| **AOSP (Google) & LineageOS** | Kode platform Android yang ikut dibangun |
| **phhusson** | `vendor_lptools` |
| **[ssut / payload-dumper-go](https://github.com/ssut/payload-dumper-go)** | Mengekstrak firmware resmi di workflow |
| **[XiaomiFirmwareUpdater](https://github.com/XiaomiFirmwareUpdater)** | Katalog ROM resmi |
| **Xiaomi & MediaTek** | Firmware, modul kernel, dan blob vendor — diambil dari ROM resmi, hak milik masing-masing |

Mau memakai tree ini untuk repo-mu? Silakan — cantumkan kredit di atas, dan baca [catatan teknis](../arsip/developer.md) dulu.
