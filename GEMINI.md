# GEMINI Memory - GatherTracker

## Proyecto
GatherTracker es un addon para WoW Classic que permite alternar automáticamente entre rastreos de minimapa.

## Reglas y Preferencias
- Mantener documentación en Español (`README_ES.md`) e Inglés (`README_EN.md`).
- Comentarios en código en Español.
- Actualizar `CHANGELOG.md` con cada cambio significativo.

## Notas Técnicas
- Estructura básica: `.toc`, `.lua`, `Embeds.xml`.
- Utiliza librerías estándar (Ace3, AceEvent-3.0).
- **v1.1.0**: Implementa HUD usando `GameTooltip:HookScript` y detección de eventos `UNIT_SPELLCAST` para limpieza inteligente.
- **v1.4.0**: Añade Interactividad Social.
    - **HUD**: Botones interactivos con Clic (Chat), Ctrl+Clic (TomTom), Shift+Clic (Export GM2).
    - **UX**: Ocultamiento automático en Combate.
    - **Integración**: TomTom restringido a nodos precisos (DB) para evitar errores visuales.
- **v1.5.0 (En progreso)**:
    - Implementada Persistencia básica (DB) y Ventana de Estadísticas (Shift+Clic).
    - Pendiente: Ingeniería inversa de GatherMate2 para "Sensor de Proximidad".

## Documentación
- `ROADMAP.md`: Plan de desarrollo y futuras características.
