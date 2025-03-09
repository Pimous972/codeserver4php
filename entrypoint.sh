#!/bin/bash

# Appliquer la configuration memory_limit à partir de la variable d'environnement
echo "memory_limit=${PHP_MEMORY_LIMIT:-128M}" > /usr/local/etc/php/conf.d/memory_limit.ini

# Lancer le serveur Code Server
su code -c "code-server --bind-addr 0.0.0.0:8080 --auth none /home/code/workspace"
