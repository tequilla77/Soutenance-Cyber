# Installation pas à pas

Ce guide explique comment monter le lab HardenWatch sur un PC, de zéro jusqu'au tableau de bord Wazuh opérationnel.

## 1. Prérequis (PC hôte)

| Élément | Minimum |
|---|---|
| Processeur | 64 bits x86 (Intel ou AMD), virtualisation VT-x / AMD-V activée dans le BIOS |
| RAM | 16 Go (le lab consomme environ 8 Go, 10 Go avec la VM attaquante) |
| Disque | 40 Go libres |
| Logiciels | [VirtualBox 7](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://developer.hashicorp.com/vagrant/install), [Git](https://git-scm.com/downloads) |
| Internet | Indispensable au premier déploiement (environ 3 Go de téléchargements) |

> ⚠️ Les Mac à puce Apple (M1/M2/M3) ne sont pas pris en charge : les images utilisées sont en x86.

> 💡 **Windows** : si VirtualBox est très lent ou refuse de démarrer les VM, désactiver Hyper-V depuis une invite de commandes **administrateur**, puis redémarrer :
> ```bash
> bcdedit /set hypervisorlaunchtype off
> ```

## 2. Récupérer le projet

```bash
git clone https://github.com/tequilla77/soutenance-cyber.git
```

```bash
cd soutenance-cyber
```

## 3. Créer les machines virtuelles

```bash
vagrant up
```

Ce qui se passe :
1. La VM **soc** est créée en premier. Elle installe Ansible et génère la clé SSH qui servira à piloter les autres machines.
2. Les VM **srv-web** et **srv-db** sont créées ensuite et autorisent cette clé.

Compter 10 à 15 minutes la première fois (téléchargement de l'image Ubuntu).

La VM attaquante est facultative et ne démarre pas automatiquement :

```bash
vagrant up attacker
```

> Variante plus légère : réutiliser une Kali déjà installée dans VirtualBox en lui ajoutant une carte réseau **Réseau privé hôte** sur le réseau `192.168.56.0/24`.

## 4. (Facultatif) Activer les alertes Telegram

1. Dans Telegram, ouvrir **@BotFather**, envoyer `/newbot` et suivre les étapes. On obtient un **token**.
2. Envoyer un message quelconque au bot que l'on vient de créer.
3. Ouvrir dans un navigateur `https://api.telegram.org/bot<TOKEN>/getUpdates` et relever la valeur `"chat":{"id": ...}`.
4. Copier `ansible/secrets.example.yml` en `ansible/secrets.yml` et y renseigner le token et le chat id.

Le fichier `ansible/secrets.yml` est exclu par `.gitignore` : il n'est jamais envoyé sur GitHub.

Sans ce fichier, tout fonctionne normalement ; seules les notifications Telegram sont désactivées.

## 5. Déployer le lab

Se connecter à la VM SOC :

```bash
vagrant ssh soc
```

Aller dans le dossier du projet (partagé avec le PC) :

```bash
cd /vagrant
```

Vérifier qu'Ansible joint les trois machines (chacune doit répondre `pong`) :

```bash
make ping
```

Lancer le déploiement complet (environ 20 minutes) :

```bash
make deploy
```

Le playbook `site.yml` enchaîne, dans l'ordre :

| Étape | Playbook | Résultat |
|---|---|---|
| 1 | `00-baseline-vulnerable.yml` | Serveurs configurés « comme une PME typique » (point de départ) |
| 2 | `10-socle.yml` | Paquets de base, fuseau horaire, Docker |
| 3 | `20-soc.yml` | Pile Wazuh (indexer, manager, dashboard) en conteneurs sur le SOC |
| 4 | `30-agents.yml` | Suricata et agent Wazuh sur chaque serveur |
| 5 | `40-services.yml` | Application web (Docker) sur srv-web, MariaDB sur srv-db |

À la fin, la console affiche l'adresse du tableau de bord et l'état des alertes Telegram.

## 6. Accéder au tableau de bord Wazuh

Depuis le navigateur du PC : **https://localhost:8443**. Accepter l'avertissement du certificat (il est auto-signé).

Identifiants du lab : `admin` / `SecretPassword`.

Contrôles à faire :
- Menu **Agents** : `srv-web` et `srv-db` apparaissent avec le statut **Active**.
- Menu **Configuration Assessment** : un score de conformité CIS s'affiche pour chaque serveur (quelques minutes après l'enrôlement).

## 7. Mesurer, durcir, mesurer

```bash
make audit-avant
```

```bash
make durcir
```

```bash
make audit-apres
```

```bash
make scores
```

Les rapports Lynis complets sont rangés dans `reports/avant/` et `reports/apres/`, et l'historique des scores dans `reports/scores.csv`. Le dossier étant partagé, ces fichiers sont aussi visibles directement sur le PC.

## 8. Commandes utiles (sur le PC)

| Action | Commande |
|---|---|
| Éteindre le lab | `vagrant halt` |
| Rallumer le lab | `vagrant up` |
| État des machines | `vagrant status` |
| Repartir de zéro | `vagrant destroy -f` puis `vagrant up` |
| Prendre un instantané | `vagrant snapshot save avant-demo` |
| Restaurer l'instantané | `vagrant snapshot restore avant-demo` |

> 💡 **Conseil pour la soutenance** : après `make deploy` et `make audit-avant`, prendre un instantané `avant-demo`. Le jour J, il suffit de le restaurer pour repartir d'un état connu et identique à la répétition.

## 9. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `vagrant up` : erreur VT-x / AMD-V | Virtualisation désactivée | L'activer dans le BIOS ; sous Windows, désactiver Hyper-V (voir §1) |
| `make ping` échoue sur un serveur | Clé SSH non copiée | Sur le PC : `vagrant provision srv-web` (ou `srv-db`) |
| Le playbook échoue au téléchargement d'un paquet | Connexion Internet instable | Relancer `make deploy` : les playbooks sont idempotents, ce qui est déjà fait est conservé |
| Tableau de bord inaccessible | Pile encore en démarrage | Attendre 2 à 3 minutes. Dans soc : `cd /opt/wazuh-docker/single-node && docker compose ps` |
| Agent « Disconnected » | Agent arrêté | Sur le serveur concerné : `sudo systemctl restart wazuh-agent` |
| Aucun événement Suricata | Mauvaise interface surveillée | Sur le serveur : `sudo tail -f /var/log/suricata/eve.json` et vérifier `IFACE` dans `/etc/default/suricata` |
| VM soc très lente | RAM insuffisante | Fermer les autres applications ; ne pas lancer la VM attaquante en même temps qu'un navigateur chargé |
