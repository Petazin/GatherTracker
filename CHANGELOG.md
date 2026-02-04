# Changelog

All notable changes to this project will be documented in this file.

## [v2.5.0] - 2026-02-04

### ✨ Features & Improvements

* **Localization Refactor**: Fixed hardcoded preset names and UI messages for full English/Spanish support.
* **Shopping List HUD**: Improved resizing behavior and added a dedicated preset management menu.

## [2.4.6] - 2026-02-02

### ✨ Combat Tracking

* **Optional Combat Pause**: Added a new setting to enable or disable tracking switching while in combat.
  * **Independent Logic**: "Pause in Combat" and "Hide in Combat" are now separate options.
  * **Smart Safeguard**: Tracking changes only occur in combat if you are NOT casting or channeling, to prevent interrupting your spells.

## [2.4.5] - 2026-02-02

### ✨ Minimap & LDB

* **Titan Panel Support**: Fully integrated with LibDataBroker.
* **Minimap Icon**: Added a standalone Minimap button for users without Titan Panel.
  * **Interactive**: Left-click to Toggle Tracking, Right-click for Options.
  * **Configurable**: Toggle visibility via the new "Minimap Icon" options panel.

## [2.4.1] - 2026-01-30

### 🐛 Bug Fixes (2.4.1)

* **Achievement Filter**: Achievements now only count items obtained through looting (mining nodes, herbs, etc.).
  * **Strict Logic**: Items received via Trade, Mail, or Quest Rewards are now correctly ignored for achievement progress.
  * **Localization Support**: Uses native Blizzard loot patterns to ensure accuracy across all languages.

## [2.4.0] - 2026-01-30

### ✨ Completion Alerts

* **Smart Feedback**: Added visual and auditory alerts when a Shopping List item goal is reached.
  * **Sound**: Plays a satisfying "Quest Objective Complete" sound.
  * **Chat**: Displays a clear completion message in your primary chat window.
* **Persistent Tracking**: Alert status is saved per item and resets if your bag count drops below the target (e.g., if you use the materials).

### 🛠 Quick Add Improvements

* **Enhanced Feedback**: The `/gt add` command now provides immediate confirmation in the chat after adding an item.
* **Robust Parsing**: Improved item detection for various chat link and text formats.

## [v2.3.2] - 2026-01-28

### ✨ Smart Utility (Non-Gatherers)

* **Durability Display**: repurposed the tracker button for characters without gathering professions.
  * **Visuals**: Displays a Chest Plate icon with your average armor durability percentage overlaid.
  * **Color Coded**: Text changes color based on health (Green > 70%, Yellow > 30%, Red < 30%).
  * **Alerts**: Border turns red if durability is critical (< 30%).
  * **Logic**: Fishing is ignored for this check (players with only Fishing will see Durability Mode).

## [v2.3.1] - 2026-01-27

### 🛠 UI Persistence

* **Sticky Visibility**: Fixed an issue where the Shopping List HUD would automatically show up after a tracking swap even if hidden. The HUD now respects your manual toggle state (`Alt + Click`).

## [v2.3.0] - 2026-01-27

### ✨ Expanded Presets (Vanilla/Classic)

* **Comprehensive Library**: Added over 20 new preset lists covering Engineering, Alchemy, Blacksmithing (Lv 1-300), First Aid, Cooking, and Rogue utilities.
* **Farming Routes**: Specific lists for efficient farming runs (e.g., "Mithril Run", "Plaguebloom Farm").

### 🛠 Custom Lists

* **Create Your Own**: You can now save your current Shopping List as a custom preset!
  * Click the **Book Icon** [📖] -> **"Save Current List..."**, give it a name, and it's saved forever.
* **Manage Lists**: Load your custom lists from the new **"My Custom Lists"** menu.
* **Delete**: Simple `Shift + Click` on a custom list to delete it.

### 📥 Bulk Import

* **Enhanced Entry**: Added a new multi-line input window for batching items.
* **Flexible Parsing**: Supports multiple formats: `Item Name xQuantity`, `Quantity Item Name`, `Item Name Quantity`.
* **Zero Conflict**: Logic prevents manual items from merging with preset-sourced items, keeping your list organized by origin.

### 🐛 Bug Fixes (v2.3.0)

* **Syntax**: Fixed a missing comma in the default configuration table that caused initialization failure.
* **Popups**: Created a dedicated confirmation popup for the "Clear List" button to prevent accidental achievement resets.
* **UI Alignment**: Fixed item icon retrieval logic and button positioning in the Shopping List.

## [v2.2.0] - 2026-01-26

### ✨ Major Features (Smart Lists v2)

* **Detached Shopping List**: The list is now a standalone window, independent of the main button.
* **Resizable Interface**: You can now resize the Shopping List window by dragging the bottom-right corner.
* **Enhanced Styling**: Updated buttons and fonts to match the standard Blizzard UI look and feel.
* **Preset System**: Added a new "Load Preset" button [📖] that allows you to quickly load starter kits for professions (Engineering, Alchemy, etc.).

### 🐛 Bug Fixes (v2.2.0)

* **Localization**: Fixed missing text keys for the new Preset system in both English and Spanish.
* **Compatibility**: Improved window resizing logic to support multiple WoW client versions including TBC/Classic.
* **Stability**: Fixed a loading order issue where Presets would not initialize correctly.

## [v1.9.2] - 2026-01-26

### ✨ User Experience (UX)

* **Visual Controls**: Added `[+]` (Add) and `[x]` (Delete) buttons directly to the Shopping List HUD.
* **Link Pasting**: You can now `Shift+Click` items into the "Add Item" popup.
* **Smart Search**: writing an item name (e.g., "Copper Ore") will check your existing list for a match, even if not in global cache.
* **Empty State**: The "Add" button remains visible even when the list is empty.

## [v1.9.1] - 2026-01-26

### ✨ New Features (Smart Lists)

* **Shopping List**: Create a list of items to track (Materials/Recipes).
* **Profession Integration**: Add recipes directly from Crafting/TradeSkill windows.
* **Active HUD**: Track progress of required items on screen (e.g., `Iron Ore: 5/20`).
* **Smart Commands**: Use `/gt add [Link] xAmount` to quickly add items.

## [v1.9.0] - 2026-01-26

### ✨ New Features (Smart Utility)

* **Utility Mode**:
  * **Status Monitor:** When not tracking (or paused), the button displays vital utility info.
  * **Repair Alert:** If durability is < 30%, icon changes to an **Anvil** with a flashing red border.
  * **Bag Alert:** If free slots are < 2, icon changes to a **Red Bag**.
  * **Idle Icon:** Displays a **Wrench** when everything is normal but tracker is paused.
* **Utility HUD**: Tooltip now includes a status section with:
  * **Durability Bar**: Visual progress bar.
  * **Bag Space**: Free/Total slots counter.
  * **Junk Value**: Total gold value of gray items in bags.

### 🛠 Improvements

* **Global Priority**: Critical alerts (Repair/Bags) now override the tracking icon to ensure visibility.
* **Visuals**: Alert icons are always displayed in full color (never desaturated).

## [v1.8.1] - 2026-01-25

### 🐛 Fixes & Polish

* **Tooltip**: Added missing `Alt + Drag` instruction to the main tooltip.
* **Code Cleanup**: Removed duplicated logic and redundant functions (legacy `UpdateTooltip`).
* **Options**: Removed "Combat (Mounted)" option as it was redundant and caused logic conflicts.
* **Stability**: General internal improvements and translation fixes.

## [v1.8.0] - 2026-01-24

### 🌍 Internationalization (i18n)

* **Multi-language Support**: Full translation of the Options interface and System messages.
* **Supported Languages**: Spanish (esES/esMX) and English (enUS/enGB). Automatic client detection.

## [v1.7.6] - 2026-01-23

### 🎮 Gamification Final Update

* **Trophy Room**: Complete UI redesign with Dark Mode theme.
* **Achievements**: Added over 50 achievements across Mining, Herbalism, Fishing, and Economy.
* **Ranking System**: From Novice to Legend based on total items collected.
* **Hardcore Challenges**: Specialized achievements for collecting specific sets of rare items (e.g., 200 Arcane Crystals).
* **Social**: Optional setting to announce unlocked achievements to Guild Chat.

## [v1.6.0] - 2026-01-21

### ⚡ Quality of Life & Automation

* **Smart Pausing**: Context-aware pausing in Stealth, Resting areas, Instances, or when targeting enemies.
* **Comfort**: Added "Mute Sound" option to silence the native tracking switching sound.
* **Combat Logic**: Improved combat detection to hide/pause properly without UI errors.
* **Tooltip Info**: Added Profession Skill levels and Average Durability to the tooltip.

## [v1.5.0] - 2026-01-15

### 📦 Core Features & Loot

* **Session Loot Tracker**: Tracks items gathered in the current session (Ores, Herbs, Gems).
* **Value Tracking**: Integration with Auctionator/TSM/Aux to show item values.
* **Universal Scanning**: Backend update to support tracking IDs instead of localized names.
* **Auto-Sell**: Automatically sells gray items when visiting a vendor.
