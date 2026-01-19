import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';
import '../services/pdf_service.dart';
import '../utils/localization.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Note note;

  const PdfPreviewScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return PopScope(
      canPop: false, // Prevent back navigation
      onPopInvoked: (didPop) {
        // Do nothing, force user to use the home button or other actions
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
      // Custom Nav
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('preview_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
        elevation: 0,
          leading: IconButton(
            icon: CircleAvatar(
               backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
               child: const Icon(Icons.home, size: 18, color: Colors.grey),
            ),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        actions: const [],
      ),
      body: Column(
        children: [
          // Preview Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16), // Rounded container for the preview
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: PdfPreview(
                build: (format) => PdfService().generateNotePdf(note, AppLocalizations.of(context).locale.languageCode),
                canDebug: false,
                useActions: false, // Turn off default actions to use our custom bottom bar
                scrollViewDecoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor, // Match bg
                ),
                pdfPreviewPageDecoration: const BoxDecoration(
                   color: Colors.white,
                   boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ), // White paper look
              ),
            ),
          ),
          
          Text(AppLocalizations.of(context).translate('preview_subtitle'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                           // Trigger native share of the PDF using Share Plus
                           final bytes = await PdfService().generateNotePdf(note, AppLocalizations.of(context).locale.languageCode);
                           final tempDir = await getTemporaryDirectory();
                           // Clean filename
                           String safeFolio = note.folio.replaceAll(RegExp(r'[^\w\s-]'), '');
                           final loc = AppLocalizations.of(context);
                           String prefix = note.type == 'VENTA' ? loc.translate('filename_sale') : loc.translate('filename_quote');
                           
                           final file = File('${tempDir.path}/${prefix}_$safeFolio.pdf');
                           await file.writeAsBytes(bytes);
                           
                           // Construct Message
                           final greeting = loc.translate('share_msg_greeting');
                           final typeName = note.type == 'VENTA' ? loc.translate('note_type_sale') : loc.translate('note_type_quote');
                           String body = loc.translate('share_msg_body');
                           body = body.replaceFirst('%s', typeName);
                           body = body.replaceFirst('%s', note.folio);
                           body = body.replaceFirst('%s', '\$${note.totalAmount.toStringAsFixed(2)}');
                           
                           final fullMessage = '$greeting ${note.clientName},\n$body';
                           
                           await Share.shareXFiles([XFile(file.path)], text: fullMessage);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.share, size: 20),
                        label: Text(AppLocalizations.of(context).translate('share_file')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    // Trigger print/save
                    final bytes = await PdfService().generateNotePdf(note, AppLocalizations.of(context).locale.languageCode);
                    
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                      // Desktop: "Save As" dialog
                      final fileName = XTypeGroup(label: 'PDF', extensions: ['pdf']);
                      final loc = AppLocalizations.of(context);
                      String prefix = note.type == 'VENTA' ? loc.translate('filename_sale') : loc.translate('filename_quote');
                      
                      final FileSaveLocation? result = await getSaveLocation(suggestedName: '${prefix}_${note.folio}.pdf', acceptedTypeGroups: [fileName]);
                      
                      if (result != null) {
                         final file = File(result.path);
                         await file.writeAsBytes(bytes);
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).translate('saved_to')} ${result.path}')));
                         }
                      }
                    } else {
                       // Mobile: Native Print/Share sheet which allows saving
                       await Printing.layoutPdf(onLayout: (_) => bytes);
                    }
                  },
                  icon: const Icon(Icons.download, size: 20, color: Colors.grey),
                  label: Text(AppLocalizations.of(context).translate('save_device'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
