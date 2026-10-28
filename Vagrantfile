# -*- mode: ruby -*-
# Lab HardenWatch : 1 SOC + 2 serveurs "PME" (+ 1 attaquant Kali optionnel)
# Réseau privé hôte : 192.168.56.0/24

LAB = {
  "soc"     => { ip: "192.168.56.10", mem: 6144, cpu: 2 },
  "srv-web" => { ip: "192.168.56.20", mem: 1024, cpu: 1 },
  "srv-db"  => { ip: "192.168.56.30", mem: 1024, cpu: 1 },
}

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=775", "fmode=664"]

  # Le SOC est défini en premier : il génère la clé SSH du contrôleur Ansible
  LAB.each do |name, opts|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: opts[:ip]
      node.vm.provider "virtualbox" do |vb|
        vb.name   = "hardenwatch-#{name}"
        vb.memory = opts[:mem]
        vb.cpus   = opts[:cpu]
      end
      if name == "soc"
        node.vm.network "forwarded_port", guest: 443, host: 8443   # tableau de bord Wazuh
        node.vm.provision "shell", path: "scripts/provision-soc.sh"
      else
        node.vm.provision "shell", path: "scripts/provision-target.sh"
      end
    end
  end

  # Machine attaquante (optionnelle) : vagrant up attacker
  config.vm.define "attacker", autostart: false do |node|
    node.vm.box = "kalilinux/rolling"
    node.vm.hostname = "attacker"
    node.vm.network "private_network", ip: "192.168.56.99"
    node.vm.synced_folder ".", "/vagrant", disabled: true
    node.vm.provider "virtualbox" do |vb|
      vb.name   = "hardenwatch-attacker"
      vb.memory = 2048
      vb.cpus   = 2
    end
  end
end
