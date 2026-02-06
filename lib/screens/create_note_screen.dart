import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import '../utils/localization.dart';
import '../utils/country_codes.dart';
import 'pdf_preview_screen.dart';

class CreateNoteScreen extends StatefulWidget {
  final Note? noteToEdit;
  final Client? clientToUse;
  final Note? templateNote;

  const CreateNoteScreen({super.key, this.noteToEdit, this.clientToUse, this.templateNote});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Client Details
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController(); 
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController(); 
  final _paymentMethodController = TextEditingController(); 
  
  // Date & Folio
  DateTime _selectedDate = DateTime.now();
  late String _folio; 
  String _noteType = 'COTIZACION'; // Default
  String _selectedCountryCode = '+52'; 

  // Check if we are editing
  bool get _isEditing => widget.noteToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadNoteData(widget.noteToEdit!);
    } else {
      _generateFolio();
      if (widget.clientToUse != null) {
        _clientNameController.text = widget.clientToUse!.name;
        _clientEmailController.text = widget.clientToUse!.email;
        _clientPhoneController.text = widget.clientToUse!.phone; 
        _selectedCountryCode = widget.clientToUse!.countryCode; 
        _clientAddressController.text = widget.clientToUse!.address;
      } else if (widget.templateNote != null) {
        // Create Sale from Quote Logic
        _loadTemplateData(widget.templateNote!);
      }
    }
  }

  void _loadTemplateData(Note note) {
    _clientNameController.text = note.clientName;
    _clientEmailController.text = note.clientEmail;
    // Extract country code if possible, simple logic
    // We assume the phone field contains the full string.
    // If we wanted to split it, we'd need robust logic. For now, just copy.
    // Actually, let's try to match existing logic if possible.
    // But since phone is stored as one string, we'll just put it in phone controller
    // and try to strip the country code if it matches our default?
    // Let's keep it simple: Copy visible fields.
    
    // Note: The phone field in UI is split "Code" + "Number". 
    // Stored `clientPhone` is "Code Number".
    final parts = note.clientPhone.split(' ');
    if (parts.length > 1) {
       _selectedCountryCode = parts[0];
       _clientPhoneController.text = note.clientPhone.substring(parts[0].length).trim();
    } else {
       _clientPhoneController.text = note.clientPhone;
    }

    _clientAddressController.text = note.clientAddress;
    _paymentMethodController.text = note.paymentMethod;
    
    _noteType = 'VENTA'; // Force to Sale
    _generateFolio(); // Generate NEW folio for the sale
    _items.addAll(note.items);
    _additionalNotesController.text = note.additionalNotes;
  }

  void _loadNoteData(Note note) {
    _clientNameController.text = note.clientName;
    _clientEmailController.text = note.clientEmail;
    // Simple parsing assumption: if phone starts with +something, try to extract. 
    // This is skipped for simplicity, we just put whole text in phone if we can't easily separate, 
    // OR we can assume we only stored the number part? 
    // Actually, in Client screen we store separated? No, Client model has separate `countryCode`. 
    // Note model does NOT have `countryCode` field, just `clientPhone`. 
    // So distinct storage is lost in Note unless we update Note model OR just parse string. 
    // Let's assume we populate `clientPhone` with full number in Note. 
    // We can try to match the prefix against `CountryCodes.list`.
    
    String fullPhone = note.clientPhone;
    String matchedCode = '+52';
    String numberPart = fullPhone;

    for (var c in CountryCodes.list) {
      if (fullPhone.startsWith(c.code)) {
        matchedCode = c.code;
        numberPart = fullPhone.substring(c.code.length).trim();
        break;
      }
    }
    
    _selectedCountryCode = matchedCode;
    _clientPhoneController.text = numberPart;
    _clientAddressController.text = note.clientAddress;
    _noteType = note.type;
    _selectedDate = note.date;
    _folio = note.folio;
    _addVat = note.addVat;
    _additionalNotesController.text = note.additionalNotes ?? '';
    _paymentMethodController.text = note.paymentMethod;
    // Load Items - Deep copy to avoid modifying original info until saved
    _items.addAll(note.items.map((item) => NoteItem(
      description: item.description,
      quantity: item.quantity,
      price: item.price
    )));
  }

  void _generateFolio() {
    setState(() {
       if (_noteType == 'VENTA') {
         _folio = NotesService().getNextSaleFolio();
       } else {
         _folio = NotesService().getNextQuoteFolio();
       }
    });
  }

  // Items - Empty by default
  final List<NoteItem> _items = [];

  // Logic
  bool _addVat = false; 
  final _additionalNotesController = TextEditingController();

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _vatAmount => _addVat ? _subtotal * 0.16 : 0.0;
  double get _total => _subtotal + _vatAmount;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _paymentMethodController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(NoteItem(description: "", price: 0, quantity: 1));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Explicit Draft Save
  void _saveDraft() {
     final note = Note(
        clientName: _clientNameController.text.isEmpty ? 'Borrador Sin Nombre' : _clientNameController.text,
        clientAddress: _clientAddressController.text,
        clientEmail: _clientEmailController.text,
        clientPhone: '$_selectedCountryCode ${_clientPhoneController.text.trim()}',
        type: _noteType,
        date: _selectedDate,
        items: List.from(_items),
        status: 'BORRADOR', 
        folio: _folio,
        addVat: _addVat,
        additionalNotes: _additionalNotesController.text,
        paymentMethod: _paymentMethodController.text,
      );
      
      if (_isEditing) {
        NotesService().updateNote(widget.noteToEdit!, note);
      } else {
        NotesService().addNote(note);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('draft_saved')), duration: const Duration(seconds: 1)),
      );
      
      Navigator.pop(context);
  }

  void _generateNote() {
    if (_formKey.currentState!.validate()) {
       if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('add_service_error'))),
        );
        return;
      }

      final note = Note(
        clientName: _clientNameController.text,
        clientAddress: _clientAddressController.text,
        clientEmail: _clientEmailController.text,
        clientPhone: '$_selectedCountryCode ${_clientPhoneController.text.trim()}',
        type: _noteType, 
        date: _selectedDate,
        items: List.from(_items),
        status: 'COMPLETADA', // Valid note logic
        folio: _folio,
        addVat: _addVat,
        additionalNotes: _additionalNotesController.text,
        paymentMethod: _paymentMethodController.text,
      );

      // Save as Completed
      if (_isEditing) {
        NotesService().updateNote(widget.noteToEdit!, note);
      } else {
        NotesService().addNote(note);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(note: note),
        ),
      ).then((_) {
        // Do nothing on return to prevent draft creation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colorSurface = theme.cardTheme.color;
    final colorInput = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final colorTextSec = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true, // Explicitly handle keyboard resizing
      // Sticky Header
      appBar: AppBar(
        title: Row(
          children: [
            Text('IMPERIO', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            Text('DEV', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -0.5)),
          ],
        ),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: colorTextSec,
          onPressed: () => Navigator.pop(context), // Normal pop
        ),
        actions: [
          // Save Draft Button
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_as_outlined, size: 18),
            label: Text(AppLocalizations.of(context).translate('save_draft')),
            style: TextButton.styleFrom(
              foregroundColor: colorTextSec,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120), // Increased bottom padding ensuring space over footer
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  Text(_isEditing ? AppLocalizations.of(context).translate('edit_note') : AppLocalizations.of(context).translate('create_note_button'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).translate('create_note_subtitle'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorTextSec),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Client
                  _SectionCard(
                    title: AppLocalizations.of(context).translate('section_client'),
                    icon: Icons.person,
                    children: [
                       // Note Type Selector
                       Row(
                         children: [
                           Expanded(
                             child: RadioListTile<String>(
                               title: Text(AppLocalizations.of(context).translate('note_type_quote'), style: const TextStyle(fontSize: 14)),
                               value: 'COTIZACION', 
                               groupValue: _noteType, 
                               onChanged: (v) {
                                  setState(() {
                                    _noteType = v!;
                                    if (!_isEditing) _generateFolio();
                                  });
                               },
                               contentPadding: EdgeInsets.zero,
                               activeColor: theme.colorScheme.primary,
                             ),
                           ),
                           Expanded(
                             child: RadioListTile<String>(
                               title: Text(AppLocalizations.of(context).translate('note_type_sale'), style: const TextStyle(fontSize: 14)),
                               value: 'VENTA', 
                               groupValue: _noteType, 
                               onChanged: (v) {
                                  setState(() {
                                    _noteType = v!;
                                    if (!_isEditing) _generateFolio();
                                  });
                               },
                               contentPadding: EdgeInsets.zero,
                               activeColor: theme.colorScheme.primary,
                             ),
                           ),
                         ],
                       ),
                       const Divider(),
                       const SizedBox(height: 12),

                      _Label(AppLocalizations.of(context).translate('client_name_hint')),
                      TextFormField(
                        controller: _clientNameController,
                        style: theme.textTheme.bodyMedium,
                        decoration: _inputDecoration(context, AppLocalizations.of(context).translate('hint_client_name')),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label(AppLocalizations.of(context).translate('label_date')),
                                InkWell(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: theme.textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label(AppLocalizations.of(context).translate('label_folio')),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _folio,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Phone and Email
                      // Phone and Email - Stacked for better mobile view
                      Column(
                        children: [
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 _Label(AppLocalizations.of(context).translate('label_phone')),
                                 Row(
                                   children: [
                                     Container(
                                      height: 50, // Fixed height to match TextField default
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCountryCode,
                                          menuMaxHeight: 300,
                                          items: CountryCodes.list.map((c) => DropdownMenuItem(
                                            value: c.code, 
                                            child: Text('${c.flag} ${c.code}', style: const TextStyle(fontSize: 14))
                                          )).toList(),
                                          onChanged: (val) {
                                             if (val != null) setState(() => _selectedCountryCode = val);
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _clientPhoneController,
                                        style: theme.textTheme.bodyMedium,
                                        keyboardType: TextInputType.phone,
                                        decoration: _inputDecoration(context, '123456...', icon: null).copyWith(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Increased padding
                                          border: OutlineInputBorder(
                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                   ],
                                 ),
                               ],
                             ),
                          const SizedBox(height: 16),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 _Label(AppLocalizations.of(context).translate('label_email')),
                                 TextFormField(
                                  controller: _clientEmailController,
                                  style: theme.textTheme.bodyMedium,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _inputDecoration(context, 'Email', icon: Icons.email).copyWith(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                ),
                               ],
                             ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _Label(AppLocalizations.of(context).translate('client_address')),
                       TextFormField(
                        controller: _clientAddressController,
                        style: theme.textTheme.bodyMedium,
                        decoration: _inputDecoration(context, 'Dirección', icon: Icons.location_on),
                      ),

                       if (_noteType == 'VENTA') ...[
                          const SizedBox(height: 16),
                          _Label(AppLocalizations.of(context).translate('label_payment_method')),
                          TextFormField(
                            controller: _paymentMethodController,
                            style: theme.textTheme.bodyMedium,
                            decoration: _inputDecoration(context, AppLocalizations.of(context).translate('hint_payment_method'), icon: Icons.payment),
                          ),
                        ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section 2: Services
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        _SectionTitle(AppLocalizations.of(context).translate('section_services'), Icons.layers, theme),
                        const SizedBox(height: 16),
                        if (_items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(AppLocalizations.of(context).translate('no_services_added'), style: TextStyle(color: Colors.grey[400])),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _items.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                            itemBuilder: (ctx, i) {
                              return _ItemCard(
                                key: ValueKey(_items[i]),
                                item: _items[i],
                                onDelete: () => _removeItem(i),
                                onUpdate: () => setState(() {}),
                                isDark: isDark,
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _addItem,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor, style: BorderStyle.solid), // Dashed border needs CustomPainter, solid is fine approx
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: colorTextSec),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context).translate('add_another_service'), style: TextStyle(color: colorTextSec, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: Summary
                  _SectionCard(
                    title: AppLocalizations.of(context).translate('section_summary'),
                    icon: Icons.receipt_long,
                    children: [
                      _SummaryRow(AppLocalizations.of(context).translate('subtotal'), _subtotal),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text('${AppLocalizations.of(context).translate('label_vat')} (16%)', style: TextStyle(color: colorTextSec, fontSize: 14)),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _addVat,
                                    onChanged: (v) => setState(() => _addVat = v!),
                                    activeColor: theme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ],
                            ),
                            Text('\$${_vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text(AppLocalizations.of(context).translate('total'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text('\$${_total.toStringAsFixed(2)}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                               const Text('MXN', style: TextStyle(fontSize: 12, color: Colors.grey)),
                             ],
                           ),
                        ],
                      ),
                    ],
                  ),

                   const SizedBox(height: 24),

                   // Additional Notes
                   _Label(AppLocalizations.of(context).translate('additional_notes')),
                   TextFormField(
                     controller: _additionalNotesController,
                     maxLines: 3,
                     decoration: _inputDecoration(context, AppLocalizations.of(context).translate('hint_additional')),
                   ),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16) + const EdgeInsets.only(bottom: 16), // Extra bottom padding safe area
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                // Removed border top
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _generateNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 18),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).translate('generate_send')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint, {IconData? icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorInput = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: colorInput,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title, icon, Theme.of(context)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final ThemeData theme;

  const _SectionTitle(this.text, this.icon, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  const _SummaryRow(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ItemCard extends StatefulWidget {
  final NoteItem item;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;
  final bool isDark;

  const _ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
    required this.isDark,
  });

  @override
  State<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<_ItemCard> {
  late TextEditingController _descCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.item.description);
    _qtyCtrl = TextEditingController(text: widget.item.quantity.toString());
    // Fix: Show empty string if price is 0 to show placeholder
    _priceCtrl = TextEditingController(text: widget.item.price == 0 ? '' : widget.item.price.toStringAsFixed(0));
  }
  
  void _update() {
    widget.item.description = _descCtrl.text;
    widget.item.quantity = int.tryParse(_qtyCtrl.text) ?? 1;
    widget.item.price = double.tryParse(_priceCtrl.text) ?? 0;
    widget.onUpdate();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorBg = widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final borderColor = Colors.transparent; 

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _descCtrl,
                  onChanged: (_) => _update(),
                  maxLines: 3, // Increased height
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).translate('hint_desc'),
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate('label_quantity'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(6)),
                      child: TextField(
                        controller: _qtyCtrl,
                        onChanged: (_) => _update(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).translate('label_unit_price'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(6)),
                       child: TextField(
                        controller: _priceCtrl,
                        onChanged: (_) => _update(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.attach_money, size: 14, color: Colors.grey),
                          prefixIconConstraints: BoxConstraints(minWidth: 24, maxHeight: 24),
                          hintText: '0', // Placeholder 0
                          border: InputBorder.none, 
                          isDense: true, 
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        ),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text('\$${widget.item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
