# 1. Убеждаемся, что диск доступен для записи
mount -o remount,rw /repair

# 2. Выключаем ядовитую переменную, которая ломала dpkg-deb в прошлый раз
unset LD_LIBRARY_PATH

# 3. Подготовка
T=/repair
mkdir -p /tmp/fix
cd /tmp/fix

echo "--- ИЩУ И СКАЧИВАЮ АКТУАЛЬНЫЕ ПАКЕТЫ ---"
# Эта функция сама читает сайт и берет точное имя файла (без 404)
get_deb() {
    URL="$1"
    PATTERN="$2"
    FILE=$(wget -qO- "$URL" | grep -o "href=\"$PATTERN\"" | cut -d'"' -f2 | head -n 1)
    echo "Качаю $FILE..."
    wget "$URL$FILE"
}

get_deb "http://mirror.yandex.ru/ubuntu/pool/main/g/glibc/" "libc6_2.39-[^\"]*amd64.deb"
get_deb "http://mirror.yandex.ru/ubuntu/pool/main/z/zlib/" "zlib1g_1.3[^\"]*amd64.deb"
get_deb "http://mirror.yandex.ru/ubuntu/pool/main/g/gcc-14/" "libstdc++6_14[^\"]*amd64.deb"
get_deb "http://mirror.yandex.ru/ubuntu/pool/main/n/ncurses/" "libtinfo6_6.4[^\"]*amd64.deb"

echo "--- РАСПАКОВКА В /repair ---"
# Используем нормальный dpkg-deb хоста. Он сам поймет формат .zst и распакует всё как надо.
for f in *.deb; do 
    echo "Извлекаю $f..."
    dpkg-deb -x "$f" $T
done

echo "--- СТАВЛЮ ССЫЛКИ НА МЕСТО ---"
mkdir -p $T/lib64
cp -L $T/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 $T/lib64/ld-linux-x86-64.so.2
ln -sf usr/lib $T/lib
ln -sf usr/bin $T/bin
cp /etc/resolv.conf $T/etc/resolv.conf

echo "--- ПРОБУЕМ ВХОД ---"
chroot $T /bin/bash
