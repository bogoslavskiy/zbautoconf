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

# /tmp/warp-watchdog занят работающим watchdog, скачиваем в отдельную папку
DL=$(mktemp -d /tmp/wwd-install.XXXXXX)
for f in warp-watchdog warp-watchdog.init; do
	wget -qO "$DL/$f" "$BASE_URL/$f" && [ -s "$DL/$f" ] || {
		echo "✗ Не удалось скачать $f — пропускаем"
		rm -rf "$DL"
		exit 1
	}
done
mv "$DL/warp-watchdog" /usr/bin/warp-watchdog
mv "$DL/warp-watchdog.init" /etc/init.d/warp-watchdog
rm -rf "$DL"
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
