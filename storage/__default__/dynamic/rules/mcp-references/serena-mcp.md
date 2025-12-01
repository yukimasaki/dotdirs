---
alwaysApply: true
type: mcp-reference
name: serena-mcp
tags: ["mcp", "serena", "code-editing", "symbol-manipulation", "implementation"]
---

# Serena MCP

シンボルベースのコード編集と操作に特化した MCP です。

## 主な機能

- シンボル検索（`find_symbol`, `get_symbols_overview`）
- シンボル編集（`replace_symbol_body`, `insert_after_symbol`, `insert_before_symbol`）
- シンボルリネーム（`rename_symbol`）
- 参照検索（`find_referencing_symbols`）
- パターン検索（`search_for_pattern`）
- メモリ機能（`write_memory`, `read_memory`）

**使用タイミング**: 05_impementation（実装フェーズ）でコード編集が必要な場合。

詳細は元々の Serena MCP ドキュメントを参照してください。

