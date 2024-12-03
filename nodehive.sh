#!/bin/bash


configure_shell() {
    local shell_type=""
    local rc_file=""
    
    if [ -n "$ZSH_VERSION" ]; then
        shell_type="zsh"
        rc_file="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_type="bash"
        rc_file="$HOME/.bashrc"
    else
        echo "Shell non supporté. Utilisation de bash par défaut."
        shell_type="bash"
        rc_file="$HOME/.bashrc"
    fi
    
    echo "Shell détecté: $shell_type"
    echo "Fichier de configuration: $rc_file"
    
    case $shell_type in
        "zsh")
            echo 'export NVM_DIR="$HOME/.nvm"' >> "$rc_file"
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$rc_file"
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$rc_file"
            ;;
        "bash")
            echo 'export NVM_DIR="$HOME/.nvm"' >> "$rc_file"
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$rc_file"
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$rc_file"
            ;;
    esac
    
    source "$rc_file"
    return "$rc_file"
}

init_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  
}

show_loading() {
    local message="$1"
    local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local delay=0.1
    
    tput sc
    
    while true; do
        for (( i=0; i<${#chars}; i++ )); do
            tput rc
            echo -en "${chars:$i:1} $message"
            sleep $delay
        done
    done &
    
    local spinner_pid=$!
    
    echo $spinner_pid
}

stop_loading() {
    local spinner_pid=$1
    kill $spinner_pid 2>/dev/null
    echo -en "\r\033[K"
}

install_node() {
    echo "Installation de NVM et Node.js LTS..."
    
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    init_nvm
    
    if ! command -v nvm &> /dev/null; then
        echo "Erreur: NVM n'a pas pu être initialisé"
        return 1
    fi
    
    nvm install --lts
    nvm use --lts
    
    echo "Node.js LTS a été installé avec succès"
    echo "Version Node.js: $(node --version)"
    echo "Version npm: $(npm --version)"
}

clean_package_manager() {
    local package_json="$HOME/package.json"
    
    if [ -f "$package_json" ]; then
        echo "Détection d'un package.json existant..."
        
        if grep -q '"packageManager"' "$package_json"; then
            echo "Conflit détecté: Un gestionnaire de paquets est déjà configuré"
            echo "Contenu actuel:"
            grep '"packageManager"' "$package_json"
            
            read -p "Voulez-vous supprimer cette configuration ? (o/n): " remove_config
            if [ "$remove_config" = "o" ] || [ "$remove_config" = "O" ]; then
                cp "$package_json" "${package_json}.backup"
                echo "Sauvegarde créée: ${package_json}.backup"
                
                sed -i '/"packageManager"/d' "$package_json"
                echo "Configuration du gestionnaire de paquets supprimée"
            else
                echo "Installation annulée pour éviter les conflits"
                return 1
            fi
        fi
    fi
    return 0
}

install_package_manager() {
    if ! clean_package_manager; then
        return 1
    fi

    if command -v corepack &> /dev/null; then
        local spinner_pid=$(show_loading "Désactivation de Corepack...")
        corepack disable >/dev/null 2>&1
        stop_loading $spinner_pid
    fi

    echo "Choisissez votre gestionnaire de paquets :"
    echo "1) 📦 npm (gestionnaire par défaut)"
    echo "2) 🧶 yarn"
    echo "3) 📦 pnpm"
    echo "4) ❌ Annuler"
    read -p "Votre choix (1-4): " choice

    local spinner_pid=$(show_loading "Installation en cours...")

    case $choice in
        1)
            npm config set prefix '~/.npm-global' >/dev/null 2>&1
            echo 'export PATH=~/.npm-global/bin:$PATH' >> "$HOME/.bashrc"
            source "$HOME/.bashrc"
            ;;
        2)
            npm install -g yarn >/dev/null 2>&1
            ;;
        3)
            npm install -g pnpm >/dev/null 2>&1
            ;;
        4)
            stop_loading $spinner_pid
            echo "Installation annulée"
            return
            ;;
        *)
            stop_loading $spinner_pid
            echo "❌ Option invalide"
            return
            ;;
    esac

    stop_loading $spinner_pid
    echo "✅ Installation terminée"
    
    echo "\n📦 Gestionnaires de paquets disponibles :"
    if command -v npm &> /dev/null; then
        echo "npm: $(npm --version)"
    fi
    if command -v yarn &> /dev/null; then
        echo "yarn: $(yarn --version)"
    fi
    if command -v pnpm &> /dev/null; then
        echo "pnpm: $(pnpm --version)"
    fi
}

update_node() {
    echo "Mise à jour de Node.js..."
    
    if [ ! -d "$HOME/.nvm" ]; then
        echo "NVM n'est pas installé. Installation en cours..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        init_nvm
    else
        init_nvm
    fi

    if ! command -v nvm &> /dev/null; then
        echo "Erreur: NVM n'a pas pu être initialisé"
        return 1
    fi

    echo "1) Mettre à jour vers la dernière version LTS"
    echo "2) Mettre à jour vers la dernière version stable"
    read -p "Votre choix (1-2): " update_choice

    case $update_choice in
        1)
            nvm install --lts
            nvm use --lts
            ;;
        2)
            nvm install node
            nvm use node
            ;;
        *)
            echo "Option invalide"
            return
            ;;
    esac
    
    echo "Node.js a été mis à jour avec succès"
    echo "Nouvelle version: $(node --version)"
}

uninstall_node() {
    echo "Attention: Ceci va désinstaller Node.js et ses composants"
    read -p "Êtes-vous sûr de vouloir continuer? (o/n): " confirm
    
    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
        nvm deactivate
        nvm uninstall --lts
        rm -rf "$HOME/.nvm"
        
        local rc_file=$(configure_shell)
        sed -i '/NVM_DIR/d' "$rc_file"
        
        echo "Node.js a été désinstallé avec succès"
    else
        echo "Désinstallation annulée"
    fi
}

check_curl() {
    if ! command -v curl &> /dev/null; then
        echo "❌ curl n'est pas installé sur votre système."
        echo "Veuillez choisir votre distribution Linux :"
        echo "1) Debian/Ubuntu"
        echo "2) Fedora"
        echo "3) OpenSUSE"
        echo "4) Arch Linux"
        echo "5) Autre/Quitter"
        read -p "Votre choix (1-5): " distro_choice

        case $distro_choice in
            1)
                sudo apt-get update && sudo apt-get install -y curl
                ;;
            2)
                sudo dnf install -y curl
                ;;
            3)
                sudo zypper install -y curl
                ;;
            4)
                sudo pacman -S --noconfirm curl
                ;;
            5)
                echo "Veuillez installer curl manuellement et relancer le script."
                exit 1
                ;;
            *)
                echo "Option invalide"
                exit 1
                ;;
        esac

        if ! command -v curl &> /dev/null; then
            echo "❌ L'installation de curl a échoué. Veuillez l'installer manuellement."
            exit 1
        else
            echo "✅ curl a été installé avec succès."
        fi
    fi
}

main_menu() {
    check_curl
    clear
    echo "🐝 NodeHive - Gestionnaire Node.js 🐝"
    echo "--------------------------------"
    echo "1) 📥 Installer Node.js LTS via NVM"
    echo "2) ⚙️ Configurer le gestionnaire de paquets"
    echo "3) 🔄 Mettre à jour Node.js"
    echo "4) 🗑️ Désinstaller Node.js"
    echo "5) 🚪 Quitter"
    echo "--------------------------------"
    echo "Propulse par Zeima"
    echo "https://github.com/zeitounmax"
    echo "https://zeitouncode.fr"
    echo "--------------------------------"
    read -p "Choisissez une option (1-5): " option

    case $option in
        1) install_node ;;
        2) 
            install_package_manager 
            ;;
        3) update_node ;;
        4) uninstall_node ;;
        5) exit 0 ;;
        *) echo "Option invalide" ;;
    esac
}

while true; do
    main_menu
    read -p "Appuyez sur Entrée pour continuer..."
done
