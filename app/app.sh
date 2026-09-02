#!/bin/bash
set -euo pipefail

# Main application entrypoint
# Provides system info, host checking, and port checking functionality

show_help() {
    cat <<EOF
Usage: app.sh <command> [options]

Commands:
  help              Display this help message
  system-info       Display system information (hostname, OS, kernel, uptime, CPU, memory)
  check-host HOST   Resolve IP address and check connectivity to HOST
  check-port HOST PORT
                    Check TCP connectivity to HOST:PORT (validates port is 1-65535)

Exit Codes:
  0  - Success / Operational pass
  1  - Operational or runtime failure (e.g., unreachable host/port)
  2  - Invalid command, missing argument, non-numeric port, or out-of-range port

Examples:
  app.sh help
  app.sh system-info
  app.sh check-host 8.8.8.8
  app.sh check-port 127.0.0.1 80
EOF
}

system_info() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    
    # CPU info (handling different OS)
    if command -v nproc &> /dev/null; then
        echo "CPUs: $(nproc)"
    else
        echo "CPUs: $(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 'Unknown')"
    fi
    
    # Memory info
    if [ -f /proc/meminfo ]; then
        mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        echo "Memory: $((mem_available / 1024))MB / $((mem_total / 1024))MB"
    elif command -v free &> /dev/null; then
        free -h
    else
        echo "Memory: Unable to determine"
    fi
    
    return 0
}

check_host() {
    local host="${1:-}"
    
    # Validate host argument
    if [[ -z "$host" ]]; then
        echo "Error: check-host requires a HOST argument"
        return 2
    fi
    
    # Try to resolve the host
    echo "Resolving host: $host"
    if ! resolved_ip=$(getent hosts "$host" 2>/dev/null | awk '{print $1}' | head -1); then
        resolved_ip=""
    fi
    
    if [[ -n "$resolved_ip" ]]; then
        echo "Resolved IP: $resolved_ip"
    else
        resolved_ip="$host"
        echo "Using provided host as address: $host"
    fi
    
    # Check connectivity with ping
    echo "Checking connectivity to $host..."
    if ping -c 1 -W 2 "$host" &>/dev/null; then
        echo "Success: Host $host is reachable"
        return 0
    else
        echo "Error: Host $host is not reachable"
        return 1
    fi
}

check_port() {
    local host="${1:-}"
    local port="${2:-}"
    
    # Validate host argument
    if [[ -z "$host" ]]; then
        echo "Error: check-port requires HOST and PORT arguments"
        return 2
    fi
    
    # Validate port argument
    if [[ -z "$port" ]]; then
        echo "Error: check-port requires PORT argument"
        return 2
    fi
    
    # Validate port is numeric
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: PORT must be numeric (got: $port)"
        return 2
    fi
    
    # Validate port range (1-65535)
    if (( port < 1 || port > 65535 )); then
        echo "Error: PORT must be between 1 and 65535 (got: $port)"
        return 2
    fi
    
    # Check TCP connectivity
    echo "Checking TCP connectivity to $host:$port..."
    
    # Try using bash's /dev/tcp first (most reliable)
    if timeout 2 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "Success: Port $port on $host is open"
        return 0
    fi
    
    # Fallback to nc if available
    if command -v nc &> /dev/null; then
        if nc -z -w 2 "$host" "$port" 2>/dev/null; then
            echo "Success: Port $port on $host is open"
            return 0
        fi
    fi
    
    # Fallback to curl if available
    if command -v curl &> /dev/null; then
        if timeout 2 curl -s --max-time 2 "http://$host:$port" &>/dev/null; then
            echo "Success: Port $port on $host is open"
            return 0
        fi
    fi
    
    echo "Error: Could not connect to $host:$port"
    return 1
}

# Main command dispatcher
main() {
    local command="${1:-}"
    
    case "$command" in
        help)
            show_help
            return 0
            ;;
        system-info)
            system_info
            return 0
            ;;
        check-host)
            shift || true
            check_host "$@"
            return $?
            ;;
        check-port)
            shift || true
            check_port "$@"
            return $?
            ;;
        "")
            echo "Error: No command provided"
            show_help
            return 2
            ;;
        *)
            echo "Error: Unknown command '$command'"
            show_help
            return 2
            ;;
    esac
}

main "$@"
