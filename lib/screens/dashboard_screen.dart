import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notes_service.dart';
import '../models/note_model.dart';
import 'create_note_screen.dart';
import 'pdf_preview_screen.dart';
import '../utils/localization.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesService = NotesService();

    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ValueListenableBuilder<List<Note>>(
        valueListenable: notesService.notesNotifier,
        builder: (context, notes, _) {
          return CustomScrollView(
            slivers: [
              // Header (Sticky-ish)
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.95),
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'IMPERIO',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : const Color(0xFF0f172a),
                          ),
                        ),
                        Text(
                          'DEV',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: theme.colorScheme.primary, // Using primary color
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Greeting Section
                      Text(
                        loc.translate('greeting'),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate('dashboard_subtitle'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Grid - Removed const to allow rebuild
                      _StatsGrid(notes: notes), 
                      const SizedBox(height: 32),
                      
                      // Create Note Button
                      const _CreateNoteButton(),
                      const SizedBox(height: 32),
                      
                      // Recent Notes Header
                      const _RecentNotesHeader(),
                      const SizedBox(height: 16),
                      
                      // Recent Notes List - Removed const and passing notes explicitly
                      if (notes.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              loc.translate('no_notes'),
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        )
                      else
                        _RecentNotesList(notes: notes),
                      
                      const SizedBox(height: 60), 
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<Note> notes;
  const _StatsGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    final notesService = NotesService();
    // Re-accessing service properties is fine, but ValueListenableBuilder triggers this rebuild
    final totalSales = notesService.totalSales;
    final notesCount = notesService.notesCount;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: AppLocalizations.of(context).translate('stat_total_sales'),
            value: currencyFormat.format(totalSales),
            icon: Icons.analytics_outlined,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: AppLocalizations.of(context).translate('stat_notes_created'),
            value: '$notesCount', 
            // notesCount uses notes.length. If drafts are in notes, they are counted.
            // User asked: "Los borradores no deben sumarse al contador de ventas totales"
            // They didn't explicitly say not to count them in "Notas Creadas", but typically separate.
            // Let's filter for now to be safe or clarify. Assuming 'Notas Creadas' means completed.
            // value: '${notes.where((n) => n.status != 'BORRADOR').length}', 
            // Stick to total count for now as "Pending" was replaced by "Created".
            // Let's keep it consistent with totalSales which excludes drafts.
            // Actually, let's show ALL notes count.
            icon: Icons.description_outlined,
            iconColor: Colors.orange,
            iconBgColor: Colors.orange.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateNoteButton extends StatelessWidget {
  const _CreateNoteButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).translate('create_note_button'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                       Text(
                        AppLocalizations.of(context).translate('create_note_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentNotesHeader extends StatelessWidget {
  const _RecentNotesHeader();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).translate('recent_notes'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RecentNotesList extends StatelessWidget {
  final List<Note> notes;
  const _RecentNotesList({required this.notes});
  
  @override
  Widget build(BuildContext context) {
    // Limit to 5 items per user request
    final recentNotes = notes.take(5).toList();

    return Column(
      children: recentNotes.map((note) => _NoteCard(note: note)).toList(),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusBg.withOpacity(0.1), // Subtle
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.description, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.clientName.isEmpty ? 'Sin Cliente' : note.clientName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                 const SizedBox(height: 4),
                Text(
                  note.folio,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      DateFormat('dd MMM, yyyy').format(note.date),
                      style: const TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                      ),
                    ),
                     Row(
                      children: [
                        Text(
                          '\$${note.totalAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                             fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        // Menu
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[400]),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'delete') {
                              NotesService().deleteNote(note);
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
