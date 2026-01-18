# Notes Generator ID

**Notes Generator ID** es una aplicación desarrollada en Flutter diseñada para optimizar la creación y gestión de notas de venta y cotizaciones para **ImperioDev**, una agencia de soluciones digitales.

La aplicación permite generar documentos PDF profesionales y estandarizados, listos para ser compartidos con clientes a través de WhatsApp o guardados localmente.

## 🚀 Características Principales

*   **Dashboard Intuitivo**: Vista rápida de métricas clave, accesos directos a creación de notas y plantillas rápidas.
*   **Diseño Moderno & Responsivo**: Interfaz basada en principios modernos de UI (Glassmorphism, colores vibrantes) adaptada para escritorio (Windows) y preparada para escalabilidad.
*   **Generador de Cotizaciones**:
    *   Formulario detallado con selección de clientes, fechas y folio dinámico (`#IMP-YYYY-NNN`).
    *   Gestión de ítems/servicios con cálculo automático de totales.
    *   Cálculo opcional de IVA (16%).
    *   Campo para notas adicionales.
*   **Motor PDF Potente**:
    *   Generación de PDFs de alta fidelidad con branding de **ImperioDev**.
    *   Diseño "pixel-perfect" con tablas detalladas, desgloses financieros y pie de página estilizado.
*   **Integración con WhatsApp**: Funcionalidad directa para enviar la cotización generada al cliente vía WhatsApp Web o App.
*   **Soporte Off-line**: Funcionalidad completa sin necesidad de conexión constante a internet.

## 🛠️ Tecnologías Utilizadas

*   **Flutter**: Framework principal para el desarrollo multiplataforma.
*   **Dart**: Lenguaje de programación.
*   **Paquetes Clave**:
    *   `pdf`: Generación de documentos.
    *   `printing`: Previsualización e impresión multiplataforma.
    *   `google_fonts`: Tipografía personalizada (Plus Jakarta Sans).
    *   `intl`: Formateo de fechas y monedas.
    *   `url_launcher`: Integración con aplicaciones externas (WhatsApp).

## 📦 Instalación y Uso (Desarrollo)

1.  **Requisitos Previos**:
    *   Flutter SDK instalado y configurado.
    *   Entorno de desarrollo para Windows (Visual Studio con cargas de trabajo de escritorio C++).

2.  **Clonar el Repositorio**:
    ```bash
    git clone https://github.com/Janosos/Notes-Generator-ID.git
    cd Notes-Generator-ID
    ```

3.  **Instalar Dependencias**:
    ```bash
    flutter pub get
    ```

4.  **Ejecutar la Aplicación**:
    ```bash
    flutter run -d windows
    ```

## 📸 Estructura del Proyecto

*   `lib/main.dart`: Punto de entrada y configuración de temas.
*   `lib/screens/`: Pantallas principales (Dashboard, Creación de Nota, Previsualización PDF).
*   `lib/services/`: Lógica de negocio (Servicio de PDF).
*   `lib/models/`: Modelos de datos (Note, NoteItem).
*   `lib/theme/`: Configuración de estilos y colores (AppTheme).

## 📄 Licencia

Este proyecto es propiedad de **ImperioDev**. Todos los derechos reservados.
