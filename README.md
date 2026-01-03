# 🚗 JGR Flip-car

[![GitHub license](https://img.shields.io/github/license/jgr-ry/Flip-car?style=flat-square)](https://github.com/jgr-ry/Flip-car/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/jgr-ry/Flip-car?style=flat-square)](https://github.com/jgr-ry/Flip-car/releases)

Un script versátil y ligero para volcar vehículos, diseñado para ofrecer una integración perfecta tanto con **Qbox/QBX** como con **ESX**.

[🎥 Ver Preview en Streamable](https://streamable.com/ts73k2)

---

## ✨ Características principaless

* 🎯 **Integración con Target:** Soporte nativo para `ox_target` y otros sistemas de "ojo".
* 📦 **Requisitos de Ítem:** Posibilidad de configurar un ítem específico (como un gato hidráulico) para poder volcar el coche.
* 🛠️ **Compatibilidad Dual:** Funciona con `qbx_core` y `es_extended` sin necesidad de scripts adicionales.
* ⌨️ **Comandos Personalizables:** Opción de activar comandos de chat para usuarios que no usen target.

---

## 🛠️ Dependencias

Para un funcionamiento óptimo, asegúrate de tener instalados:

| Recurso | Enlace | Requerido |
| :--- | :--- | :--- |
| **ox_lib** | [GitHub](https://github.com/overextended/ox_lib) | ✅ Sí |
| **ox_target** | [GitHub](https://github.com/overextended/ox_target) | ✅ Sí |
| **ox_inventory** | [GitHub](https://github.com/overextended/ox_inventory) | ⚠️ Opcional |
| **qbx_core** | [GitHub](https://github.com/qbcore-framework/qbx_core) | ⚠️ Opcional |
| **es_extendede** | [GitHub](https://github.com/qbcore-framework/qbx_core) | ⚠️ Opcional |

---

## 🚀 Instalación

1.  **Descarga** el recurso y colócalo en tu carpeta de `resources`.
2.  **Configuración:** Edita el archivo `config.lua` para adaptar el script a tu framework:
    * Para **QBX**: Establece `Config.UseQBX = true` y `Config.UseESX = false`.
    * Para **ESX**: Establece `Config.UseESX = true` y asegúrate de descomentar las líneas de ESX en el manifest.
3.  **Orden de carga:** Es **crítico** que los recursos se inicien en este orden en tu `server.cfg`:

```cfg
ensure ox_lib
ensure qbx_core
ensure ox_target
ensure JGR_Flipcar
