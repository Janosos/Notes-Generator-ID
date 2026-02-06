import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

class PdfService {
  Future<Uint8List> generateNotePdf(Note note, String languageCode) async {
    final pdf = pw.Document();
    
    // Load custom fonts
    final font = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    // Load Material Icons for the new design
    final iconFont = await PdfGoogleFonts.materialIcons();

    final isEn = languageCode == 'en';
    
    if (note.type == 'VENTA') {
      _buildSaleNoteLayout(pdf, note, font, fontBold, iconFont, isEn);
    } else {
      _buildQuoteLayout(pdf, note, font, fontBold, iconFont, isEn);
    }

    return pdf.save();
  }

  void _buildQuoteLayout(pw.Document pdf, Note note, pw.Font font, pw.Font fontBold, pw.Font iconFont, bool isEn) {
    // ... [Existing Quote Logic - Kept distinct] ...
    final labels = {
      'quote': isEn ? 'QUOTE' : 'COTIZACIÓN',
      'prepared_for': isEn ? 'PREPARED FOR' : 'PREPARADO PARA',
      'concept': isEn ? 'CONCEPT' : 'CONCEPTO',
      'total_header': isEn ? 'TOTAL' : 'TOTAL',
      'quantity': isEn ? 'Quantity' : 'Cantidad',
      'unit': isEn ? 'Unit' : 'Unitario',
      'subtotal': isEn ? 'Subtotal' : 'Subtotal',
      'vat': isEn ? 'VAT (16%)' : 'IVA (16%)',
      'total': isEn ? 'Total (MXN)' : 'Total (MXN)',
      'additional_notes': isEn ? 'ADDITIONAL NOTES' : 'NOTAS ADICIONALES',
      'footer': isEn 
          ? 'This document is valid for 15 days. Thank you for trusting ImperioDev.'
          : 'Este documento es válido por 15 días. Gracias por confiar en ImperioDev.',
      'slogan': isEn ? 'Transforming ideas into code\nHermosillo, Mexico' : 'Transformando ideas en código\nHermosillo, México',
    };

    final primaryColor = PdfColor.fromInt(0xFF0D9488); // Teal
    final secondaryColor = PdfColor.fromInt(0xFF1E293B); // Dark Slate
    final textGrey = PdfColor.fromInt(0xFF64748B); // Slate-500
    final textDark = PdfColor.fromInt(0xFF1E293B); // Slate-800

    final subtotal = note.subtotal;
    final vat = note.vatAmount;
    final total = note.totalAmount;
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          icons: iconFont,
        ),
        build: (context) {
          return pw.Stack(
            children: [
              pw.Positioned(
                  top: 0, left: 0, right: 0, 
                  child: pw.Container(height: 8, color: primaryColor)
                ),
               pw.Padding(
                 padding: const pw.EdgeInsets.fromLTRB(40, 48, 40, 40),
                 child: pw.Column(
                   crossAxisAlignment: pw.CrossAxisAlignment.start,
                   children: [
                     pw.Row(
                       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                       crossAxisAlignment: pw.CrossAxisAlignment.start,
                       children: [
                         pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.start,
                           children: [
                             pw.Text(labels['quote']!, style: pw.TextStyle(color: PdfColors.grey400, fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
                             pw.SizedBox(height: 4),
                             pw.Text(note.folio, style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                             pw.SizedBox(height: 2),
                             pw.Text(DateFormat('dd MMM, yyyy', isEn ? 'en_US' : 'es_MX').format(note.date), style: pw.TextStyle(color: textGrey, fontSize: 10)),
                           ],
                         ),
                         pw.Column(
                           crossAxisAlignment: pw.CrossAxisAlignment.end,
                           children: [
                             pw.RichText(
                               text: pw.TextSpan(children: [
                                   pw.TextSpan(text: 'IMPERIO', style: pw.TextStyle(color: secondaryColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                                   pw.TextSpan(text: 'DEV', style: pw.TextStyle(color: primaryColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                               ])
                             ),
                             pw.SizedBox(height: 2),
                             pw.Text(labels['slogan']!, textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textGrey, fontSize: 9)),
                           ],
                         ),
                       ],
                     ),
                     pw.SizedBox(height: 35),
                     pw.Container(
                       padding: const pw.EdgeInsets.only(left: 12, top: 4, bottom: 4),
                       decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: PdfColors.grey200, width: 4))),
                       child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                           pw.Text(labels['prepared_for']!, style: pw.TextStyle(color: PdfColors.grey400, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                           pw.SizedBox(height: 4),
                           pw.Text(note.clientName, style: pw.TextStyle(color: textDark, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                           if (note.clientAddress.isNotEmpty) ...[
                              pw.SizedBox(height: 2), 
                              pw.Row(children: [
                                pw.Icon(pw.IconData(0xe0c8), color: textGrey, size: 10), // location_on
                                pw.SizedBox(width: 4),
                                pw.Text(note.clientAddress, style: pw.TextStyle(color: textGrey, fontSize: 10))
                              ])
                           ],
                           if (note.clientPhone.isNotEmpty) ...[
                              pw.SizedBox(height: 2), 
                              pw.Row(children: [
                                pw.Icon(pw.IconData(0xe0b0), color: textGrey, size: 10), // phone
                                pw.SizedBox(width: 4),
                                pw.Text(note.clientPhone, style: pw.TextStyle(color: textGrey, fontSize: 10))
                              ])
                           ],
                           if (note.clientEmail.isNotEmpty) ...[
                              pw.SizedBox(height: 2),
                              pw.Row(children: [
                                pw.Icon(pw.IconData(0xe158), color: textGrey, size: 10), // email
                                pw.SizedBox(width: 4),
                                pw.Text(note.clientEmail, style: pw.TextStyle(color: textGrey, fontSize: 10))
                              ])
                           ],
                       ]),
                     ),
                     pw.SizedBox(height: 35),
                     pw.Container(
                       padding: const pw.EdgeInsets.only(bottom: 8),
                       decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                       child: pw.Row(children: [
                           pw.Expanded(flex: 3, child: pw.Text(labels['concept']!, style: pw.TextStyle(color: textGrey, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                           pw.Expanded(flex: 1, child: pw.Text(labels['total_header']!, textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textGrey, fontSize: 9, fontWeight: pw.FontWeight.bold))),
                       ]),
                     ),
                     ...note.items.map((item) {
                       return pw.Container(
                         padding: const pw.EdgeInsets.symmetric(vertical: 12),
                         decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100))),
                         child: pw.Row(children: [
                             pw.Expanded(flex: 3, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                                   pw.Text(item.description, style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                   pw.SizedBox(height: 2),
                                   pw.Text('${labels['quantity']}: ${item.quantity} | ${labels['unit']}: \$${item.price.toStringAsFixed(2)} MXN', style: pw.TextStyle(color: textGrey, fontSize: 9)),
                             ])),
                             pw.Expanded(flex: 1, child: pw.Text('\$${item.total.toStringAsFixed(2)} MXN', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold))),
                         ]),
                       );
                     }),
                     pw.SizedBox(height: 20),
                     pw.Container(
                       padding: const pw.EdgeInsets.only(top: 16),
                       decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey100, width: 2))),
                       child: pw.Column(children: [
                           pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(labels['subtotal']!, style: pw.TextStyle(color: textGrey, fontSize: 10)), pw.Text('\$${subtotal.toStringAsFixed(2)} MXN', style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold))]),
                           pw.SizedBox(height: 8),
                           pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(labels['vat']!, style: pw.TextStyle(color: textGrey, fontSize: 10)), pw.Text('\$${vat.toStringAsFixed(2)} MXN', style: pw.TextStyle(color: textDark, fontSize: 11, fontWeight: pw.FontWeight.bold))]),
                           pw.SizedBox(height: 12),
                           pw.Container(
                             padding: const pw.EdgeInsets.all(12),
                             decoration: pw.BoxDecoration(color: PdfColors.grey50, borderRadius: pw.BorderRadius.circular(6)),
                             child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(labels['total']!, style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)), pw.Text('\$${total.toStringAsFixed(2)} MXN', style: pw.TextStyle(color: primaryColor, fontSize: 16, fontWeight: pw.FontWeight.bold))]),
                           ),
                       ]),
                     ),
                     if (note.additionalNotes.isNotEmpty) ...[
                        pw.SizedBox(height: 20),
                        pw.Container(width: double.infinity, padding: const pw.EdgeInsets.all(12), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey200), borderRadius: pw.BorderRadius.circular(6)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(labels['additional_notes']!, style: pw.TextStyle(color: PdfColors.grey400, fontSize: 8, fontWeight: pw.FontWeight.bold)), pw.SizedBox(height: 4), pw.Text(note.additionalNotes, style: pw.TextStyle(color: textDark, fontSize: 10))])),
                     ],
                     pw.Spacer(),
                     pw.Center(child: pw.Text(labels['footer']!, style: pw.TextStyle(color: PdfColors.grey400, fontSize: 8, fontStyle: pw.FontStyle.italic))),
                     pw.Container(height: 8, color: primaryColor) // Bottom strip simplified for brevity in this view
                   ],
                 ),
               ),
            ]
          );
        },
      ),
    );
  }

  void _buildSaleNoteLayout(pw.Document pdf, Note note, pw.Font font, pw.Font fontBold, pw.Font iconFont, bool isEn) {
    // Labels
    final labels = {
      'sale_note': isEn ? 'SALES NOTE' : 'NOTA DE VENTA',
      'folio': 'Folio:',
      'date': isEn ? 'Date:' : 'Fecha:',
      'prepared_for': isEn ? 'PREPARED FOR:' : 'PREPARADO PARA:',
      'issued_by': isEn ? 'ISSUED BY:' : 'EMITIDO POR:',
      'concept': isEn ? 'CONCEPT' : 'CONCEPTO',
      'qty': isEn ? 'QTY' : 'CANT.',
      'total_col': isEn ? 'TOTAL' : 'TOTAL',
      'subtotal': 'Subtotal',
      'vat': isEn ? 'VAT (16%)' : 'IVA (16%)',
      'total_pay': isEn ? 'TOTAL (MXN)' : 'TOTAL (MXN)',
      'notes': isEn ? 'ADDITIONAL NOTES' : 'NOTAS ADICIONALES',
      'slogan': isEn ? 'Transforming ideas into code' : 'Transformando ideas en código',
      'location': isEn ? 'Hermosillo, Mexico' : 'Hermosillo, México',
      'website': 'imperiodev.com',
      'payment_method': isEn ? 'Payment Method' : 'Método de Pago',
      'footer_copy': isEn 
          ? '© 2026 ImperioDev. All rights reserved. Hermosillo, Sonora, Mexico.'
          : '© 2026 ImperioDev. Todos los derechos reservados. Hermosillo, Sonora, México.',
      'unit': isEn ? 'Unit' : 'Unit',
    };

    // Colors
    final primaryColor = PdfColor.fromInt(0xFF0D9488); // Teal-600 (Matches App Theme)
    final slate900 = PdfColor.fromInt(0xFF0F172A);
    final slate800 = PdfColor.fromInt(0xFF1E293B);
    final slate600 = PdfColor.fromInt(0xFF475569);
    final slate500 = PdfColor.fromInt(0xFF64748B);
    final slate400 = PdfColor.fromInt(0xFF94A3B8); 
    final slate100 = PdfColor.fromInt(0xFFF1F5F9); 
    final slate50  = PdfColor.fromInt(0xFFF8FAFC); 
    
    final emeraldTexto = PdfColor.fromInt(0xFF34D399); 

    // Calculations
    final subtotal = note.subtotal;
    final vat = note.vatAmount;
    final total = note.totalAmount;
    
    // Date Locale
    final dateLocale = isEn ? 'en_US' : 'es_MX';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          icons: iconFont,
        ),
        build: (context) {
          return pw.Stack(
            children: [
              // Background
              pw.Container(color: slate50),


              
              pw.Column(
                children: [
                  // --- HEADER (Dark) ---
                  pw.Container(
                    color: slate900,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left: Title + Folio + Date
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(labels['sale_note']!, style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 12),
                            // Folio
                            pw.Row(
                              children: [
                                pw.Text('#', style: pw.TextStyle(color: primaryColor, fontSize: 12, fontWeight: pw.FontWeight.bold)), 
                                pw.SizedBox(width: 6),
                                pw.Text('${labels['folio']} ', style: pw.TextStyle(color: slate400, fontSize: 10)),
                                pw.Text(note.folio, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, font: font, fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            // Date
                            pw.Row(
                              children: [
                                pw.Icon(pw.IconData(0xe916), color: primaryColor, size: 12), // date_range
                                pw.SizedBox(width: 6),
                                pw.Text('${labels['date']} ', style: pw.TextStyle(color: slate400, fontSize: 10)),
                                pw.Text(DateFormat('dd MMM, yyyy', dateLocale).format(note.date), style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),

                        // Right: Status + Branding
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            // Status Pill
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF064E3B), 
                                borderRadius: pw.BorderRadius.circular(12),
                                border: pw.Border.all(color: PdfColor.fromInt(0xFF065F46))
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Icon(pw.IconData(0xe86c), color: emeraldTexto, size: 10), 
                                  pw.SizedBox(width: 4),
                                  pw.Text(
                                    (note.status == 'COMPLETADA' 
                                        ? (isEn ? 'COMPLETED' : 'COMPLETADA') 
                                        : (isEn ? 'DRAFT' : 'BORRADOR')).toUpperCase(),
                                    style: pw.TextStyle(color: emeraldTexto, fontSize: 9, fontWeight: pw.FontWeight.bold)
                                  ),
                                ]
                              )
                            ),
                            pw.SizedBox(height: 16),
                            // Branding
                            pw.RichText(
                               text: pw.TextSpan(children: [
                                   pw.TextSpan(text: 'IMPERIO', style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                                   pw.TextSpan(text: 'DEV', style: pw.TextStyle(color: primaryColor, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                               ])
                             ),
                            pw.Text(labels['slogan']!.toUpperCase(), style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold, letterSpacing: 1)),
                          ]
                        ),
                      ]
                    )
                  ),

                  // --- BODY ---
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Column(
                      children: [
                        // Addresses Grid
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                             // Client
                             pw.Expanded(
                               child: pw.Column(
                                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                                 children: [
                                   pw.Text(labels['prepared_for']!.toUpperCase(), style: pw.TextStyle(color: slate400, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                   pw.SizedBox(height: 8),
                                   pw.Text(note.clientName, style: pw.TextStyle(color: slate800, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                                   if (note.clientAddress.isNotEmpty) ...[
                                      pw.SizedBox(height: 4),
                                      pw.Row(children: [
                                        pw.Icon(pw.IconData(0xe0c8), color: slate500, size: 11), // location_on
                                        pw.SizedBox(width: 4),
                                        pw.Text(note.clientAddress, style: pw.TextStyle(color: slate600, fontSize: 10))
                                      ]),
                                   ],
                                   if (note.clientPhone.split(' ').length > 1 && note.clientPhone.split(' ')[1].isNotEmpty) ...[
                                      pw.SizedBox(height: 4),
                                      pw.Row(children: [
                                        pw.Icon(pw.IconData(0xe0b0), color: slate500, size: 11), // phone
                                        pw.SizedBox(width: 4),
                                        pw.Text(note.clientPhone, style: pw.TextStyle(color: slate600, fontSize: 10))
                                      ]),
                                   ],
                                   if (note.clientEmail.isNotEmpty) ...[
                                      pw.SizedBox(height: 4),
                                      pw.Row(children: [
                                        pw.Icon(pw.IconData(0xe158), color: slate500, size: 11), // email
                                        pw.SizedBox(width: 4),
                                        pw.Text(note.clientEmail, style: pw.TextStyle(color: slate600, fontSize: 10))
                                      ]),
                                   ]
                                 ]
                               )
                             ),
                             
                             // Issuer
                             pw.Expanded(
                               child: pw.Column(
                                 crossAxisAlignment: pw.CrossAxisAlignment.end, // Right align
                                 children: [
                                   pw.Text(labels['issued_by']!.toUpperCase(), style: pw.TextStyle(color: slate400, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                                   pw.SizedBox(height: 8),
                                   pw.Text('ImperioDev', style: pw.TextStyle(color: slate800, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                   pw.SizedBox(height: 4),
                                   pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Icon(pw.IconData(0xe0c8), color: slate500, size: 11),
                                        pw.SizedBox(width: 4),
                                        pw.Text(labels['location']!, style: pw.TextStyle(color: slate600, fontSize: 10))
                                      ]
                                   ),
                                   pw.SizedBox(height: 4),
                                   pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.end,
                                      children: [
                                        pw.Icon(pw.IconData(0xe894), color: slate500, size: 11), // language
                                        pw.SizedBox(width: 4),
                                        pw.UrlLink(
                                          child: pw.Text(labels['website']!, style: pw.TextStyle(color: slate600, fontSize: 10, decoration: pw.TextDecoration.underline)),
                                          destination: 'https://www.imperiodev.com/',
                                        )
                                      ]
                                   ),
                                 ]
                               )
                             ),
                          ]
                        ),

                        pw.SizedBox(height: 40),

                        // --- TABLE ---
                        pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 20),
                          child: pw.Table(
                            border: null,
                            columnWidths: {
                              0: const pw.FlexColumnWidth(4),
                              1: const pw.FlexColumnWidth(1),
                              2: const pw.FlexColumnWidth(1.5),
                            },
                            children: [
                              // Header
                              pw.TableRow(
                                decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: slate100, width: 2))),
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 12),
                                    child: pw.Text(labels['concept']!, style: pw.TextStyle(color: slate800, fontSize: 10, fontWeight: pw.FontWeight.bold))
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 12),
                                    child: pw.Text(labels['qty']!, textAlign: pw.TextAlign.center, style: pw.TextStyle(color: slate800, fontSize: 10, fontWeight: pw.FontWeight.bold))
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 12),
                                    child: pw.Text(labels['total_col']!, textAlign: pw.TextAlign.right, style: pw.TextStyle(color: slate800, fontSize: 10, fontWeight: pw.FontWeight.bold))
                                  ),
                                ]
                              ),
                              
                              // Rows
                              ...note.items.map((item) {
                                return pw.TableRow(
                                  decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: slate50))),
                                  children: [
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 12),
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(item.description, style: pw.TextStyle(color: slate800, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                          pw.SizedBox(height: 4),
                                          pw.Text('${labels['unit']}: \$${item.price.toStringAsFixed(2)} MXN', style: pw.TextStyle(color: primaryColor, fontSize: 9, fontStyle: pw.FontStyle.italic)),
                                        ]
                                      )
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 12),
                                      child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: pw.TextStyle(color: slate600, fontSize: 10))
                                    ),
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.symmetric(vertical: 12),
                                      child: pw.Text('\$${item.total.toStringAsFixed(2)} MXN', textAlign: pw.TextAlign.right, style: pw.TextStyle(color: slate800, fontSize: 11, fontWeight: pw.FontWeight.bold))
                                    ),
                                  ]
                                );
                              }).toList()
                            ]
                          )
                        ),

                        // --- FOOTER SECTION (Notes + Totals) ---
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Left Box (Payment + Notes)
                            pw.Expanded(
                              flex: 2,
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(16),
                                decoration: pw.BoxDecoration(
                                  color: slate50,
                                  borderRadius: pw.BorderRadius.circular(8),
                                  border: pw.Border.all(color: slate100)
                                ),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(labels['payment_method']!.toUpperCase(), style: pw.TextStyle(color: slate400, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 4),
                                    pw.Row(
                                      children: [
                                        pw.Container(width: 6, height: 6, decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle)),
                                        pw.SizedBox(width: 6),
                                        pw.Text(
                                          note.paymentMethod.isNotEmpty 
                                            ? note.paymentMethod 
                                            : (isEn ? 'Not specified' : 'No especificado'), 
                                          style: pw.TextStyle(color: slate600, fontSize: 10, fontWeight: pw.FontWeight.bold)
                                        ),
                                      ]
                                    ),
                                    pw.SizedBox(height: 12),
                                    if (note.additionalNotes.isNotEmpty) ...[
                                      pw.Text(labels['notes']!, style: pw.TextStyle(color: slate400, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 2),
                                      pw.Text(note.additionalNotes, style: pw.TextStyle(color: slate600, fontSize: 9, fontStyle: pw.FontStyle.italic)),
                                    ]
                                  ]
                                )
                              )
                            ),
                            
                            pw.SizedBox(width: 30),

                            // Right Box (Totals)
                            pw.Expanded(
                              flex: 2,
                              child: pw.Column(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(labels['subtotal']!, style: pw.TextStyle(color: slate500, fontSize: 10)),
                                        pw.Text('\$${subtotal.toStringAsFixed(2)}', style: pw.TextStyle(color: slate500, fontSize: 10)),
                                      ]
                                    )
                                  ),
                                  if (note.addVat)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(labels['vat']!, style: pw.TextStyle(color: slate500, fontSize: 10)),
                                        pw.Text('\$${vat.toStringAsFixed(2)}', style: pw.TextStyle(color: slate500, fontSize: 10)),
                                      ]
                                    )
                                  ),
                                  pw.SizedBox(height: 8),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.all(12),
                                    decoration: pw.BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: pw.BorderRadius.circular(6),
                                      boxShadow: const [pw.BoxShadow(blurRadius: 2, color: PdfColors.grey200)]
                                    ),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(labels['total_pay']!, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                        pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                                      ]
                                    )
                                  ),
                                ]
                              )
                            )

                          ]
                        ),
                      ]
                    )
                  ),

                  pw.Spacer(),

                  // --- BOTTOM FOOTER ---
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: slate50,
                      border: pw.Border(top: pw.BorderSide(color: slate100))
                    ),
                    child: pw.Text(labels['footer_copy']!, textAlign: pw.TextAlign.center, style: pw.TextStyle(color: slate400, fontSize: 8))
                  )
                ],
              ),
            ]
          );
        },
      ),
    );
  }
}
