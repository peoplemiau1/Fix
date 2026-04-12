#!/bin/sh
set -e

T=/repair

echo "=== Ремонт системы в $T ==="

# 1. Делаем доступным для записи
mount -o remount,rw $T 2>/dev/null || true

# 2. Убираем ядовитую переменную
unset LD_LIBRARY_PATH

cd /tmp
rm -rf fix-lib
mkdir fix-lib && cd fix-lib

echo "=== Скачиваем актуальные пакеты ==="

wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/glibc/libc6_2.39-0ubuntu8.7_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/gcc-14/libgcc-s1_14.2.0-4ubuntu2~24.04.1_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/g/gcc-14/libstdc++6_14.2.0-4ubuntu2~24.04.1_amd64.deb
wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/z/zlib/zlib1g_1.3.dfsg+really1.3.1-1ubuntu3_amd64.deb
# wget -q --show-progress http://mirror.yandex.ru/ubuntu/pool/main/n/ncurses/libtinfo6_6.4+20240113-1ubuntu2_amd64.deb  # раскомментируй если нужен

echo "=== Распаковываем ==="
for deb in *.deb; do
    echo "Извлекаю $deb..."
    dpkg-deb -x "$deb" $T
done

echo "=== Настраиваем симлинки ==="
mkdir -p $T/lib64
cp -a $T/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/ 2>/dev/null || true
ln -sf usr/lib $T/lib
ln -sf usr/lib64 $T/lib64 2>/dev/null || true
ln -sf usr/bin $T/bin

# Копируем resolv.conf для интернета внутри chroot
cp /etc/resolv.conf $T/etc/ 2>/dev/null || true

echo "=== Готово! Пробуем войти ==="
echo "Если войдёшь — сразу делай: apt update && apt upgrade -y"
echo "-----------------------------------------------------"

chroot $T /bin/bash --loginln -sf usr/lib $T/lib
ln -sf usr/bin $T/bin
cp /etc/resolv.conf $T/etc/resolv.conf

echo "--- ПРОБУЕМ ВХОД ---"
chroot $T /bin/bash
