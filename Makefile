# Raccourcis HardenWatch - à lancer depuis la VM soc :  vagrant ssh soc  puis  cd /vagrant
export ANSIBLE_CONFIG := $(CURDIR)/ansible/ansible.cfg
SECRETS := $(if $(wildcard ansible/secrets.yml),-e @secrets.yml,)
PLAY := cd ansible && ansible-playbook $(SECRETS)

.PHONY: help ping deploy audit-avant durcir audit-apres demo scores

help:            ## Affiche cette aide
	@grep -E '^[a-z-]+:.*##' Makefile | awk -F':.*## ' '{printf "  make %-12s %s\n", $$1, $$2}'

ping:            ## Vérifie qu'Ansible joint toutes les machines
	cd ansible && ansible all -m ping

deploy:          ## Déploie le lab : PME vulnérable + SOC + agents + services
	$(PLAY) playbooks/site.yml

audit-avant:     ## Mesure le niveau de sécurité AVANT durcissement
	$(PLAY) playbooks/50-audit.yml -e phase=avant

durcir:          ## Applique le durcissement automatisé
	$(PLAY) playbooks/60-durcissement.yml

audit-apres:     ## Mesure le niveau de sécurité APRÈS durcissement
	$(PLAY) playbooks/50-audit.yml -e phase=apres

demo: deploy audit-avant durcir audit-apres scores  ## Enchaîne tout le scénario

scores:          ## Affiche le comparatif des scores
	@column -t -s ';' reports/scores.csv
