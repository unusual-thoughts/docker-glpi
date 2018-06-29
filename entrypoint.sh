echo "Waiting 5 sec for db..."
sleep 5

echo "Running Install (in french)..."
php /var/www/html/scripts/cliinstall.php --host=db --db=glpi --user=user-glpi --pass=pass-glpi --lang="fr_FR"
sleep 1

echo "Starting server"
docker-php-entrypoint &

