# Mesma base do cloud-monitoring-lab: alpine pinado.
# - pinar evita upgrade surpresa quando a tag "latest" anda;
# - alpine e ~8 MB vs ~190 MB da imagem padrao: pull e build mais rapidos,
#   menor superficie de ataque.
FROM nginx:1.31-alpine

# A app: so trocamos o index.html padrao do nginx pelo nosso.
COPY app/index.html /usr/share/nginx/html/index.html

# Forca a permissao DENTRO da imagem: dono le+escreve, todos leem (644).
# O usuario "nginx" (nao-root) precisa conseguir ler o arquivo -- senao, se o
# arquivo no disco veio da pasta compartilhada vboxsf (modo 0770, sem leitura
# pra "outros"), o nginx devolve 403 Forbidden.
# Usamos "RUN chmod" (e nao "COPY --chmod=644") porque --chmod exige o BuildKit,
# e esta VM ainda usa o builder classico do Docker.
RUN chmod 644 /usr/share/nginx/html/index.html

# Obs: um HEALTHCHECK do Docker (como no monitoring-lab) seria ignorado pelo
# Kubernetes -- la quem sonda a app sao as "probes" (readiness/liveness) do
# proprio K8s, um conceito que a gente pode adicionar no Deployment depois.
