# JGR Flipcar

Da la vuelta a vehículos volcados con una animación de empuje, desde el target (ojo) o con un comando, con restricción opcional por trabajo y/o ítem.

`Versión 1.2.0` · `QBCore · Qbox · ESX · Standalone (ox_core)` · `Requiere ox_lib`

[Ver vídeo de ejemplo (Streamable)](https://streamable.com/ts73k2)

---

## Características

- **Volcar vehículos** con la animación `pushcar_offcliff_m`; tras `Config.TimetoFlip` segundos el vehículo queda sobre sus ruedas.
- **Target**: opción «Flip Vehicle» en todos los vehículos con **ox_target**, **qb-target** o **qtarget** (detección automática). Desde el target se vuelca el vehículo que estás mirando.
- **Comando** configurable (`/flipcar` por defecto) que vuelca el vehículo más cercano.
- **Permisos opcionales**: lista de trabajos con grado mínimo y/o ítem requerido (el ítem no se gasta), combinables con «o» / «y».
- **Sincronizado**: pide el control de red del vehículo antes de girarlo para que todos lo vean igual.
- **Avisos**: si estás dentro de un vehículo, lejos, sin permiso o el vehículo ya está derecho.
- **Notificaciones** del framework, de ox_lib, nativas o tu propio sistema.
- **Multi-framework** con detección automática.
- **Aviso de actualizaciones** en la consola del servidor.

## Requisitos

| Recurso | ¿Obligatorio? | Uso |
| :--- | :--- | :--- |
| [ox_lib](https://github.com/overextended/ox_lib) | Sí | Vehículo cercano, carga de animación, notificaciones |
| [ox_target](https://github.com/overextended/ox_target) / qb-target / qtarget | No | Opción en el ojo (si no hay, usa el comando) |
| [ox_inventory](https://github.com/overextended/ox_inventory) | No | Comprobar `Config.RequiredItem` (obligatorio para el ítem en standalone) |
| qbx_core / qb-core / es_extended / ox_core | No | Trabajos, inventario y notificaciones del framework |

## Instalación

1. Descarga el repositorio y deja la carpeta en `resources` con el nombre exacto **`JGR_Flipcar`**.
2. Si vas a exigir un ítem, créalo en tu inventario (nombre por defecto: `Workingtofix`, cámbialo en `Config.RequiredItem`).
3. Añade a tu `server.cfg`, **después** de ox_lib, tu framework, tu inventario y tu target:

   ```cfg
   ensure ox_lib
   # ensure qbx_core / qb-core / es_extended (si usas alguno)
   # ensure ox_inventory
   # ensure ox_target
   ensure JGR_Flipcar
   ```

4. Ya no hace falta editar el `fxmanifest.lua` para ESX: el framework se detecta solo.

## Configuración (`config.lua`)

| Opción | Por defecto | Descripción |
| :--- | :--- | :--- |
| `Config.Framework` | `'auto'` | `'auto'`, `'qbx'`, `'qb'`, `'esx'` o `'standalone'`. En `auto`: qbx_core → qb-core → es_extended → standalone. |
| `Config.Notify` | `'auto'` | `'auto'` (framework y, si no hay, ox_lib), `'ox_lib'` o `'native'`. |
| `Config.UseCustomNotify` | `false` | `true` para usar tu propio sistema: completa el handler de `flipcar-Ryder:CustomNotify` en `config.lua`. |
| `Config.TimetoFlip` | `3` | Segundos de animación antes de girar el vehículo. |
| `Config.FlipDistance` | `3.0` | Distancia máxima (m) al vehículo. |
| `Config.Jobs` | `{}` | `{ ['police'] = 0, ['mechanic'] = 2 }` → trabajo y grado mínimo. Vacía = cualquiera. |
| `Config.AndOr` | `false` | `false`: basta con el trabajo **o** el ítem. `true`: hace falta el trabajo **y** el ítem. |
| `Config.RequiredItem` | `'Workingtofix'` | Ítem necesario (no se gasta). |
| `Config.UseThirdEye` | `true` | Añade la opción al target. |
| `Config.ThirdEyeName` | `'auto'` | `'auto'`, `'ox_target'`, `'qb-target'` o `'qtarget'`. |
| `Config.UseChatCommand` / `Config.ChatCommand` | `true` / `'flipcar'` | Activa y nombra el comando. |
| `Config.Lang` / `Config.LangType` | — | Textos y tipos de notificación. |

### Cómo se combinan trabajo e ítem

| `Config.Jobs` | `Config.AndOr` | Quién puede volcar |
| :--- | :--- | :--- |
| vacía | `false` | Todo el mundo (por defecto) |
| vacía | `true` | Quien lleve el ítem |
| con trabajos | `false` | Quien tenga uno de los trabajos **o** lleve el ítem |
| con trabajos | `true` | Quien tenga uno de los trabajos **y** lleve el ítem |

### Configs antiguas

- `Config.UseESX` y `Config.UseQBX` ya no hacen falta. Si tu `config.lua` no tiene `Config.Framework` y tiene `Config.UseESX = true`, se fuerza ESX igual que antes.
- `Config.enableUpdates` se ha eliminado: el aviso de versión se desactiva con `set jgr_versioncheck 0` (ver abajo).

## Compatibilidad con frameworks

| Framework | Trabajos | Ítem | Notificaciones |
| :--- | :--- | :--- | :--- |
| **QBCore** (`qb-core`) | `job.name` + `job.grade.level` | ox_inventory o `PlayerData.items` (qb-inventory) | `QBCore.Functions.Notify` |
| **Qbox** (`qbx_core`) | `job` y también `jobs` (multitrabajo) | ox_inventory | `exports.qbx_core:Notify` |
| **ESX Legacy** (`es_extended`) | `job.name` + `job.grade` | ox_inventory o `PlayerData.inventory` | `ESX.ShowNotification` |
| **Standalone / ox_core** | No disponible* | Solo con ox_inventory | `lib.notify` (ox_lib) |

\* Sin framework de trabajos, si `Config.Jobs` tiene entradas la condición de trabajo **nunca se cumple** (se avisa una vez en la consola F8). Deja `Config.Jobs` vacío y usa el ítem si necesitas restringirlo. ox_core se trata como standalone.

## Comandos, eventos y uso desde otros scripts

| Tipo | Nombre | Descripción |
| :--- | :--- | :--- |
| Comando | `/flipcar` | Vuelca el vehículo más cercano (configurable). |
| Evento cliente | `flipcar-Ryder:flipcar` | Intenta volcar. Acepta opcionalmente una tabla con `entity` (el vehículo); es lo que usa el target. |
| Evento cliente | `flipcar-Ryder:Notify` | `(mensaje, tipo)`: muestra un aviso con el sistema de notificaciones configurado. |
| Evento cliente | `flipcar-Ryder:CustomNotify` | `(mensaje, tipo)`: lo dispara el script cuando `Config.UseCustomNotify = true`. |

## Actualizaciones

Al arrancar, el servidor comprueba la versión publicada (clave `JGR_Flipcar` del `versions.json` central de JGR) y muestra en consola si estás actualizado o si hay una versión nueva con el enlace de descarga.

Para desactivar el aviso, añade a tu `server.cfg`:

```cfg
set jgr_versioncheck 0
```

## Changelog

### 1.2.0
- Compatible con **QBCore, Qbox, ESX y standalone/ox_core**: se quitan del fxmanifest las dependencias obligatorias `qbx_core` y `ox_inventory` y los módulos `@qbx_core/...`; nuevo `bridge/client.lua` con detección automática y `Config.Framework`.
- Nuevo comprobador de versiones común (`server/version_check.lua`). Se elimina `check_update.lua` (comparaba versiones quitando los puntos) y `Config.enableUpdates`.
- ESX: ya no se usa el evento `getSharedObject` (ESX Legacy no lo atiende), que dejaba un bucle infinito a `Wait(0)`; ahora se usa `exports.es_extended:getSharedObject()`.
- La restricción por trabajos ahora funciona en QBCore y en ESX aunque no se haya puesto `Config.UseESX` (antes se ignoraba y dejaba pasar a todos).
- El ítem requerido se comprueba en todos los frameworks (ox_inventory, qb-inventory e inventario de ESX).
- Target: soporte explícito para **ox_target**, **qb-target** y **qtarget** con `Config.ThirdEyeName = 'auto'`, comprobando que el recurso esté iniciado (antes se miraba si existía la export, lo que no detecta recursos parados) y esperando a que arranque. Desde el target se vuelca el vehículo apuntado. La opción se quita al parar el recurso.
- Se pide el control de red del vehículo antes de girarlo (antes, si otro jugador era el propietario, el giro no se veía para el resto).
- Nuevo aviso «far_away» cuando no hay ningún vehículo cerca (antes no pasaba nada). Nueva opción `Config.FlipDistance`.
- No se puede lanzar el volteo varias veces a la vez; la animación se carga con timeout y se libera al terminar.
- `Config.UseCustomNotify` pasa a `false` por defecto (el handler de ejemplo está vacío, así que antes no se veía ninguna notificación).
- Variables y funciones globales pasadas a locales; el evento de notificación personalizada solo se registra en el cliente.
- `repository` del fxmanifest corregido (`jgr-ry/JGR_Flipcar`). README reescrito.

### 1.1.6
- Versión anterior (Qbox / ESX).

## Soporte y créditos

Autor: **JGR (Ryder)** — GitHub [jgr-ry](https://github.com/jgr-ry). Para dudas o errores, abre un issue en este repositorio.
