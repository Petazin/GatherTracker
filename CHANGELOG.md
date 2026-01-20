# Changelog

Todas las actualizaciones notables de este proyecto se documentarán en este archivo.

## [v1.5.1] - 2026-01-20
### Added
- **Social Integration**:
- **Automation (QoL)**:
    - **Profession Detection**: Automatically configures tracking on login based on character skills (v1.2.0).
    - **Auto-Sell**: New option to automatically sell gray items when visiting a vendor.
    - **Combat Mode**: Button fades out/hides during combat.
    - **Keybindings**: Added support for key binding via WoW Key Bindings menu.
- **Configuration**:
    - Complete Ace3 Profile system (v1.5.0).
    - Sound alert options on node detection.
- **Validation**: Included syntax validation script.

### Hotfixes
- Added `/gtr reset` command to recover the button if lost position.
- Expanded node detection dictionary to include specific Spanish herb names (Brezospina, Musgo, etc.) and 'Filón'.
- Fixed load error due to missing `AceBucket-3.0` library.
    - Fixed Auto-Sell error (`UseContainerItem` nil) by implementing modern `C_Container` API hybrid support.
    - **False Positive Fix**: Tooltip scanner now strictly checks `Minimap` ownership to ignore bag/chat items.
    - **Localization Fix**: Profession detection is now UNIVERSAL (language-agnostic) using Spell IDs.
    - **Spam Fix**: Prevented repeated "Professions detected" messages on login/zoning.
    - **Bug Fix**: Right-click on minimap button now correctly opens options.
    - **Bug Fix**: Combat Hide consistently respects configuration (added strict state flag).
    - Improved icon compatibility with Anniversary client (string paths).
- **New Feature**: **Session Loot Tracker** (Replaces Node History).
    - Tracks gathered items (Ores, Herbs, Stones, Gems) by **Item ID** (Universal Language Support).
    - Displays Session Totals (Quantity, Vendor Value, AH Value).
    - Displays Bag Totals for tracked items.
    - Shows "N/A" for AH if no auction addon is detected.
- Fixed XML loading errors by temporarily removing `Bindings.xml`. (Keybinding menu support disabled due to client errors).

### Changed
- Chat command changed to `/gtr` or `/gtrack` to avoid conflicts.
- Migrated to Ace3 Profile structure to support per-character settings.
- Updated `GatherTracker.toc` to reflect file structure changes.

## [v1.0.0] - 2025-12-18
- Lanzamiento inicial.
- Alternancia básica de rastreo (Minerales/Hierbas).
- Botón de minimapa móvil.
