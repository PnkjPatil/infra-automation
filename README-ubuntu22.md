# Ubuntu 22.04 PHP Adminer Multi-Version Installation

This project provides a complete solution for installing multiple PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4) on Ubuntu 22.04 along with Apache, NGINX, MySQL, Java, Python, Node.js, Docker, and other development tools.

## Features

- **Multiple PHP Versions**: Install and manage PHP 5.6 through 8.4
- **Web Servers**: Apache (port 81) and NGINX (port 80) with reverse proxy setup
- **Database**: MySQL 8.0 with Adminer for database management
- **Development Tools**: Java (OpenJDK 17 & 21), Python (3.10-3.13), Node.js 18.x
- **Containerization**: Docker and Docker Compose
- **Security**: UFW firewall, fail2ban, and secure configurations
- **Monitoring**: Built-in logging and monitoring tools

## Prerequisites

- Ubuntu 22.04 (Jammy Jellyfish)
- User with sudo privileges (not root)
- Internet connection for package downloads
- At least 4GB RAM and 20GB disk space

## Installation Methods

### Method 1: Bash Script (Recommended)

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/your-repo/install-ubuntu22.sh
   chmod +x install-ubuntu22.sh
   ```

2. **Run the installation:**
   ```bash
   ./install-ubuntu22.sh
   ```

3. **Follow the prompts:**
   - Enter your username
   - Enter your full name
   - Wait for installation to complete

### Method 2: Ansible Playbook

1. **Install Ansible:**
   ```bash
   sudo apt update
   sudo apt install ansible
   ```

2. **Download the playbook:**
   ```bash
   wget https://raw.githubusercontent.com/your-repo/install-ubuntu22-ansible.yml
   ```

3. **Run the playbook:**
   ```bash
   ansible-playbook -i localhost, -c local install-ubuntu22-ansible.yml --become
   ```

## What Gets Installed

### PHP Versions
- PHP 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4
- PHP-FPM for each version
- Common PHP extensions (GD, cURL, MySQL, XML, etc.)

### Web Servers
- Apache 2.4 with PHP modules
- NGINX with reverse proxy to Apache
- Virtual hosts for each PHP version

### Database
- MySQL 8.0 Server
- Adminer 4.8.1 for database management

### Development Tools
- **Java**: OpenJDK 17 & 21, Maven, Gradle
- **Python**: 3.10, 3.11, 3.12, 3.13 with pip and virtualenv
- **Node.js**: 18.x with npm, yarn, and global packages
- **Docker**: Latest version with Docker Compose

### Additional Software
- Git, Vim, Nano, Htop, Tree, MC
- Geany IDE with plugins
- FileZilla, Meld, VLC, Sublime Text
- UFW firewall, fail2ban, logwatch

## Access URLs

After installation, you can access each PHP version at:

- **PHP 5.6**: `http://username-php5.local`
- **PHP 7.0**: `http://username-php7.local`
- **PHP 7.1**: `http://username-php71.local`
- **PHP 7.2**: `http://username-php72.local`
- **PHP 7.3**: `http://username-php73.local`
- **PHP 7.4**: `http://username-php74.local`
- **PHP 8.0**: `http://username-php8.local`
- **PHP 8.1**: `http://username-php81.local`
- **PHP 8.2**: `http://username-php82.local`
- **PHP 8.3**: `http://username-php83.local`
- **PHP 8.4**: `http://username-php84.local`

**Adminer**: `http://username-php84.local/adminer/`

## Architecture

```
Internet → NGINX (Port 80) → Apache (Port 81) → PHP-FPM
```

- **NGINX**: Acts as reverse proxy and load balancer
- **Apache**: Handles PHP processing and serves content
- **PHP-FPM**: FastCGI Process Manager for each PHP version
- **MySQL**: Database server
- **Adminer**: Web-based database management tool

## Configuration Files

### PHP-FPM Pools
- Location: `/etc/php/{version}/fpm/pool.d/`
- Each site has its own pool configuration
- Optimized for development with reasonable memory limits

### Apache Virtual Hosts
- Location: `/etc/apache2/sites-available/`
- Configured for PHP-FPM integration
- Custom error and access logs

### NGINX Configuration
- Location: `/etc/nginx/sites-available/php-sites`
- Reverse proxy configuration
- Upstream definitions for each PHP version

## Security Features

- **Firewall**: UFW with minimal open ports (22, 80, 443)
- **Intrusion Detection**: fail2ban for SSH and web attacks
- **PHP Security**: Disabled dangerous functions, secure file permissions
- **User Isolation**: Each site runs under dedicated user account
- **Sudo Permissions**: Minimal required permissions for service management

## Performance Optimization

- **PHP-FPM**: On-demand process management
- **NGINX**: Efficient reverse proxy with gzip compression
- **Apache**: Optimized for PHP processing
- **MySQL**: Tuned for development workloads
- **Memory Management**: Reasonable limits for development

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 80 and 81 are not in use
2. **Permission errors**: Check file ownership and sudo permissions
3. **Service failures**: Verify all required packages are installed
4. **DNS resolution**: Ensure hosts file entries are correct

### Log Files

- **Apache**: `/var/log/apache2/`
- **NGINX**: `/var/log/nginx/`
- **PHP-FPM**: `/var/log/php{version}-fpm.log`
- **System**: `/var/log/syslog`

### Service Management

```bash
# Restart Apache
sudo service apache2 restart

# Restart NGINX
sudo service nginx restart

# Restart PHP-FPM (replace version)
sudo service php8.4-fpm restart

# Check service status
sudo systemctl status apache2 nginx php8.4-fpm
```

## Post-Installation

### 1. Log Out and Back In
Group changes (especially Docker) require a new login session.

### 2. Test PHP Versions
Visit each URL to verify PHP versions are working correctly.

### 3. Configure Database
- Access Adminer at `http://username-php84.local/adminer/`
- Create databases and users as needed
- Import existing data if required

### 4. Set Up Development Environment
- Configure your IDE/editor
- Set up version control
- Install project-specific dependencies

### 5. Customize Configuration
- Modify PHP settings in `/etc/php/{version}/fpm/php.ini`
- Adjust Apache/Nginx configurations as needed
- Update firewall rules for your requirements

## Maintenance

### Updates
```bash
# System updates
sudo apt update && sudo apt upgrade

# PHP updates (if available)
sudo apt update
sudo apt upgrade php*
```

### Backups
- Database: Use Adminer or mysqldump
- Configuration: Backup `/etc/` directories
- Websites: Backup `/var/www/` directories

### Monitoring
- Check service status regularly
- Monitor log files for errors
- Verify firewall and security settings

## Support

### Documentation
- [PHP Documentation](https://www.php.net/docs.php)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Community
- [Ubuntu Forums](https://ubuntuforums.org/)
- [Stack Overflow](https://stackoverflow.com/)
- [GitHub Issues](https://github.com/your-repo/issues)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Changelog

### Version 1.0.0
- Initial release for Ubuntu 22.04
- Support for PHP 5.6 through 8.4
- Complete LAMP stack with NGINX reverse proxy
- Development tools and security features

---

**Note**: This installation script is designed for development and testing environments. For production use, please review and customize security settings according to your requirements.
