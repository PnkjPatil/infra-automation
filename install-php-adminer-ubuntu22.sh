#!/bin/bash

# PHP Adminer Multi-Version Installation Script for Ubuntu 22.04
# This script installs all PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4)
# along with Apache, NGINX, MySQL, and other development tools

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        exit 1
    fi
}

# Function to debug system information

# Function to check Ubuntu version
check_ubuntu_version() {
    if [[ -r /etc/lsb-release ]]; then
        . /etc/lsb-release
        if [[ $ID == "ubuntu" ]]; then
            print_status "Detected Ubuntu $UBUNTU_VERSION_NAME ($DISTRIB_CODENAME)"
            if [[ $DISTRIB_CODENAME != "jammy" ]]; then
                print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish). You are running $DISTRIB_CODENAME."
                read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
            fi
        else
            print_error "This script is designed for Ubuntu. You are running $ID."
            exit 1
        fi
    else
        print_error "Could not determine Ubuntu version. Please ensure you are running Ubuntu 22.04."
        exit 1
    fi
}

# Function to get user input
get_user_input() {
    read -p "Enter your username (e.g., developer): " username
    
    if [[ -z "$username" ]]; then
        print_error "Username cannot be empty."
        exit 1
    fi
    
    read -p "Enter your full name: " full_name
    
    if [[ -z "$full_name" ]]; then
        full_name="$username"
    fi
    
    # Set domain names for each PHP version
    domains=(
        "${username}-php5.local"
        "${username}-php7.local"
        "${username}-php71.local"
        "${username}-php72.local"
        "${username}-php73.local"
        "${username}-php74.local"
        "${username}-php8.local"
        "${username}-php81.local"
        "${username}-php82.local"
        "${username}-php83.local"
        "${username}-php84.local"
        "${username}-php7.1.local"
        "${username}-php7.2.local"
        "${username}-php7.3.local"
        "${username}-php7.4.local"
        "${username}-php8.1.local"
        "${username}-php8.2.local"
        "${username}-php8.3.local"
        "${username}-php8.4.local"
    )
    
    user_home_dir="/home/${username}"
}

# Function to check if user exists
check_user_exists() {
    if [[ ! -d "$user_home_dir" ]]; then
        print_error "User $username does not exist. Please create the user first."
        exit 1
    fi
}

# Function to install system dependencies
install_system_dependencies() {
    print_status "Installing system dependencies..."
    
    sudo apt-get update
    sudo apt-get install -y software-properties-common apt-transport-https ca-certificates \
        curl wget unzip gnupg lsb-release build-essential git vim nano htop tree mc \
        openssh-server ufw fail2ban logwatch nginx-extras apache2-utils
}

# Function to add repositories
add_repositories() {
    print_status "Adding required repositories..."
    
    # Add ondrej PHP repositories
    sudo add-apt-repository -y ppa:ondrej/php
    
    # Add ondrej Apache repositories
    sudo add-apt-repository -y ppa:ondrej/apache2
    
    # Add ondrej Ansible repositories
    sudo add-apt-repository -y ppa:ansible/ansible
    
    # Add OpenJDK repository
    sudo add-apt-repository -y ppa:openjdk-r/ppa
    
    # Add Python PPA
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    
    # Add NodeSource repository for Node.js 18.x
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    
    sudo apt-get update
}

# Function to install PHP versions
install_php_versions() {
    print_status "Installing PHP versions..."
    
    # Install all PHP versions
    php_versions=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
    
    for version in "${php_versions[@]}"; do
        print_status "Installing PHP $version..."
        
        # Install PHP packages for this version
        sudo apt-get install -y \
            php${version}-common php${version}-cli php${version}-dev php${version}-fpm \
            php${version}-gd php${version}-curl php${version}-imap php${version}-opcache \
            php${version}-xml php${version}-mbstring php${version}-mysql php${version}-zip \
            php${version}-json php${version}-bcmath php${version}-intl php${version}-soap \
            php${version}-xmlrpc php${version}-ldap php${version}-redis php${version}-memcached \
            php${version}-sqlite3 php${version}-pgsql php${version}-mongodb || true
        
        # Remove default www.conf for this PHP version
        if [[ -f "/etc/php/${version}/fpm/pool.d/www.conf" ]]; then
            sudo rm -f "/etc/php/${version}/fpm/pool.d/www.conf"
        fi
    done
    
    # Start and enable PHP 8.1 FPM (most stable on Ubuntu 22.04)
    if systemctl list-unit-files | grep -q "php8.1-fpm"; then
        sudo systemctl enable php8.1-fpm
        sudo systemctl start php8.1-fpm
    fi
}

# Function to install web servers
install_web_servers() {
    print_status "Installing web servers..."
    
    # Install Apache
    sudo apt-get install -y apache2 libapache2-mod-php
    
    # Install NGINX
    sudo apt-get install -y nginx
    
    # Install Apache modules
    sudo a2enmod rewrite remoteip headers expires proxy proxy_fcgi setenvif
    
    # Disable default sites
    sudo a2dissite 000-default.conf
    sudo systemctl stop apache2
}

# Function to install database
install_database() {
    print_status "Installing MySQL..."
    
    sudo apt-get install -y mysql-server-8.0 mysql-client-8.0 mysql-common
    
    # Secure MySQL installation (non-interactive)
    sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';"
    sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
    sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    sudo mysql -e "DROP DATABASE IF EXISTS test;"
    sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    sudo mysql -e "FLUSH PRIVILEGES;"
}

# Function to install additional tools
install_additional_tools() {
    print_status "Installing additional development tools..."
    
    sudo apt-get install -y geany geany-plugins geany-plugins-common geany-plugin-addons \
        geany-plugin-prettyprinter filezilla meld vlc sublime-text ubuntu-restricted-extras \
        libpcre3-dev
}

# Function to create web directories and files
create_web_environment() {
    print_status "Creating web environment..."
    
    # Create site directories for all versions
    for domain in "${domains[@]}"; do
        site_path="/var/www/${domain}"
        sudo mkdir -p "${site_path}/public/adminer" "${site_path}/logs" "${site_path}/tmp" "${site_path}/run"
        
        # Create index.php
        sudo tee "${site_path}/public/index.php" > /dev/null << 'EOF'
<?php
phpinfo();
?>
EOF
        
        # Download Adminer
        sudo wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php \
            -O "${site_path}/public/adminer/index.php" || true
        
        # Download Adminer CSS
        sudo wget -q https://raw.githubusercontent.com/vrana/adminer/master/designs/lucas-sandery/adminer.css \
            -O "${site_path}/public/adminer/adminer.css" || true
        
        # Set proper ownership
        sudo chown -R "${username}:${username}" "${site_path}"
    done
}

# Function to configure Apache virtual hosts
configure_apache_vhosts() {
    print_status "Configuring Apache virtual hosts..."
    
    # Create Apache vhosts for all sites
    for domain in "${domains[@]}"; do
        site_id=$(echo "$domain" | sed 's/.*-\(.*\)\.local/\1/')
        
        sudo tee "/etc/apache2/sites-available/${site_id}.conf" > /dev/null << EOF
<VirtualHost *:81>
    ServerName ${domain}
    DocumentRoot /var/www/${domain}/public
    
    <Directory /var/www/${domain}/public>
        AllowOverride All
        Require all granted
    </Directory>
    
    <FilesMatch ".+\\.php$">
        SetHandler "proxy:unix:/run/php/php8.1-fpm.sock|fcgi://localhost/"
    </FilesMatch>
    
    ErrorLog \${APACHE_LOG_DIR}/${site_id}_error.log
    CustomLog \${APACHE_LOG_DIR}/${site_id}_access.log combined
</VirtualHost>
EOF
        
        # Enable site
        sudo a2ensite "${site_id}.conf"
    done
}

# Function to configure NGINX
configure_nginx() {
    print_status "Configuring NGINX..."
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Create NGINX server blocks for all domains
    for domain in "${domains[@]}"; do
        sudo tee "/etc/nginx/sites-available/${domain}" > /dev/null << EOF
server {
    listen 80;
    server_name ${domain};
    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://127.0.0.1:81;
    }
}
EOF
        
        # Enable site
        sudo ln -sf "/etc/nginx/sites-available/${domain}" "/etc/nginx/sites-enabled/${domain}"
    done
}

# Function to configure hosts file
configure_hosts_file() {
    print_status "Configuring hosts file..."
    
    # Add all domains to hosts file
    for domain in "${domains[@]}"; do
        if ! grep -q "[[:space:]]${domain}\b" /etc/hosts; then
            echo "127.0.0.1 ${domain}" | sudo tee -a /etc/hosts
        fi
    done
}

# Function to configure services
configure_services() {
    print_status "Configuring services..."
    
    # Configure firewall
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    
    # Configure fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    
    # Set up sudo permissions
    echo "${username} ALL = NOPASSWD: /usr/sbin/service apache2 *" | sudo tee -a /etc/sudoers
    echo "${username} ALL = NOPASSWD: /usr/sbin/service nginx *" | sudo tee -a /etc/sudoers
    echo "${username} ALL = NOPASSWD: /usr/sbin/service mysql *" | sudo tee -a /etc/sudoers
    
    # Allow user to restart PHP-FPM services
    for version in "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4"; do
        if [[ -f "/etc/init.d/php${version}-fpm" ]]; then
            echo "${username} ALL = NOPASSWD: /etc/init.d/php${version}-fpm *" | sudo tee -a /etc/sudoers
        fi
    done
}

# Function to start services
start_services() {
    print_status "Starting services..."
    
    # Ensure Apache listens on port 81
    if ! grep -q "^Listen 81" /etc/apache2/ports.conf; then
        echo "Listen 81" | sudo tee -a /etc/apache2/ports.conf
    fi
    
    # Start Apache
    sudo systemctl start apache2
    sudo systemctl enable apache2
    
    # Start NGINX
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Start MySQL
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # Start PHP 8.1 FPM
    if systemctl list-unit-files | grep -q "php8.1-fpm"; then
        sudo systemctl restart php8.1-fpm
        sudo systemctl enable php8.1-fpm
    fi
}

# Function to test installation
test_installation() {
    print_status "Testing installation..."
    
    # Test a few domains
    test_domains=("${username}-php5.local" "${username}-php74.local" "${username}-php8.local" "${username}-php84.local")
    
    for domain in "${test_domains[@]}"; do
        echo -n "Testing ${domain}: "
        if curl -s -o /dev/null -w "%{http_code}" "http://${domain}/" 2>/dev/null; then
            print_success "OK"
        else
            print_error "FAILED"
        fi
    done
}

# Function to display installation summary
display_summary() {
    print_success "Installation completed successfully!"
    echo
    echo "=== Installation Summary ==="
    echo "User: $username"
    echo "PHP versions installed: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4"
    echo "Web servers: Apache (port 81), NGINX (port 80)"
    echo "Database: MySQL 8.0 (root password: root123)"
    echo
    echo "=== Access URLs ==="
    echo "Main sites:"
    for domain in "${domains[@]}"; do
        echo "  - http://${domain}"
    done
    echo
    echo "Adminer (database management):"
    for domain in "${domains[@]}"; do
        echo "  - http://${domain}/adminer/"
    done
    echo
    echo "=== Next Steps ==="
    echo "1. Open your browser and navigate to any of the URLs above"
    echo "2. If you see 'This site can't be reached', try:"
    echo "   - Clear browser cache and DNS"
    echo "   - Wait a few seconds for services to fully start"
    echo "   - Check if the domain is in /etc/hosts"
    echo "3. To access Adminer, use: http://${username}-php84.local/adminer/"
    echo "   - Server: localhost"
    echo "   - Username: root"
    echo "   - Password: root123"
    echo
    echo "=== Troubleshooting ==="
    echo "If you encounter issues:"
    echo "1. Check service status: sudo systemctl status apache2 nginx mysql php8.1-fpm"
    echo "2. Check Apache config: sudo apache2ctl configtest"
    echo "3. Check NGINX config: sudo nginx -t"
    echo "4. Check hosts file: cat /etc/hosts | grep $username"
    echo "5. Check logs: sudo tail -f /var/log/nginx/error.log /var/log/apache2/error.log"
}

# Main installation function
main() {
    echo "=========================================="
    echo "PHP Adminer Multi-Version Installation"
    echo "for Ubuntu 22.04"
    echo "=========================================="
    echo
    
    # Check prerequisites
    check_root
    check_ubuntu_version
    get_user_input
    check_user_exists
    
    # Installation steps
    install_system_dependencies
    add_repositories
    install_php_versions
    install_web_servers
    install_database
    install_additional_tools
    create_web_environment
    configure_apache_vhosts
    configure_nginx
    configure_hosts_file
    configure_services
    start_services
    
    # Wait a moment for services to fully start
    sleep 5
    
    # Test installation
    test_installation
    
    # Display summary
    display_summary
}

# Run main function
main "$@"
