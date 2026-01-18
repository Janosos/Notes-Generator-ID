import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note_model.dart';
import '../services/pdf_service.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Note note;

  const PdfPreviewScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Custom Nav
      appBar: AppBar(
        title: const Text('Vista Previa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
             backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
             child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
               icon: CircleAvatar(
                 backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                 child: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
               ),
              onPressed: () {
                // Edit logic
                Navigator.pop(context);
              },
            ),
          ),
        ],
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
                build: (format) => PdfService().generateNotePdf(note),
                canDebug: false,
                useActions: false, // Turn off default actions to use our custom bottom bar
                scrollViewDecoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor, // Match bg
                ),
                pdfPreviewPageDecoration: BoxDecoration(
                   color: Colors.white,
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ), // White paper look
              ),
            ),
          ),
          
          const Text('Vista previa del documento PDF', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                           // Trigger native share of the PDF
                           final bytes = await PdfService().generateNotePdf(note);
                           await Printing.sharePdf(bytes: bytes, filename: 'cotizacion.pdf');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text('Compartir'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Allow sending a message to a number or just generic share
                          // Assuming clientAddress field might contain a number if we parsed it, 
                          // but for now let's just create a generic link or try to use the one from contact field specific
                          
                          // Simplified: Try to open specific number if it looks like one, or just open WA
                          // Note: In real app, we need to clean the number.
                          String phone = ''; 
                          // Minimal effort parsing for demo:
                          if (note.clientAddress.contains(RegExp(r'\d'))) {
                             phone = note.clientAddress.replaceAll(RegExp(r'[^\d]'), '');
                          }
                          
                          final text = Uri.encodeComponent("Hola ${note.clientName}, aquí te comparto la cotización ${note.folio}.\n\nTotal: \$${note.totalAmount.toStringAsFixed(2)}");
                          final url = Uri.parse("https://wa.me/$phone?text=$text");
                          
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            // Fallback or error snackbar (not implemented here)
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.send, size: 20),
                        label: const Text('WhatsApp'), // Shortened for space
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    // Trigger print/save
                    final bytes = await PdfService().generateNotePdf(note);
                    await Printing.layoutPdf(onLayout: (_) => bytes);
                  },
                  icon: const Icon(Icons.download, size: 20, color: Colors.grey),
                  label: const Text('Guardar en dispositivo', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
