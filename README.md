# PentAGI — teste gratuito no GitHub Codespaces

Ambiente de teste do projeto [vxcontrol/pentagi](https://github.com/vxcontrol/pentagi), com Docker, PostgreSQL, navegador local e Ollama. Usa Qwen3 1.7B e embeddings nomic-embed-text no próprio Codespace, sem chave de API paga.

## Abrir pelo iPhone

Crie ou inicie o Codespace neste repositório. A preparação e a inicialização são automáticas. A primeira execução baixa as imagens Docker e os modelos; pode levar vários minutos. Se alterar a configuração do contêiner, use **Codespaces: Rebuild Container**.

Em **Ports**, abra **8443 / PentAGI**. A porta usa HTTPS e deve permanecer **Private**; entre no GitHub com a conta que criou o Codespace.

O login inicial do PentAGI é **admin@pentagi.com** e a senha inicial documentada pelo projeto é **admin**. A instalação não oferece cadastro público.

## Recursos gratuitos e limites

A máquina de teste tem 2 núcleos e 8 GB de RAM. O modelo pequeno roda em CPU e serve para testar o painel e tarefas simples; não tem a capacidade de um modelo grande.

O [GitHub Free inclui](https://docs.github.com/en/billing/concepts/product-billing/github-codespaces) 120 horas de núcleo e 15 GB-mês de armazenamento. Em 2 núcleos, isso equivale a até 60 horas de máquina por ciclo, compartilhadas com os outros Codespaces da conta. Pare o Codespace quando terminar para interromper o consumo de processamento. O armazenamento continua contando enquanto o ambiente existe. Sem método de pagamento cadastrado, o GitHub bloqueia o uso ao acabar a cota.

Nenhum provedor de IA pago é configurado por estes scripts.

## Diagnóstico

- Inicialização: .pentagi-state/start.log
- Download do modelo: .pentagi-state/qwen-pull.log
- Download de embeddings: .pentagi-state/embedding-pull.log
- Serviços: docker ps
- Reinício manual, se necessário: bash .devcontainer/start-free.sh

O código, os modelos e os dados ficam no ambiente; arquivos gerados e segredos locais não são enviados ao repositório.
