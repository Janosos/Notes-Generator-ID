# Notes Creator

**Notes Creator** es una aplicacion desarrollada en Flutter disenada para optimizar la creacion y gestion de notas de venta y cotizaciones para **ImperioDev**, una agencia de soluciones digitales.

La aplicacion permite generar documentos PDF profesionales y estandarizados, listos para ser compartidos con clientes a traves de WhatsApp o guardados localmente.

## Caracteristicas Principales

*   **Dashboard Intuitivo**: Vista rapida de metricas clave, accesos directos a creacion de notas y plantillas rapidas.
*   **Diseno Moderno & Responsivo**: Interfaz basada en principios modernos de UI (Glassmorphism, colores vibrantes) adaptada para escritorio (Windows) y dispositivos moviles (Android).
*   **Persistencia de Datos**:
    *   Guardado automatico de notas y clientes.
    *   La informacion persiste despues de cerrar la aplicacion.
*   **Localizacion Completa**:
    *   Soporte para Ingles (EN) y Espanol (ES).
    *   Deteccion automatica y cambio de idioma en tiempo real.
    *   Generacion de PDF adaptada al idioma seleccionado.
*   **Generador de Cotizaciones**:
    *   Formulario detallado con seleccion de clientes, fechas y folio dinamico.
    *   Gestion de items/servicios con calculo automatico de totales.
    *   Calculo opcional de IVA (16%).
    *   Campo para notas adicionales.
*   **Motor PDF Potente**:
    *   Generacion de PDFs de alta fidelidad con branding de **ImperioDev**.
    *   Diseno profesional con tablas detalladas y desgloses financieros.
*   **Integracion con WhatsApp**: Funcionalidad directa para enviar la cotizacion generada al cliente via WhatsApp.
*   **Soporte Multiplataforma**:
    *   Windows (Escritorio).
    *   Android (APK optimizado).

## Tecnologias Utilizadas

*   **Flutter**: Framework principal para el desarrollo multiplataforma.
*   **Dart**: Lenguaje de programacion.
*   **Paquetes Clave**:
    *   `pdf`: Generacion de documentos.
    *   `printing`: Previsualizacion e impresion multiplataforma.
    *   `shared_preferences`: Persistencia de datos local.
    *   `flutter_localizations`: Soporte de internacionalizacion.
    *   `intl`: Formateo de fechas y monedas.
    *   `path_provider` & `file_selector`: Gestion de archivos en diferentes sistemas operativos.

## Instalacion y Uso (Desarrollo)

1.  **Requisitos Previos**:
    *   Flutter SDK instalado y configurado.
    *   Entorno de desarrollo para Windows (Visual Studio) o Android (Android Studio).

2.  **Clonar el Repositorio**:
    ```bash
    git clone https://github.com/Janosos/Notes-Generator-ID.git
    cd Notes-Generator-ID
    ```

3.  **Instalar Dependencias**:
    ```bash
    flutter pub get
    ```

4.  **Ejecutar la Aplicacion**:
    *   Windows: `flutter run -d windows`
    *   Android: `flutter run -d android`

## Estructura del Proyecto

*   `lib/main.dart`: Punto de entrada y configuracion de temas.
*   `lib/screens/`: Pantallas principales (Dashboard, Creacion de Nota, Previsualizacion PDF, Ajustes).
*   `lib/services/`: Logica de negocio (Servicio de PDF, Persistencia de Notas/Clientes).
*   `lib/models/`: Modelos de datos (Note, NoteItem, Client).
*   `lib/l10n/`: Archivos de localizacion y traduccion.

## Licencia

Este proyecto es propiedad de **ImperioDev**. Todos los derechos reservados.
