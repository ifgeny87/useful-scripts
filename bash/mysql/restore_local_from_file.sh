# Скрипт разворачивает дамп на локальной БД

CALL="mysql -h 0.0.0.0 -P 3306 -u monetka -pmonetka -D monetka-premium"

# Script will stops when error throwed
set -e

# Проверяем наличие файла
if [[ -z "$1" ]]; then echo "Use $0 <sql file>"; exit 1; fi
if [[ ! -e "$1" ]]; then echo "File $1 foes not exists"; exit 1; fi

echo "🤖 [`date +%H:%M:%S`] Восстанавливаем базу на локальном сервере"
gunzip -c $1 | sed -e 's/DEFINER[ ]*=[ ]*`[^`][^`]*`@`[^`][^`]*`//g' | sed -e 's/`moncheck_prod`.//g' | $CALL
echo "✅ [`date +%H:%M:%S`] База восстановлена"

echo "🤖 [`date +%H:%M:%S`] Заменяем продуктовые контакты"
echo 'UPDATE user SET email="ifgeny87@gmail.com" WHERE email IS NOT NULL;
      DELETE FROM user_setting WHERE 1;
      UPDATE account_setting SET value="ifgeny87@gmail.com";' | $CALL

echo "🤖 [`date +%H:%M:%S`] Удаляем старые инциденты"
echo 'DELETE FROM incident WHERE date < TIMESTAMP(NOW() - INTERVAL 5 day);' | $CALL

echo "✅ [`date +%H:%M:%S`] Работа завершена"
