# 1. Настройка путей
T=/mnt/repair; U="http://archive.ubuntu.com/ubuntu/pool/main"

# 2. Скачивание базы (всего 3 главных пакета)
busybox wget $U/g/glibc/libc6_2.39-0ubuntu8.3_amd64.deb \
$U/z/zlib/zlib1g_1.3.1.dfsg-1ubuntu1_amd64.deb \
$U/g/gcc-14/libstdc++6_14-20240412-0ubuntu1_amd64.deb

# 3. Распаковка "Танком" (используем только BusyBox)
for f in *.deb; do 
    busybox ar x $f
    busybox tar -xf data.tar.xz -C $T
    rm -f data.tar.xz control.tar.gz debian-binary
done

# 4. Восстановление "скелета" ссылок
busybox mkdir -p $T/lib64
busybox cp -L $T/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/
busybox ln -sf usr/lib $T/lib
busybox ln -sf usr/bin $T/bin
busybox cp /etc/resolv.conf $T/etc/resolv.conf

# 5. ВХОД В ОЖИВШУЮ СИСТЕМУ
chroot $T /bin/bash
