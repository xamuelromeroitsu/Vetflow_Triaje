# VetFlow Triaje

Aplicación Flutter del proyecto VetFlow Triaje.

## Preparar el proyecto en una máquina nueva

Ejecuta los comandos desde esta carpeta (`vetflow_triaje/`), donde está este
archivo y `pubspec.yaml`:

1. `flutter pub get` descarga/resuelve las dependencias y crea la configuración
	local que usa Dart para encontrar paquetes.
2. `flutter analyze` comprueba el código.
3. `flutter test` ejecuta las pruebas automatizadas.

La carpeta `vetflow_triaje/` es la raíz Flutter; la raíz Git del repositorio
está un nivel por encima. Ejecutar `flutter pub get` desde la raíz Git produce
`Expected to find project root in current working directory` porque allí no hay
un `pubspec.yaml` de Flutter.

## Error: `package:flutter_lints/flutter.yaml` no se encuentra

`analysis_options.yaml` incluye las reglas recomendadas de `flutter_lints`, y
el paquete ya está declarado en `dev_dependencies` de `pubspec.yaml`. El error
`The URI 'package:flutter_lints/flutter.yaml' ... can't be found` no indicaba
que faltara añadir otra dependencia: la configuración local de paquetes no se
había descargado/resuelto (por ejemplo, tras clonar el repositorio o abrir la
carpeta Git en vez de la subcarpeta Flutter).

**Solución:** abre `vetflow_triaje/` como carpeta del proyecto en VS Code o
ejecuta `flutter pub get` desde ella. Si el subrayado rojo persiste después de
que el comando termine correctamente, ejecuta **Dart: Restart Analysis Server**
desde la paleta de comandos de VS Code.

**Verificación realizada:** `flutter pub get` terminó con `Got dependencies!`
y `flutter analyze` informó `No issues found!`. El aviso de que hay versiones
más nuevas incompatibles con las restricciones actuales es informativo; no es
un error de resolución ni requiere actualizar versiones para solucionar este
caso.
