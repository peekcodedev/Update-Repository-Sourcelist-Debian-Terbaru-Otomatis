Berikut adalah deskripsi untuk "Update Repository Sourcelist Debian Terbaru Otomatis

---

### Update Repository Sourcelist Debian Terbaru Otomatis

#### Deskripsi
Script ini bertujuan untuk mempermudah proses pembaruan dan pemeliharaan file `sources.list` pada sistem operasi Debian. File `sources.list` merupakan konfigurasi utama yang menentukan dari mana sistem akan mengunduh paket perangkat lunak. Dengan script ini, pengguna dapat:

1. **Membuat Cadangan (Backup) File `sources.list` yang Lama**: Sebelum melakukan perubahan, script ini secara otomatis membuat salinan cadangan dari file `sources.list` yang ada. Ini memastikan bahwa pengguna dapat mengembalikan ke konfigurasi sebelumnya jika diperlukan.

2. **Mengganti `sources.list` dengan Repository Terbaru**: Script ini akan menggantikan konten `sources.list` dengan daftar repository terbaru yang mencakup repositori utama, pembaruan, backports, dan keamanan dari Debian versi Bullseye.

3. **Memperbarui Daftar Paket**: Setelah memperbarui `sources.list`, script ini akan menjalankan perintah `apt update` untuk memperbarui daftar paket yang tersedia berdasarkan repository baru.

4. **Opsi untuk Mengembalikan Konfigurasi Sebelumnya**: Jika pengguna ingin mengembalikan konfigurasi `sources.list` yang asli, script ini menyediakan opsi untuk merestorasi file `sources.list` dari cadangan yang telah dibuat sebelumnya.

#### Fitur Utama
- **Backup Otomatis**: Secara otomatis mencadangkan file `sources.list` yang lama sebelum melakukan perubahan.
- **Pembaruan Repository**: Menulis daftar repository terbaru ke dalam file `sources.list`.
- **Pembaruan Paket**: Memperbarui daftar paket yang tersedia menggunakan repository baru.
- **Restorasi Cadangan**: Opsi untuk mengembalikan file `sources.list` dari cadangan kapan saja.

#### Cara Menggunakan
1. Simpan script berikut ke dalam file bernama `manage_sources.sh` Contoh Debian 11:
    ```bash
    #!/bin/bash

    # Function to show the menu
    show_menu() {
        echo "1) Update sources.list"
        echo "2) Restore original sources.list"
        echo "3) Exit"
    }

    # Function to update sources.list
    update_sources() {
        # Backup the existing sources.list
        cp /etc/apt/sources.list /etc/apt/sources.list.bak

        # Check if the backup was successful
        if [ $? -eq 0 ]; then
            echo "Backup of sources.list successful."
        else
            echo "Backup of sources.list failed. Exiting."
            exit 1
        fi

        # Write the new sources to sources.list
        cat <<EOL > /etc/apt/sources.list
    deb http://deb.debian.org/debian bullseye main contrib non-free
    deb http://deb.debian.org/debian bullseye-updates main contrib non-free
    deb http://deb.debian.org/debian bullseye-backports main contrib non-free
    deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free
    EOL

        # Check if the writing was successful
        if [ $? -eq 0 ]; then
            echo "New sources.list has been written successfully."
        else
            echo "Failed to write new sources.list. Restoring backup."
            cp /etc/apt/sources.list.bak /etc/apt/sources.list
            exit 1
        fi

        # Update the package list
        apt update

        # Check if the update was successful
        if [ $? -eq 0 ]; then
            echo "Package list has been updated successfully."
        else
            echo "Failed to update package list. Please check your sources."
        fi
    }

    # Function to restore the original sources.list
    restore_sources() {
        if [ -f /etc/apt/sources.list.bak ]; then
            cp /etc/apt/sources.list.bak /etc/apt/sources.list
            echo "Original sources.list has been restored."
            apt update

            # Check if the update was successful
            if [ $? -eq 0 ]; then
                echo "Package list has been updated successfully."
            else
                echo "Failed to update package list. Please check your sources."
            fi
        else
            echo "No backup found to restore."
        fi
    }

    # Main script logic
    while true; do
        show_menu
        read -p "Choose an option: " choice
        case $choice in
            1)
                update_sources
                ;;
            2)
                restore_sources
                ;;
            3)
                echo "Exiting."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
    ```

2. Beri izin eksekusi pada file tersebut dengan perintah:
    ```bash
    chmod +x manage_sources.sh
    ```

3. Jalankan script dengan perintah:
    ```bash
    sudo ./manage_sources.sh
    ```

Script ini akan menampilkan menu interaktif di mana Anda dapat memilih untuk memperbarui `sources.list`, mengembalikan konfigurasi sebelumnya, atau keluar dari script.

---

Dengan menggunakan script ini, dapat mengelola pembaruan repository Debian secara otomatis dan dengan mudah mengembalikan konfigurasi sebelumnya jika diperlukan.
