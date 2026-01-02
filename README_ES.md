# GatherTracker

**GatherTracker** es un addon ligero y eficiente para World of Warcraft Classic que alterna automáticamente tu rastreo en el minimapa (ej: Minerales y Hierbas) en intervalos configurables. ¡Perfecto para recolectores que no quieren perderse nada!

## Características

*   **Alternancia Automática:** Cambia entre dos tipos de rastreo (Rastreo Primario y Secundario) cíclicamente.
*   **Intervalo Configurable:** Ajusta la velocidad de cambio desde 2 segundos hasta 60 segundos.
*   **Botón de Minimapa Inteligente:**
    *   **Clic Izquierdo:** Activar/Pausar el rastreador.
    *   **Clic Derecho:** Abrir el menú de configuración.
    *   **Rueda del Ratón:** Aumentar o disminuir el intervalo de tiempo rápidamente.
    *   **Alt + Arrastrar:** Mover el botón a cualquier parte de la pantalla.
*   **Detección Inteligente:** Se pausa automáticamente si estás casteando, en combate o muerto.
*   **HUD Visual (v1.1.0):**
    *   Muestra una lista en pantalla de los recursos que ves en el minimapa.
    *   **Limpieza Inteligente:** Los nodos desaparecen automáticamente al recolectarlos.
    *   **Interactivo:**
        *   `Alt + Arrastrar`: Mover lista.
        *   `Clic Derecho`: Borrar lista.
        *   `Clic Izquierdo`: Recargar.

### v1.4.0: Social e Integración (Nuevo)
El HUD ahora es interactivo:
*   **Clic Izquierdo**: Anuncia el recurso en el chat (Decir/Grupo/Banda).
*   **Ctrl + Clic**: Crea un **Waypoint de TomTom** hacia la ubicación *precisa* del nodo.
    *   *Nota*: Para garantizar precisión, esta función está restringida a nodos exportados o verificados.
*   **Shift + Clic**: Exporta el nodo a la base de datos de **GatherMate2**.

## Uso

1.  Una vez instalado, verás un botón en tu pantalla con el icono de tu rastreo actual.
2.  Haz **Clic Izquierdo** en el botón para iniciar la alternancia.
3.  Usa la **Rueda del Ratón** sobre el botón para ajustar qué tan rápido cambia el rastreo.

### Comandos de Chat

*   `/gt` - Activa o desactiva el rastreador.
*   `/gt opt` - Abre el panel de configuración completo.

## Configuración

En el menú de opciones (Clic Derecho en el botón o `/gt opt`), puedes:
*   Seleccionar qué dos tipos de recursos quieres rastrear (ej: Minerales y Hierbas, o Tesoros y Bestias para Enanos/Cazadores).
*   Ocultar el botón del minimapa si prefieres usar solo atajos.

## Autor

Creado por **Petazo**.

## Roadmap

Puedes consultar nuestros planes futuros en [ROADMAP.md](ROADMAP.md).

## Licencia

Este proyecto es de código abierto.
