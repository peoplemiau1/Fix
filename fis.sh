# 1. Сначала ГАРАНТИРОВАННО делаем диск доступным на запись
mount -o remount,rw /dev/nvme0n1p4 /mnt/repair

# 2. Переходим в папку для работы
T=/repair
cd /tmp; mkdir -p fix; cd fix

# 3. Прямые ссылки с mirror.yandex.ru (версии Noble 24.04)
Y="http://mirror.yandex.ru/ubuntu/pool/main"

echo "--- СКАЧИВАЮ ПАКЕТЫ С ЯНДЕКСА ---"
wget $Y/g/glibc/libc6_2.39-0ubuntu8.3_amd64.deb
wget $Y/z/zlib/zlib1g_1.3.1.dfsg-1ubuntu1_amd64.deb
wget $Y/g/gcc-14/libstdc++6_14-20240412-0ubuntu1_amd64.deb
wget $Y/n/ncurses/libtinfo6_6.4+20240113-1ubuntu2_amd64.deb

# 4. Распаковка силами BusyBox
echo "--- РАСПАКОВКА В СИСТЕМУ ---"
for f in *.deb; do 
    busybox ar x $f
    busybox tar -xJf data.tar.xz -C $T
    rm -f data.tar.xz control.tar.gz debian-binary
done

# 5. Чиним КРИТИЧЕСКИЕ пути (линкер и системные ссылки)
echo "--- ФИНАЛЬНАЯ НАСТРОЙКА ---"
busybox mkdir -p $T/lib64
busybox ln -sf /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/ld-linux-x86-64.so.2
busybox ln -sf usr/lib $T/lib
busybox ln -sf usr/bin $T/bin
busybox cp /etc/resolv.conf $T/etc/resolv.conf

echo "--- ГОТОВО. ПРОБУЕМ ЗАЙТИ ---"
chroot $T /bin/bash
