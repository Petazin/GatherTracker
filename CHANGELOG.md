# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-12-18
### Added
- Created `README_EN.md` and `README_ES.md` for multilingual support.
- Initial release of GatherTracker.

## [1.4.0] - 2026-01-02
### Added
- **Interactive HUD**: Refactored HUD list into interactive buttons.
- **Social Sharing**: Left-Click on a node to announce it in Chat (Say/Party/Raid).
- **TomTom Integration**: Ctrl-Click on a node to create a precise waypoint.
    - Includes **Trigonometric Calculation** to estimate node position relative to player.
    - *restriction*: Disabled for visual nodes to ensure accuracy. Enabled for DB/Exported nodes.
- **GatherMate2 Integration**: 
    - **Export**: Shift-Click to force add a node to GM2 database.
    - **Proximity Foundation**: Backend prepared to receive GM2 data.
- **Improved UX**: HUD and Minimap Button now automatically hide when entering combat and reappear when leaving.

### Changed
- Reordered `ROADMAP.md` to prioritize Social features.
- Improved HUD button event handling.

## [1.1.0] - 2026-01-02
### Added
- **HUD Visual**: New on-screen list showing recently seen resources.
- **Tooltip Hook**: Automatically detects resources when hovering over them on the minimap.
- **HUD Options**: Added settings for Opacity, Fade Duration, and HUD Enable/Disable.
- **Dynamic Coloring**: Resources are colored in the HUD (Orange for Mining, Green for Herbs).

