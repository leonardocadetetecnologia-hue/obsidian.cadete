# 🏠 Cadete HQ

## Tasks abertas
```dataview
TASK
FROM "40-Tasks" OR "20-Projetos"
WHERE !completed
SORT file.mtime DESC
LIMIT 20
```

## Insights recentes
```dataview
TABLE file.mtime as "Quando"
FROM "30-Insights"
SORT file.mtime DESC
LIMIT 10
```

## Projetos ativos
```dataview
TABLE status, atualizado
FROM "20-Projetos"
WHERE status = "ativo"
```

## Últimas sessões Claude Code
```dataview
TABLE file.mtime as "Quando"
FROM "10-Inteligencia/sessoes"
SORT file.mtime DESC
LIMIT 5
```

→ [[Skills]] · [[40-Tasks/Inbox|Inbox]]
