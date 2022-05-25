# Скрипт скачивает файл дампа и разворачивает дамп на локальной БД

DOWNLOAD_DIR="/Users/makarov/Projects/backups"
CALL="mysql -h 0.0.0.0 -P 3306 -u monetka -pmonetka -D monetka-premium"

# Script will stops when error throwed
set -e

# Проверяем наличие ссылки при вызове скрипта
if [[ -z "$1" ]]; then echo "Use $0 <http://web.site/dump.slq.gz>"; exit 1; fi
# Берем последний тег из имени файла в ссылке
fn=$DOWNLOAD_DIR/`echo $1 | awk -F '/' '{print $NF}'`

# Скачиваем файл
echo "🤖 [`date +%H:%M:%S`] Скачиваем файл $1 в $fn"
wget -P $DOWNLOAD_DIR/ $1
# Проверяем наличие файла
if [[ ! -e "$fn" ]]; then echo "⛔ [`date +%H:%M:%S`] Файл $fn не существует"; exit 1; fi
echo "✅ [`date +%H:%M:%S`] Файл скачан"

echo "🤖 [`date +%H:%M:%S`] Восстанавливаем базу на локальном сервере"
gunzip -c $fn | sed -e 's/DEFINER[ ]*=[ ]*`[^`][^`]*`@`[^`][^`]*`//g' | sed -e 's/`moncheck_prod`.//g' | $CALL
echo "✅ [`date +%H:%M:%S`] База восстановлена"

echo "🤖 [`date +%H:%M:%S`] Заменяем продуктовые контакты"
echo 'UPDATE user SET email="ifgeny87@gmail.com" WHERE email IS NOT NULL;
      DELETE FROM user_setting WHERE 1;
      UPDATE account_setting SET value="ifgeny87@gmail.com";' | $CALL

echo "🤖 [`date +%H:%M:%S`] Удаляем старые инциденты"
echo 'DELETE FROM incident WHERE date < TIMESTAMP(NOW() - INTERVAL 5 day);' | $CALL

echo "✅ [`date +%H:%M:%S`] Работа завершена"
