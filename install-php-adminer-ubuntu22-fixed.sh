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

# Global variables
FORCE_INSTALL=false
SKIP_VERSION_CHECK=false
DEBUG_MODE=false

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -f, --force          Force installation even if Ubuntu version check fails"
    echo "  -s, --skip-check     Skip Ubuntu version compatibility check"
    echo "  -d, --debug          Enable debug mode with verbose output"
    echo "  -h, --help           Show this help message"
    echo
    echo "Examples:"
    echo "  $0                    # Normal installation with version check"
    echo "  $0 --force           # Force installation"
    echo "  $0 --skip-check      # Skip version check"
    echo "  $0 --debug           # Enable debug mode"
    echo
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                FORCE_INSTALL=true
                shift
                ;;
            -s|--skip-check)
                SKIP_VERSION_CHECK=true
                shift
                ;;
            -d|--debug)
                DEBUG_MODE=true
                set -x  # Enable debug mode
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

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
debug_system_info() {
    print_status "Debug: Collecting system information..."
    
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Shell: $SHELL"
    echo "Current directory: $(pwd)"
    echo
    
    echo "=== Distribution Detection ==="
    echo "1. /etc/lsb-release:"
    if [[ -r /etc/lsb-release ]]; then
        cat /etc/lsb-release
    else
        echo "  File not readable"
    fi
    echo
    
    echo "2. /etc/os-release:"
    if [[ -r /etc/os-release ]]; then
        cat /etc/os-release
    else
        echo "  File not readable"
    fi
    echo
    
    echo "3. /etc/issue:"
    if [[ -r /etc/issue ]]; then
        cat /etc/issue
    else
        echo "  File not readable"
    fi
    echo
    
    echo "4. hostnamectl:"
    if command -v hostnamectl >/dev/null 2>&1; then
        hostnamectl 2>/dev/null | head -10
    else
        echo "  Command not available"
    fi
    echo
    
    echo "5. uname:"
    uname -a
    echo
    
    echo "6. lsb_release:"
    if command -v lsb_release >/dev/null 2>&1; then
        lsb_release -a 2>/dev/null || echo "  Command failed"
    else
        echo "  Command not available"
    fi
    echo
    
    echo "7. cat /proc/version:"
    if [[ -r /proc/version ]]; then
        cat /proc/version
    else
        echo "  File not readable"
    fi
    echo
}

# Function to check Ubuntu version
check_ubuntu_version() {
    if [[ "$SKIP_VERSION_CHECK" == true ]]; then
        print_warning "Skipping Ubuntu version check as requested."
        return 0
    fi
    
    print_status "Checking Ubuntu version..."
    
    # Try multiple methods to detect Ubuntu version
    ubuntu_detected=false
    
    # Method 1: Check /etc/lsb-release
    if [[ -r /etc/lsb-release ]]; then
        . /etc/lsb-release
        if [[ $ID == "ubuntu" ]]; then
            print_status "Detected Ubuntu $UBUNTU_VERSION_NAME ($DISTRIB_CODENAME)"
            if [[ $DISTRIB_CODENAME == "jammy" ]]; then
                ubuntu_detected=true
            else
                print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish). You are running $DISTRIB_CODENAME."
                if [[ "$FORCE_INSTALL" == false ]]; then
                    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        ubuntu_detected=true
                    fi
                else
                    print_warning "Force install enabled. Continuing..."
                    ubuntu_detected=true
                fi
            fi
        fi
    fi
    
    # Method 2: Check /etc/os-release
    if [[ "$ubuntu_detected" == false ]] && [[ -r /etc/os-release ]]; then
        . /etc/os-release
        if [[ $ID == "ubuntu" ]]; then
            print_status "Detected Ubuntu $VERSION ($VERSION_CODENAME)"
            if [[ $VERSION_CODENAME == "jammy" ]]; then
                ubuntu_detected=true
            else
                print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish). You are running $VERSION_CODENAME."
                if [[ "$FORCE_INSTALL" == false ]]; then
                    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        ubuntu_detected=true
                    fi
                else
                    print_warning "Force install enabled. Continuing..."
                    ubuntu_detected=true
                fi
            fi
        fi
    fi
    
    # Method 3: Check hostnamectl
    if [[ "$ubuntu_detected" == false ]]; then
        if command -v hostnamectl >/dev/null 2>&1; then
            os_info=$(hostnamectl 2>/dev/null | grep "Operating System")
            if [[ $os_info == *"Ubuntu"* ]]; then
                print_status "Detected Ubuntu via hostnamectl"
                if [[ $os_info == *"22.04"* ]] || [[ $os_info == *"jammy"* ]]; then
                    ubuntu_detected=true
                else
                    print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish)."
                    if [[ "$FORCE_INSTALL" == false ]]; then
                        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            ubuntu_detected=true
                        fi
                    else
                        print_warning "Force install enabled. Continuing..."
                        ubuntu_detected=true
                    fi
                fi
            fi
        fi
    fi
    
    # Method 4: Check /etc/issue
    if [[ "$ubuntu_detected" == false ]] && [[ -r /etc/issue ]]; then
        if grep -q "Ubuntu" /etc/issue; then
            print_status "Detected Ubuntu via /etc/issue"
            if grep -q "22.04\|jammy" /etc/issue; then
                ubuntu_detected=true
            else
                print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish)."
                if [[ "$FORCE_INSTALL" == false ]]; then
                    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        ubuntu_detected=true
                    fi
                else
                    print_warning "Force install enabled. Continuing..."
                    ubuntu_detected=true
                fi
            fi
        fi
    fi
    
    # Method 5: Check dpkg
    if [[ "$ubuntu_detected" == false ]]; then
        if command -v dpkg >/dev/null 2>&1; then
            if dpkg -l | grep -q "ubuntu-base"; then
                print_status "Detected Ubuntu via package manager"
                ubuntu_detected=true
            fi
        fi
    fi
    
    # Method 6: Check lsb_release command
    if [[ "$ubuntu_detected" == false ]]; then
        if command -v lsb_release >/dev/null 2>&1; then
            distro=$(lsb_release -si 2>/dev/null)
            version=$(lsb_release -sr 2>/dev/null)
            codename=$(lsb_release -sc 2>/dev/null)
            if [[ $distro == "Ubuntu" ]]; then
                print_status "Detected Ubuntu $version ($codename) via lsb_release"
                if [[ $codename == "jammy" ]]; then
                    ubuntu_detected=true
                else
                    print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish). You are running $codename."
                    if [[ "$FORCE_INSTALL" == false ]]; then
                        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
                        echo
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                            ubuntu_detected=true
                        fi
                    else
                        print_warning "Force install enabled. Continuing..."
                        ubuntu_detected=true
                    fi
                fi
            fi
        fi
    fi
    
    # Final check
    if [[ "$ubuntu_detected" == false ]]; then
        print_warning "Could not reliably determine Ubuntu version."
        print_warning "This script is designed for Ubuntu 22.04 (Jammy Jellyfish)."
        
        if [[ "$FORCE_INSTALL" == true ]]; then
            print_warning "Force install enabled. Continuing despite version check failure..."
            ubuntu_detected=true
        else
            print_warning "Debug information will be displayed to help troubleshoot."
            echo
            debug_system_info
            read -p "Do you want to continue anyway? This may cause issues. (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ubuntu_detected=true
            else
                print_error "Installation aborted. Please ensure you are running Ubuntu 22.04."
                print_error "You can use --force or --skip-check options to bypass this check."
                exit 1
            fi
        fi
    fi
    
    if [[ "$ubuntu_detected" == true ]]; then
        print_success "Ubuntu version check passed. Continuing with installation..."
    fi
}

# Function to get user input
get_user_input() {
    print_status "Getting user information..."
    
    # Get username
    read -p "Enter your username (e.g., developer): " USERNAME
    if [[ -z "$USERNAME" ]]; then
        print_error "Username cannot be empty."
        exit 1
    fi
    
    # Get full name
    read -p "Enter your full name (e.g., John Doe): " FULL_NAME
    if [[ -z "$FULL_NAME" ]]; then
        print_error "Full name cannot be empty."
        exit 1
    fi
    
    print_success "User information collected: $USERNAME ($FULL_NAME)"
}

# Main installation function
main() {
    echo "=========================================="
    echo "PHP Adminer Multi-Version Installation"
    echo "for Ubuntu 22.04"
    echo "=========================================="
    echo
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check prerequisites
    check_root
    check_ubuntu_version
    get_user_input
    
    print_status "Starting installation for user: $USERNAME"
    
    # Continue with the rest of your installation logic here
    # This is where you would call your existing installation functions
    
    print_success "Installation completed successfully!"
}

# Run main function
main "$@"


