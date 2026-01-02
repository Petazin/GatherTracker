# Roadmap - GatherTracker

## Estado Actual (v1.0.0)
- [x] Alternancia automática de rastreo (Minería/Herboristería, etc.).
- [x] Configuración de intervalo de cambio.
- [x] Soporte para clases (Cazador, Druida) y razas (Enano - Tesoros).
- [x] Botón de minimapa movible para control rápido (Activar/Pausar/Configurar).
- [x] Localización básica de nombres de habilidades.

---

## v1.1.0: "Visualización y Conciencia" (Core + UI Básica)
**Objetivo**: Mejorar la información inmediata que recibe el jugador sobre lo que está viendo.
- [x] **Historial de Nodos Visibles (Hover)**: Detectar y listar nodos al pasar el ratón por el minimapa.
- [x] **Opacidad Dinámica**: Hacer la lista semitransparente cuando el mouse no está sobre ella.
- [x] **Código de Colores**: Colorear el texto de la lista según la rareza del mineral/hierba.
- [ ] **Marca de Tiempo**: Indicar hace cuánto tiempo se avistó el nodo (ej. "hace 30s").
- [x] **Limpieza Automática (Fade Out)**: Eliminar nodos de la lista automáticamente después de X minutos.
- [x] **Cálculo de Distancia**: Mostrar la distancia estimada al nodo en la lista. (Parcialmente cubierto con limpieza inteligente)

## v1.4.0: "Social e Integración" (Conectividad)
**Objetivo**: Interactuar con otros jugadores y addons populares.
- [ ] **Integración con TomTom**: Flecha de navegación automática al detectar o clicar un nodo.
- [ ] **Soporte Data Broker (LDB)**: Integración con Titan Panel, ChocolateBar o Fubar.
- [ ] **Compartir Recursos**: Enviar coordenadas automáticamente al chat de grupo/banda (ej. Loto Negro).
- [ ] **Sincronización de Guild**: Compartir datos de nodos encontrados con la hermandad.
- [ ] **Macro de Anuncio**: Clic derecho en la lista para anunciar rápidamente en el chat.

## v1.5.0: "Personalización Total" (Look & Feel)
**Objetivo**: Permitir que el usuario adapte el addon a su gusto estético y auditivo.
- [ ] **Personalización de Icono**: Cambiar el borde, tamaño o forma del botón del minimapa.
- [ ] **Skinning de Botón**: Soporte para LibDBIcon o MinimapButtonBag.
- [ ] **Perfiles Completos**: Guardar configuraciones por personaje o cuenta (AceProfile).
- [ ] **Alertas Sonoras Configurables**: Avisos básicos al detectar recursos específicos.
- [ ] **Sonidos Personalizados**: Asignar sonidos distintos según tipo (ej. metálico vs orgánico).
- [ ] **Paquetes de Voz**: Soporte para packs de sonidos de la comunidad.

## v1.2.0: "Automatización y Flujo de Trabajo" (QoL)
**Objetivo**: Hacer que el addon sea más inteligente y requiera menos gestión manual.
- [ ] **Detección de Profesión**: Activar automáticamente el rastreo si el personaje tiene Minería o Herboristería aprendidas.
- [ ] **Atajos de Teclado**: Asignar una tecla rápida para activar/desactivar el rastreo sin usar el mouse.
- [ ] **Modo Combate Inteligente**: Ocultar HUD y botón, pausar rastreo al entrar en combate y reanudar al salir.
- [ ] **Filtros Inteligentes**: Lista negra para ignorar recursos de bajo nivel o no deseados.
- [ ] **Filtro por Zona**: Configurar rastreos específicos que solo se activen en ciertas zonas.
- [ ] **Auto-Venta de Basura**: Opción auxiliar para vender automáticamente ítems grises obtenidos al recolectar.

## v1.5.0: "Datos y Persistencia"
**Objetivo**: Guardar y analizar la información recolectada a largo plazo.
- [ ] Importación Profunda GM2 (Sensor de Proximidad con la BD completa)
- [ ] Base de datos propia persistente
- [ ] Estadísticas de recolección (Gold/Hour)
- [ ] **Persistencia de Sesión**: Guardar la lista de nodos recientes incluso si recargas la interfaz (/reload).
- [ ] **Persistencia de Datos Global**: Guardar mapa de calor o historial entre sesiones.
- [ ] **Contador/Estadísticas**: Rastrear cuántas veces has visto cada tipo de recurso en la sesión/total.
- [ ] **Exportación de Mapa de Calor**: Exportar datos para herramientas externas de análisis.
- [ ] **Detección de Capa (Layer)**: Anotar en qué capa (Layer) se encontró un nodo (si es posible).
