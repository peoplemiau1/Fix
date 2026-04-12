#!/bin/bash
T=/repair

echo "=== Монтируем rw и чистим окружение ==="
mount -o remount,rw $T 2>/dev/null || true
unset LD_LIBRARY_PATH

cd /tmp
rm -rf fix-apt && mkdir fix-apt && cd fix-apt

echo "=== Качаем пакеты ==="

wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/glibc/libc6_2.43-2ubuntu2_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/gcc-14/libgcc-s1_14.2.0-4ubuntu2~24.04.1_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/gcc-14/libstdc++6_14.2.0-4ubuntu2~24.04.1_amd64.deb

wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/d/dpkg/dpkg_1.22.21ubuntu3.1_amd64.deb

wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/a/apt/libapt-pkg7.0_3.2.0_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/a/apt/apt_3.2.0_amd64.deb

# Критические библиотеки
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/z/zlib/zlib1g_1.3.dfsg+really1.3.1-1ubuntu3_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/libz/libzstd/libzstd1_1.5.7+dfsg-3_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/x/xz-utils/liblzma5_5.8.3-1_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/b/bzip2/libbz2-1.0_1.0.8-6_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/libs/libselinux/libselinux1_3.9-4build1_amd64.deb

echo "=== Распаковываем ТОЛЬКО через ar + tar (без dpkg-deb) ==="
for deb in *.deb; do
    echo "→ $deb"
    ar x "$deb"
    
    datafile=$(ls data.tar.* 2>/dev/null | head -n1)
    if [ -n "$datafile" ]; then
        case "$datafile" in
            *.xz)  tar -C "$T" --overwrite -xJf "$datafile" ;;
            *.zst) tar -C "$T" --overwrite --zstd -xf "$datafile" 2>/dev/null || zstd -qdc "$datafile" | tar -C "$T" --overwrite -xf - ;;
            *.gz)  tar -C "$T" --overwrite -xzf "$datafile" ;;
            *.bz2) tar -C "$T" --overwrite -xjf "$datafile" ;;
            *)     tar -C "$T" --overwrite -xf "$datafile" ;;
        esac
        echo "   ✓ распаковано"
    fi
    rm -f *.tar.* debian-binary control.tar.* 2>/dev/null
done

echo "=== Восстанавливаем симлинки и ld-linux ==="
mkdir -p $T/lib64 $T/usr/lib $T/usr/bin $T/var/lib/dpkg
cp -a $T/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/ 2>/dev/null || true
ln -sfn usr/lib $T/lib
ln -sfn usr/lib $T/lib64
ln -sfn usr/bin $T/bin
cp -f /etc/resolv.conf $T/etc/resolv.conf 2>/dev/null || true

# Монтируем всё необходимое
mount --bind /proc $T/proc 2>/dev/null || true
mount --bind /sys  $T/sys  2>/dev/null || true
mount --bind /dev  $T/dev  2>/dev/null || true
mount --bind /run  $T/run  2>/dev/null || true
mount --bind /dev/pts $T/dev/pts 2>/dev/null || true

echo "=== Готово ==="
echo "Теперь пытаемся зайти. После входа сразу выполняй:"
echo "    apt update && apt install --reinstall -y dpkg apt libc6"
echo ""

chroot $T /bin/bash --login
