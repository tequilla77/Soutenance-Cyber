#!/usr/bin/env bash
# Prépare la VM SOC comme contrôleur Ansible
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq software-properties-common make git
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y -qq ansible

# Clé SSH utilisée par Ansible pour joindre les serveurs
sudo -u vagrant bash -c '[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519'
mkdir -p /vagrant/.lab
cp /home/vagrant/.ssh/id_ed25519.pub /vagrant/.lab/lab_key.pub

echo 'export ANSIBLE_CONFIG=/vagrant/ansible/ansible.cfg' > /etc/profile.d/ansible.sh
echo "SOC prêt : vagrant ssh soc, puis cd /vagrant && make ping"
