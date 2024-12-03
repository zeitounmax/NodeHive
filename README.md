# NodeHive 🐝

NodeHive est un gestionnaire de versions Node.js avec une interface CLI interactive. 

## Fonctionnalités Principales

- ✅ Vérification et installation automatique de curl
- 📦 Installation de Node.js via NVM (Node Version Manager)
- 🔄 Gestion des versions Node.js (LTS et stable)
- ⚙️ Configuration des gestionnaires de paquets (npm, yarn, pnpm)
- 🖥️ Support multi-shell (bash, zsh)

## Prérequis

- Système Linux (Debian/Ubuntu, Fedora, OpenSUSE, Arch Linux)
- Privilèges sudo
- Connexion Internet

## Installation

```bash
git clone https://github.com/votre-repo/nodehive.git
cd nodehive
chmod +x nodehive.sh
./nodehive.sh
```

## Menu Principal

1. 📥 **Installer Node.js LTS via NVM**
   - Installation automatique de NVM
   - Installation de la dernière version LTS de Node.js

2. ⚙️ **Configurer le gestionnaire de paquets**
   - Choix entre npm, yarn et pnpm
   - Configuration automatique des variables d'environnement

3. 🔄 **Mettre à jour Node.js**
   - Mise à jour vers la dernière version LTS
   - Mise à jour vers la dernière version stable

4. 🗑️ **Désinstaller Node.js**
   - Suppression complète de Node.js et NVM
   - Nettoyage des configurations

5. 🚪 **Quitter**

## Fonctionnalités Détaillées

### Gestion des Dépendances
- Vérification automatique de curl
- Installation automatique selon la distribution Linux
- Configuration automatique du shell (bash/zsh)

### Gestionnaires de Paquets
- Support de npm (configuration globale)
- Support de yarn
- Support de pnpm
- Gestion des conflits de configuration

## Auteur

Créé par Zeima
- 🌐 [zeitouncode.fr](https://zeitouncode.fr)
- 💻 [GitHub](https://github.com/zeitounmax)

## Licence

WTFPL - Do What The Fuck You Want To Public License

```
Copyright © 2024 Zeima
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
```

En d'autres termes : faites ce que vous voulez avec ce code ! 🎉
