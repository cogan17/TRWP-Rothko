@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Update TWRP lewat TWRP - Xiaomi 14T Pro rothko
set "IMG=@TWRP_IMG@"
set "SHA=@TWRP_SHA256@"
set "HASIL=%TEMP%\twrp-update-hasil.txt"
echo.
echo  ==================================================
echo   UPDATE TWRP LEWAT TWRP - Xiaomi 14T Pro / rothko
echo   Untuk firmware @VERSION@
echo  ==================================================
echo.
echo  Untuk HP yang SUDAH punya TWRP. Tidak perlu mode FASTBOOT.
echo  Data di HP TIDAK dihapus.
echo.
call :siapkan
if errorlevel 1 goto gagal
echo  Langkah:
echo   1. Matikan HP, lalu tahan Power + Volume Atas sampai logo Mi muncul.
echo      Tunggu sampai TWRP terbuka.
echo   2. Kalau TWRP minta pola atau PIN, boleh dibuka atau tekan CANCEL.
echo   3. Sambungkan HP ke komputer dengan kabel USB.
echo.
pause
call :cek_hp
if errorlevel 1 goto gagal
echo.
echo  Mengirim file ke HP...
call adb push "%IMG%" /tmp/twrp-baru.img >nul 2>&1
if errorlevel 1 goto gagal_kirim
call adb push twrp-update.sh /tmp/twrp-update.sh >nul 2>&1
if errorlevel 1 goto gagal_kirim
echo  Memasang TWRP, jangan cabut kabel...
rem the phone re-checks device, partition and file, writes, then reads the partition back
call adb shell "tr -d '\r' < /tmp/twrp-update.sh | sh" > "%HASIL%" 2>&1
findstr /c:"SELESAI" "%HASIL%" >nul
if not errorlevel 1 goto berhasil
findstr /c:"HP_LAIN" "%HASIL%" >nul
if not errorlevel 1 goto wrong_hp
findstr /c:"TIDAK_ADA_PARTISI" "%HASIL%" >nul
if not errorlevel 1 goto no_part
findstr /c:"KIRIM_RUSAK" "%HASIL%" >nul
if not errorlevel 1 goto gagal_kirim
goto gagal_flash

:berhasil
echo.
echo  BERHASIL. TWRP baru sudah terpasang.
echo  HP sekarang menyala ke Android dulu, tunggu sampai selesai.
echo.
echo  Cara cek TWRP baru:
echo   1. Matikan HP, lalu tahan Power + Volume Atas.
echo   2. Di TWRP buka Advanced - File Manager, lihat file /BUILD-INFO.txt
echo      yang berisi tanggal build TWRP baru.
rem Normal boot, not "reboot recovery": that writes boot-recovery to misc, so a TWRP that crashes would bootloop
call adb reboot >nul 2>&1
echo.
pause
exit /b 0

:siapkan
call adb version >nul 2>&1
if errorlevel 1 goto no_adb
if not exist "%IMG%" goto no_file
if not exist "twrp-update.sh" goto no_file
echo  Memeriksa file TWRP...
set "H="
for /f "skip=1 delims=" %%a in ('certutil -hashfile "%IMG%" SHA256') do if not defined H set "H=%%a"
set "H=%H: =%"
if /i not "%H%"=="%SHA%" goto bad_file
echo  File TWRP OK.
echo.
exit /b 0
:no_adb
echo  [!] adb tidak ditemukan.
echo      Salin SEMUA file paket ini ke folder platform-tools, lalu jalankan lagi.
exit /b 1
:no_file
echo  [!] File %IMG% atau twrp-update.sh tidak ada di folder ini.
echo      Ekstrak ulang semua file dari zip paket ke folder yang sama.
exit /b 1
:bad_file
echo  [!] File %IMG% rusak atau bukan file yang benar.
echo      Unduh ulang paketnya.
exit /b 1

:cek_hp
set "M="
for /f "skip=1 tokens=1,2" %%a in ('adb devices 2^>nul') do if not "%%b"=="" set "M=%%b"
if not defined M goto no_hp
if /i "%M%"=="recovery" goto hp_ok
if /i "%M%"=="device" goto masih_android
echo  [!] HP terdeteksi dalam mode %M%, bukan TWRP.
echo      Masuk TWRP dulu, lalu jalankan lagi.
exit /b 1
:hp_ok
echo  HP terdeteksi di TWRP.
exit /b 0
:masih_android
echo  [!] HP masih di Android. Masuk TWRP dulu:
echo      matikan HP, tahan Power + Volume Atas, lalu jalankan lagi.
exit /b 1
:no_hp
echo  [!] HP tidak terdeteksi lewat kabel.
echo      Pastikan TWRP sudah terbuka dan kabel tersambung, lalu jalankan lagi.
exit /b 1

:wrong_hp
echo  [!] Perangkat yang tersambung bukan Xiaomi 14T Pro - rothko.
goto gagal

:no_part
echo  [!] Partisi vendor_boot tidak ditemukan di HP ini.
goto gagal

:gagal
echo.
echo  Proses dihentikan. HP kamu TIDAK diubah.
echo.
pause
exit /b 1

:gagal_kirim
echo.
echo  [!] File gagal terkirim ke HP dengan utuh. HP kamu TIDAK diubah.
echo      Cabut lalu pasang lagi kabelnya, kemudian jalankan skrip ini sekali lagi.
echo.
pause
exit /b 1

:gagal_flash
echo.
echo  [!] Gagal menulis TWRP. Pesan dari HP:
type "%HASIL%"
echo.
echo  JANGAN matikan HP dulu - TWRP masih berjalan.
echo  Jalankan skrip ini sekali lagi. Kalau tetap gagal: di TWRP pilih
echo  Reboot - Bootloader, lalu jalankan 2-KEMBALIKAN-STOK.bat.
echo.
pause
exit /b 1
