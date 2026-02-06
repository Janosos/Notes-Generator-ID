import 'dart:io';

void main() {
  print('Building web release...');
  final result = Process.runSync('flutter', ['build', 'web', '--release', '--base-href', '/notes-creator/'], runInShell: true);
  
  if (result.exitCode != 0) {
    print('Error building web:');
    print(result.stdout);
    print(result.stderr);
    exit(result.exitCode);
  }
  
  print('Build complete. Generating index.php...');
  
  final indexPhpContent = r'''<?php
// Cargar el entorno de WordPress
// Ajusta la ruta si tu instalación de WP está en otro nivel, 
// normalmente esto busca en la raíz del dominio.
require_once($_SERVER['DOCUMENT_ROOT'] . '/wp-load.php');

// Verificar permisos
if (!is_user_logged_in() || !current_user_can('administrator')) {
    // Si no es admin, redirigir al login de WP y luego volver aquí
    auth_redirect();
    exit;
}
?>
<!DOCTYPE html>
<html>

<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base path you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    For more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base

    This is a placeholder for base href that will be replaced by the value of
    the `--base-href` argument provided to `flutter build`.
  -->
  <base href="/notes-creator/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="ImperioDev Notes Generator">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png" />

  <title>ImperioDev Notes Generator</title>
  <link rel="manifest" href="manifest.json">
</head>

<body>
  <script src="flutter_bootstrap.js?v=${DateTime.now().millisecondsSinceEpoch}" async></script>
  <script>
    // FORCE CACHE CLEARING
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for(let registration of registrations) {
          registration.unregister();
          console.log('ServiceWorker unregistered');
        }
      });
      caches.keys().then(function(names) {
        for (let name of names) caches.delete(name);
        console.log('Caches deleted');
      });
    }
  </script>
</body>

</html>
''';

  final buildDir = Directory('build/web');
  if (!buildDir.existsSync()) {
    print('Error: build/web directory not found.');
    exit(1);
  }
  
  final indexPhpFile = File('${buildDir.path}/index.php');
  indexPhpFile.writeAsStringSync(indexPhpContent);
  
  // Remove index.html to ensure index.php is served (avoiding priority issues)
  final indexHtmlFile = File('${buildDir.path}/index.html');
  if (indexHtmlFile.existsSync()) {
    indexHtmlFile.deleteSync();
    print('Removed index.html to ensure precedence of index.php');
  }

  // Create a version file for easy verification
  final versionFile = File('${buildDir.path}/version.json');
  versionFile.writeAsStringSync('{"version": "3.6.2", "build_time": "${DateTime.now().toIso8601String()}"}');
  
  print('Created index.php and version.json successfully.');
}
