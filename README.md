# Rbq2012Tagger

Quick tagging utility for local pictures built with Flutter.

Focuses on convenient tagging of local pictures from any folders, targeting PC and Android, featuring one-key shortcuts and keyboard navigation.

Currently still in progress. Not planning to update for the next month as my P0 demand is already fulfilled.

## Roadmap

- [x] Core viewing functionalities (lazy grid, folder picker, sort by name/date asc/desc)
- [x] Welcome page (recent, pinned folders, ...)
  - [x] ~~write super-long, unreadable, and un-maintainable sql one-liners to fetch most recent M (at most N) pinned folders and most recent N - M unpinned folders: look this cat should have been fired for being the doom of cooperation, hopefully this is just a kittenal project~~
- [x] centralized management for tag templates, shortcuts, and color schema (currently *broken* after refactoring)
- [x] Keyboard shortcuts and navigation (single-letter for tagging, alt/shift + letter for continuous/reverse tagging, arrows for navigation)
- [x] Displaying/managing tags (sqlite CRUD)
- [x] Explorer.exe-like Multiple selection ([ctrl/shift/alt +] click, ctrl/shift/alt + arrow)
- [x] VS Code-like multiple tabs (PC only)
- [x] VS Code-like side tabs for showing all available tag templates, and other functionalities, some listed below (switchable, resizable, collapsible, keep-state)
- [x] intersection/union of tags for selected pictures via side tab (viewing and removal)
- [ ] (P0, ++) Add comments so that at least I myself can read after a month or so
- [ ] (P1, +) Reconnect the broken tag templates management (open from home page, open in new tab from any opened folder)
- [ ] (P1, +++) Search and highlight (by name, range of date, included and/or excluded tags)
  - [ ] (P2, +) Save/load searches
- [ ] (P1, +) Selection/search -based actions (move/copy to, add/remove tags)
- [ ] (P2, ++) Advanced searching and actions using JavaScript (or maybe Lua if Flutter's built-in JavaScript is restricted to web views, anyway never bundle a Python or Ruby environment, though I am currently using Python outsides the app for bulk-manipulation based on tags)
- [ ] (P2, ++++) Mobile adaptation (will be mainly used for pictures stored in the app's container, you know it can get really annoying that almost every day friends (at least logical friends since SNS platforms use the term "friend", doubting where the hell I got those friends) come up asking for your private photos for a pleasant morning/noon/bedtime ____tion and you have to go through the hidden gallery to find those that fit their preferences, with an unforgivable O(N) complicity, considering the rapid growth of the gallery it would be O(N^2) in total):
  - [ ] (P2, ++) conditional/responsive UI
  - [ ] (P2, +) tapping and swapping instead of keystrokes
  - [ ] (P3, +) incremental import/export (backup/restore)
- [ ] (P3, +) Undo/redo stack
- [ ] (P3, ++) OCR and AI-based tagging via third-party APIs or inference models (preferring the latter, "finally found some practical application for my learnt deep learning stuff dude! but wait I guess I'd give up before reaching this step")