# PHP Adminer Multi-Version Installation for Ubuntu 22.04

A comprehensive solution for installing multiple PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4) on Ubuntu 22.04 with Apache, NGINX, MySQL, and Adminer database management tool.

## 🚀 Features

- **Multiple PHP Versions**: Install and manage PHP 5.6 through 8.4
- **Web Stack**: Apache (port 81) + NGINX (port 80) reverse proxy setup
- **Database**: MySQL 8.0 with Adminer for web-based database management
- **Development Tools**: Java, Python, Node.js, Docker, and more
- **Security**: UFW firewall, fail2ban, and secure configurations
- **Easy Installation**: One-command installation script

## 📋 Prerequisites

- Ubuntu 22.04 (Jammy Jellyfish)
- User with sudo privileges (not root)
- Internet connection for package downloads
- At least 4GB RAM and 20GB disk space

## 🛠️ Quick Installation

### Method 1: One-Command Installation (Recommended)

```bash
# Download and run the installation script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-php-adminer-ubuntu22.sh | bash
```

### Method 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Make the script executable
chmod +x install-php-adminer-ubuntu22.sh

# Run the installation
./install-php-adminer-ubuntu22.sh
```

### Method 3: Ansible Installation

```bash
# Install Ansible
sudo apt update && sudo apt install -y ansible

# Clone and run with Ansible
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
ansible-playbook -i localhost, -c local install-ubuntu22-ansible.yml --become
```

## 🌐 Access URLs

After installation, you can access each PHP version at:

| PHP Version | URL Pattern | Example |
|-------------|-------------|---------|
| PHP 5.6 | `http://username-php5.local` | `http://developer-php5.local` |
| PHP 7.0 | `http://username-php7.local` | `http://developer-php7.local` |
| PHP 7.1 | `http://username-php71.local` | `http://developer-php71.local` |
| PHP 7.2 | `http://username-php72.local` | `http://developer-php72.local` |
| PHP 7.3 | `http://username-php73.local` | `http://developer-php73.local` |
| PHP 7.4 | `http://username-php74.local` | `http://developer-php74.local` |
| PHP 8.0 | `http://username-php8.local` | `http://developer-php8.local` |
| PHP 8.1 | `http://username-php81.local` | `http://developer-php81.local` |
| PHP 8.2 | `http://username-php82.local` | `http://developer-php82.local` |
| PHP 8.3 | `http://username-php83.local` | `http://developer-php83.local` |
| PHP 8.4 | `http://username-php84.local` | `http://developer-php84.local` |

**Adminer Database Management**: `http://username-php84.local/adminer/`

## 🏗️ Architecture

```
Internet → NGINX (Port 80) → Apache (Port 81) → PHP-FPM → MySQL
```

- **NGINX**: Reverse proxy and load balancer
- **Apache**: PHP processing and content serving
- **PHP-FPM**: FastCGI Process Manager for each PHP version
- **MySQL**: Database server
- **Adminer**: Web-based database management tool

## 📁 Project Structure

```
infra-automation/
├── install-php-adminer-ubuntu22.sh    # Main installation script
├── install-ubuntu22-ansible.yml       # Ansible playbook
├── environment-setup-ubuntu22.yml      # Environment setup
├── vars/
│   └── default-ubuntu22.yml           # Configuration variables
├── templates/                          # Configuration templates
│   ├── php-fpm-pool.j2
│   ├── apache-vhost.j2
│   └── nginx-sites.j2
├── test-installation.sh               # Testing script
└── README.md                          # This file
```

## 🔧 Configuration

### PHP-FPM Pools
- Location: `/etc/php/{version}/fpm/pool.d/`
- Each site has its own pool configuration
- Optimized for development with reasonable memory limits

### Apache Virtual Hosts
- Location: `/etc/apache2/sites-available/`
- Configured for PHP-FPM integration
- Custom error and access logs

### NGINX Configuration
- Location: `/etc/nginx/sites-available/`
- Reverse proxy configuration
- Upstream definitions for each PHP version

## 🔒 Security Features

- **Firewall**: UFW with minimal open ports (22, 80, 443)
- **Intrusion Detection**: fail2ban for SSH and web attacks
- **PHP Security**: Disabled dangerous functions, secure file permissions
- **User Isolation**: Each site runs under dedicated user account
- **Sudo Permissions**: Minimal required permissions for service management

## 🚨 Troubleshooting

### Common Issues

1. **NXDOMAIN Error**: Clear browser DNS cache and refresh
2. **502 Bad Gateway**: Check if Apache and PHP-FPM are running
3. **Permission Errors**: Verify file ownership and sudo permissions
4. **Service Failures**: Check if all required packages are installed

### Debug Commands

```bash
# Check service status
sudo systemctl status apache2 nginx mysql php8.1-fpm

# Check Apache configuration
sudo apache2ctl configtest

# Check NGINX configuration
sudo nginx -t

# Check hosts file
cat /etc/hosts | grep username

# Check logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/apache2/error.log
```

## 📚 Documentation

- [PHP Documentation](https://www.php.net/docs.php)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Adminer Documentation](https://www.adminer.org/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Commit your changes: `git commit -am 'Add feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Important Notes

- This installation script is designed for development and testing environments
- For production use, please review and customize security settings
- The script requires sudo privileges but should not be run as root
- All PHP versions are configured to use PHP 8.1 FPM on Ubuntu 22.04

## 🆘 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review the logs for error messages
3. Open an issue on GitHub with detailed information
4. Include your Ubuntu version and any error messages

---

**Made with ❤️ for the PHP development community**
