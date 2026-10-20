# 🔒 Runbook Maintainer (internal)

> Catatan operasional cara menjalankan workflow. **Bukan untuk end user** — tidak di-link dari
> README/panduan. Pelajaran teknis (kenapa) ada di [docs/developer.md](../docs/developer.md).

## Daftar workflow

| Workflow | Fungsi | Jalan |
|---|---|---|
| **Build TWRP** | compile TWRP dari sumber (~80 mnt) | manual / otomatis |
| **Extract stock blobs** | tarik modul + dtb + blob + backup stok dari ROM resmi | manual |
| **Verify TWRP image** | repack dua-fragmen (jalur cepat) + gate + pre-release | manual / otomatis |
| **Update TWRP sources** | cek/tarik commit TWRP terbaru ke lock | manual |
| **Rothko Build Storage Gate** | diagnostik sisa disk/RAM runner — **abaikan** | manual |

Jalankan dari tab **Actions** → pilih workflow → **Run workflow**.

---

## Skenario & urutan

### A. HyperOS update (sinkron blob) — paling sering
1. **Extract stock blobs** → Run workflow. Isi:
   - `version` — versi HOS baru (mis. `OS3.0.4xx.0.XXXXX`)
   - `rom_url` — link **ROM recovery resmi** (.zip berisi `payload.bin`)
   - `rom_md5` — md5 ROM
   - `boot_sha256` — sha256 `boot.img` yang di-dump dari HP (bukti ROM = firmware HP)
   - → commit ke branch `stock/<version>`, dan upload backup stok vendor_boot/boot/init_boot
2. **Review + merge** branch `stock/<version>` → `twrp-14.1_a16`
3. **Verify TWRP image** → Run workflow. Isi `twrp_run_id` = nomor run **Build TWRP** terakhir yang sukses.
   - → paket + **pre-release** otomatis (~3 mnt, tanpa compile)

### B. Versi TWRP baru keluar
1. **Update TWRP sources** → Run (mode `update`)
   - → commit lock baru, otomatis memicu **Build TWRP** → otomatis **Verify**

### C. Build ulang dari nol (jarang)
1. **Build TWRP** → Run → otomatis **Verify**

> **Verify jalan otomatis** setelah Build (skenario B & C). Di skenario A, Verify dijalankan **manual**.

---

## Cara dapat input `Extract stock blobs`

- **`rom_url` + `rom_md5`:** dari **XiaomiFirmwareUpdater** (cari device `rothko`, ambil **Recovery ROM** atau **Fastboot ROM** yang punya `payload.bin`).
- **`boot_sha256`:** dump `boot.img` dari HP, lalu `sha256sum`:
  - via TWRP Backup `boot` → ambil `boot.emmc.win` (itu isi partisi boot), atau
  - via root: `dd if=/dev/block/by-name/boot of=/sdcard/boot.img` → `sha256sum boot.img`.
  - Gunanya: kalau sha256 tidak cocok dengan kernel di ROM, workflow **berhenti** (ROM salah firmware).

---

## Catatan operasional (jangan diulangi kesalahannya)

- **Verify via `workflow_run` memakai definisi dari branch DEFAULT.** Jadi jaga `twrp-14.1_a16` selalu terbaru (merge), atau jalankan Verify via `workflow_dispatch` dari branch kerja. (Ini penyebab bootloop semalam — paket lama di-repack verify versi usang dari default.)
- **ccache sudah dibuang** — pernah disangka penyebab bootloop, ternyata bukan. Boleh dipasang lagi untuk mempercepat build, tapi tidak wajib.
- **Pre-release** butuh `GH_REPO` di step-nya karena repo di-checkout ke subfolder `repo/` (tanpa itu `gh release` gagal "not a git repository").
- **Jalur cepat** = Verify meng-overlay `recovery/root` + `prebuilt/dtb` ke ramdisk build terakhir → tidak perlu compile ulang untuk ganti modul/dtb/blob.
- **Build penuh (80 mnt)** hanya kalau **kode TWRP** berubah (patch vold/dekripsi, dll) — bukan karena HOS update.
- **Hapus branch** harus lewat web/PC (proxy sesi memblokir penghapusan ref).

---

## Alur praktis saat HOS beneran update
1. Backup dulu (data + partisi).
2. Kembalikan stok sebelum ambil OTA (OTA sering gagal kalau partisi termodifikasi).
3. Ambil OTA → tes TWRP lama.
4. Kalau ada yang rusak (sentuh/layar/boot) → jalankan skenario **A** di atas.
