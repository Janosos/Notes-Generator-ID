import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'create_note_screen.dart';
import 'pdf_preview_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

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

  void _deleteSelected() {
    if (_selectedNotes.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Notas'),
        content: Text('¿Estás seguro de eliminar ${_selectedNotes.length} notas seleccionadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
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
            child: const Text('Eliminar'),
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
          _isSelectionMode ? '${_selectedNotes.length} Seleccionadas' : 'Mis Notas',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteSelected,
            )
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
              tooltip: 'Seleccionar',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<Note>>(
        valueListenable: NotesService().notesNotifier,
        builder: (context, notes, _) {
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   Text(
                    'No tienes notas aún',
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
    
    // Status Logic
    Color statusColor = Colors.teal;
    Color statusBg = Colors.teal.withOpacity(0.1);
    String statusText = note.status;

    if (note.status == 'BORRADOR') {
      statusColor = Colors.grey;
      statusBg = Colors.grey.withOpacity(0.1);
    } else if (note.status == 'COMPLETADA') {
       statusColor = Colors.blue; 
       statusBg = Colors.blue.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelect,
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_outlined, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.clientName.isEmpty ? 'Sin Cliente' : note.clientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  note.folio,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: Theme.of(context).scaffoldBackgroundColor, // Slight contrast
                   borderRadius: BorderRadius.circular(6),
                   border: Border.all(color: Colors.white12),
                 ),
                 child: Text(
                   statusText,
                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                 ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${note.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(width: 4),
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
                }
              },
              itemBuilder: (context) => [
                if (note.status == 'COMPLETADA')
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text('Ver PDF'),
                      ],
                    ),
                  ),
                if (note.status == 'BORRADOR')
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Eliminar'),
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
