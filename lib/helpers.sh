#!/usr/bin/env bash

# This is not an executable script, but a library of shared functions.

# Function to check if a resource (container, network, volume) exists.
# Usage: resource_exists "container" "my-container-name"
resource_exists() {
    local type="$1"
    local name="$2"
    podman "$type" inspect "$name" &>/dev/null
}

# Function to list all containers with user-friendly formatting.
list_all_containers() {
    podman ps -a --format "{{.Names}} ({{.Image}}) [{{.Status}}]"
}

# Function to list only running containers.
list_running_containers() {
    podman ps --format "{{.Names}} ({{.Image}})"
}

# Function to check for required commands.
check_deps() {
    if ! command -v gum &> /dev/null; then
        echo "Error: gum is not installed. Please install it to continue."
        echo "See: https://github.com/charmbracelet/gum"
        exit 1
    fi
}
