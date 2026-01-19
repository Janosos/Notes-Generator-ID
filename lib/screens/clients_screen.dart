import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/clients_service.dart';
import 'create_note_screen.dart';
import 'notes_list_screen.dart';
import '../utils/localization.dart';
import '../utils/country_codes.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _clientsService = ClientsService();

  void _showAddEditClientDialog({Client? clientToEdit}) {
    final isEditing = clientToEdit != null;
    final nameCtrl = TextEditingController(text: clientToEdit?.name ?? '');
    final emailCtrl = TextEditingController(text: clientToEdit?.email ?? '');
    final phoneCtrl = TextEditingController(text: clientToEdit?.phone ?? '');
    final addressCtrl = TextEditingController(text: clientToEdit?.address ?? '');
    
    // Country Code logic
    String selectedCountryCode = clientToEdit?.countryCode ?? '+52';
    // Ensure selected is in list, if not add it practically or just default (simple check)
    // We will trust the list covers most. If current not in list, we might have an issue displaying, 
    // but Dropdown can handle 'value' matching. If distinct custom code exists, we should probably add it or handle unique.
    // For now assuming the huge list covers it.

    final loc = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? loc.translate('edit_client') : loc.translate('add_client')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: loc.translate('client_name'), 
                      hintText: loc.translate('hint_client_name'),
                      filled: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    decoration: InputDecoration(
                      labelText: loc.translate('label_email'), 
                      hintText: loc.translate('hint_contact'),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.grey.shade200,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                          border: Border(bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54))
                        ),
                        child: DropdownButton<String>(
                          value: selectedCountryCode,
                          underline: const SizedBox(),
                          menuMaxHeight: 300, // Limit height since list is long
                          items: CountryCodes.list.map((c) => DropdownMenuItem(
                            value: c.code, 
                            child: Text('${c.flag} ${c.code}')
                          )).toList(),
                          onChanged: (val) {
                             if (val != null) setDialogState(() => selectedCountryCode = val);
                          },
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          decoration: InputDecoration(
                            labelText: loc.translate('label_phone'), 
                            hintText: '1234567890',
                            filled: true,
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                   TextField(
                    controller: addressCtrl,
                    decoration: InputDecoration(
                      labelText: loc.translate('client_address'),
                      filled: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    final newClient = Client(
                      id: isEditing ? clientToEdit.id : DateTime.now().toString(),
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      phone: phoneCtrl.text,
                      countryCode: selectedCountryCode,
                      address: addressCtrl.text,
                    );
                    
                    if (isEditing) {
                        _clientsService.updateClient(clientToEdit!, newClient); 
                    } else {
                        _clientsService.addClient(newClient);
                    }
                    
                    Navigator.pop(ctx);
                    if (isEditing) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.translate('client_details_updated'))));
                    }
                  }
                },
                child: Text(loc.translate('save')),
              ),
            ],
          );
        }
      ),
    );
  }

  void _confirmDelete(Client client) {
     final loc = AppLocalizations.of(context);
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('delete_client_title')),
        content: Text('${loc.translate('delete_client_msg')} (${client.name})'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.translate('cancel'))),
          TextButton(
            onPressed: () {
              _clientsService.removeClient(client);
              Navigator.pop(ctx);
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.translate('client_deleted'))),
                );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('delete_note')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
     final loc = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(loc.translate('client_title'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditClientDialog(),
        icon: const Icon(Icons.person_add),
        label: Text(loc.translate('add_client')),
      ),
      body: ValueListenableBuilder<List<Client>>(
        valueListenable: _clientsService.clientsNotifier,
        builder: (context, clients, _) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('clients_empty'),
                    style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
               final client = clients[i];
               return _ClientCard(
                 client: client,
                 onDelete: () => _confirmDelete(client),
                 onEdit: () => _showAddEditClientDialog(clientToEdit: client),
                 onViewHistory: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => NotesListScreen(filterClientName: client.name)),
                   );
                 },
                 onCreateNote: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => CreateNoteScreen(clientToUse: client)),
                   );
                 },
               );
            },
          );
        },
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewHistory;
  final VoidCallback onCreateNote;

  const _ClientCard({
    required this.client,
    required this.onDelete,
    required this.onEdit,
    required this.onViewHistory,
    required this.onCreateNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: theme.cardTheme.color,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
         boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
         ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.business, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (client.email.isNotEmpty || client.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      client.email.isNotEmpty ? client.email : client.phone,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'note') onCreateNote();
              if (val == 'history') onViewHistory();
              if (val == 'edit') onEdit(); // New
              if (val == 'delete') onDelete();
            },
            itemBuilder: (ctx) {
              final loc = AppLocalizations.of(context);
              return [
                PopupMenuItem(
                  value: 'note', 
                  child: Row(children: [const Icon(Icons.add_circle_outline, color: Colors.blue), const SizedBox(width: 8), Text(loc.translate('create_note_for'))])
                ),
                PopupMenuItem(
                  value: 'history', 
                  child: Row(children: [const Icon(Icons.history, color: Colors.grey), const SizedBox(width: 8), Text(loc.translate('view_history'))])
                ),
                PopupMenuItem(
                  value: 'edit', 
                  child: Row(children: [const Icon(Icons.edit, color: Colors.orange), const SizedBox(width: 8), Text(loc.translate('edit_client'))])
                ),
                 PopupMenuItem(
                  value: 'delete', 
                  child: Row(children: [const Icon(Icons.delete_outline, color: Colors.red), const SizedBox(width: 8), Text(loc.translate('delete_note'))])
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
