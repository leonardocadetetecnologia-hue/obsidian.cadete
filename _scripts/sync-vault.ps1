# sync-vault.ps1 — sincroniza o vault Obsidian com REPOSClaude-Cadete
# Copia o CLAUDE.md global e regenera 00-Dashboard\Skills.md a partir do frontmatter
# YAML de cada skills\**\SKILL.md (suporta description: plano, "quotado" e block scalar |- / >).

$vault = "D:\IA\ECOSSISTEMA-Leo\VAULT-Cadete"
$claudeMd = "$env:USERPROFILE\.claude\CLAUDE.md"
if (Test-Path $claudeMd) {
    Copy-Item $claudeMd "$vault\10-Inteligencia\CLAUDE-global.md" -Force
}

$skillsDir = "$vault\10-Inteligencia\skills"

function Get-SkillDescription {
    param([string]$Path)

    $lines = Get-Content -LiteralPath $Path -Encoding UTF8
    $descIndex = -1
    $inline = ""
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($i -gt 0 -and $lines[$i] -match '^---\s*$') { break }
        if ($lines[$i] -match '^description:\s?(.*)$') {
            $descIndex = $i
            $inline = $matches[1]
            break
        }
    }
    if ($descIndex -eq -1) { return "" }

    $trimmedInline = $inline.Trim()

    if ($trimmedInline -match '^[|>][-+0-9]*\s*$') {
        # block scalar (literal | ou folded >): junta as linhas indentadas seguintes
        $blockLines = New-Object System.Collections.Generic.List[string]
        $j = $descIndex + 1
        while ($j -lt $lines.Count -and ($lines[$j] -match '^\s+\S' -or $lines[$j].Trim() -eq '')) {
            $blockLines.Add(($lines[$j] -replace '^\s+', ''))
            $j++
        }
        while ($blockLines.Count -gt 0 -and $blockLines[$blockLines.Count - 1] -eq '') {
            $blockLines.RemoveAt($blockLines.Count - 1)
        }
        $desc = ($blockLines -join ' ') -replace '\s+', ' '
    }
    elseif ($trimmedInline -match '^"(.*)"$') {
        $desc = $matches[1] -replace '\\"', '"'
    }
    elseif ($trimmedInline -match "^'(.*)'$") {
        $desc = $matches[1] -replace "''", "'"
    }
    else {
        $desc = $trimmedInline
    }

    $desc = $desc.Trim()
    if ($desc.Length -gt 160) {
        $desc = $desc.Substring(0, 160).TrimEnd() + '...'
    }
    return $desc
}

$rows = Get-ChildItem $skillsDir -Recurse -Filter "SKILL.md" -ErrorAction SilentlyContinue | ForEach-Object {
    $skillDir = $_.Directory
    $relPath = $skillDir.FullName.Substring($skillsDir.Length + 1) -replace '\\', '/'
    $segments = $relPath -split '/'
    $name = $segments[-1]
    if ($segments.Count -ge 2) {
        $categoria = $segments[0]
    } else {
        $categoria = "raiz"
    }
    $desc = Get-SkillDescription -Path $_.FullName
    if ([string]::IsNullOrWhiteSpace($desc)) { $desc = "_(sem descrição)_" }
    $desc = $desc -replace '\|', '\|'
    [PSCustomObject]@{
        Categoria = $categoria
        Nome      = $name
        Link      = "[[10-Inteligencia/skills/$relPath/SKILL\|$name]]"
        Descricao = $desc
    }
} | Sort-Object Categoria, Nome

$utf8Bom = New-Object System.Text.UTF8Encoding($true)
$hubDir = "$vault\00-Dashboard\Skills"
New-Item -ItemType Directory -Path $hubDir -Force | Out-Null

$categorias = $rows | Group-Object Categoria | Sort-Object Name

# Uma nota "hub" por categoria — cada uma linkando só pras suas skills.
# Isso faz o grafo do Obsidian mostrar um cluster por categoria em vez de
# uma estrela única com as 105 skills no Skills.md.
foreach ($cat in $categorias) {
    $catBody = New-Object System.Text.StringBuilder
    [void]$catBody.AppendLine("# $($cat.Name)")
    [void]$catBody.AppendLine("$($cat.Count) skills — [[00-Dashboard/Skills|voltar ao índice]]")
    [void]$catBody.AppendLine("")
    [void]$catBody.AppendLine("| Skill | Descrição |")
    [void]$catBody.AppendLine("|---|---|")
    foreach ($r in ($cat.Group | Sort-Object Nome)) {
        [void]$catBody.AppendLine("| $($r.Link) | $($r.Descricao) |")
    }
    [System.IO.File]::WriteAllText("$hubDir\$($cat.Name).md", $catBody.ToString(), $utf8Bom)
}

# Índice: só linka pras notas-hub de categoria, não pras 105 skills direto.
$indexBody = New-Object System.Text.StringBuilder
[void]$indexBody.AppendLine("# 🧩 Inventário de Skills")
[void]$indexBody.AppendLine("Atualizado: $(Get-Date -Format "yyyy-MM-dd HH:mm") — Total: $($rows.Count) skills em $($categorias.Count) categorias")
[void]$indexBody.AppendLine("")
[void]$indexBody.AppendLine("| Categoria | Skills | Nota |")
[void]$indexBody.AppendLine("|---|---|---|")
foreach ($cat in $categorias) {
    [void]$indexBody.AppendLine("| $($cat.Name) | $($cat.Count) | [[00-Dashboard/Skills/$($cat.Name)\|abrir]] |")
}
[System.IO.File]::WriteAllText("$vault\00-Dashboard\Skills.md", $indexBody.ToString(), $utf8Bom)

Write-Host "Skills.md + $($categorias.Count) notas-hub geradas: $($rows.Count) skills."
