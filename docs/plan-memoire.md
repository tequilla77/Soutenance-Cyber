# Plan du mémoire

> **Titre** : *Conception et déploiement d'une plateforme automatisée de durcissement et de supervision de la sécurité du système d'information d'une PME : cas pratique avec Ansible, Docker et Wazuh*
>
> **Projet** : HardenWatch — Licence Cybersécurité, IPNET Institute of Technology (Lomé)

Volume visé : **50 à 70 pages** hors annexes. Les pages indiquées par partie sont des repères, pas des obligations.

Fil conducteur à garder dans tout le mémoire : **une PME n'a ni budget ni équipe sécurité ; l'automatisation et l'open source lui permettent quand même de durcir et de surveiller son SI, et on peut le mesurer.**

---

## Pages liminaires

- Page de garde (logo IPNET, titre, nom, encadrant, année académique)
- Dédicace et remerciements
- Résumé en français (≈ 250 mots) et **abstract** en anglais
- Sommaire
- Liste des sigles et abréviations (SI, SOC, SIEM, IDS, CIS, SCA, FIM, IaC, PME…)
- Liste des figures et des tableaux

---

## Introduction générale (3 à 4 pages)

1. **Contexte** : transformation numérique au Togo, place des PME dans l'économie, hausse des cyberattaques.
2. **Problématique** — à formuler sous forme de question, par exemple :
   > *Comment une PME, sans budget ni équipe dédiée, peut-elle renforcer durablement la sécurité de son système d'information et détecter les attaques qui la visent ?*
3. **Objectifs** :
   - automatiser l'application des bonnes pratiques de sécurité (CIS, ISO 27001) ;
   - mettre en place une supervision de sécurité centralisée avec alerte et réponse automatique ;
   - **mesurer** objectivement le gain de sécurité obtenu.
4. **Démarche suivie** : étude, conception, réalisation en laboratoire, évaluation.
5. **Annonce du plan**.

---

## Partie 1 — Cadre de l'étude

### Chapitre 1 : Contexte et problématique (8 à 10 pages)

**1.1 Présentation de la structure d'accueil**
- Si stage : présentation de l'entreprise, organigramme, SI existant.
- Sinon : définir une **PME de référence** (activité, nombre de postes, serveurs, données traitées) que le lab représente.

**1.2 La cybersécurité des PME au Togo**
- Panorama des menaces : hameçonnage, rançongiciels, brute-force, fraude, défiguration de sites.
- Contraintes typiques : budget, absence de RSSI, serveurs configurés par défaut, aucune journalisation exploitée.
- Chiffres et rapports : ANCy, CERT.tg, rapports internationaux (à sourcer).

**1.3 Cadre juridique et réglementaire**
- Loi n°2018-026 du 7 décembre 2018 sur la cybersécurité et la lutte contre la cybercriminalité.
- Loi n°2019-014 du 29 octobre 2019 relative à la protection des données à caractère personnel.
- Rôle de l'ANCy (Agence nationale de la cybersécurité) et de l'IPDCP.
- Convention de l'Union africaine sur la cybersécurité (Malabo).
- ⚠️ Vérifier les références exactes sur les textes officiels avant de les citer.

**1.4 Problématique et objectifs détaillés**

**1.5 Méthodologie de travail et planning** (diagramme de Gantt)

### Chapitre 2 : État de l'art (12 à 15 pages)

**2.1 Concepts fondamentaux**
- Triade DIC (disponibilité, intégrité, confidentialité), traçabilité.
- Défense en profondeur.
- Le cycle **NIST Cybersecurity Framework 2.0** : Gouverner, Identifier, Protéger, Détecter, Répondre, Rétablir. Montrer que HardenWatch couvre *Protéger* (durcissement), *Détecter* (SOC) et *Répondre* (réponse active).

**2.2 Le durcissement des systèmes**
- Définition, principe du moindre privilège, réduction de la surface d'attaque.
- Référentiels : **CIS Benchmarks**, guide de l'ANSSI pour GNU/Linux, **ISO/IEC 27001:2022** (Annexe A).
- Outils d'évaluation : Lynis, OpenSCAP, Wazuh SCA.

**2.3 La supervision de sécurité**
- SOC : définition, rôles (N1, N2, N3), cycle de gestion d'incident (NIST SP 800-61).
- **SIEM** : collecte, normalisation, corrélation, alerte.
- **IDS / IPS** : réseau (NIDS) vs hôte (HIDS), signatures vs anomalies.
- **FIM** (surveillance de l'intégrité des fichiers).
- **MITRE ATT&CK** comme langage commun pour décrire les attaques.

**2.4 Automatisation et conteneurisation**
- Infrastructure as Code : principe, avantages (reproductibilité, traçabilité, idempotence).
- **Ansible** : architecture sans agent, inventaire, playbooks, rôles.
- **Docker** : conteneurs vs machines virtuelles, images, Docker Compose.

**2.5 Étude comparative des solutions**
- Tableau comparatif SIEM : Wazuh, Elastic Security, Splunk, Graylog, Security Onion (coût, licence, fonctionnalités, ressources nécessaires, communauté).
- Tableau comparatif IDS : Suricata, Snort, Zeek.
- Tableau comparatif outils d'automatisation : Ansible, Puppet, Chef, SaltStack.
- **Justification des choix** : gratuité, open source, couverture fonctionnelle, adaptée à une PME.

---

## Partie 2 — Conception et réalisation

### Chapitre 3 : Analyse et conception (8 à 10 pages)

**3.1 Analyse des risques de la PME de référence**
- Méthode allégée inspirée d'**EBIOS Risk Manager** (ANSSI) ou ISO 27005.
- Biens essentiels (données clients, application web, base de données) et biens supports (serveurs).
- Scénarios de menace et niveau de risque initial (matrice gravité × vraisemblance).

**3.2 Expression des besoins**
- Besoins fonctionnels : durcir automatiquement, détecter, alerter, bloquer, mesurer.
- Besoins non fonctionnels : coût nul en licences, reproductibilité, simplicité d'exploitation, ressources limitées.

**3.3 Architecture proposée**
- Schéma d'architecture globale → [docs/architecture.md](architecture.md) §1
- Plan d'adressage et matrice des flux → [docs/architecture.md](architecture.md) §2
- Chaîne de détection (collecte → analyse → alerte → réponse) → [docs/architecture.md](architecture.md) §3

**3.4 Politique de durcissement**
- Tableau des mesures avec correspondance **CIS / ISO 27001** → [docs/architecture.md](architecture.md) §4
- Justification de chaque domaine (SSH, pare-feu, comptes, journalisation…).

**3.5 Stratégie de détection**
- Règles natives utilisées et règles personnalisées HardenWatch, avec correspondance MITRE ATT&CK → [docs/architecture.md](architecture.md) §3.

### Chapitre 4 : Mise en œuvre (12 à 15 pages)

**4.1 Environnement de laboratoire**
- Vagrant et VirtualBox, caractéristiques des machines → `Vagrantfile`.
- Justification : environnement isolé, reproductible, sans risque pour des systèmes réels.

**4.2 Organisation du projet Ansible**
- Arborescence (inventaire, playbooks, rôles) → [README](../README.md).
- Séquencement des playbooks 00 → 60.
- Gestion des secrets (fichier exclu de Git ; perspective : Ansible Vault).

**4.3 Déploiement du SOC sous Docker**
- Rôle `wazuh_soc` : pile officielle Wazuh, certificats, règles locales, intégration Telegram, réponse active.
- Capture : conteneurs en fonctionnement (`docker compose ps`), tableau de bord.

**4.4 Déploiement des sondes**
- Rôle `wazuh_agent` : agent, collecte des journaux, FIM temps réel.
- Rôle `suricata` : configuration, règles Emerging Threats et règles HardenWatch.

**4.5 Le durcissement automatisé**
- Rôle `hardening`, présenté domaine par domaine avec extraits YAML commentés.
- Montrer l'**idempotence** : un second passage ne modifie rien (`changed=0`).

**4.6 Difficultés rencontrées et solutions apportées**
- À remplir au fil de la réalisation (c'est une section que le jury apprécie : elle montre que vous avez réellement fait le travail).

> 💡 Ne pas coller de longs blocs de code dans le corps du mémoire : des extraits courts et commentés suffisent, le reste va en annexe ou sur GitHub.

---

## Partie 3 — Évaluation

### Chapitre 5 : Tests, résultats et analyse (8 à 10 pages)

**5.1 Protocole d'évaluation**
- Environnement de test, état initial, mesures avant/après.
- Indicateurs retenus :

| Indicateur | Outil | Mesure |
|---|---|---|
| Indice de durcissement | Lynis | Score /100 par machine |
| Conformité CIS | Wazuh SCA | % de contrôles réussis |
| Couverture de détection | Wazuh | Nombre de cas de test détectés / nombre de cas |
| Délai de détection | Wazuh | Temps entre l'action et l'alerte |
| Délai de notification | Telegram | Temps entre l'alerte et la réception |
| Faux positifs | Wazuh | Alertes non justifiées sur une période donnée |
| Temps de déploiement | Ansible | Durée d'un durcissement complet du parc |

**5.2 Résultats du durcissement**
- Tableau et graphique avant/après à partir de `reports/scores.csv`.
- Captures du module *Configuration Assessment*.
- Analyse : contrôles corrigés, contrôles restés en échec et pourquoi (choix assumés, hors périmètre…).

**5.3 Résultats de la supervision**
- Tableau des cas de test : action réalisée dans le lab → règle déclenchée → niveau → technique MITRE → réponse.
- Captures : tableau de bord, détail d'une alerte, notification Telegram, IP bloquée.

**5.4 Analyse critique**
- Ce qui a bien fonctionné, ce qui reste perfectible.
- Comparaison avec la situation initiale de la PME de référence et avec la matrice de risques du chapitre 3 (risque résiduel).

**5.5 Estimation des coûts**
- Coût en licences (nul), matériel minimal requis, temps d'administration estimé.
- Comparaison avec une solution commerciale ou un SOC externalisé.

### Chapitre 6 : Limites et perspectives (3 à 4 pages)

- **Limites** : lab virtuel, serveurs Linux uniquement, pas de postes Windows, identifiants par défaut de Wazuh, pas de haute disponibilité.
- **Perspectives** :
  - déploiement sur Microsoft Azure (lien avec AZ-104 / AZ-500) ;
  - prise en charge des postes Windows ;
  - Ansible Vault pour les secrets ;
  - intégration de renseignement sur les menaces (VirusTotal, MISP) ;
  - chaîne CI qui vérifie les playbooks à chaque modification ;
  - offre de service « SOC mutualisé » pour plusieurs PME (lien avec le cours d'entrepreneuriat).

---

## Conclusion générale (2 pages)

- Rappel de la problématique.
- Synthèse des résultats chiffrés (score avant → après, taux de détection).
- Compétences acquises (en lien avec les cours : CSEC 378, CSEC 389, CSEC 394/395, NET 377, NET 379).
- Ouverture.

---

## Bibliographie et webographie

À citer au format choisi par l'école (APA ou IEEE). Pistes :
- CIS — *CIS Ubuntu Linux 22.04 LTS Benchmark*
- ISO/IEC 27001:2022 et ISO/IEC 27002:2022
- ANSSI — *Recommandations de configuration d'un système GNU/Linux*
- ANSSI — *EBIOS Risk Manager, le guide*
- NIST — *Cybersecurity Framework 2.0* ; *SP 800-61* (gestion des incidents)
- MITRE ATT&CK — attack.mitre.org
- Documentations officielles : Wazuh, Suricata, Ansible, Docker, Lynis
- Textes de loi togolais cités au chapitre 1 (Journal officiel)

---

## Annexes

| Annexe | Contenu | Source dans le dépôt |
|---|---|---|
| A | Guide d'installation | [docs/installation.md](installation.md) |
| B | Inventaire et variables Ansible | `ansible/inventory/` |
| C | Rôle de durcissement complet | `ansible/roles/hardening/` |
| D | Règles de détection Wazuh et Suricata | `local_rules.xml`, `local.rules` |
| E | Extraits des rapports Lynis avant/après | `reports/` |
| F | Lien vers le dépôt GitHub | https://github.com/tequilla77/soutenance-cyber |

---

## Conseils de rédaction

- **Commencer par les chapitres 3 et 4** pendant la réalisation (c'est frais), puis le 5, et écrire l'introduction et la conclusion **en dernier**.
- Faire les **captures d'écran au fur et à mesure**, en les nommant clairement (`fig-4-3-dashboard-agents.png`).
- Chaque figure et chaque tableau : un numéro, un titre, une source, et **une phrase dans le texte qui l'explique**.
- Garder un journal des problèmes rencontrés : il alimente directement la section 4.6.
- Faire relire au moins une fois par une autre personne (orthographe et clarté).
