#!/bin/bash

LOGFILE="/root/cyberpanel.txt"

# Создаём файл, если он не существует, и задаём права
if [ ! -f "$LOGFILE" ]; then
    touch "$LOGFILE"
    chmod 600 "$LOGFILE"
fi

# Обновляем систему без диалогов
DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -yq || yum update -y

# Запускаем установку CyberPanel
sh <(curl -s https://cyberpanel.net/install.sh) <<EOF
1  # Устанавливаем CyberPanel с OpenLiteSpeed
Y  # Устанавливаем PowerDNS, Postfix и Pure-FTPD
Y  # Используем стандартную версию MariaDB
Y  # Устанавливаем Memcached
Y  # Устанавливаем Redis
Y  # Включаем Watchdog
EOF

# Получаем пароль администратора из логов установки
PASSWORD=$(grep -oP 'Admin password: \K.*' /var/log/installLogs.txt | tail -1)

# Записываем данные в файл
cat <<EOL > $LOGFILE
CyberPanel успешно установлен!
URL: https://$(hostname -I | awk '{print $1}'):8090
Логин: admin
Пароль: $PASSWORD
EOL

# Выводим данные пользователю
echo "CyberPanel установлен! Данные сохранены в $LOGFILE"
