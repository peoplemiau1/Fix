cd /tmp && \
wget -q http://mirror.yandex.ru/ubuntu/pool/main/u/util-linux/libblkid1_2.39.3-9ubuntu6.5_amd64.deb && \
wget -q http://mirror.yandex.ru/ubuntu/pool/main/u/util-linux/libmount1_2.39.3-9ubuntu6.5_amd64.deb && \
wget -q http://mirror.yandex.ru/ubuntu/pool/main/u/util-linux/libuuid1_2.39.3-9ubuntu6.5_amd64.deb && \
for f in lib*{blkid,mount,uuid}1_*.deb; do 
    echo "Распаковываем $f ..." && 
    sudo dpkg-deb -x "$f" / 
done && \
echo "✅ Готово! Установлена версия 2.39.3-9ubuntu6.5 (актуальная на апрель 2026)"
