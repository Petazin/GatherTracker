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

### v1.6.0: Control y Automatización (QoL)
*Enfoque: Mejoras de calidad de vida sencillas y opciones de control de automatización.*

- [ ] **Silenciar Cambio de Rastreo**: Opción para desactivar el sonido que se reproduce al alternar entre rastreos.
- [ ] **Alineación Visual**: Centrar/Alinear columnas de precio Venta vs AH en el tooltip para mejor lectura.
- [ ] **Durabilidad Promedio**: Mostrar el porcentaje de durabilidad del equipo en el tooltip/HUD.
- [ ] **Nivel de Profesión**: Mostrar/Ocultar el nivel de habilidad actual de la profesión rastreada en el tooltip.
- [ ] **Configuración Persistente**: Fix para asegurar que opciones (Auto-Venta, Sonidos, Combat Hide) se guarden tras /reload.
- [ ] **Control de Automatización (Triggers de Pausa)**:
    - [ ] **Combate**: Opción para ignorar el modo "Ocultar en Combate" (seguir rastreando).
    - [ ] **Combate (Montura)**: Seguir rastreando en combate SOLO si se está montado.
    - [ ] **Sigilo**: Pausar automáticamente al entrar en sigilo.
    - [ ] **Descanso**: Pausar automáticamente en Posadas o Ciudades.
    - [ ] **Target Enemigo**: Pausar si se tiene un enemigo seleccionado.
    - [ ] **Instancias**: Pausar automáticamente en Mazmorras y Bandas (BG/Arena incluido).

### v1.7.0: Personalización y Universalidad
*Enfoque: Expandir el sistema de rastreo y opciones de usuario.*

- [ ] **Rastreo Universal**: Permitir seleccionar *cualquier* tipo de rastreo (Pesca, Buzones, Posaderos, etc.) como Primario o Secundario.
- [ ] **Sistema de Perfiles**: Implementación completa de perfiles Ace3 para guardar configuraciones por personaje/cuenta.
- [ ] **Sonidos Personalizados**: Alertas de sonido configurables para cambio de rastreo o loot raro.
- [ ] **Atajos de Teclado (Keybindings)**: Integración nativa en el menú de teclado de WoW.

### v1.8.0: Persistencia Visual y Externa
*Enfoque: Mejoras visuales que requieren librerías externas o bases de datos complejas.*

- [ ] **Persistencia de Loot**: Guardar el historial de "Session Loot" entre sesiones (DB).
- [ ] **Filtros Avanzados**: Configuración para ignorar ciertos items en el conteo de loot.
- [ ] **Skinning de Botón**: Soporte real para `LibDBIcon` o `MinimapButtonBag`.

### v2.0.0: Inteligencia de Datos (Complexity High)
*Enfoque: Nuevos sistemas complejos de navegación y datos compartidos.*

- [ ] **Ruta Inteligente GatherMate2**: Sugerir ruta de farmeo basada en nodos conocidos.
- [ ] **Persistencia Global (Heatmap)**: Mapa de calor de nodos encontrados.
- [ ] **Sincronización de Hermandad**: Compartir datos de hallazgos en tiempo real con la guild.

---

## ❌ Descartado / Obsoleto
- [x] ~~**Historial de Nodos en HUD**~~: Reemplazado por Loot Tracker directo.
- [x] ~~**Compartir Shift+Clic**~~: Eliminado en favor del resumen de loot.
- [x] ~~**Integración TomTom**~~: Eliminada para simplificar dependencias.
