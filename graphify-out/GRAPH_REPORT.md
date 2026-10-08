# Graph Report - time-counter  (2026-09-24)

## Corpus Check
- Corpus is ~431 words - fits in a single context window. You may not need a graph.

## Summary
- 32 nodes · 48 edges · 8 communities (4 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Theme Colours
- Imports and Modules
- App Entry Point
- Weeks Archive Class
- Manual Week Entry
- Week Properties
- Automatic Archiving

## God Nodes (most connected - your core abstractions)
1. `Weeks` - 12 edges
2. `Theme` - 8 edges
3. `main()` - 3 edges
4. `Archive of finished study weeks, persisted as JSON.` - 1 edges
5. `Automatic archive of the week that just ended. Numbered after the highest week…` - 1 edges
6. `Add a past week typed in by hand. Returns an error message, or "" on success.` - 1 edges

## Surprising Connections (you probably didn't know these)
- `main()` --calls--> `Theme`  [EXTRACTED]
  main.py → theme.py
- `main()` --calls--> `Weeks`  [EXTRACTED]
  main.py → weeks.py

## Import Cycles
- None detected.

## Communities (8 total, 4 thin omitted)

### Community 0 - "Theme Colours"
Cohesion: 0.38
Nodes (3): Property, QObject, Theme

### Community 1 - "Imports and Modules"
Cohesion: 0.47
Nodes (4): json, os, pathlib, pyside6_qtcore

### Community 2 - "App Entry Point"
Cohesion: 0.40
Nodes (4): main(), pyside6_qtgui, pyside6_qtqml, sys

### Community 3 - "Weeks Archive Class"
Cohesion: 0.50
Nodes (3): QObject, Archive of finished study weeks, persisted as JSON., Weeks

## Knowledge Gaps
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Weeks` connect `Weeks Archive Class` to `Imports and Modules`, `App Entry Point`, `Manual Week Entry`, `Week Properties`, `Automatic Archiving`, `Persistence Helpers`?**
  _High betweenness centrality (0.632) - this node is a cross-community bridge._
- **Why does `Theme` connect `Theme Colours` to `Imports and Modules`, `App Entry Point`?**
  _High betweenness centrality (0.349) - this node is a cross-community bridge._
- **Why does `main()` connect `App Entry Point` to `Theme Colours`, `Weeks Archive Class`?**
  _High betweenness centrality (0.105) - this node is a cross-community bridge._