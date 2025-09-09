#!/bin/bash

# Ubuntu 22.04 PHP Adminer Multi-Version Installation Script
# This script installs all PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4)
# along with Apache, NGINX, MySQL, Java, Python, and other development tools

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
    read -p "Enter non-admin username (e.g., developer): " non_admin_username
    
    if [[ -z "$non_admin_username" ]]; then
        print_error "Username cannot be empty."
        exit 1
    fi
    
    read -p "Enter full name for user: " newuser_name
    
    if [[ -z "$newuser_name" ]]; then
        newuser_name="$non_admin_username"
    fi
    
    # Set domain names for each PHP version
    php84_name="${non_admin_username}-php84.local"
    php83_name="${non_admin_username}-php83.local"
    php82_name="${non_admin_username}-php82.local"
    php81_name="${non_admin_username}-php81.local"
    php8_name="${non_admin_username}-php8.local"
    php74_name="${non_admin_username}-php74.local"
    php73_name="${non_admin_username}-php73.local"
    php72_name="${non_admin_username}-php72.local"
    php71_name="${non_admin_username}-php71.local"
    php7_name="${non_admin_username}-php7.local"
    php5_name="${non_admin_username}-php5.local"
    
    non_admin_home_dir="/home/${non_admin_username}"
}

# Function to check if user exists
check_user_exists() {
    if [[ ! -d "$non_admin_home_dir" ]]; then
        print_error "User $non_admin_username does not exist. Please create the user first."
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
            php${version}-sqlite3 php${version}-pgsql php${version}-mongodb
        
        # Remove default www.conf for this PHP version
        if [[ -f "/etc/php/${version}/fpm/pool.d/www.conf" ]]; then
            sudo rm -f "/etc/php/${version}/fpm/pool.d/www.conf"
        fi
        
        # Start and enable PHP-FPM service
        if [[ -f "/etc/init.d/php${version}-fpm" ]]; then
            sudo systemctl enable php${version}-fpm
            sudo systemctl start php${version}-fpm
        fi
    done
}

# Function to install web servers
install_web_servers() {
    print_status "Installing web servers..."
    
    # Install Apache
    sudo apt-get install -y apache2 libapache2-mod-php
    
    # Install NGINX
    sudo apt-get install -y nginx
    
    # Install Apache modules
    sudo a2enmod rewrite remoteip headers expires
    
    # Disable default sites
    sudo a2dissite 000-default.conf
    sudo systemctl stop apache2
}

# Function to install database
install_database() {
    print_status "Installing MySQL..."
    
    sudo apt-get install -y mysql-server-8.0 mysql-client-8.0 mysql-common
    
    # Secure MySQL installation
    sudo mysql_secure_installation
}

# Function to install Java
install_java() {
    print_status "Installing Java..."
    
    sudo apt-get install -y openjdk-17-jdk openjdk-21-jdk maven gradle
    
    # Set JAVA_HOME
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' | sudo tee -a /etc/environment
    echo 'export PATH=$PATH:$JAVA_HOME/bin' | sudo tee -a /etc/environment
    
    source /etc/environment
}

# Function to install Python
install_python() {
    print_status "Installing Python versions..."
    
    sudo apt-get install -y python3 python3-pip python3-venv python3.10 python3.11 python3.12 python3.13
    
    # Upgrade pip
    sudo python3 -m pip install --upgrade pip setuptools wheel
    
    # Install global Python packages
    sudo python3 -m pip install virtualenv virtualenvwrapper
}

# Function to install Node.js
install_nodejs() {
    print_status "Installing Node.js..."
    
    sudo apt-get install -y nodejs
    
    # Install global npm packages
    sudo npm install -g yarn pm2 nodemon typescript @angular/cli @vue/cli
}

# Function to install Docker
install_docker() {
    print_status "Installing Docker..."
    
    sudo apt-get install -y docker.io docker-compose containerd
    
    # Add user to docker group
    sudo usermod -aG docker $non_admin_username
    
    # Start and enable Docker
    sudo systemctl enable docker
    sudo systemctl start docker
}

# Function to install Composer
install_composer() {
    print_status "Installing Composer..."
    
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    
    # Install global Composer packages
    composer global require codeception/codeception phpunit/phpunit friendsofphp/php-cs-fixer phpstan/phpstan
}

# Function to install additional tools
install_additional_tools() {
    print_status "Installing additional development tools..."
    
    sudo apt-get install -y geany geany-plugins geany-plugins-common geany-plugin-addons \
        geany-plugin-prettyprinter filezilla meld vlc sublime-text ubuntu-restricted-extras \
        libpcre3-dev
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
    
    # Create log directories
    sudo mkdir -p /var/log/nginx/php5 /var/log/nginx/php7 /var/log/nginx/php71 \
        /var/log/nginx/php72 /var/log/nginx/php73 /var/log/nginx/php74 \
        /var/log/nginx/php8 /var/log/nginx/php81 /var/log/nginx/php82 \
        /var/log/nginx/php83 /var/log/nginx/php84
    
    # Set proper permissions
    sudo chown -R $non_admin_username:$non_admin_username /var/log/nginx/php*
}

# Function to create PHP sites
create_php_sites() {
    print_status "Creating PHP sites..."
    
    # Create site directories
    sites=("php5" "php7" "php71" "php72" "php73" "php74" "php8" "php81" "php82" "php83" "php84")
    php_versions=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
    
    for i in "${!sites[@]}"; do
        site=${sites[$i]}
        php_version=${php_versions[$i]}
        
        print_status "Creating site for PHP $php_version..."
        
        # Create site directory
        sudo mkdir -p /var/www/${non_admin_username}-${site}.local/{public,logs,tmp,run}
        sudo chown -R $non_admin_username:$non_admin_username /var/www/${non_admin_username}-${site}.local
        
        # Create index.php
        cat > /tmp/index.php << EOF
<?php
phpinfo();
?>
EOF
        sudo cp /tmp/index.php /var/www/${non_admin_username}-${site}.local/public/
        sudo chown $non_admin_username:$non_admin_username /var/www/${non_admin_username}-${site}.local/public/index.php
        
        # Create Adminer directory and download Adminer
        sudo mkdir -p /var/www/${non_admin_username}-${site}.local/public/adminer
        sudo wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php \
            -O /var/www/${non_admin_username}-${site}.local/public/adminer/index.php
        sudo wget -q https://raw.githubusercontent.com/vrana/adminer/master/designs/lucas-sandery/adminer.css \
            -O /var/www/${non_admin_username}-${site}.local/public/adminer/adminer.css
        sudo chown -R $non_admin_username:$non_admin_username /var/www/${non_admin_username}-${site}.local/public/adminer
        
        # Add to hosts file
        echo "127.0.0.1 ${non_admin_username}-${site}.local" | sudo tee -a /etc/hosts
    done
}

# Function to configure PHP-FPM pools
configure_php_fpm() {
    print_status "Configuring PHP-FPM pools..."
    
    sites=("php5" "php7" "php71" "php72" "php73" "php74" "php8" "php81" "php82" "php83" "php84")
    php_versions=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
    
    for i in "${!sites[@]}"; do
        site=${sites[$i]}
        php_version=${php_versions[$i]}
        
        # Create FPM pool configuration
        sudo tee /etc/php/${php_version}/fpm/pool.d/${site}.conf > /dev/null << EOF
[${site}]
user = ${non_admin_username}
group = ${non_admin_username}
listen = /run/php/php${php_version}-fpm-${site}.sock
listen.owner = ${non_admin_username}
listen.group = ${non_admin_username}
listen.mode = 0660
pm = ondemand
pm.max_children = 5
pm.start_servers = 1
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 500
chdir = /
security.limit_extensions = .php
php_admin_value[disable_functions] = exec,passthru,shell_exec,system
php_admin_flag[allow_url_fopen] = off
php_admin_value[memory_limit] = 256M
php_admin_value[max_execution_time] = 300
php_admin_value[upload_max_filesize] = 64M
php_admin_value[post_max_size] = 64M
EOF
        
        # Create run directory
        sudo mkdir -p /run/php
        sudo chown -R $non_admin_username:$non_admin_username /run/php
        
        # Restart PHP-FPM
        sudo systemctl restart php${php_version}-fpm
    done
}

# Function to configure Apache virtual hosts
configure_apache_vhosts() {
    print_status "Configuring Apache virtual hosts..."
    
    sites=("php5" "php7" "php71" "php72" "php73" "php74" "php8" "php81" "php82" "php83" "php84")
    php_versions=("5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
    
    for i in "${!sites[@]}"; do
        site=${sites[$i]}
        php_version=${php_versions[$i]}
        
        # Create Apache virtual host
        sudo tee /etc/apache2/sites-available/${site}.conf > /dev/null << EOF
<VirtualHost *:81>
    ServerName ${non_admin_username}-${site}.local
    DocumentRoot /var/www/${non_admin_username}-${site}.local/public
    
    <Directory /var/www/${non_admin_username}-${site}.local/public>
        AllowOverride All
        Require all granted
    </Directory>
    
    ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php/php${php_version}-fpm-${site}.sock|fcgi://127.0.0.1:9000/var/www/${non_admin_username}-${site}.local/public/\$1
    
    ErrorLog \${APACHE_LOG_DIR}/${site}_error.log
    CustomLog \${APACHE_LOG_DIR}/${site}_access.log combined
</VirtualHost>
EOF
        
        # Enable site
        sudo a2ensite ${site}.conf
    done
}

# Function to configure NGINX
configure_nginx() {
    print_status "Configuring NGINX..."
    
    # Remove default site
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Create main NGINX configuration
    sudo tee /etc/nginx/sites-available/php-sites > /dev/null << EOF
upstream php5 { server 127.0.0.1:81; }
upstream php7 { server 127.0.0.1:81; }
upstream php71 { server 127.0.0.1:81; }
upstream php72 { server 127.0.0.1:81; }
upstream php73 { server 127.0.0.1:81; }
upstream php74 { server 127.0.0.1:81; }
upstream php8 { server 127.0.0.1:81; }
upstream php81 { server 127.0.0.1:81; }
upstream php82 { server 127.0.0.1:81; }
upstream php83 { server 127.0.0.1:81; }
upstream php84 { server 127.0.0.1:81; }

server {
    listen 80;
    server_name ${non_admin_username}-php5.local;
    location / { proxy_pass http://php5; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php7.local;
    location / { proxy_pass http://php7; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php71.local;
    location / { proxy_pass http://php71; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php72.local;
    location / { proxy_pass http://php72; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php73.local;
    location / { proxy_pass http://php73; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php74.local;
    location / { proxy_pass http://php74; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php8.local;
    location / { proxy_pass http://php8; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php81.local;
    location / { proxy_pass http://php81; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php82.local;
    location / { proxy_pass http://php82; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php83.local;
    location / { proxy_pass http://php83; }
}

server {
    listen 80;
    server_name ${non_admin_username}-php84.local;
    location / { proxy_pass http://php84; }
}
EOF
    
    # Enable NGINX site
    sudo ln -sf /etc/nginx/sites-available/php-sites /etc/nginx/sites-enabled/
}

# Function to set up sudo permissions
setup_sudo_permissions() {
    print_status "Setting up sudo permissions..."
    
    # Allow user to restart services
    echo "${non_admin_username} ALL = NOPASSWD: /usr/sbin/service apache2 *" | sudo tee -a /etc/sudoers
    echo "${non_admin_username} ALL = NOPASSWD: /usr/sbin/service nginx *" | sudo tee -a /etc/sudoers
    echo "${non_admin_username} ALL = NOPASSWD: /usr/sbin/service mysql *" | sudo tee -a /etc/sudoers
    echo "${non_admin_username} ALL = NOPASSWD: /usr/sbin/service docker *" | sudo tee -a /etc/sudoers
    
    # Allow user to restart PHP-FPM services
    for version in "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4"; do
        echo "${non_admin_username} ALL = NOPASSWD: /etc/init.d/php${version}-fpm *" | sudo tee -a /etc/sudoers
    done
}

# Function to start services
start_services() {
    print_status "Starting services..."
    
    # Start Apache
    sudo systemctl start apache2
    sudo systemctl enable apache2
    
    # Start NGINX
    sudo systemctl start nginx
    sudo systemctl enable nginx
    
    # Start MySQL
    sudo systemctl start mysql
    sudo systemctl enable mysql
    
    # Restart all PHP-FPM services
    for version in "5.6" "7.0" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4"; do
        sudo systemctl restart php${version}-fpm
        sudo systemctl enable php${version}-fpm
    done
}

# Function to display installation summary
display_summary() {
    print_success "Installation completed successfully!"
    echo
    echo "=== Installation Summary ==="
    echo "User: $non_admin_username"
    echo "PHP versions installed: 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4"
    echo "Web servers: Apache (port 81), NGINX (port 80)"
    echo "Database: MySQL 8.0"
    echo "Java: OpenJDK 17 & 21"
    echo "Python: 3.10, 3.11, 3.12, 3.13"
    echo "Node.js: 18.x"
    echo "Docker: Latest"
    echo
    echo "=== Access URLs ==="
    echo "PHP 5.6: http://${non_admin_username}-php5.local"
    echo "PHP 7.0: http://${non_admin_username}-php7.local"
    echo "PHP 7.1: http://${non_admin_username}-php71.local"
    echo "PHP 7.2: http://${non_admin_username}-php72.local"
    echo "PHP 7.3: http://${non_admin_username}-php73.local"
    echo "PHP 7.4: http://${non_admin_username}-php74.local"
    echo "PHP 8.0: http://${non_admin_username}-php8.local"
    echo "PHP 8.1: http://${non_admin_username}-php81.local"
    echo "PHP 8.2: http://${non_admin_username}-php82.local"
    echo "PHP 8.3: http://${non_admin_username}-php83.local"
    echo "PHP 8.4: http://${non_admin_username}-php84.local"
    echo
    echo "Adminer: http://${non_admin_username}-php84.local/adminer/"
    echo
    echo "=== Next Steps ==="
    echo "1. Log out and log back in for group changes to take effect"
    echo "2. Test each PHP version by visiting the URLs above"
    echo "3. Configure your development environment"
    echo "4. Set up your database and applications"
}

# Main installation function
main() {
    echo "=========================================="
    echo "Ubuntu 22.04 PHP Adminer Multi-Version"
    echo "Installation Script"
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
    install_java
    install_python
    install_nodejs
    install_docker
    install_composer
    install_additional_tools
    configure_services
    create_php_sites
    configure_php_fpm
    configure_apache_vhosts
    configure_nginx
    setup_sudo_permissions
    start_services
    
    # Display summary
    display_summary
}

# Run main function
main "$@"
