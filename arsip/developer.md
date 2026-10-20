# 🛠️ Catatan Developer & Pelajaran

[← Kembali ke README](../README.md) · <img src="https://flagcdn.com/24x18/gb.png" width="22" alt=""> [English](developer.en.md)

> 📦 **Arsip teknis** — tidak perlu dibaca end user.

Untuk siapa pun yang **membangun, merawat, atau mem-fork** tree ini — **bebas disalin & disesuaikan** untuk repo kalian sendiri.
**Baca bagian Pelajaran dulu** — itu kesalahan yang sudah kami buat, biar kamu tidak mengulanginya.

---

## Pelajaran penting (baca sebelum mengubah apa pun)

### 1. vendor_boot WAJIB punya fragmen recovery
vendor_boot v4 stok punya **dua** fragmen ramdisk: PLATFORM (`type 0x1`) dan RECOVERY (`type 0x2`, name `recovery`). Bootloader hanya memuat fragmen recovery **saat mode recovery**. Kalau TWRP dikemas sebagai **satu** fragmen platform saja, Android tetap boot tapi recovery **tidak pernah sampai ke kernel** — di HP ini: **bootloop di kedua mode**.
- Perbaikan: repack jadi platform + recovery seperti stok (`verify-image.yml`: `--ramdisk_type platform` + `--ramdisk_type recovery --ramdisk_name recovery`).
- Gejala kalau salah: bootloop boot normal **dan** recovery.

### 2. workflow_run memakai file workflow dari branch DEFAULT
Ini yang bikin kami kehilangan satu malam. Workflow yang dipicu `workflow_run` memakai definisinya dari **branch default repo**, bukan dari branch/commit yang memicunya. Jadi "Verify" otomatis mengemas build pakai `verify-image.yml` **lama** dari branch default (yang belum punya pemisahan fragmen, Pelajaran 1) → **paket bootloop**, padahal build-nya sendiri sehat.
- Perbaikan: jaga branch default selalu terbaru (merge), **atau** jalankan verify via `workflow_dispatch` dari branch kerja.
- Pelajaran: **jangan percaya centang hijau `workflow_run` di branch fitur** — itu menjalankan logika branch default yang usang.

### 3. Diagnosa dengan bukti, bukan keyakinan (jebakan ccache)
Saat paket bootloop, kami **terlalu yakin** menyalahkan ccache dan nyaris membuang build "perbaikan" 80 menit. ccache **tak bersalah**: commit sumber yang dikunci sama dengan HEAD branch default yang dipakai build yang berhasil (cabang TWRP 14.1 setahun tak berubah), jadi sumbernya identik; dan perubahan vold hanya untuk recovery. Penyebab asli = Pelajaran 2. **Bandingkan artefak yang berhasil vs rusak di tingkat struktur sebelum mengubah kode.**

### 4. HyperOS LSKF: Weaver aktif, Gatekeeper cadangan
Pelindung layar-kunci aktif memakai **Weaver** di eSE NXP, diakses lewat OMAPI — **mustahil di recovery**. HyperOS juga menyimpan pelindung **Gatekeeper** untuk synthetic password yang sama. Dekripsi recovery harus **jatuh ke pelindung Gatekeeper**.
- Gatekeeper di perangkat Android 13+ **hanya AIDL** (`android.hardware.gatekeeper-service.mitee`); jalur HIDL @1.0 tidak ada.

### 5. unwrapSyntheticPasswordBlob harus pakai protektor yang sedang dicoba
vold TWRP membaca ulang **sp-handle aktif** dari `locksettings.db` untuk memilih kunci keystore, mengabaikan handle protektor cadangan yang sedang dibuka — jadi ia mendekripsi blob pelindung Gatekeeper dengan **kunci pelindung Weaver**, dan `finish()` gagal. **Pakai handle yang sedang kamu coba.**

### 6. Touch: Focaltech mulai di mode THP
Panel boot di mode **THP** (raw-frame) yang ditujukan untuk touch HAL yang hanya ada di Android. Di recovery: tulis `0` ke `enable_touch_raw` di `on boot`, **dan** terapkan lagi tiap layar menyala lewat `postscreenunblank.sh` (layar menyala me-reset chip).

### 7. Library tertinggal dari vold
Relink list TWRP membawa lib AIDL **V1**, padahal vold kini menaut keystore2-**V4** / keymint-**V3**, dan bootstrap servicemanager butuh `/system/bin/bootstrap/linker64`. `recovery_deps.py` menambal setelah build — dan **harus GAGAL saat readelf error**, bukan lolos diam-diam.

### 8. Masuk recovery
`fastboot reboot recovery` / `reboot recovery` menulis **BCB** (boot-recovery) dan akan **mem-loop TWRP yang crash**. Jalur perangkat-keras sekali-jalan: **Power + Volume Atas** dari HP mati. Dengan TWRP yang sehat, `reboot recovery` aman (TWRP membersihkan BCB). Karena itu `1-PASANG-TWRP.bat` memakai `fastboot reboot` biasa.

---

## Commit berpengaruh

| Commit | Perubahan | Kenapa penting |
|---|---|---|
| `6a9f539` | split vendor_boot → platform + recovery fragment | **Pelajaran 1** — tanpa ini recovery bootloop |
| `2f71439` | perbaikan touch + dekripsi metadata | touch (Pelajaran 6) + mount /data |
| `5bebf11` | semua program di ramdisk bisa dimuat | lib + bootstrap linker (Pelajaran 7) |
| `9ff7a47` | buka storage via AIDL Gatekeeper | **Pelajaran 4** |
| `7c5af05` | dekripsi blob protektor dengan kunci-nya sendiri | **Pelajaran 5** |
| `5459d38` | recovery_deps gagal saat readelf error | Pelajaran 7 (ketahanan gate) |
| `5320d78` | buang ccache | dibuang saat debugging Pelajaran 3 — **ccache sebenarnya tak bersalah**, boleh dipasang lagi untuk mempercepat build |
| `0eb8a19` | kunci sumber + jalur cepat + bawa dtb | reproducibility + build cepat |

---

## Alur build

| Workflow | Fungsi |
|---|---|
| `build-twrp.yml` | sync manifest TWRP 14.1 (dikunci `twrp-sources.lock.xml`), terapkan `patches/`, build `vendorbootimage`, jalankan `recovery_deps.py` |
| `verify-image.yml` | repack jadi vendor_boot dua-fragmen seperti stok, jalankan gate struktur, kemas zip end-user, tandatangani (attestation), lalu terbitkan pre-release. **Jalankan via `workflow_dispatch` dari branch kerja** (Pelajaran 2) |
| `update-twrp-sources.yml` | segarkan kunci sumber |
| `republish-release.yml` | terbitkan ulang versi lama dari artifact run Verify (disimpan 90 hari) |

> **Rilis baru:** tambahkan dulu bagian `## vX.Y` (✨ Baru / 🔧 Perbaikan) di `CHANGELOG.md` **dan** `CHANGELOG.en.md`. Verify mengambil versi + catatan rilis dari situ, dan berhenti kalau versi kedua file berbeda. **Setiap versi punya rilis sendiri dan tidak pernah dihapus**; Verify menolak versi yang sudah ada di Releases (jalankan manual dengan `replace` kalau memang sengaja menimpa).
| `extract-stock.yml` | unduh ROM resmi & ekstrak blob stok (**manual; berat — 6.3 GB**) |

### Jalur cepat (fast path)
Versi TWRP baru atau firmware HyperOS yang **tidak mengubah kode terkompilasi** bisa pakai ramdisk build terakhir: `verify-image` meng-overlay `recovery/root` + `prebuilt/dtb` (~3 menit), tanpa kompilasi penuh.

### Gate `verify-image` (pelindung sebelum paket keluar)
Fragmen cocok stok · ukuran muat partisi · dtb sama stok · UI TWRP di fragmen recovery · fstab & modul = stok · **tiap program nemu library + linker** (`recovery_deps.py`).

---

> Mau tahu arsitektur dekripsi lebih dalam (synthetic password, protektor, keystore)? Baca komentar di `patches/system_vold/*.patch` dan `recovery/root/system/bin/postscreenunblank.sh`.
