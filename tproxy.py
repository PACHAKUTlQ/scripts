#!/usr/bin/env python

import subprocess
import json
import sys
import re


def route_rules():
    """Add route rules"""
    subprocess.run(["ip", "route", "add", "local", "default", "dev", "lo", "table", "100"], check=False)
    subprocess.run(["ip", "rule", "add", "fwmark", "1", "table", "100"], check=False)

def setup_nftables():
    """Sets up nftables rules."""
    subprocess.run(["nft", "flush", "ruleset"], check=True)

    nft_rules = """
define RESERVED_IP = {
    10.0.0.0/8,
    100.64.0.0/10,
    127.0.0.0/8,
    169.254.0.0/16,
    172.16.0.0/12,
    192.0.0.0/24,
    224.0.0.0/4,
    240.0.0.0/4,
    255.255.255.255/32
}

table ip xray {
    chain prerouting {
        type filter hook prerouting priority mangle; policy accept;
        ip daddr $RESERVED_IP return
        ip daddr 192.168.0.0/16 tcp dport != 53 return
        ip daddr 192.168.0.0/16 udp dport != 53 return
        ip protocol tcp tproxy to 127.0.0.1:12345 meta mark set 1
        ip protocol udp tproxy to 127.0.0.1:12345 meta mark set 1
    }
    chain output {
        type route hook output priority mangle; policy accept;
        ip daddr $RESERVED_IP return
        ip daddr 192.168.0.0/16 tcp dport != 53 return
        ip daddr 192.168.0.0/16 udp dport != 53 return
        meta mark 2 return
        ip protocol tcp meta mark set 1
        ip protocol udp meta mark set 1
    }
}
"""
    subprocess.run(["nft", "-f", "-"], input=nft_rules.encode(), check=True)


def clear_nftables():
    """Clears nftables rules."""
    subprocess.run(["nft", "flush", "ruleset"], check=True)


def replace_config_text(mode):
    """Replaces text in config.json based on mode."""
    config_file = "$HOME/Xray/config.json"

    text_a = {
        "inbounds": [{
            "tag": "socks-in",
            "protocol": "socks",
            "listen": "127.0.0.1",
            "port": 1080,
            "settings": {
                "udp": True
            }
        }]
    }

    text_b = {
        "inbounds": [{
            "tag": "all-in",
            "port": 12345,
            "protocol": "dokodemo-door",
            "settings": {
                "network": "tcp,udp",
                "followRedirect": True
            },
            "sniffing": {
                "enabled": True,
                "destOverride": ["http", "tls", "quic"]
            },
            "streamSettings": {
                "sockopt": {
                    "tproxy": "tproxy"
                }
            }
        }]
    }

    try:
        with open(config_file, "r") as f:
            # Read the file content
            content = f.read()

            # Remove comments (lines starting with //)
            content = re.sub(r"^\s*//.*$", "", content, flags=re.MULTILINE)

            # Parse the cleaned JSON
            config_data = json.loads(content)

        if mode == "on":
            config_data.update(text_b)
        elif mode == "off":
            config_data.update(text_a)

        with open(config_file, "w") as f:
            json.dump(config_data, f, indent=2)

    except FileNotFoundError:
        print(f"Error: {config_file} not found.", file=sys.stderr)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {config_file}.", file=sys.stderr)
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)


def main():
    """Main function."""
    if len(sys.argv) != 2:
        print("Usage: tproxy.py <on|off>")
        sys.exit(1)

    mode = sys.argv[1]

    if mode == "on":
        print("Turning on transparent proxy...")
        route_rules()
        setup_nftables()
        replace_config_text("on")
        print("Transparent proxy turned on.")
    elif mode == "off":
        print("Turning off transparent proxy...")
        clear_nftables()
        replace_config_text("off")
        print("Transparent proxy turned off.")
    else:
        print("Invalid argument: {}".format(mode))
        print("Usage: tproxy.py <on|off>")
        sys.exit(1)


if __name__ == "__main__":
    main()
