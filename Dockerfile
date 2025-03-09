FROM php:8.3-cli

# Mettre à jour les paquets et installer des dépendances nécessaires
RUN apt-get update && apt-get install -y \
    git unzip nano vim tree curl npm htop wget bash sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath gd imagick intl mbstring http ctype \
    pdo_pgsql tokenizer pdo_mysql mysqli zip xml

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installer Node.js et Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global yarn

# Installer VS Code Server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Installer la Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Définir les arguments pour l'UID et le GID du développeur
ARG USER_ID=1000
ARG GROUP_ID=1000

# Créer un utilisateur avec le même UID/GID que l'hôte et lui définir un mot de passe
RUN groupadd -g $GROUP_ID code \
    && useradd -m -u $USER_ID -g code -s /bin/bash code \
    && echo "code:password" | chpasswd

    # Création du repertoire workspace du developpeur
RUN mkdir /home/code/workspace \
    && chown -R code:code /home/code/

# Ajouter "code" au sudoers avec accès sans mot de passe
RUN echo "code ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Installation des extensions code-server
RUN su code -c "code-server --install-extension johnpapa.vscode-peacock && \
    code-server --install-extension usernamehw.errorlens && \
    code-server --install-extension seatonjiang.gitmoji-vscode && \
    code-server --install-extension oderwat.indent-rainbow && \
    code-server --install-extension eamodio.gitlens && \
    code-server --install-extension mblode.twig-language-2 && \
    code-server --install-extension MehediDracula.php-namespace-resolver && \
    code-server --install-extension SanderRonde.phpstan-vscode && \
    code-server --install-extension zobo.php-intellisense && \
    code-server --install-extension DavidAnson.vscode-markdownlint && \
    code-server --install-extension recca0120.vscode-phpunit && \
    code-server --install-extension Gruntfuggly.todo-tree && \
    code-server --install-extension devsense.phptools-vscode && \
    code-server --install-extension PKief.material-icon-theme && \
    code-server --install-extension esbenp.prettier-vscode"


# Configuration de .bashrc pour l'utilisateur "code"
RUN echo "alias ll='ls -lah'" >> /home/code/.bashrc && \
    echo "alias ss='symfony serve -d --listen-ip=0.0.0.0'" >> /home/code/.bashrc && \
    echo "alias symc='symfony console'" >> /home/code/.bashrc && \
    echo "alias slog='symfony server:log'" >> /home/code/.bashrc && \
    echo "PS1='\n \[\033[0;35m\]┌──(\[\033[1;33m\]\u@\h\[\033[0;35m\])─($(hostname -I | cut -d " " -f 1))─(\[\033[1;32m\]\w\[\033[0;35m\]) \t \n \[\033[0;35m\]└> ​​\[\033[1;35m\]\$ \[\033[0m\]'" >> /home/code/.bashrc && \
    chown code:code /home/code/.bashrc  

# Exposer le port pour Code Server
EXPOSE 8080

# Définir le répertoire de travail
WORKDIR /home/code/

# Copier le script entrypoint.sh dans le conteneur
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Démarrer VSCode Server avec l'utilisateur "code"
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]