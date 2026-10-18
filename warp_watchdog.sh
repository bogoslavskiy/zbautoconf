#!/bin/sh

if [ "$1" != "noclear" ]; then clear; fi

echo ""
echo "Устанавливается WARP watchdog (быстрая смена адреса WARP при обрыве)"
echo ""

BASE_URL="https://raw.githubusercontent.com/bogoslavskiy/zbautoconf/refs/heads/main/warp-watchdog"

if ! command -v rrws >/dev/null 2>&1; then
	echo "✗ Нужен RR-WARP-Scanner (rrws), он ставится вместе с zbautoconf — пропускаем"
	exit 1
fi

for f in warp-watchdog warp-watchdog.init; do
	wget -qO "/tmp/$f" "$BASE_URL/$f" && [ -s "/tmp/$f" ] || {
		echo "✗ Не удалось скачать $f — пропускаем"
		exit 1
	}
done
mv /tmp/warp-watchdog /usr/bin/warp-watchdog
mv /tmp/warp-watchdog.init /etc/init.d/warp-watchdog
chmod +x /usr/bin/warp-watchdog /etc/init.d/warp-watchdog

grep -qxF /usr/bin/warp-watchdog /etc/sysupgrade.conf 2>/dev/null || {
	echo /usr/bin/warp-watchdog >> /etc/sysupgrade.conf
	echo /etc/init.d/warp-watchdog >> /etc/sysupgrade.conf
	echo /etc/warp-watchdog/ >> /etc/sysupgrade.conf
}

/etc/init.d/warp-watchdog enable
/etc/init.d/warp-watchdog restart
echo "✓ WARP watchdog запущен. Состояние: warp-watchdog status"
echo "=== КОНЕЦ! ==="
echo ""
