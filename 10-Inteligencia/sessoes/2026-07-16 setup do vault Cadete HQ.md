---
data: 2026-07-16
tags: [sessao, claude-code, vault-setup]
---
# Setup do vault Obsidian "Cadete HQ"

## O que foi feito
- Corrigido `_scripts/sync-vault.ps1` (era v1, não a v2 mencionada): novo parser de YAML
  block-scalar (`|-`, `>`, aspas), coluna de categoria e link completo pro `Skills.md`.
- Resolvido mojibake recorrente em `Skills.md`, `Home.md`, `Inbox.md` e nos próprios
  templates — causa raiz: PowerShell 5.1 lê `.ps1`/`.md` sem BOM usando o codepage ANSI do
  sistema. Fix: sempre regravar como UTF-8 **com BOM**.
- `Skills.md` regenerado: 105 skills reais (não ~102), com acentos corretos.
- `Home.md` regenerado com os 4 blocos Dataview (tasks, insights, projetos ativos, sessões).
- Instalados manualmente os 4 plugins da comunidade (dataview, tasks, quickadd, git) —
  baixados dos releases oficiais no GitHub, registrados em `community-plugins.json`, ativados
  no Obsidian.
- QuickAdd configurado: choices "Insight" e "Task" (`data.json` escrito a partir do schema real
  do código-fonte da tag 2.19.1, pra não arriscar chave errada).
- obsidian-git configurado: `autoSaveInterval: 15`, `autoPullOnBoot: true`.
- `D:\IA` removida da sincronização do Google Drive (conflito com Git).
- `git init` + primeiro commit + repo novo no GitHub
  (`leonardocadetetecnologia-hue/obsidian.cadete`, privado) + push. Confirmado ciclo automático
  funcionando (o obsidian-git já criou e enviou um segundo commit sozinho).
- `gh` CLI instalado via winget nesta máquina (faltava autenticação, resolvida pelo usuário).

## Decisões/adiado
- Junction `10-Inteligencia/skills` fica de fora do git (evita duplicar o repo
  REPOSClaude-Cadete). Consequência: clonar este vault em outra máquina não traz as skills —
  decisão de como resolver isso foi adiada.
- Captura automática de sessões Claude Code/Codex não foi construída (hook só roda shell sem
  conteúdo real). Decisão: eu escrevo o resumo manualmente ao fim de sessões relevantes —
  essa nota é a primeira aplicação desse hábito.

## Achado à parte, não corrigido
`skills/apolo/SKILL.md`, `skills/engenheiro/SKILL.md` e `skills/especialista/SKILL.md` (raiz de
`skills/`, distintos dos que existem dentro de `00-personas-leo/`) estão vazios (0 bytes) — não
mexi por ser fora do escopo (repo `REPOSClaude-Cadete`, só leitura).
