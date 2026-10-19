@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Ambil Log TWRP - Xiaomi 14T Pro rothko
echo.
echo  ==================================================
echo   AMBIL LOG TWRP - Xiaomi 14T Pro / rothko
echo  ==================================================
echo.
echo  Pakai ini kalau TWRP macet atau layarnya tidak muncul.
echo  HP harus tersambung ke komputer dengan kabel USB.
echo.
pause
call adb version >nul 2>&1
if errorlevel 1 goto no_adb
set "M="
for /f "skip=1 tokens=1,2" %%a in ('adb devices 2^>nul') do if not "%%b"=="" set "M=%%b"
if not defined M goto no_hp
echo  HP terdeteksi, mode: %M%
if not exist LOG-TWRP mkdir LOG-TWRP
echo  Mengambil log, tunggu sebentar...
call adb pull /tmp/recovery.log LOG-TWRP\recovery.log >nul 2>&1
call adb shell dmesg > LOG-TWRP\dmesg.txt 2>&1
call adb shell logcat -d > LOG-TWRP\logcat.txt 2>&1
call adb shell getprop > LOG-TWRP\getprop.txt 2>&1
echo.
echo  SELESAI. Kirim semua file di folder LOG-TWRP ke pembuat TWRP.
echo  Folder itu ada di sini: %CD%\LOG-TWRP
echo.
echo  Tekan tombol apa saja untuk menyalakan ulang HP ke Android.
pause >nul
call adb reboot >nul 2>&1
exit /b 0

:no_adb
echo  [!] adb tidak ditemukan.
echo      Salin file ini ke folder platform-tools, lalu jalankan lagi.
goto selesai
:no_hp
echo  [!] HP tidak terdeteksi lewat kabel.
echo      Artinya TWRP belum sempat berjalan. Lakukan ini:
echo       1. Tahan tombol Power 15 detik sampai HP menyala ulang.
echo       2. Biarkan HP masuk ke Android.
echo       3. Buka /sys/fs/pstore dengan Material Files,
echo          lalu kirim semua file di sana ke pembuat TWRP.
:selesai
echo.
pause
exit /b 1
