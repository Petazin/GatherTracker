# Changelog

Todas las actualizaciones notables de este proyecto se documentarán en este archivo.

## [v1.7.6] - 2026-01-23
### Summary
**"La Actualización de Gamificación - Edición Completa"**
Esta versión masiva transforma GatherTracker en un juego dentro del juego. Introduce un sistema completo de logros con más de 50 objetivos, una "Sala de Trofeos" visualmente renovada, clasificaciones por rangos (Bronce a Diamante), y retos "Hardcore" para los recolectores más dedicados. Incluye correcciones visuales importantes y un rediseño de notificaciones.

### New Features
- **Sala de Trofeos Renodava (`/gt history`)**:
    - **Interfaz Estandarizada**: Nuevo diseño oscuro/plano consistente con AceConfig.
    - **Sistema de Puntos**: Visualización de "Puntos Obtenidos / Totales" con colores de progreso.
    - **Categorización Visual**: Logros agrupados por secciones (Minería, Pesca, Economía, etc.) con encabezados claros.
    - **Botón de Reset Seguro**: Nueva opción para borrar datos con doble confirmación.

- **Sistema de Logros Expandido (50+)**:
    - **Curva de Aprendizaje**: Nuevos logros de inicio (1 y 10 unidades) para todas las profesiones.
    - **Rangos**: Progresión clara desde "Novato" hasta "Leyenda".
    - **Especialista Hardcore**: Retos de 200 unidades para materiales de endgame (Torio, Hierro Negro, Flor de Peste).
    - **Economía**: Logros basados en el valor de venta acumulado ("Millonario").

- **Social & UX**:
    - **Anuncios de Hermandad**: Opción para compartir automáticamente tus logros en el chat de Guild.
    - **Notificaciones "Heroicas"**: Nuevo diseño de Toast (alerta de logro) más grande, dorado y animado.
    - **Acceso Rápido**: `Shift + Click` en el botón del minimapa abre la Sala de Trofeos.

### Bug Fixes & Polish
- **Iconos**: Corregidos múltiples iconos faltantes o erróneos para el cliente Classic (incluyendo Pesca, Anguilas y Millonario).
- **Estabilidad**: El reset de base de datos ahora refresca la interfaz instantáneamente sin requerir `/reload`.
- **Feedback**: Mejorada la descripción de tooltips con valores detallados (Progreso y Puntos).

## [v1.6.0] - 2026-01-21
### ✨ New Features
- **Tooltip Information**:
    - **Durability**: Shows average equipment durability % (green/yellow/red).
    - **Profession Level**: Displays current skill level of the tracked profession (e.g., Mining 150/300).
    - **Smart Clean**: Automatically hides the "Session Loot" section if the character has no gathering professions.
- **Advanced Automation (Pauses)**:
    - Configurable options to automatically pause tracking in:
        - **Resting Areas** (Inns/Cities).
        - **Stealth** (Rogues/Druids).
        - **Instances** (Dungeons/Raids/PVP).
        - **Combat** (Hostile Target selected).
- **Combat Improvements**:
    - New **"Allow if Mounted"** option: Keeps the button visible during combat if you are mounted (pauses cycling for safety).
- **Sound**:
    - Added option to **Mute** the "Click" sound when switching tracking (temporarily suppresses system SFX).

### 🐛 Bug Fixes
- Fixed a critical bug where multiple timers would stack after leaving combat, causing the cycle to accelerate exponentially.
- Fixed persistence issues where some options (Auto-Sell, CombatHide, Sounds) were not saved after `/reload`.
- Optimized Tooltip display logic for price column alignment.

## [v1.5.2] - 2026-01-21
### Added
- **Core**: Dynamic Tracking System.
    - Replaced hardcoded class lists with a real-time scanner (`ScanTrackingSpells`).
    - Finds *any* tracking ability available to the character (Professions, Racials, Class Spells) automatically.
    - **Future-Proof**: Automatically supports new spells or changes without addon updates.
    - **Paladin Fix**: "Sense Undead" is now natively supported via this new system.

## [v1.5.1] - 2026-01-20
### Added
- **Social Integration**:
- **Automation (QoL)**:
    - **Profession Detection**: Automatically configures tracking on login based on character skills (v1.2.0).
    - **Auto-Sell**: New option to automatically sell gray items when visiting a vendor.
    - **Combat Mode**: Button fades out/hides during combat.
    - **Keybindings**: Added support for key binding via WoW Key Bindings menu.
- **Configuration**:
    - (Reverted due to bugs) Profile system moved to v1.7.0.

- **Validation**: Included syntax validation script.

### Hotfixes
- Added `/gtr reset` command to recover the button if lost position.

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

### Documentation
- **Roadmap Reorganization**: Restructured `ROADMAP.md` into v1.6 (QoL), v1.7 (Universal), v1.8 (Persistence), and v2.0 (Deep Intelligence) to prioritize features by complexity.


## [v1.0.0] - 2025-12-18
- Lanzamiento inicial.
- Alternancia básica de rastreo (Minerales/Hierbas).
- Botón de minimapa móvil.
