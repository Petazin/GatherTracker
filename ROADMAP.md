# Roadmap - GatherTracker

Este documento rastrea el desarrollo del proyecto.

---

## ✅ Completado (Versión Actual v1.5.1)

### Core & Interfaz
- [x] Alternancia automática de rastreo (Minería/Herboristería, etc.).
- [x] Configuración de intervalo de cambio (2s - 60s).
- [x] Soporte de Clases/Razas: Cazador, Druida, Enano (Tesoros).
- [x] Botón de minimapa movible (Drag & Drop con ALT).
- [x] **Universalidad**: Detección de nodos y profesiones compatible con cualquier idioma del cliente (IDs internos).
- [x] **Perfiles Ace3**: Configuración independiente por personaje.

### Automatización Inteligente (QoL - v1.2.0)
- [x] **Detección de Profesión**: Auto-configura rastreo al loguear si eres minero/herborista.
- [x] **Modo Combate**: Oculta el botón y pausa el rastreo al entrar en combate. Autoreanuda opcionalmente.
- [x] **Auto-Venta**: Vende automáticamente objetos grises (basura) al abrir un comerciante.

### Datos y Loot (v1.5.1)
- [x] **Session Loot Tracker**:
    - Registra Minerales, Hierbas, Piedras y Gemas farmeadas en la sesión.
    - Filtra por ID de objeto (universal).
- [x] **Totales**: Muestra cantidad y valor total de la sesión vs lo que hay en bolsa.
- [x] **Integración de Precios**: Soporte para Auctionator, TSM y Aux.

---

## 🚧 Pendiente / En Desarrollo

### Mejoras de Interfaz (v1.6.0)
- [ ] **Skinning de Botón**: Soporte real para LibDBIcon / MinimapButtonBag (Faltan librerías).
- [ ] **Sonidos Personalizados**: Alertas de sonido funcionales al cambiar rastreo o encontrar loot raro.
- [ ] **Configuración Persistente**: Asegurar que opciones (Auto-Venta, Sonidos, Combat Hide) se guarden tras /reload (Fix DB mismatch).
- [ ] **Alineación Visual**: Centrar/Alinear columnas de precio Venta vs AH en el tooltip para mejor lectura.
- [ ] **Durabilidad Promedio**: Mostrar el porcentaje de durabilidad del equipo en el tooltip/HUD.
- [ ] **Persistencia de Loot**: Guardar el historial de "Session Loot" para que no se borre al hacer /reload.

### Funcionalidad Avanzada (v2.0.0)
- [ ] **Ruta Inteligente GatherMate2**: Sugerir ruta basada en nodos conocidos.
- [ ] **Filtros Avanzados**: Ignorar ciertos tipos de mineral/hierba en el conteo de loot.
- [ ] **Atajos de Teclado (Menú)**: Integración nativa en el menú de "Teclado" de WoW (actualmente deshabilitado por error XML).
- [ ] **Persistencia Global (Heatmap)**: Guardar historial de nodos entre sesiones y mostrar mapa de calor.
- [ ] **Sincronización de Hermandad**: Compartir datos de hallazgos con la guild.

---

## ❌ Descartado / Obsoleto
- [x] ~~**Historial de Nodos en HUD**~~: Reemplazado por Loot Tracker directo.
- [x] ~~**Compartir Shift+Clic**~~: Eliminado en favor del resumen de loot.
- [x] ~~**Integración TomTom**~~: Eliminada para simplificar dependencias.
