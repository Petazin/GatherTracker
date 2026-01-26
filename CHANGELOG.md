# Changelog

All notable changes to this project will be documented in this file.

## [v1.9.0] - 2026-01-26
### ✨ New Features (Smart Utility)
*   **Utility Mode**:
    *   **Status Monitor:** When not tracking (or paused), the button displays vital utility info.
    *   **Repair Alert:** If durability is < 30%, icon changes to an **Anvil** with a flashing red border.
    *   **Bag Alert:** If free slots are < 2, icon changes to a **Red Bag**.
    *   **Idle Icon:** Displays a **Wrench** when everything is normal but tracker is paused.
*   **Utility HUD**: Tooltip now includes a status section with:
    *   **Durability Bar**: Visual progress bar.
    *   **Bag Space**: Free/Total slots counter.
    *   **Junk Value**: Total gold value of gray items in bags.

### 🛠 Improvements
*   **Global Priority**: Critical alerts (Repair/Bags) now override the tracking icon to ensure visibility.
*   **Visuals**: Alert icons are always displayed in full color (never desaturated).

## [v1.8.1] - 2026-01-25
### 🐛 Fixes & Polish
*   **Tooltip**: Added missing `Alt + Drag` instruction to the main tooltip.
*   **Code Cleanup**: Removed duplicated logic and redundant functions (legacy `UpdateTooltip`).
*   **Options**: Removed "Combat (Mounted)" option as it was redundant and caused logic conflicts.
*   **Stability**: General internal improvements and translation fixes.

## [v1.8.0] - 2026-01-24
### 🌍 Internationalization (i18n)
*   **Multi-language Support**: Full translation of the Options interface and System messages.
*   **Supported Languages**: Spanish (esES/esMX) and English (enUS/enGB). Automatic client detection.

## [v1.7.6] - 2026-01-23
### 🎮 Gamification Final Update
*   **Trophy Room**: Complete UI redesign with Dark Mode theme.
*   **Achievements**: Added over 50 achievements across Mining, Herbalism, Fishing, and Economy.
*   **Ranking System**: From Novice to Legend based on total items collected.
*   **Hardcore Challenges**: Specialized achievements for collecting specific sets of rare items (e.g., 200 Arcane Crystals).
*   **Social**: Optional setting to announce unlocked achievements to Guild Chat.

## [v1.6.0] - 2026-01-21
### ⚡ Quality of Life & Automation
*   **Smart Pausing**: Context-aware pausing in Stealth, Resting areas, Instances, or when targeting enemies.
*   **Comfort**: Added "Mute Sound" option to silence the native tracking switching sound.
*   **Combat Logic**: Improved combat detection to hide/pause properly without UI errors.
*   **Tooltip Info**: Added Profession Skill levels and Average Durability to the tooltip.

## [v1.5.0] - 2026-01-15
### 📦 Core Features & Loot
*   **Session Loot Tracker**: Tracks items gathered in the current session (Ores, Herbs, Gems).
*   **Value Tracking**: Integration with Auctionator/TSM/Aux to show item values.
*   **Universal Scanning**: Backend update to support tracking IDs instead of localized names.
*   **Auto-Sell**: Automatically sells gray items when visiting a vendor.
