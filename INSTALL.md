# Quick Installation Guide

## 🚀 One-Command Installation

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install-php-adminer-ubuntu22.sh | bash
```

## 📋 Step-by-Step Installation

### 1. Prerequisites
- Ubuntu 22.04 LTS
- User with sudo privileges
- Internet connection

### 2. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### 3. Run Installation
```bash
chmod +x install-php-adminer-ubuntu22.sh
./install-php-adminer-ubuntu22.sh
```

### 4. Follow Prompts
- Enter your username
- Enter your full name
- Wait for installation to complete

## 🌐 Access Your Sites

After installation, access your PHP versions at:
- **PHP 5.6**: `http://username-php5.local`
- **PHP 7.4**: `http://username-php74.local`
- **PHP 8.1**: `http://username-php81.local`
- **PHP 8.4**: `http://username-php84.local`

**Adminer Database**: `http://username-php84.local/adminer/`

## 🔧 Troubleshooting

If you see "This site can't be reached":
1. Clear browser cache and DNS
2. Wait a few seconds for services to start
3. Check if domain is in `/etc/hosts`

## 📞 Need Help?

- Check the main README.md for detailed information
- Open an issue on GitHub
- Review the troubleshooting section
