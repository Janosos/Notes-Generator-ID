# Changelog

## [3.5.0] - 2026-01-19
### Agregado
- **Edición de Clientes**: Ahora es posible editar clientes existentes (nombre, dirección, contactos).
- **Campos Separados**: Teléfono y correo electrónico ahora tienen campos dedicados.
- **Códigos de País**: Selección de código de país con bandera para números de teléfono (Latinoamérica y Europa).
- **Tipos de Nota**: Opción para seleccionar entre "Cotización" y "Nota de Venta".
- **Seleccionar Todas**: Nueva opción para seleccionar todas las notas en la lista con un solo toque.

### Cambiado
- **PDF Preview**: Se eliminó el botón directo de WhatsApp. Se mejoró la función "Compartir" para incluir un mensaje con saludo, tipo de nota, folio y total.
- **Seguridad**: Se previene la navegación hacia atrás accidental en la vista previa del PDF (móvil).
- **Correcciones**:
    - Arreglado el autocompletado del nombre del cliente al crear nota desde la pantalla de clientes.
    - Validación de número de teléfono antes de acciones de compartir.

## [3.4.0] - 2026-01-18
### Agregado
- Persistencia de datos para Notas y Clientes usando `shared_preferences`.
- Localización completa de etiquetas faltantes ("CANT.", "PRECIO UNITARIO").
- Icono de aplicación personalizado para Android.
- Nombre de aplicación actualizado a "Notes Creator" en Android.
- Generación de APK de lanzamiento (`Notes_V3.4.0.apk`).

### Cambiado
- Actualizado el botón de "Atrás" en la previsualización de PDF por un botón de "Inicio" para mejorar la navegación.
- Reemplazado el icono de basura por una "X" roja en la lista de servicios.
- Actualizada la versión mostrada en Ajustes a 3.4.0.

## [3.3.0] - 2026-01-17
### Agregado
- Soporte inicial de localización (Español/Inglés).
- Generación de PDF multilingüe.
- Pantalla de Ajustes con selector de idioma y tema.

### Cambiado
- Mejoras en la interfaz de usuario del Dashboard.
- Optimización de la generación de PDF.

## [3.0.0] - 2026-01-15
### Inicial
- Versión inicial de la aplicación Notes Generator ID.
- Funcionalidades básicas de creación de notas y generación de PDF.
