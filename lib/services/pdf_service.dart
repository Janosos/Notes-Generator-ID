import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

class PdfService {
  Future<Uint8List> generateNotePdf(Note note) async {
    final pdf = pw.Document();
    
    // Load custom font
    final font = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    
    // Exact Colors from design
    final primaryColor = PdfColor.fromInt(0xFF0D9488); // Teal
    final secondaryColor = PdfColor.fromInt(0xFF1E293B); // Dark Slate
    final textGrey = PdfColor.fromInt(0xFF64748B); // Slate-500
    final textDark = PdfColor.fromInt(0xFF1E293B); // Slate-800
    final bgLight = PdfColor.fromInt(0xFFF1F5F9); 

    // Calculate totals
    final subtotal = note.subtotal;
    final vat = note.vatAmount;
    final total = note.totalAmount;
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0), // Full bleed for the footer/header strips
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (context) {
          return pw.Stack(
            children: [
               // Top Strip
               pw.Positioned(
                 top: 0, 
                 left: 0, 
                 right: 0, 
                 child: pw.Container(height: 8, color: primaryColor)
               ),
               
               // Content Container
               pw.Padding(
                 padding: const pw.EdgeInsets.fromLTRB(40, 48, 40, 40),
                 child: pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                     // HEADER
                     pw.Row(
                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: [
                             pw.Text('COTIZACIÓN', style: pw.TextStyle(color: PdfColors.grey400, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                             pw.SizedBox(height: 4),
                             pw.Text(note.folio, style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                             pw.SizedBox(height: 2),
                             pw.Text(DateFormat('dd MMM, yyyy').format(note.date), style: pw.TextStyle(color: textGrey, fontSize: 10)),
                           ],
                         ),
                         pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.end,
                           children: [
                             pw.RichText(
                               text: pw.TextSpan(
                                 children: [
                                   pw.TextSpan(text: 'IMPERIO', style: pw.TextStyle(color: secondaryColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                                   pw.TextSpan(text: 'DEV', style: pw.TextStyle(color: primaryColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                                 ]
                               )
                             ),
                             pw.SizedBox(height: 2),
                             pw.Text('Transformando ideas en código\nHermosillo, México', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textGrey, fontSize: 9)),
                           ],
                         ),
                       ],
                     ),
                     
                     pw.SizedBox(height: 35),
                     
                     // PREPARED FOR
                     pw.Container(
                       padding: const pw.EdgeInsets.only(left: 12, top: 4, bottom: 4),
                       decoration: const pw.BoxDecoration(
                         border: pw.Border(left: pw.BorderSide(color: PdfColors.grey200, width: 4)),
                       ),
                       child: pw.Column(
                         crossAxisAlignment: pw.CrossAxisAlignment.start,
                         children: [
                           pw.Text('PREPARADO PARA', style: pw.TextStyle(color: PdfColors.grey400, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                           pw.SizedBox(height: 4),
                           pw.Text(note.clientName, style: pw.TextStyle(color: textDark, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                           if (note.clientAddress.isNotEmpty) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(note.clientAddress, style: pw.TextStyle(color: textGrey, fontSize: 10)),
                           ]
                         ],
                       ),
                     ),
                     
                     pw.SizedBox(height: 35),
                     
                     // TABLE HEADERS
                     pw.Container(
                       padding: const pw.EdgeInsets.only(bottom: 8),
                       decoration: const pw.BoxDecoration(
                         border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                       ),
                       child: pw.Row(
                         children: [
                           pw.Expanded(flex: 3, child: pw.Text('CONCEPTO', style: pw.TextStyle(color: textGrey, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                           pw.Expanded(flex: 1, child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textGrey, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                         ]
                       ),
                     ),
                     
                     // TABLE ITEMS
                     ...note.items.map((item) {
                       return pw.Container(
                         padding: const pw.EdgeInsets.symmetric(vertical: 12),
                         decoration: const pw.BoxDecoration(
                           border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100)),
                         ),
                         child: pw.Row(
                           children: [
                             pw.Expanded(
                               flex: 3, 
                               child: pw.Column(
                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                                 children: [
                                   pw.Text(item.description, style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                   pw.SizedBox(height: 2),
                                   pw.Text('Cantidad: ${item.quantity} | Unit: \$${item.price.toStringAsFixed(2)}', style: pw.TextStyle(color: textGrey, fontSize: 9)),
                                 ]
                               )
                             ),
                             pw.Expanded(
                               flex: 1, 
                               child: pw.Text('\$${item.total.toStringAsFixed(2)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold))
                             ),
                           ]
                         ),
                       );
                     }),
                     
                     pw.SizedBox(height: 20),
                     
                     // TOTALS SECTION
                     pw.Container(
                       padding: const pw.EdgeInsets.only(top: 16),
                       decoration: const pw.BoxDecoration(
                         border: pw.Border(top: pw.BorderSide(color: PdfColors.grey100, width: 2)),
                       ),
                       child: pw.Column(
                         children: [
                           pw.Row(
                             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                             children: [
                               pw.Text('Subtotal', style: pw.TextStyle(color: textGrey, fontSize: 10)),
                               pw.Text('\$${subtotal.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                             ]
                           ),
                           pw.SizedBox(height: 8),
                           pw.Row(
                             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                             children: [
                               pw.Text('IVA (16%)', style: pw.TextStyle(color: textGrey, fontSize: 10)),
                               pw.Text('\$${vat.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                             ]
                           ),
                           pw.SizedBox(height: 12),
                           pw.Container(
                             padding: const pw.EdgeInsets.all(12),
                             decoration: pw.BoxDecoration(
                               color: PdfColors.grey50, // Very light grey
                               borderRadius: pw.BorderRadius.circular(6),
                             ),
                             child: pw.Row(
                               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                               children: [
                                 pw.Text('Total (MXN)', style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                 pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(color: primaryColor, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                               ]
                             ),
                           ),
                         ]
                       ),
                     ),
                     
                     if (note.additionalNotes.isNotEmpty) ...[
                        pw.SizedBox(height: 20),
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey200),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('NOTAS ADICIONALES', style: pw.TextStyle(color: PdfColors.grey400, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 4),
                              pw.Text(note.additionalNotes, style: pw.TextStyle(color: textDark, fontSize: 10)),
                            ],
                          ),
                        ),
                     ],

                     pw.Spacer(),
                     
                     // Footer Note
                     pw.Center(
                       child: pw.Text(
                         'Esta cotización es válida por 15 días. Gracias por confiar en ImperioDev.',
                         style: pw.TextStyle(color: PdfColors.grey400, fontSize: 8, fontStyle: pw.FontStyle.italic)
                       )
                     ),
                   ],
                 ),
               ),
               
               // Bottom Colorful Strip
               pw.Positioned(
                 bottom: 0,
                 left: 0,
                 right: 0,
                 child: pw.Row(
                   children: [
                     pw.Expanded(child: pw.Container(height: 8, color: PdfColor.fromInt(0x330D9488))), // 20%
                     pw.Expanded(child: pw.Container(height: 8, color: PdfColor.fromInt(0x660D9488))), // 40%
                     pw.Expanded(child: pw.Container(height: 8, color: PdfColor.fromInt(0x990D9488))), // 60%
                     pw.Expanded(child: pw.Container(height: 8, color: primaryColor)),
                   ]
                 )
               ),
            ]
          );
        },
      ),
    );

    return pdf.save();
  }
}
