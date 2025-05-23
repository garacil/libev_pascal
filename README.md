# libev.pas

## Descripción

Este proyecto desarrollado por **Germán Luis Aracil Boned** (garacilb@gmail.com) proporciona un binding en Pascal para la biblioteca de eventos asincrónicos [libev](http://software.schmorp.de/pkg/libev.html). El fichero `libev.pas` expone la funcionalidad esencial de libev a programas escritos en Object Pascal (Free Pascal/Lazarus), permitiendo la programación de eventos no bloqueantes mediante bucles de espera eficientes.

El fichero `ejemplo_libev.pas` muestra un caso de uso básico del binding, demostrando cómo crear y usar un bucle de eventos y configurar un `ev_io` para manejar entradas estándar.

---

## Archivos incluidos

- `libev.pas`: Binding en Pascal de la biblioteca libev.
- `ejemplo_libev.pas`: Ejemplo de uso del binding.

---

## Requisitos

- **Compilador**: Free Pascal Compiler (FPC)
- **Biblioteca**: libev (instalada en el sistema)
  - En Debian/Ubuntu puedes instalarla con:
    ```bash
    sudo apt-get install libev-dev
    ```

---

## Compilación

Para compilar el ejemplo:

```bash
fpc ejemplo_libev.pas -Fl/usr/include -lev
