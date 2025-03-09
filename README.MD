# Dockerfile pour Symfony avec PHP 8.3

Ce projet utilise une image Docker basée sur **PHP 8.3 CLI** et inclut un ensemble d'outils et d'extensions nécessaires pour développer une application Symfony.

## Contenu du Dockerfile

### 1. Image de base

Nous utilisons l'image officielle `php:8.3-cli`.

### 2. Installation des paquets Debian

Nous mettons à jour les paquets et installons les dépendances nécessaires :

```sh
apt-get update && apt-get install -y \
    git \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    zlib1g-dev \
    unzip \
    nano \
    vim \
    tree \
    curl \
    npm \
    bash
```

### 3. Installation des extensions PHP

Nous utilisons `install-php-extensions` pour installer les extensions suivantes :

- `bcmath`
- `gd`
- `imagick`
- `intl`
- `mbstring`
- `http`
- `ctype`
- `pdo_pgsql`
- `tokenizer`
- `pdo_mysql`
- `mysqli`
- `zip`
- `xml`

### 4. Installation de Composer

Nous installons **Composer**, le gestionnaire de dépendances PHP :

```sh
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
```

### 5. Installation de Node.js et Yarn

Nous installons **Node.js 18** et **Yarn** pour la gestion des dépendances frontend :

```sh
curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global yarn
```

### 6. Installation de VSCode Server

Nous installons **code-server**, un serveur VSCode exécutable dans le conteneur :

```sh
curl -fsSL https://code-server.dev/install.sh | sh
```

### 7. Installation de Symfony CLI

Nous installons la **CLI Symfony** pour faciliter le développement et le déploiement :

```sh
curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony
```

### 8. Configuration de Bash

Nous ajoutons des alias utiles et une configuration de prompt personnalisée dans `~/.bashrc` :

```sh
echo "alias ll='ls -lah'" >> ~/.bashrc && \
echo "alias ss='symfony serve -d --allow-all-ip'" >> ~/.bashrc && \
echo "alias slog='symfony server:log'" >> ~/.bashrc && \
echo "PS1='\n \[\033[0;35m\]\u@\h:\[\033[1;32m\]\w \[\033[0;35m\]\t\n\$ \[\033[0m\]'" >> ~/.bashrc
```

### 9. Exposition des ports

Nous exposons les ports suivants :

- **8000** : Pour exécuter l'application Symfony
- **8080** : Pour accéder à VSCode Server

### 10. Définition du répertoire de travail

Nous utilisons `/workspace` comme répertoire de travail :

```sh
WORKDIR /workspace
```

### 11. Démarrage du conteneur

Le conteneur est configuré pour exécuter **VSCode Server** au démarrage :

```sh
CMD ["bash", "-c", "code-server --bind-addr 0.0.0.0:8080 --auth none"]
```

## Utilisation

### Construire l'image Docker

```sh
docker build -t mon-symfony-container .
```

### Exécuter le conteneur

```sh
docker run -p 8000:8000 -p 8080:8080 -v $(pwd):/workspace -it mon-symfony-container
```

### Accéder à Symfony et VSCode Server

- Symfony : <http://localhost:8000>
- VSCode Server : <http://localhost:8080>

## Utilisation avec Docker Compose

### Construire et démarrer les services Docker

```sh
docker-compose up --build
```
