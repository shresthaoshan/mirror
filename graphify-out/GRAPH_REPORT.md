# Graph Report - .  (2026-11-08)

## Corpus Check
- Corpus is ~4,826 words - fits in a single context window. You may not need a graph.

## Summary
- 105 nodes · 152 edges · 7 communities (5 shown, 2 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 23 edges (avg confidence: 0.83)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Camera View
- Contribution and Product Docs
- Popup Panel
- CI, Testing and Limits
- App Delegate and Entry
- Package Manifest
- Feature Request Form

## God Nodes (most connected - your core abstractions)
1. `CameraView` - 22 edges
2. `Panel` - 15 edges
3. `Mirror menu-bar camera app` - 13 edges
4. `Contributing guide` - 13 edges
5. `AppDelegate` - 7 edges
6. `Popup panel (Panel NSPanel)` - 6 edges
7. `Design rules document` - 5 edges
8. `PanelTests` - 4 edges
9. `Hover buttons (enlarge, mirror, Center Stage)` - 4 edges
10. `Tests CI workflow` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Camera off when hidden` --semantically_similar_to--> `Code rules (camera only while popup open)`  [INFERRED] [semantically similar]
  DESIGN.md → CONTRIBUTING.md
- `Report a bug process` --semantically_similar_to--> `Bug report issue form`  [INFERRED] [semantically similar]
  CONTRIBUTING.md → .github/ISSUE_TEMPLATE/bug_report.yml
- `UserDefaults settings (width, mirrored)` --shares_data_with--> `Popup panel (Panel NSPanel)`  [INFERRED]
  README.md → DESIGN.md
- `Troubleshooting` --references--> `Camera state messages (No camera, Access off)`  [INFERRED]
  README.md → DESIGN.md
- `Bug report issue form` --references--> `Mirror menu-bar camera app`  [EXTRACTED]
  .github/ISSUE_TEMPLATE/bug_report.yml → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Contribution workflow** — contributing_guide, _github_pull_request_template_pr_checklist, _github_workflows_test_tests_workflow, _github_issue_template_feature_request_feature_request_form [INFERRED 0.85]
- **Popup lifecycle components** — design_menu_bar_icon, design_popup_panel, design_camera_capture, design_camera_off_when_hidden [INFERRED 0.85]

## Communities (7 total, 2 thin omitted)

### Community 0 - "Camera View"
Cohesion: 0.12
Nodes (14): AVCaptureVideoPreviewLayer, Bool, CGFloat, NSButton, NSCoder, NSEvent, NSView, Selector (+6 more)

### Community 1 - "Contribution and Product Docs"
Cohesion: 0.11
Nodes (25): Bug report issue form, Issue template config (blank issues disabled), GitHub Pages Jekyll site (minimal-mistakes), AI-assisted contributions policy, Code architecture (main.swift, AppDelegate, Panel, CameraView), Report a bug process, Code style, Contributing guide (+17 more)

### Community 2 - "Popup Panel"
Cohesion: 0.15
Nodes (10): Any, NSPanel, NSWindowDelegate, NSStatusBarButton, Panel, Notification, NSRect, NSStatusBarButton (+2 more)

### Community 3 - "CI, Testing and Limits"
Cohesion: 0.17
Nodes (15): Pull request checklist, macos-26 runner (Xcode 26 SDK), Tests CI workflow, Commits and PRs (Conventional Commits, [skip ci]), No new dependency without issue discussion, Testing policy (swift test, no real system state), Ad hoc code signing, Camera-only permission (+7 more)

### Community 4 - "App Delegate and Entry"
Cohesion: 0.13
Nodes (9): AppKit, AVFoundation, Mirror, NSApplicationDelegate, NSObject, ServiceManagement, AppDelegate, Notification (+1 more)

## Knowledge Gaps
- **13 isolated node(s):** `PackageDescription`, `AVFoundation`, `.isExpanded`, `ServiceManagement`, `XCTest` (+8 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CameraView` connect `Camera View` to `Popup Panel`, `App Delegate and Entry`?**
  _High betweenness centrality (0.219) - this node is a cross-community bridge._
- **Why does `Panel` connect `Popup Panel` to `Camera View`, `App Delegate and Entry`?**
  _High betweenness centrality (0.183) - this node is a cross-community bridge._
- **Why does `AppDelegate` connect `App Delegate and Entry` to `Popup Panel`?**
  _High betweenness centrality (0.071) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `Panel` (e.g. with `AppDelegate` and `CameraView`) actually correct?**
  _`Panel` has 4 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `AVFoundation`, `.isExpanded` to the rest of the system?**
  _13 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Camera View` be split into smaller, more focused modules?**
  _Cohesion score 0.11692307692307692 - nodes in this community are weakly interconnected._
- **Should `Contribution and Product Docs` be split into smaller, more focused modules?**
  _Cohesion score 0.10666666666666667 - nodes in this community are weakly interconnected._