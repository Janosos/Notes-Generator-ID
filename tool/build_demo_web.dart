import 'dart:io';

void main() {
  print('Starting Demo Build Process...');

  // files to modify
  final dashboardFile = File('lib/screens/dashboard_screen.dart');
  final pdfServiceFile = File('lib/services/pdf_service.dart');

  // backups
  final dashboardBackup = File('lib/screens/dashboard_screen.dart.bak');
  final pdfServiceBackup = File('lib/services/pdf_service.dart.bak');

  try {
    // 1. Create Backups
    print('Creating backups...');
    dashboardFile.copySync(dashboardBackup.path);
    pdfServiceFile.copySync(pdfServiceBackup.path);

    // 2. Modify Dashboard Screen
    print('Modifying Dashboard Screen...');
    String dashboardContent = dashboardFile.readAsStringSync();
    
    // Regex matches "Text(\n whitespace 'DEV',"
    // We replace it with "Text(\n whitespace 'DEV APP DEMO',"
    final devTextRegex = RegExp(r"Text\(\s*'DEV',");
    if (devTextRegex.hasMatch(dashboardContent)) {
       dashboardContent = dashboardContent.replaceAllMapped(devTextRegex, (match) {
         return match.group(0)!.replaceFirst("'DEV'", "'DEV APP DEMO'");
       });
       print('Dashboard: "DEV" text replaced with "DEV APP DEMO".');
    } else {
       print('WARNING: Dashboard "DEV" text NOT found.');
    }
    dashboardFile.writeAsStringSync(dashboardContent);

    // 3. Modify PDF Service
    print('Modifying PDF Service...');
    String pdfContent = pdfServiceFile.readAsStringSync();

    // Inject Watermark
    // Strategy:
    // 1. Quote Layout: Inject AT START of Stack children (behind everything).
    //    Anchor: The top strip "pw.Positioned(top: 0, left: 0..."
    // 2. Sale Layout: Inject AFTER Background Container (above background, behind content).
    //    Anchor: "pw.Container(color: slate50),"

    final watermarkCode = '''
              pw.Positioned(
                top: 0, bottom: 0, left: 0, right: 0,
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.5,
                    child: pw.Opacity(
                      opacity: 0.15,
                      child: pw.Text(
                        'IMPERIODEV DEMO',
                        style: pw.TextStyle(
                          color: PdfColors.grey500,
                          fontSize: 60, // Slightly smaller to fit longer text
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
''';

    int injectionCount = 0;

    // 1. Quote Layout Injection
    // Anchor: The first child of the Quote stack is the top strip.
    // Regex matches: pw.Positioned(\n whitespace top: 0, left: 0, right: 0,
    final quoteAnchorRegex = RegExp(r"pw\.Positioned\(\s*top: 0, left: 0, right: 0,");
    if (quoteAnchorRegex.hasMatch(pdfContent)) {
        pdfContent = pdfContent.replaceAllMapped(quoteAnchorRegex, (match) {
            injectionCount++;
            // Insert watermark BEFORE the anchor
            return "$watermarkCode\n${match.group(0)}";
        });
    }

    // 2. Sale Layout Injection
    // Anchor: The background container.
    // Regex matches: pw.Container(color: slate50),
    final saleAnchorRegex = RegExp(r"pw\.Container\(color: slate50\),");
    if (saleAnchorRegex.hasMatch(pdfContent)) {
        pdfContent = pdfContent.replaceAllMapped(saleAnchorRegex, (match) {
            injectionCount++;
            // Insert watermark AFTER the anchor
            return "${match.group(0)}\n$watermarkCode";
        });
    }

    print('PDF Service: Watermark injected in $injectionCount places.');
    
    // Safety check
    if (injectionCount == 0) {
        print('WARNING: No watermark injection points found!');
    }
    
    pdfServiceFile.writeAsStringSync(pdfContent);

    // 4. Run Build
    print('Running Flutter Build...');
    
    // Force a clean build to ensure no stale artifacts
    if (Directory('build/web').existsSync()) {
      Directory('build/web').deleteSync(recursive: true);
    }
    
    final result = Process.runSync(
      'flutter.bat', 
      ['build', 'web', '--release', '--base-href', '/'], 
      runInShell: true,
    );
    
    if (result.stdout.toString().isNotEmpty) print(result.stdout);
    if (result.stderr.toString().isNotEmpty) print(result.stderr);

    if (result.exitCode != 0) {
      print('Build failed!');
      exit(result.exitCode);
    }

    // 5. Cache Busting & Renaming
    final webBuildDir = Directory('build/web');
    final demoDir = Directory('build/web_demo');
    
    // Add cache busting and fix base href to relative
    final indexHtml = File('${webBuildDir.path}/index.html');
    if (indexHtml.existsSync()) {
        String htmlContent = indexHtml.readAsStringSync();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Fix base href to be relative for portability
        htmlContent = htmlContent.replaceAll(
            '<base href="/">', '<base href="./">'
        );
        
        htmlContent = htmlContent.replaceAll(
            'main.dart.js', 'main.dart.js?v=$timestamp'
        ).replaceAll(
            'flutter_bootstrap.js', 'flutter_bootstrap.js?v=$timestamp'
        ).replaceAll(
            'styles.css', 'styles.css?v=$timestamp'
        );
        
        indexHtml.writeAsStringSync(htmlContent);
        print('Added cache busting and set base href to ./ in index.html');
    }

    if (demoDir.existsSync()) {
      print('Cleaning previous demo build...');
      demoDir.deleteSync(recursive: true);
    }
    
    if (webBuildDir.existsSync()) {
      print('Renaming build/web to build/web_demo...');
      webBuildDir.renameSync(demoDir.path);
    } else {
       print('Error: build/web not generated.');
       exit(1);
    }
    
    print('Demo build created at build/web_demo');

  } catch (e, stack) {
    print('Error during demo build process: $e');
    print(stack);
  } finally {
    // 6. Restore Files
    print('Restoring original files...');
    if (dashboardBackup.existsSync()) {
      dashboardBackup.copySync(dashboardFile.path);
      dashboardBackup.deleteSync();
    }
    if (pdfServiceBackup.existsSync()) {
      pdfServiceBackup.copySync(pdfServiceFile.path);
      pdfServiceBackup.deleteSync();
    }
    print('Files restored.');
  }
}
