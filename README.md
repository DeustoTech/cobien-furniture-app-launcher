# CoBien Furniture App Launcher

Repositorio base para preparar una instalacion Ubuntu orientada a los muebles de CoBien con Openbox como gestor de ventanas principal.

## Aviso

Este repositorio contiene un instalador para equipos objetivo de los muebles CoBien.

No debe ejecutarse en este ordenador de desarrollo.

## Contenido actual

- `setup-cobien-furniture-environment.sh`: instalador principal del entorno de los muebles CoBien.

## Que hace el instalador

- Instala paquetes base del sistema necesarios para Openbox, LightDM, audio y acceso remoto.
- Crea el directorio de trabajo `~/cobien`.
- Clona o actualiza los repositorios `cobien_FrontEnd` y `cobien_MQTT_Dictionnary` en la rama `development_fix`.
- Habilita SSH.
- Configura LightDM con autologin sobre una sesion Openbox.
- Genera los scripts de arranque de Openbox para levantar servicios basicos y RustDesk.
- Valida la sesion Openbox y ejecuta una limpieza segura con `apt autoremove`.

## Uso

```bash
chmod +x setup-cobien-furniture-environment.sh
./setup-cobien-furniture-environment.sh
```

## Requisitos y notas

- El script esta pensado para Ubuntu con `apt`.
- Requiere permisos de `sudo`.
- Usa el alias SSH `github-trabajo` para clonar los repositorios de CoBien con la cuenta de trabajo.
- RustDesk no se instala automaticamente; debe estar instalado y configurado antes del reinicio final.

## Siguientes iteraciones previstas

- Parametrizar rama, resolucion de pantalla y ruta de instalacion.
- Añadir comprobaciones previas del sistema.
- Automatizar mas componentes del arranque remoto del mueble.