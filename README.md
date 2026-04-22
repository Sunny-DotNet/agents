# agents

这个仓库用于维护一组**标准 Agent 模板**（位于 `templates/`），并通过统一约定与校验保证可持续维护。

`soul` 标准词库不在本仓库维护，由各自独立仓库负责；本仓库只校验模板结构与基础数据有效性。

## 目录结构

```text
templates/                      # 标准 Agent 模板（*.role.json）
scripts/
  validate-templates.ps1        # 本地/CI 统一校验脚本
.github/workflows/
  validate-templates.yml        # CI 校验工作流
```

## 模板结构约定

- 模板文件名：`templates/*.role.json`
- `schema` 固定为：`openstaff.role-sync.v2`
- `soul` 结构固定包含：
  - `traits`
  - `attitudes`
  - `style`（可为单个 key 字符串，或 key 数组）
  - `custom`（可为 `null` 或字符串）
- `soul.traits / soul.attitudes / soul.style` 的值应为非空字符串 key（不在本仓库做词库归属校验）。
- `mcps` 与 `skills` 为对象数组，元素至少包含 `key` 字段。

## 校验方式

本地执行：

```powershell
pwsh -File .\scripts\validate-templates.ps1
```

CI 会在 PR / Push 时自动执行同一脚本。
