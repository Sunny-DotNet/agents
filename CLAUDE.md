# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库概述

这是一个 **AI Agent 模板治理仓库**，不是 .NET 应用程序。用于维护标准化的 Agent 角色模板（`*.role.json`），通过 PowerShell 脚本和 CI 保证模板结构合规。

## 常用命令

```powershell
# 本地校验模板
pwsh -File .\scripts\validate-templates.ps1
```

CI（GitHub Actions）会在 PR/Push 涉及模板文件时自动执行同一脚本。

## 模板规范

所有模板必须遵循 `openstaff.role-sync.v2` schema，文件位于 `templates/*.role.json`。

必填字段：`schema`, `id`, `name`, `jobTitle`, `description`, `avatar`, `model`, `modelConfig`, `source`, `isBuiltin`, `isActive`, `soul`, `mcps`, `skills`

关键约束：
- `id` 必须是有效 GUID
- `source` 只允许 `builtin` 或 `custom`
- `isBuiltin` 和 `isActive` 必须是布尔值
- `modelConfig` 必须是合法 JSON
- `soul` 包含 `traits`、`attitudes`（字符串数组）、`style`（字符串或字符串数组）、`custom`（null 或字符串）
- `soul.traits` / `soul.attitudes` / `soul.style` 不允许空字符串和重复 key
- `mcps` 和 `skills` 是对象数组，每个元素必须包含非空的 `key` 字段

## 架构说明

- `templates/` — Agent 角色模板定义
- `scripts/validate-templates.ps1` — 唯一的校验逻辑，本地与 CI 共用
- `.github/workflows/validate-templates.yml` — CI 工作流，触发路径为 `templates/**`、校验脚本和工作流自身

soul 标准词库由独立仓库维护，本仓库不做词库归属校验。
