# Rothko Weaver — rencana validasi build recovery (tahap 65)

Status: **rencana dan patch source siap ditinjau; build belum dijalankan**.
Update tahap 66: Clang yang dibutuhkan tersedia dalam source AOSP yang dipilih;
identitas commit dan target symlink sudah diperiksa pada remote resmi. Bukti:
[toolchain metadata](twrp-rothko-stage66-toolchain.json). Tidak perlu mengganti
versi compiler. Workspace Android lengkap dan manifest hasil checkout belum ada.
PR #2 tetap Draft/HOLD. Tidak ada perubahan pada vold produksi, integrasi HAL,
workflow, atau cabang default. Rencana ini hanya menguji satu executable probe
yang tidak dipasang dan tidak dijalankan pada perangkat.

## Source yang dipatok

Manifest dasar: `minimal-manifest-twrp/platform_manifest_twrp_aosp`, commit
`cb31ddec08f495d3f70631b22140642d0045ba0d`, file `default.xml`.
Default AOSP-nya adalah tag `android-14.0.0_r67`; ini bukan bukti kompatibilitas
FBE Android 16. Overlay selektif: [validation-pins.xml](../../experiments/weaver-aidl/validation-pins.xml).

| Path dalam workspace | Commit |
| --- | --- |
| `device/xiaomi/rothko` | `c471f27f7811c0e96bca5a824f7281dd1a4fdabe` |
| `build/make` | `506df226dd003a364916b6b3ee1eb3bf9064f97f` |
| `bootable/recovery` | `426b747737e7ce9e9e17da5b4d2ba883f296aec7` |
| `system/core` | `ab2f1a4834dd01c2aa17989b887b1e794c3d342d` |
| `build/soong` | `fed50f11f6d8dd08dd157e5450e938e2d11dbbb3` |
| `system/vold` | `8e2fb2556d9d4d0b2ad5fea2e301d7c445a1ddb5` |
| `hardware/interfaces` | `a155fffda456a650c3b89c5d13092172446782a8` |
| `vendor/twrp` | `1b4b1ff73617ff690ea525e1e1955ae9be603cbf` |
| `system/tools/aidl` | `de1052c28d821a7f9263b986e9200c4ca4971276` |
| `frameworks/native` | `64792e223d982e7032ef17d797484b488bdb887c` |
| `build/release` | `e4fc71a1aef3d297e11f710d4e31fc34f77bfd90` |
| `prebuilts/clang/host/linux-x86` | `7154d3eddcb62ff7909a6ae2bf0c03e445e65bc4` |

Overlay ini **bukan lock seluruh workspace**: proyek lain pada manifest masih
mengikuti revision masing-masing. Setelah source disiapkan di checkout terpisah,
ekspor `repo manifest -r -o resolved-manifest.xml`, simpan seluruh diff lokal dan
hash patch, lalu gunakan snapshot itu untuk reproduksi. Jangan mengaku seluruh
workspace sudah terkunci hanya berdasarkan dua belas pin di atas. Jika device tree
sudah tercantum dalam local manifest lain, ganti entri itu; jangan menggandakan
project pada path yang sama.

Pada tahap 65, commit AOSP untuk AIDL, Binder dan build/release diperoleh dari annotated tag
`android-14.0.0_r67` pada mirror `aosp-mirror-neo`; tag menunjuk ke commit yang
tercantum. Pembacaan langsung Gitiles untuk file terkait gagal pada sesi ini.
Tahap 66 berhasil membaca remote AOSP resmi secara langsung dan mencocokkan
ketiga commit tersebut, beserta commit prebuilt Clang. Mirror tidak ditambahkan
sebagai remote build. Identitas checkout nyata tetap perlu dicocokkan saat sync.
Pin TeamWin berasal dari repo TeamWin.

## Temuan source yang menentukan prosedur

| Temuan | Konsekuensi |
| --- | --- |
| Soong `cc/config/global.go` memilih `clang-r510928`, short version `18` | Tahap 66 membuktikan direktorinya ada dalam snapshot AOSP, dengan metadata versi `18.0.0` dan target symlink yang tersedia. Versi executable dan kompatibilitas host tetap perlu diperiksa sebelum bootstrap. |
| `cc/cc.go` menambahkan suffix `.recovery` untuk modul dengan varian core dan recovery | Target yang diminta adalah `rothko_weaver_aidl_link_probe.recovery`, bukan nama tanpa suffix atau static archive. Konfirmasi lagi target hasil generate. |
| Weaver `aidl_interface` tidak mengisi `Recovery_available`; generator AIDL meneruskan properti tersebut ke library native | Ada kekurangan deklarasi source untuk varian recovery Weaver. Siapkan override terisolasi; keberhasilan graph dan dependensi transitif belum dibuktikan. |
| `libbinder_ndk` AOSP pada pin di atas menyatakan `recovery_available: true` | Dukungan deklaratif Binder tersedia; seluruh dependensi recovery tetap harus diperiksa di graph. |
| `envsetup.sh` memerlukan `<product>-<release>-<variant>`; `build/release` mendeklarasikan `ap2a` | Gunakan `twrp_rothko-ap2a-eng`; menu dua bagian dalam device tree perlu disesuaikan pada checkout validasi. |
| BoardConfig mengizinkan missing dependencies; `soong_config.mk` mengirim nilai itu ke Soong | Ubah menjadi `false` hanya dalam checkout validasi dan periksa JSON konfigurasi hasil generate. Environment variable saja tidak membuktikan override berhasil. |

## Patch validasi yang sudah disiapkan

[validation-workspace.patch](../../experiments/weaver-aidl/validation-workspace.patch)
berisi tiga perubahan untuk diterapkan dari root workspace Android:

1. `hardware/interfaces/weaver/aidl/Android.bp`: tambahkan `recovery_available: true`.
2. `device/xiaomi/rothko/AndroidProducts.mk`: gunakan pilihan lunch dengan `ap2a`.
3. `device/xiaomi/rothko/BoardConfig.mk`: set `ALLOW_MISSING_DEPENDENCIES := false`.

Patch hanya tersimpan sebagai bahan validasi; ketiga file produksi tersebut
belum diubah di repo ini. `git apply --check` lulus terhadap tiga file referensi
yang sesuai pin. Ini membuktikan kecocokan patch, bukan kompilasi atau dukungan
HAL. Jangan menerapkan patch ke checkout lain dengan revision yang berbeda.

## Urutan pelaksanaan setelah build terisolasi diizinkan

Gunakan satu checkout Android Linux yang terpisah dan direktori output baru.
Jangan memulai sync besar atau menggunakan checkout kerja milik owner tanpa
persetujuan. Tidak ada workspace Android lengkap atau runner yang disiapkan
oleh tahap ini. Perintah berikut merupakan prosedur, belum dieksekusi.

1. Siapkan manifest pada commit di atas. Tambahkan overlay selektif sebagai
   local manifest, sync source, cocokkan dua belas SHA, dan ekspor manifest penuh.
   Simpan versi `repo`, status/diff tiap project, dan hash kedua file validasi.
2. Periksa prebuilt yang dipilih Soong:

   ```bash
   prebuilts/clang/host/linux-x86/clang-r510928/bin/clang++ --version
   prebuilts/clang/host/linux-x86/clang-r510928/bin/ld.lld --version
   ```

   Jika direktori hilang atau versi tidak sesuai, **berhenti sebelum build**.
   Jangan mengganti compiler diam-diam atau membuat symlink ke versi lain.
   Catat `LLVM_PREBUILTS_BASE`, `LLVM_PREBUILTS_VERSION`, dan
   `LLVM_RELEASE_VERSION` bila disetel, karena Soong mengizinkan override ini.
   Versi dan hash executable nyata harus ikut bukti; nilai default source saja
   tidak cukup. Linker harus mendukung `SHF_GNU_RETAIN`.
3. Dari root workspace, jalankan `git apply --check` terhadap patch tersimpan,
   lalu terapkan sekali. Simpan diff ketiga project/file hasilnya. Jalankan
   audit Python yang sudah tersedia dari device tree; jangan membuat job CI baru.
4. Pilih output dan produk secara eksplisit:

   ```bash
   export OUT_DIR=out/rothko-weaver-validation
   source build/envsetup.sh
   lunch twrp_rothko-ap2a-eng
   ```

   Lunch dapat menjalankan bootstrap/configuration dan fungsi roomservice pada
   fork ini; langkah ini termasuk fase yang memerlukan izin. Tolak tambahan
   project/revision dari roomservice yang mengubah snapshot. Cocokkan kembali
   manifest/diff jika ada perubahan. Tidak boleh ada pemilihan release tebakan.
5. Jalankan **satu** target recovery, dengan log command verbose dari build
   system dan exit code yang dipertahankan:

   ```bash
   NINJA_ARGS="-v" m -j4 rothko_weaver_aidl_link_probe.recovery
   ```

   Jangan membangun target tanpa suffix sebagai pengganti. Pada konfigurasi
   hasil generate, pastikan `Allow_missing_dependencies` bernilai false dalam
   `$OUT_DIR/soong/soong.variables` dan alias Make menunjuk ke varian recovery.
   Kegagalan graph apa pun, termasuk dependensi baseline di luar Weaver, adalah
   kegagalan; simpan error pertama dan dependensinya sebelum mengubah source.
   Jangan mengaktifkan kembali missing dependencies agar job terlihat hijau.

## Bukti kelulusan yang harus dikumpulkan

| Gate | Bukti yang diperlukan |
| --- | --- |
| Identitas input | Manifest penuh dengan SHA, diff lokal, hash overlay/patch, dan SHA device source. |
| Toolchain | Path, versi, dan hash Clang/LLD yang benar-benar dipakai oleh command build. |
| Recovery graph | Varian arm64 recovery probe, `android.hardware.weaver-V2-ndk` dan `libbinder_ndk`, serta dependensi transitif; tanpa missing-dependency placeholder atau system-only substitute. |
| Kompilasi dan link | Command nyata untuk `LinkProbe.cpp` beserta final link; archive saja tidak cukup. Catat optimasi, GC, dan apakah LTO benar-benar aktif. |
| Retensi Verify | ELF arm64 **unstripped** dari varian recovery; `llvm-nm -C` untuk referensi/method, `llvm-readelf` untuk retained section dan relocation pada object native, serta disassembly/link map yang menelusuri referensi ke implementasi Verify. Jika LTO menghasilkan bitcode, gunakan object native setelah LTO; jangan memperlakukan bitcode sebagai ELF. |
| Isolasi | `installable: false`, tidak ada probe dalam product packages atau staging image, tidak ada perubahan libvold produksi, dan probe tidak pernah dijalankan. |

Temukan path ELF dari output graph yang dipilih; jangan menebak hash varian
atau memakai ELF core yang kebetulan bernama sama. Periksa output sebelum
stripping. Tidak adanya simbol literal `IWeaver::read` bukan bukti kegagalan
atau keberhasilan karena panggilan bisa virtual/inlined. Jika build tidak
menghasilkan link map secara default, simpan command dan siapkan instrumentasi
map khusus probe untuk ditinjau; jangan mengklaim map sudah diperiksa atau
menjalankan build kedua tanpa alasan yang berasal dari hasil pertama.

Build probe yang lulus hanya menutup gate API/link/retensi pada konfigurasi
yang diuji. NXP HAL dalam ramdisk recovery, startup service, throttling,
Gatekeeper/Keystore2, dekripsi FBE Android 16, packaging vendor_boot dan ukuran
partisi tetap memerlukan validasi tersendiri. Tidak ada izin flash atau merge
yang tersirat dari rencana ini.

## Referensi source

- [Manifest dan include TWRP pada pin dasar](https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp/tree/cb31ddec08f495d3f70631b22140642d0045ba0d).
- [Default Clang dan override Soong](https://github.com/TeamWin/android_build_soong/blob/fed50f11f6d8dd08dd157e5450e938e2d11dbbb3/cc/config/global.go#L388-L390).
- [Suffix recovery](https://github.com/TeamWin/android_build_soong/blob/fed50f11f6d8dd08dd157e5450e938e2d11dbbb3/cc/cc.go#L1923-L1928) dan [pemilihan image variant](https://github.com/TeamWin/android_build_soong/blob/fed50f11f6d8dd08dd157e5450e938e2d11dbbb3/cc/image.go#L547-L553).
- [Penerusan NINJA_ARGS](https://github.com/TeamWin/android_build_soong/blob/fed50f11f6d8dd08dd157e5450e938e2d11dbbb3/ui/build/ninja.go#L104-L110).
- [Format lunch](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/envsetup.sh#L807-L817) dan [pengiriman missing-dependency flag](https://github.com/TeamWin/android_build/blob/506df226dd003a364916b6b3ee1eb3bf9064f97f/core/soong_config.mk#L52).
- [Weaver AIDL pada pin TeamWin](https://github.com/TeamWin/android_hardware_interfaces/blob/a155fffda456a650c3b89c5d13092172446782a8/weaver/aidl/Android.bp).
- [Propagasi properti AIDL, salinan tagged source](https://github.com/aosp-mirror-neo/platform_system_tools_aidl/blob/de1052c28d821a7f9263b986e9200c4ca4971276/build/aidl_interface_backends.go#L147-L180).
- [Binder NDK, salinan tagged source](https://github.com/aosp-mirror-neo/platform_frameworks_native/blob/64792e223d982e7032ef17d797484b488bdb887c/libs/binder/ndk/Android.bp#L35-L39).
- [Release ap2a, salinan tagged source](https://github.com/aosp-mirror-neo/platform_build_release/blob/e4fc71a1aef3d297e11f710d4e31fc34f77bfd90/release_config_map.mk#L23).
- [Prebuilt Clang pada commit AOSP yang sudah diverifikasi](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/7154d3eddcb62ff7909a6ae2bf0c03e445e65bc4/clang-r510928/).
