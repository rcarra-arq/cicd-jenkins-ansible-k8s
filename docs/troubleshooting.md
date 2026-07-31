# Troubleshooting notes / Casos de troubleshooting

Rascunho no estilo postmortem — cada nota termina na causa raiz e na lição.
Estas notas serão dobradas para dentro do README bilíngue no final do projeto.

---

## Port conflict: Jenkins default 8080 collides with the monitored app

**EN —** The `cloud-monitoring-lab` app is already published on host port `8080`
(VirtualBox NAT forward `app,tcp,,8080,,8080`). Jenkins **also** defaults to
`8080`, so leaving it on the default would mean two services fighting for the
same host port — the second one to bind fails, and if both are containers the
port publish simply refuses. The fix is to publish Jenkins on a different host
port (e.g. `8082 -> 8080`) and add a matching VirtualBox port-forward so it is
reachable from the Windows host. **Lesson:** default ports are a convention,
not a reservation — when you run more than one service on one host, map them
deliberately and keep a table of who owns which port.

**PT —** A app do `cloud-monitoring-lab` já está publicada na porta `8080` do
host (port-forward NAT do VirtualBox `app,tcp,,8080,,8080`). O Jenkins **também**
usa `8080` por padrão, então deixar no default seria dois serviços disputando a
mesma porta — o segundo a subir falha, e sendo containers o publish da porta
simplesmente recusa. A correção é publicar o Jenkins numa porta diferente do
host (ex.: `8082 -> 8080`) e adicionar o port-forward correspondente no
VirtualBox para acessá-lo do host Windows. **Lição:** porta padrão é convenção,
não reserva — quando se roda mais de um serviço num host, mapeie de propósito e
mantenha uma tabela de quem é dono de qual porta.

### Mapa de portas do projeto (host da VM)

| Porta host | Serviço | Origem |
|---|---|---|
| 8080 | app nginx (cloud-monitoring-lab) | já existente |
| 3000 | Grafana | já existente |
| 9090 | Prometheus | já existente |
| 2222 | SSH (→ 22) | já existente |
| 8090 | app no Kubernetes (via `kubectl port-forward`) | **adicionada** (NAT `k8s-web`) |
| 8082 | Jenkins (→ 8080 no container) | **a adicionar** |

---

## nginx returns 403 Forbidden inside Kubernetes: file permissions leaked from the host, and a BuildKit trap

**EN —** After building a custom nginx image and deploying it to the kind
cluster, every request returned `403 Forbidden` — yet the pods were `Running`.
That combination is the clue: 403 is an HTTP answer, so nginx *was* alive; it
just could not **read** the page. `kubectl exec deploy/web -- ls -l
/usr/share/nginx/html/index.html` showed the file as `-rwxrwx---` owned by
`root`, and `kubectl logs` said it outright: `open() ... failed (13: Permission
denied)`. nginx workers run as the non-root `nginx` user, which falls under
"others" — and "others" had no read bit, so 403.

The bad permissions came from the host: the `index.html` originated in the
VirtualBox shared folder (`vboxsf`, mounted `0770`, no world-read), and
`docker build`'s `COPY` preserved those bits straight into the image. The first
fix attempt, `COPY --chmod=644`, failed with *"the --chmod option requires
BuildKit"* — this VM's Docker still uses the **legacy builder**, and `--chmod`
is a BuildKit feature. The portable fix that works on any builder is a plain
`COPY` followed by `RUN chmod 644`. A second lesson landed alongside: reusing
the same image tag (`web-app:v1`) let the kind node keep a **cached** old image;
bumping the tag to `web-app:v2` forced a clean image load and made `kubectl
apply` trigger the rollout automatically. **Lessons:** (1) never let host file
permissions leak into an image — set them explicitly in the Dockerfile; (2)
know your builder — `--chmod` needs BuildKit, `RUN chmod` is universal; (3) a
unique tag per build is what makes deploys deterministic.

**PT —** Depois de buildar uma imagem nginx customizada e subir no cluster kind,
toda requisição voltava `403 Forbidden` — mas os pods estavam `Running`. Essa
combinação é a pista: 403 é uma resposta HTTP, então o nginx *estava* vivo; ele
só não conseguia **ler** a página. O `kubectl exec deploy/web -- ls -l
/usr/share/nginx/html/index.html` mostrou o arquivo como `-rwxrwx---` dono
`root`, e o `kubectl logs` disse na lata: `open() ... failed (13: Permission
denied)`. Os workers do nginx rodam como o usuário não-root `nginx`, que cai em
"outros" — e "outros" não tinha o bit de leitura, logo 403.

A permissão ruim veio do host: o `index.html` nasceu na pasta compartilhada do
VirtualBox (`vboxsf`, montada `0770`, sem leitura pra "outros"), e o `COPY` do
`docker build` carregou esses bits direto pra dentro da imagem. A primeira
tentativa de conserto, `COPY --chmod=644`, falhou com *"the --chmod option
requires BuildKit"* — o Docker desta VM ainda usa o **builder clássico**, e o
`--chmod` é recurso do BuildKit. O conserto portável, que roda em qualquer
builder, é um `COPY` normal seguido de `RUN chmod 644`. Uma segunda lição veio
junto: reusar a mesma tag (`web-app:v1`) deixou o nó do kind com a imagem antiga
em **cache**; subir a tag pra `web-app:v2` forçou o carregamento limpo da imagem
e fez o `kubectl apply` disparar o rollout sozinho. **Lições:** (1) nunca deixe a
permissão de arquivo do host vazar pra imagem — defina explícito no Dockerfile;
(2) conheça seu builder — `--chmod` precisa de BuildKit, `RUN chmod` é universal;
(3) uma tag única por build é o que torna o deploy determinístico.
