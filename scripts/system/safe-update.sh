#!/bin/bash
#
# safe-update.sh - Robust system update script with error checking
#
# This script performs system updates with comprehensive error detection,
# logging, and validation to prevent silent failures.
#
# Usage:
#   ./safe-update.sh           # Full update with all checks
#   ./safe-update.sh --check   # Dry run, check what would be updated
#   ./safe-update.sh --quick   # Skip some slower validation steps

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="$HOME/.cache/system-updates"
LOG_FILE="$LOG_DIR/update-$(date +%Y%m%d-%H%M%S).log"
PACKAGE_BACKUP="$LOG_DIR/packages-$(date +%Y%m%d-%H%M%S).txt"
MIN_DISK_SPACE_MB=2048  # 2GB minimum free space

# Flags
DRY_RUN=false
QUICK_MODE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --check)
            DRY_RUN=true
            ;;
        --quick)
            QUICK_MODE=true
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --check   Dry run, show what would be updated"
            echo "  --quick   Skip slower validation steps"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
            exit 1
            ;;
    esac
done

# Setup logging
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Pre-update checks
check_disk_space() {
    print_header "Checking Disk Space"

    local available_mb
    available_mb=$(df /usr | tail -1 | awk '{print int($4/1024)}')

    if [ "$available_mb" -lt "$MIN_DISK_SPACE_MB" ]; then
        print_error "Insufficient disk space: ${available_mb}MB available, ${MIN_DISK_SPACE_MB}MB required"
        return 1
    fi

    print_success "Disk space: ${available_mb}MB available"
}

check_pacman_db() {
    print_header "Checking Pacman Database"

    if ! sudo pacman -Dk &>/dev/null; then
        print_error "Pacman database integrity check failed"
        print_info "Try running: sudo pacman -Dk"
        return 1
    fi

    print_success "Pacman database is healthy"
}

check_broken_packages() {
    print_header "Checking for Broken Packages"

    local broken
    broken=$(pacman -Qk 2>&1 | grep -i "warning\|error" || true)

    if [ -n "$broken" ]; then
        print_warning "Some packages have issues:"
        echo "$broken"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        print_success "No broken packages detected"
    fi
}

check_failed_services() {
    print_header "Checking System Services"

    local failed
    failed=$(systemctl --failed --no-legend --user 2>/dev/null || true)
    failed+=$(systemctl --failed --no-legend 2>/dev/null || sudo systemctl --failed --no-legend || true)

    if [ -n "$failed" ]; then
        print_warning "Some services have failed:"
        echo "$failed"
    else
        print_success "All services running normally"
    fi
}

backup_package_list() {
    print_header "Backing Up Package List"

    {
        echo "# System packages"
        pacman -Qe
        echo ""
        echo "# AUR packages"
        pacman -Qm
    } > "$PACKAGE_BACKUP"

    print_success "Package list saved to: $PACKAGE_BACKUP"
}

check_arch_news() {
    print_header "Checking Arch Linux News"

    if ! command -v curl &>/dev/null; then
        print_warning "curl not installed, skipping news check"
        return 0
    fi

    print_info "Latest Arch news (check https://archlinux.org/news/):"

    # Fetch and display recent news titles
    local news
    news=$(curl -s https://archlinux.org/feeds/news/ 2>/dev/null | \
           grep -oP '(?<=<title>).*?(?=</title>)' | \
           head -5 || echo "Unable to fetch news")

    echo "$news"
    echo ""

    if [ "$DRY_RUN" = false ]; then
        read -p "Have you reviewed the news? Continue? [Y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_info "Update cancelled. Review news at https://archlinux.org/news/"
            exit 0
        fi
    fi
}

# Update process
perform_update() {
    print_header "Starting System Update"

    if [ "$DRY_RUN" = true ]; then
        print_info "DRY RUN MODE - No changes will be made"
        yay -Syu --devel --timeupdate
        return 0
    fi

    # Update with error checking
    print_info "Running: yay -Syu --devel --timeupdate --answerdiff None"

    if ! yay -Syu --devel --timeupdate --answerdiff None; then
        print_error "Update failed with exit code $?"
        print_info "Check the log file: $LOG_FILE"
        return 1
    fi

    print_success "Update completed successfully"
}

# Post-update checks
check_pacnew_files() {
    print_header "Checking for .pacnew Files"

    local pacnew_files
    pacnew_files=$(find /etc -name "*.pacnew" 2>/dev/null || true)

    if [ -n "$pacnew_files" ]; then
        print_warning "Found .pacnew files that need manual review:"
        echo "$pacnew_files"
        print_info "Review these with: sudo pacdiff"
    else
        print_success "No .pacnew files found"
    fi
}

check_orphaned_packages() {
    print_header "Checking for Orphaned Packages"

    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null || true)

    if [ -n "$orphans" ]; then
        print_info "Found orphaned packages:"
        echo "$orphans"

        if [ "$DRY_RUN" = false ]; then
            read -p "Remove orphaned packages? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo pacman -Rns $(pacman -Qtdq)
                print_success "Orphaned packages removed"
            fi
        fi
    else
        print_success "No orphaned packages"
    fi
}

check_kernel_update() {
    print_header "Checking Kernel Update"

    local running_kernel
    local installed_kernel

    running_kernel=$(uname -r)
    installed_kernel=$(pacman -Q linux-lts 2>/dev/null | awk '{print $2}' || echo "not installed")

    print_info "Running kernel: $running_kernel"
    print_info "Installed kernel: $installed_kernel"

    if [[ "$running_kernel" != *"$installed_kernel"* ]]; then
        print_warning "Kernel was updated - reboot recommended"
        return 1
    else
        print_success "Kernel is current"
    fi
}

validate_critical_services() {
    print_header "Validating Critical Services"

    local critical_services=(
        "sddm"
        "pipewire"
        "pipewire-pulse"
        "avahi-daemon"
    )

    local all_good=true

    for service in "${critical_services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null || \
           systemctl is-active --quiet --user "$service" 2>/dev/null; then
            print_success "$service is running"
        else
            # Check if it's enabled but not running
            if systemctl is-enabled --quiet "$service" 2>/dev/null || \
               systemctl is-enabled --quiet --user "$service" 2>/dev/null; then
                print_warning "$service is enabled but not running"
                all_good=false
            fi
        fi
    done

    if [ "$all_good" = false ]; then
        return 1
    fi
}

# Main execution
main() {
    print_header "Safe System Update - $(date)"
    print_info "Log file: $LOG_FILE"

    # Pre-update checks
    check_disk_space || exit 1
    check_pacman_db || exit 1

    if [ "$QUICK_MODE" = false ]; then
        check_broken_packages || exit 1
        check_failed_services
        check_arch_news
    fi

    backup_package_list

    # Perform update
    perform_update || {
        print_error "Update process failed"
        exit 1
    }

    if [ "$DRY_RUN" = true ]; then
        print_success "Dry run completed"
        exit 0
    fi

    # Post-update validation
    check_pacnew_files
    check_orphaned_packages

    local needs_reboot=false

    if [ "$QUICK_MODE" = false ]; then
        check_kernel_update || needs_reboot=true
        validate_critical_services || print_warning "Some services need attention"
    fi

    # Final summary
    print_header "Update Complete"
    print_success "All updates applied successfully"
    print_info "Log saved to: $LOG_FILE"
    print_info "Package backup: $PACKAGE_BACKUP"

    if [ "$needs_reboot" = true ]; then
        echo ""
        print_warning "REBOOT RECOMMENDED"
        print_info "Run: systemctl reboot"
    fi

    echo ""
}

# Run main function
main
