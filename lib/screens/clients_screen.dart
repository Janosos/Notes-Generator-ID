import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/clients_service.dart';
import 'create_note_screen.dart';
import 'notes_list_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _clientsService = ClientsService();

  void _showAddClientDialog() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController(); // Email or Phone
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre / Empresa', hintText: 'Ej. ImperioDev'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contactCtrl,
              decoration: const InputDecoration(labelText: 'Contacto', hintText: 'Email o Teléfono'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newClient = Client(
                  id: DateTime.now().toString(),
                  name: nameCtrl.text,
                  email: contactCtrl.text.contains('@') ? contactCtrl.text : '',
                  phone: !contactCtrl.text.contains('@') ? contactCtrl.text : '',
                ); // Simple heuristic
                _clientsService.addClient(newClient);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Client client) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Eliminar a ${client.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              _clientsService.removeClient(client);
              Navigator.pop(ctx);
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cliente eliminado')),
                );
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Clientes', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClientDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Cliente'),
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
                    'No hay clientes registrados',
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
  final VoidCallback onViewHistory;
  final VoidCallback onCreateNote;

  const _ClientCard({
    required this.client,
    required this.onDelete,
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
              if (val == 'delete') onDelete();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'note', 
                child: Row(children: [Icon(Icons.add_circle_outline, color: Colors.blue), SizedBox(width: 8), Text('Crear Nota')])
              ),
              const PopupMenuItem(
                value: 'history', 
                child: Row(children: [Icon(Icons.history, color: Colors.grey), SizedBox(width: 8), Text('Ver Notas')])
              ),
               const PopupMenuItem(
                value: 'delete', 
                child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 8), Text('Eliminar')])
              ),
            ],
          ),
        ],
      ),
    );
  }
}
