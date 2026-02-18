# 📜 GatherTracker - Manual de Capacidades

GatherTracker es un addon "todo en uno" diseñado para **recolectores, artesanos y completistas**. No solo rota tu rastreo, sino que gamifica tu experiencia y gestiona tus objetivos de farmeo.

## 🚀 1. Rastreo Inteligente (Smart Tracking)

El núcleo del addon. Permite rastrear **dos recursos simultáneamente** (ej. Minerales y Hierbas) alternando entre ellos automáticamente.

* **Rotación Automática**: Cambia entre dos tipos de rastreo cada X segundos (Configurable: 2s - 60s).
* **Modo Combate Seguro**:
  * **Pausa Automática**: Detiene la rotación en combate para evitar errores de UI o sonidos molestos.
  * **Ocultar en Combate**: Puede ocultar el botón principal mientras peleas.
* **Filtros de Pausa**:
  * Se detiene si estás en **Sigilo** (Pícaros/Druidas).
  * Se detiene si estás **Descansando** (Aumentando maná/vida).
  * Se detiene si estás en **Instancia** (Mazmorra/Banda).
  * Se detiene si tu objetivo es un **Enemigo** (para no distraer).

## 🛒 2. Lista de Compra (Shopping List)

Olvídate de usar papel y lápiz. Crea listas de materiales necesarios y sigue tu progreso en tiempo real.

* **HUD de Compra**: Una ventana dedicada que muestra qué necesitas y cuánto tienes.
* **Múltiples formas de añadir**:
  * **Desde Profesiones**: Abre tu ventana de Herrería/Alquimia/Ingeniería y verás un botón **[+]** al lado de cada receta. ¡Añade todos los materiales con un clic!
  * **Por Comando**: Escribe `/gt add [Link del Item] x20` (o `x 20`, o simplemente el número).
  * **Importación Masiva**: Pega una lista de texto completa (ej. de una guía web) y el addon intentará reconocer los items.
  * **Recetas Inteligentes**: Si linkeas una receta (ej. *[Elixir de Mangosta]*), el addon descompondrá la receta y añadirá todos sus ingredientes a la lista.
* **Alertas de Progreso**:
  * Te avisa con un sonido y mensaje verde cuando completas la cantidad objetivo de un item.
  * Barra de progreso visual en el HUD (Verde = Completado).
* **Presets (Listas Guardadas)**:
  * **Kits Incluidos**: Viene con listas pre-cargadas para subir Ingeniería (1-300), Alquimia, Herrería y Kits de Farmeo (ej. "Starter Copper").
  * **Presets Personalizados**: Guarda tu lista actual con un nombre para cargarla después.

## 🏆 3. Gamificación y Logros (Trophy Room)

¡Convierte el farmeo en un juego! GatherTracker registra todo lo que recolectas.

* **Sala de Trofeos**: Escribe `/gt history` (o Shift+Click en el minimapa) para ver tus logros.
* **Sistema de Puntos**: Gana puntos por desbloquear logros y sigue tu rango (Novato -> Leyenda).
* **Categorías**:
  * ⛏️ **Minería**: Desde "Primera Piedra" hasta "Señor de la Roca".
  * 🌿 **Herboristería**: Desde "Una Flor" hasta "Guardián de la Arboleda".
  * 🎣 **Pesca**: "Lobo de Mar", "Cena", etc.
  * 💎 **Tesoros**: Gemas y piedras raras.
  * 💰 **Economía**: Basado en el valor de venta (vendor) de lo recolectado.
  * 🔥 **Especialista**: Logros para items raros (Loto Negro, Cristal Arcano) y materiales de TBC (Hierro Vil, Adamantita).
* **Notificaciones (Toasts)**: Un aviso visual estilo "Logro Desbloqueado" aparece cuando consigues uno nuevo.
* **Social**: Opción para anunciar tus logros a la Hermandad automáticamente.

## 🛠️ 4. Utilidades y Calidad de Vida

Pequeñas herramientas que hacen la vida más fácil.

* **Venta Automática (Auto-Sell)**: Vende automáticamente todos los objetos grises (basura) al visitar un mercader.
* **Alertas de Estado**:
  * **Reparación Crítica**: El botón se pone ROJO y muestra un icono de yunque si tu durabilidad baja del 30%.
  * **Bolsas Llenas**: Te avisa si te quedan menos de 2 espacios libres.
* **Información en Tooltip**:
  * Pasa el ratón sobre el botón para ver: Durabilidad promedio, Espacio en bolsas y Valor de la basura acumulada.
  * **Sesión de Loot**: Muestra un resumen de lo recolectado en la sesión actual, con precios de vendedor y subasta (si tienes un addon de subastas compatible).

## ⌨️ Comandos Rápidos

* `/gt`: Activa/Desactiva el rastreo.
* `/gt opt`: Abre el menú de configuración.
* `/gt history`: Abre la Sala de Trofeos.
* `/gt add [Item]`: Añade un item a la lista.
* `/gt clear`: Borra la lista de compra.
* **Click Izquierdo**: Activar/Desactivar.
* **Click Derecho**: Opciones.
* **Shift + Click**: Sala de Trofeos.
* **Alt + Click**: Mostrar/Ocultar Lista de Compra.
* **Rueda del Ratón**: Ajustar velocidad de rotación (intervalo).
