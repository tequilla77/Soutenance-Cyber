#!/usr/bin/env bash
# Autorise la clé du contrôleur Ansible (SOC) sur ce serveur
set -euo pipefail
KEY=/vagrant/.lab/lab_key.pub
AUTH=/home/vagrant/.ssh/authorized_keys

if [ ! -f "$KEY" ]; then
  echo "Clé introuvable : lancer d'abord 'vagrant up soc'" >&2
  exit 1
fi
grep -qxF "$(cat "$KEY")" "$AUTH" || cat "$KEY" >> "$AUTH"
