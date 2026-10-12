#!/usr/bin/env bash
set -euo pipefail
TASK_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$TASK_ROOT/.pentagi-state"
exec 9>"$TASK_ROOT/.pentagi-state/start.lock"
flock -n 9 || exit 0
docker info >/dev/null
if [ ! -d "$TASK_ROOT/pentagi/.git" ]; then
  git clone --depth 1 https://github.com/vxcontrol/pentagi.git "$TASK_ROOT/pentagi"
fi
cd "$TASK_ROOT/pentagi"
umask 077
if [ ! -f .env.codespaces-free ]; then
  COOKIE_SALT=$(openssl rand -hex 32)
  DB_PASSWORD=$(openssl rand -hex 24)
  cat > .env.codespaces-free <<FREE_ENV
PUBLIC_URL=https://$CODESPACE_NAME-8443.app.github.dev
CORS_ORIGINS=https://$CODESPACE_NAME-8443.app.github.dev
COOKIE_SIGNING_SALT=$COOKIE_SALT
PENTAGI_POSTGRES_PASSWORD=$DB_PASSWORD
PENTAGI_LISTEN_IP=127.0.0.1
PENTAGI_LISTEN_PORT=8443
OLLAMA_SERVER_URL=http://ollama:11434
OLLAMA_SERVER_MODEL=pentagi-codespaces
OLLAMA_SERVER_CONFIG_PATH=/opt/pentagi/conf/ollama.provider.yml
OLLAMA_SERVER_PULL_MODELS_ENABLED=false
OLLAMA_SERVER_LOAD_MODELS_ENABLED=false
EMBEDDING_PROVIDER=ollama
EMBEDDING_URL=http://ollama:11434
EMBEDDING_MODEL=nomic-embed-text
EMBEDDING_BATCH_SIZE=4
EMBEDDING_MAX_TEXT_BYTES=4096
GRAPHITI_ENABLED=false
ASSISTANT_USE_AGENTS=false
ASK_USER=true
DUCKDUCKGO_ENABLED=true
SPLOITUS_ENABLED=false
LOCAL_SCRAPER_MAX_CONCURRENT_SESSIONS=1
DOCKER_INSIDE=false
FREE_ENV
fi
cp examples/configs/ollama-llama318b.provider.yml example.ollama.provider.yml
sed -i 's/llama3.1:8b/pentagi-codespaces/g; s/max_tokens: [0-9]*/max_tokens: 2048/g' example.ollama.provider.yml
touch example.custom.provider.yml example.bedrock.provider.yml
cat > Modelfile.codespaces <<'MODEL_FILE'
FROM qwen3:1.7b
PARAMETER num_ctx 32768
PARAMETER num_predict 2048
PARAMETER temperature 0.2
MODEL_FILE
cat > docker-compose.codespaces-free.yml <<'FREE_COMPOSE'
services:
  ollama:
    image: ollama/ollama:latest
    container_name: pentagi-local-ollama
    restart: unless-stopped
    environment:
      OLLAMA_NUM_PARALLEL: "1"
      OLLAMA_MAX_LOADED_MODELS: "1"
      OLLAMA_CONTEXT_LENGTH: "32768"
    volumes:
      - ollama-codespaces:/root/.ollama
    networks:
      - pentagi-network
  pentagi:
    depends_on:
      ollama:
        condition: service_started
volumes:
  ollama-codespaces:
FREE_COMPOSE
compose() { docker compose --env-file .env.codespaces-free -f docker-compose.yml -f docker-compose.codespaces-free.yml "$@"; }
compose config --quiet
printf 'Iniciando banco de dados e Ollama local...\n'
compose up -d pgvector ollama
printf 'Baixando o modelo Qwen3 1.7B local...\n'
compose exec -T ollama ollama pull qwen3:1.7b > "$TASK_ROOT/.pentagi-state/qwen-pull.log" 2>&1
printf 'Baixando embeddings locais...\n'
compose exec -T ollama ollama pull nomic-embed-text > "$TASK_ROOT/.pentagi-state/embedding-pull.log" 2>&1
docker cp Modelfile.codespaces pentagi-local-ollama:/tmp/Modelfile.codespaces
compose exec -T ollama ollama create pentagi-codespaces -f /tmp/Modelfile.codespaces
printf 'Iniciando PentAGI e navegador local...\n'
compose up -d pentagi scraper
compose ps
printf 'Painel: https://%s-8443.app.github.dev\n' "$CODESPACE_NAME"
