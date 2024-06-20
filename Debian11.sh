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