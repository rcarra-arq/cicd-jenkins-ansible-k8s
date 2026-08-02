# Checklist de screenshots para o README

Regra: **terminal → bloco de código** no README (limpo, copiável). **Visual →
print** (app, dashboard, pipeline). Capturar cada print no seu melhor momento.

## Pronto pra capturar agora (opcional)
- [ ] **Self-healing ao vivo** — `kubectl get pods -o wide` antes e depois de
      `kubectl delete pod`, mostrando o pod renascer com IP novo. Boa história.
      (Também vira bloco de código; print é bônus.)

## Esperar o momento certo (prints herói)
- [x] **App no navegador** — DEPOIS de trocar o nginx genérico pela imagem do
      `cloud-monitoring-lab` (a página custom, não a "Welcome to nginx").
      → `screenshots/app-v2-running.png`, já no README.
- [ ] **Rolling update** — `kubectl rollout status` / `get pods` durante a troca
      de versão, mostrando pods novos entrando e velhos saindo sem downtime.
- [x] **Ansible** — a saída do `ansible-playbook` com o resumo `ok/changed`
      (idempotência: `changed=4` → `changed=2` com `changed_when`).
      → `screenshots/ansible-idempotency.png`, já no README.
- [x] **Jenkins** — o **Stage View** do pipeline (o gráfico de blocos verdes:
      Checkout → Build → Load → Deploy). Esse é o print mais vendedor do projeto.
      → `screenshots/jenkins-pipeline-green.png`, já no README.
- [x] **Grafana** — dashboard Prometheus + Grafana rodando dentro do cluster K8s.
      → `screenshots/grafana-k8s-dashboard.png`, já no README.

## Como levar o print pro repo
Print é tirado no **Windows** (a janela do navegador ou do terminal PuTTY).
Salvar em `screenshots/` dentro do repo, no host, e o sync manda pro GitHub.
