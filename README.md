# agents

## English

`agents` stores standard agent templates in `templates/*.role.json`.

This repository does not maintain soul vocabulary sources. It only validates template structure and auto-generates `index.json` for discovery and GitHub Pages publishing.

### Structure

```text
templates/                       # agent templates
scripts/
  validate-templates.ps1         # template validation
  generate-index.ps1             # generate index.json
index.json                       # generated template index
index.html                       # pages UI
.github/workflows/
  validate-templates.yml
  generate-index.yml
  deploy-pages.yml
```

### Local commands

```powershell
pwsh -File .\scripts\validate-templates.ps1
pwsh -File .\scripts\generate-index.ps1
```

---

## 中文

`agents` 仓库用于维护 `templates/*.role.json` 下的标准智能体模板。

本仓库不维护 soul 词库来源，仅负责模板结构校验，并自动生成 `index.json` 供检索与 GitHub Pages 发布使用。

### 目录结构

```text
templates/                       # 智能体模板
scripts/
  validate-templates.ps1         # 模板校验
  generate-index.ps1             # 生成 index.json
index.json                       # 自动生成的模板索引
index.html                       # Pages 展示页面
.github/workflows/
  validate-templates.yml
  generate-index.yml
  deploy-pages.yml
```

### 本地命令

```powershell
pwsh -File .\scripts\validate-templates.ps1
pwsh -File .\scripts\generate-index.ps1
```

---

## 日本語

`agents` リポジトリは `templates/*.role.json` にある標準エージェントテンプレートを管理します。

このリポジトリでは soul 語彙セット自体は管理せず、テンプレート構造の検証と `index.json` の自動生成（検索・GitHub Pages 公開用）を行います。

### 構成

```text
templates/                       # エージェントテンプレート
scripts/
  validate-templates.ps1         # テンプレート検証
  generate-index.ps1             # index.json 生成
index.json                       # 生成されるテンプレート索引
index.html                       # Pages UI
.github/workflows/
  validate-templates.yml
  generate-index.yml
  deploy-pages.yml
```

### ローカルコマンド

```powershell
pwsh -File .\scripts\validate-templates.ps1
pwsh -File .\scripts\generate-index.ps1
```

---

## Français

Le dépôt `agents` stocke des modèles d'agents standards dans `templates/*.role.json`.

Ce dépôt ne maintient pas le vocabulaire soul. Il valide la structure des modèles et génère automatiquement `index.json` pour la découverte et la publication via GitHub Pages.

### Structure

```text
templates/                       # modèles d'agents
scripts/
  validate-templates.ps1         # validation des modèles
  generate-index.ps1             # génération de index.json
index.json                       # index généré
index.html                       # interface Pages
.github/workflows/
  validate-templates.yml
  generate-index.yml
  deploy-pages.yml
```

### Commandes locales

```powershell
pwsh -File .\scripts\validate-templates.ps1
pwsh -File .\scripts\generate-index.ps1
```
