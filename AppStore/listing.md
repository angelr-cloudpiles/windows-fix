# Ficha de App Store Connect — Window Memory

Reemplaza los campos entre [corchetes] antes de enviar.

## Datos generales
- **Nombre (máx. 30):** Window Memory
- **Subtítulo (máx. 30):** Guarda y restaura tus ventanas
- **Categoría principal:** Productividad (secundaria: Utilidades)
- **Precio:** Gratis
- **Clasificación por edades:** 4+ (todas las respuestas "No")
- **URL de soporte:** https://github.com/angelr-cloudpiles/windows-fix
- **URL de política de privacidad:** https://angelr-cloudpiles.github.io/windows-fix/privacy.html
- **Derechos de autor:** 2026 Angel Reale

## Palabras clave (máx. 100 caracteres)
ventanas,monitores,layout,posición,tamaño,pantallas,escritorio,organizar,restaurar,multimonitor

## Descripción (español)
Window Memory recuerda dónde estaba cada ventana y la devuelve a su sitio cuando quieras, incluso con varios monitores.

Acomoda tus ventanas una vez, guarda el layout con un nombre y restáuralo con un clic desde la barra de menú.

• Guarda la posición y el tamaño de las ventanas de tus apps.
• Funciona con varios monitores: cada monitor se identifica de forma estable, aunque lo desconectes y lo vuelvas a conectar.
• Crea varios perfiles, por ejemplo "Oficina" y "Casa".
• Edita cada perfil: activa o desactiva ventanas sin borrarlas, quita las que no necesitas o añade las que tienes abiertas.
• Vive en la barra de menú: elige un perfil, abre la ventana o cierra la app desde ahí.
• Privada: todo se guarda solo en tu Mac. Sin cuentas, sin red, sin análisis.

Window Memory necesita el permiso de Accesibilidad para leer y mover las ventanas. Lo concedes tú en Ajustes del Sistema y puedes quitarlo cuando quieras.

## Description (English)
Window Memory remembers where every window was and puts it back whenever you want, even across multiple monitors.

Arrange your windows once, save the layout with a name, and restore it with one click from the menu bar.

• Saves the position and size of your apps' windows.
• Multi-monitor aware: each display is identified reliably, even if you unplug and reconnect it.
• Keep several profiles, such as "Office" and "Home".
• Edit each profile: turn windows off without deleting them, remove the ones you don't need, or add the ones currently open.
• Lives in the menu bar: pick a profile, open the window, or quit from there.
• Private: everything stays on your Mac. No accounts, no network, no analytics.

Window Memory needs the Accessibility permission to read and move windows. You grant it in System Settings and can revoke it at any time.

## Novedades de la versión 1.0
Primera versión.

## Notas para el revisor (App Review)
Window Memory is a window-layout utility. It uses the macOS Accessibility API (AXUIElement) only to read the position and size of other apps' standard windows and to move/resize them back when the user presses "Restore" or chooses a profile in the menu bar.

How to test:
1. Launch the app and click "Conceder acceso" (Grant access). Enable Window Memory in System Settings > Privacy & Security > Accessibility.
2. Open a few windows (for example Safari and Notes) and arrange them.
3. In Window Memory, type a name and click "Guardar ventanas actuales" (Save current windows).
4. Move or resize those windows, then click "Restaurar" (Restore), or choose the profile from the menu bar icon > "Aplicar perfil".
5. "Editar" lets you disable, remove, or add windows to a profile.

The app does not record the screen, capture keystrokes, read window contents, or send any data off the device. It has no network access. Data (names, positions, sizes of windows) is stored in the app container only.

## Capturas de pantalla
App Store Connect acepta para Mac: 1280×800, 1440×900, 2560×1600 o 2880×1800 (mínimo 1, máximo 10). Sugeridas:
1. Ventana principal con dos o tres perfiles.
2. Editor de un perfil con ventanas activadas y desactivadas.
3. Menú de la barra con "Aplicar perfil".
4. Aviso de Accesibilidad (opcional).
