#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
default_config="${script_dir}/config/config.json"
default_creds="${script_dir}/config/creds.json"

config_path="${default_config}"
creds_path="${default_creds}"
creds_key=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		--config)
			config_path="$2"
			shift 2
			;;
		--creds)
			creds_path="$2"
			shift 2
			;;
		--creds-decryption-key)
			creds_key="$2"
			shift 2
			;;
		-h|--help)
			echo "Usage: $0 [--config <path-or-url>] [--creds <path-or-url>] [--creds-decryption-key <key>]"
			exit 0
			;;
		*)
			echo "Unknown argument: $1"
			exit 1
			;;
	esac
done

if ! command -v archinstall >/dev/null 2>&1; then
	echo "archinstall not found. Boot the official Arch ISO and run again."
	exit 1
fi

tmp_config=""
cleanup() {
	if [[ -n "${tmp_config}" ]]; then
		rm -f "${tmp_config}"
	fi
}
trap cleanup EXIT

if [[ "${config_path}" != http* && -f "${config_path}" ]]; then
	if grep -q '"device": "/dev/DEVICE"' "${config_path}"; then
		read -rp "Install device (e.g., /dev/nvme0n1 or /dev/sda): " device
		if [[ -z "${device}" || ! -b "${device}" ]]; then
			echo "Device not found: ${device}"
			exit 1
		fi

		tmp_config="$(mktemp)"
		python - "${config_path}" "${tmp_config}" "${device}" <<'PY'
import json
import sys

config_path, out_path, device = sys.argv[1:]

with open(config_path, 'r', encoding='utf-8') as f:
		data = json.load(f)

disk_cfg = data.get('disk_config', {})
mods = disk_cfg.get('device_modifications', [])
for mod in mods:
		mod['device'] = device

with open(out_path, 'w', encoding='utf-8') as f:
		json.dump(data, f, indent=2)
PY

		config_path="${tmp_config}"
	fi
fi

if [[ "${creds_path}" != http* && -f "${creds_path}" ]]; then
	if grep -q 'REPLACE_ME' "${creds_path}"; then
		echo "Update ${creds_path} with real credentials or use an encrypted creds file."
		exit 1
	fi
fi

cmd=(archinstall --config "${config_path}" --creds "${creds_path}")
if [[ -n "${creds_key}" ]]; then
	cmd+=(--creds-decryption-key "${creds_key}")
fi

exec "${cmd[@]}"
