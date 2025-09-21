#!/bin/bash

# File konfigurasi baru untuk Debian 13 (format deb822)
DEBIAN_SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
BACKUP_DIR="/etc/apt/sources.list.d/backup-sources"
OLD_SOURCES_FILE="/etc/apt/sources.list"
OLD_SOURCES_BACKUP="$BACKUP_DIR/sources.list.bak"

# Function to show the menu
show_menu() {
    echo "1) Set sources untuk Debian 13 (Trixie) — format modern (.sources)"
    echo "2) Gunakan sources.list klasik"
    echo "3) Restore original sources (backup)"
    echo "4) Exit"
}

# Pastikan backup direktori ada
prepare_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        chmod 755 "$BACKUP_DIR"
    fi
}

# Function to write sources modern (.sources format)
set_modern_sources() {
    # Backup file-file yang ada
    prepare_backup_dir
    # Backup old sources.list jika ada
    if [ -f "$OLD_SOURCES_FILE" ]; then
        cp "$OLD_SOURCES_FILE" "$OLD_SOURCES_BACKUP"
        echo "Backup sources.list -> $OLD_SOURCES_BACKUP"
    fi
    # Backup existing .sources file jika ada
    if [ -f "$DEBIAN_SOURCES_FILE" ]; then
        cp "$DEBIAN_SOURCES_FILE" "$BACKUP_DIR/debian.sources.bak"
        echo "Backup debian.sources -> $BACKUP_DIR/debian.sources.bak"
    fi

    # Tuliskan konfigurasi `.sources` baru
    cat <<EOL > "$DEBIAN_SOURCES_FILE"
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOL

    if [ $? -eq 0 ]; then
        echo ".sources file telah ditulis di $DEBIAN_SOURCES_FILE"
    else
        echo "Gagal menulis file .sources. Mengembalikan backup jika ada."
        [ -f "$BACKUP_DIR/debian.sources.bak" ] && cp "$BACKUP_DIR/debian.sources.bak" "$DEBIAN_SOURCES_FILE"
        exit 1
    fi

    # Opsional: hapus atau komentar file sources.list lama agar tidak konflik
    if [ -f "$OLD_SOURCES_FILE" ]; then
        mv "$OLD_SOURCES_FILE" "${OLD_SOURCES_FILE}.disabled"
        echo "sources.list lama telah dipindahkan ke sources.list.disabled"
    fi

    # Update
    apt update

    if [ $? -eq 0 ]; then
        echo "apt update berhasil setelah set modern sources."
    else
        echo "Gagal update setelah set modern sources. Periksa konfigurasi."
    fi
}

# Function untuk memakai sources.list klasik
set_legacy_sources() {
    prepare_backup_dir
    # Backup lama
    if [ -f "$OLD_SOURCES_FILE" ]; then
        cp "$OLD_SOURCES_FILE" "$OLD_SOURCES_BACKUP"
        echo "Backup sources.list -> $OLD_SOURCES_BACKUP"
    fi

    # Hapus/deaktivasi .sources jika ada
    if [ -f "$DEBIAN_SOURCES_FILE" ]; then
        mv "$DEBIAN_SOURCES_FILE" "${DEBIAN_SOURCES_FILE}.disabled"
        echo "debian.sources dinonaktifkan"
    fi

    # Tulis sources.list klasik untuk Debian 13
    cat <<EOL > "$OLD_SOURCES_FILE"
deb https://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb https://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb https://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

# Optional: source lines kalau kamu butuh kode sumber
deb-src https://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb-src https://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOL

    if [ $? -eq 0 ]; then
        echo "sources.list klasik telah ditulis ke $OLD_SOURCES_FILE"
    else
        echo "Gagal menulis sources.list klasik. Mengembalikan backup jika ada."
        [ -f "$OLD_SOURCES_BACKUP" ] && cp "$OLD_SOURCES_BACKUP" "$OLD_SOURCES_FILE"
        exit 1
    fi

    apt update

    if [ $? -eq 0 ]; then
        echo "apt update berhasil setelah set legacy sources."
    else
        echo "Gagal update setelah set legacy sources. Periksa konfigurasi."
    fi
}

# Function to restore original
restore_original() {
    prepare_backup_dir
    # Cek backup lama
    if [ -f "$OLD_SOURCES_BACKUP" ]; then
        cp "$OLD_SOURCES_BACKUP" "$OLD_SOURCES_FILE"
        echo "Restored sources.list dari backup."
    else
        echo "Backup sources.list tidak ditemukan."
    fi
    # Restore .sources juga jika ada backup
    if [ -f "$BACKUP_DIR/debian.sources.bak" ]; then
        cp "$BACKUP_DIR/debian.sources.bak" "$DEBIAN_SOURCES_FILE"
        echo "Restored debian.sources dari backup."
    fi

    apt update

    if [ $? -eq 0 ]; then
        echo "apt update berhasil setelah restore."
    else
        echo "Gagal update setelah restore. Periksa konfigurasi."
    fi
}

# Main script logic
while true; do
    show_menu
    read -p "Pilih opsi: " choice
    case $choice in
        1)
            set_modern_sources
            ;;
        2)
            set_legacy_sources
            ;;
        3)
            restore_original
            ;;
        4)
            echo "Keluar."
            exit 0
            ;;
        *)
            echo "Opsi tidak valid. Silakan coba lagi."
            ;;
    esac
    echo
done
