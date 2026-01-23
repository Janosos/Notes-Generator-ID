import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'create_note_screen.dart';
import 'pdf_preview_screen.dart';
import '../utils/localization.dart';

class NotesListScreen extends StatefulWidget {
  final String? filterClientName;
  const NotesListScreen({super.key, this.filterClientName});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final Set<Note> _selectedNotes = {};
  bool _isSelectionMode = false;

  void _toggleSelection(Note note) {
    setState(() {
      if (_selectedNotes.contains(note)) {
        _selectedNotes.remove(note);
        if (_selectedNotes.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNotes.add(note);
        _isSelectionMode = true;
      }
    });
  }

  void _selectAll() {
    final allNotes = NotesService().notes; // Access source of truth
    final notes = widget.filterClientName != null 
              ? allNotes.where((n) => n.clientName.toLowerCase() == widget.filterClientName!.toLowerCase()).toList()
              : allNotes;
              
    setState(() {
      if (_selectedNotes.length == notes.length) {
        _selectedNotes.clear();
        _isSelectionMode = false;
      } else {
        _selectedNotes.clear();
        _selectedNotes.addAll(notes);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedNotes.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('delete_notes_title')),
        content: Text(AppLocalizations.of(context).translate('delete_notes_msg').replaceAll('%s', _selectedNotes.length.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              NotesService().deleteNotes(_selectedNotes.toList());
              setState(() {
                _selectedNotes.clear();
                _isSelectionMode = false;
              });
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).translate('delete_note')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isSelectionMode ? AppLocalizations.of(context).translate('selected_count').replaceAll('%s', _selectedNotes.length.toString()) : AppLocalizations.of(context).translate('my_notes'),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
             // Select All / Deselect All
             ValueListenableBuilder<List<Note>>(
               valueListenable: NotesService().notesNotifier,
               builder: (context, allNotes, _) {
                  // Filter visible notes to select ONLY visible ones if filtered? 
                  // For simplicity, select visible if filtered, or all if not.
                  // Need access to current filtered list... difficult in AppBar directly without moving filter logic up.
                  // Alternative: TextButton "Todas"
                  
                  // Let's rely on the body Builder's list for logic, but UI here. 
                  // Simpler: Just a checkmark icon to Select All, or clear if full.
                  
                  return IconButton(
                    icon: Icon(_selectedNotes.length == (widget.filterClientName != null ? 0 /* Too complex to check count here cheaply */ : allNotes.length) ? Icons.done_all : Icons.select_all),
                    tooltip: AppLocalizations.of(context).translate('tooltip_select_all'),
                    onPressed: () {
                      // We need the filtered list to select all pertinent notes.
                      // Since we can't easily access the filtered list here without refactoring, 
                      // we'll trigger a selection update via a method or use passed list logic.
                      // Refactoring logic to helper method `_selectAll`.
                      _selectAll();
                    },
                  );
               }
             ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteSelected,
            )
          ]
          else
            IconButton(
              icon: const Icon(Icons.checklist_rtl),
              onPressed: () {
                // Toggle selection mode without selecting anything yet
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                  _selectedNotes.clear();
                });
              },
              tooltip: AppLocalizations.of(context).translate('tooltip_select'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<Note>>(
        valueListenable: NotesService().notesNotifier,
        builder: (context, allNotes, _) {
          // Apply filter if exists
          final notes = widget.filterClientName != null 
              ? allNotes.where((n) => n.clientName.toLowerCase() == widget.filterClientName!.toLowerCase()).toList()
              : allNotes;

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   Text(
                    widget.filterClientName != null 
                      ? 'No hay notas para este cliente'
                      : AppLocalizations.of(context).translate('no_notes'),
                    style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final note = notes[i];
              final isSelected = _selectedNotes.contains(note);
              
              return GestureDetector(
                onLongPress: () => _toggleSelection(note),
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(note);
                  } else {
                     // Navigate to details/edit if needed, for now just create new
                  }
                },
                child: _NoteListCard(
                  note: note, 
                  isSelected: isSelected, 
                  isSelectionMode: _isSelectionMode,
                  onSelect: (v) => _toggleSelection(note),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NoteListCard extends StatelessWidget {
  final Note note;
  final bool isSelected;
  final bool isSelectionMode;
  final Function(bool?) onSelect;

  const _NoteListCard({
    required this.note,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    // Status Logic
    String statusText = note.status;
    Color statusColor = Colors.teal;
    Color statusBg = Colors.teal.withOpacity(0.1);
    
    // Match the dark badge style from image specifically for 'BORRADOR'
    if (note.status == 'BORRADOR') {
      statusText = loc.translate('status_draft');
      statusColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
      statusBg = isDark ? const Color(0xFF1e293b) : Colors.grey.shade200; 
    } else if (note.status == 'COMPLETADA') {
      statusText = loc.translate('status_completed');
      statusColor = Colors.blue; 
      statusBg = Colors.blue.withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.1), width: isSelected ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onSelect(null),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onSelect,
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.clientName.isEmpty ? 'Sin Cliente' : note.clientName,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: statusBg,
                             borderRadius: BorderRadius.circular(6),
                           ),
                           child: Text(
                             statusText,
                             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                           ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(note.folio, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd/MM/yyyy').format(note.date), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        const SizedBox(width: 8),
                        // Type Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: note.type == 'VENTA' ? Colors.purple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: note.type == 'VENTA' ? Colors.purple.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                              width: 0.5
                            ),
                          ),
                          child: Text(
                            note.type == 'VENTA' 
                                ? (loc.translate('note_type_sale').toUpperCase()) 
                                : (loc.translate('note_type_quote').toUpperCase()),
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.bold,
                              color: note.type == 'VENTA' ? Colors.purple : Colors.orange[800],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${note.totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!isSelectionMode)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                  onSelected: (value) {
                     if (value == 'delete') {
                       NotesService().deleteNotes([note]); 
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Nota eliminada')),
                       );
                     } else if (value == 'view') {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => PdfPreviewScreen(note: note)),
                       );
                     } else if (value == 'edit') {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => CreateNoteScreen(noteToEdit: note)),
                       );
                     } else if (value == 'create_sale') {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => CreateNoteScreen(templateNote: note)),
                       );
                     }
                  },
                  itemBuilder: (context) => [
                    if (note.status == 'COMPLETADA')
                       PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.translate('menu_view_pdf')),
                          ],
                        ),
                      ),
                    if (note.type == 'COTIZACION')
                       PopupMenuItem(
                        value: 'create_sale',
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.teal, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.translate('menu_create_sale')),
                          ],
                        ),
                      ),
                    if (note.status == 'BORRADOR')
                       PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(loc.translate('menu_edit')),
                          ],
                        ),
                      ),
                     PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(loc.translate('menu_delete')),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
