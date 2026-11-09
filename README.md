# Tibia Idle Native Nim Bot (Zero-GC & Ultra-Light)

Bot autônomo de alta performance para o jogo **Tibia Idle**, reescrito em **Nim 2.2** com gerenciamento de memória ORC (`--mm:orc`), consumo ultra-baixo de RAM (< 10MB) e 100% de paridade com as versões em Go e Rust.

## Funcionalidades
- **Conexão WebSocket Segura**: Stream com autenticação baseada em ticket de mundo.
- **Validação de Sessão**: Suporte a `/auth/me` e `/auth/world-ticket` com cookie de sessão.
- **Seleção Inteligente de Rotas**: Catálogo integrado de hunts por faixa de nível (hunt-26 a hunt-220).
- **Venda Automática e Bênçãos**: Venda automática de drops no NPC e compra de blessings.
- **Furtividade Anti-Detecção**: Jitter orgânico contínuo em todos os loops e pausas de pacing humano.
- **Dashboard e API HTTP**: Endpoint `/api/status` na porta 3001 com métricas em tempo real.

## Compilação

### Linux (Cross-compilação com Zig):
```bash
nim c --os:linux --cpu:amd64 --gcc.exe:zigcc-linux-gnu.bat --gcc.linkerexe:zigcc-linux-gnu.bat -d:ssl -d:release -o:bot-tibiaidle-linux-nim main.nim
```

### Windows:
```bash
nim c -d:ssl -d:release -o:bot-tibiaidle-nim.exe main.nim
```
