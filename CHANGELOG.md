# Changelog

Todas las actualizaciones notables de este proyecto se documentarán en este archivo.

## [v1.5.0] - 2026-01-14
### Added
- **Node History**: HUD now displays a list of recently spotted nodes with elapsed time (v1.1.0).
- **Social Integration**:
    - **Data Broker (LDB)**: Launcher icon for Titan Panel/ChocolateBar (v1.4.0).
    - **Chat**: Shift+Click on the button announces the last found node.
- **Automation (QoL)**:
    - **Profession Detection**: Automatically configures tracking on login based on character skills (v1.2.0).
    - **Auto-Sell**: New option to automatically sell gray items when visiting a vendor.
    - **Combat Mode**: Button fades out/hides during combat.
    - **Keybindings**: Added support for key binding via WoW Key Bindings menu.
- **Configuration**:
    - Complete Ace3 Profile system (v1.5.0).
    - Sound alert options on node detection.
- **Global Persistence**: Basic tracking of found nodes in a global database (heatmap support groundwork).
    - Added Layer detection support.
- **Validation**: Included syntax validation script.

### Hotfixes
- Added `/gtr reset` command to recover the button if lost position.
- Expanded node detection dictionary to include specific Spanish herb names (Brezospina, Musgo, etc.) and 'Filón'.
- Fixed load error due to missing `AceBucket-3.0` library.
    - Fixed Auto-Sell error (`UseContainerItem` nil) by implementing modern `C_Container` API hybrid support.
    - **False Positive Fix**: Tooltip scanner now strictly checks `Minimap` ownership to ignore bag/chat items.
    - Improved icon compatibility with Anniversary client (string paths).
- Fixed XML loading errors by removing `Bindings.xml` (Keybindings now handled via Lua).

### Changed
- Chat command changed to `/gtr` or `/gtrack` to avoid conflicts.
- Migrated to Ace3 Profile structure to support per-character settings.
- Updated `GatherTracker.toc` to reflect file structure changes.

## [v1.0.0] - 2025-12-18
- Lanzamiento inicial.
- Alternancia básica de rastreo (Minerales/Hierbas).
- Botón de minimapa móvil.
