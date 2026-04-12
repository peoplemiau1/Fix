# Настройка
T=/repair; M="http://mirrors.kernel.org/ubuntu/pool/main"
cd /tmp; mkdir -p fix; cd fix

# Скачиваем (ссылки проверены, 404 не будет)
busybox wget $M/g/glibc/libc6_2.39-0ubuntu8.3_amd64.deb
busybox wget $M/z/zlib/zlib1g_1.3.1.dfsg-1ubuntu1_amd64.deb
busybox wget $M/g/gcc-14/libstdc++6_14-20240412-0ubuntu1_amd64.deb

# Распаковка "Танком"
for f in *.deb; do 
    busybox ar x $f
    busybox tar -xf data.tar.xz -C $T
    rm -f data.tar.xz control.tar.gz debian-binary
done

# Чиним ссылки
busybox mkdir -p $T/lib64
busybox cp -L $T/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/
busybox ln -sf usr/lib $T/lib
busybox ln -sf usr/bin $T/bin
busybox cp /etc/resolv.conf $T/etc/resolv.conf

# ВХОД В ОЖИВШУЮ СИСТЕМУ
chroot $T /bin/bash
