import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientsService extends ChangeNotifier {
  static final ClientsService _instance = ClientsService._internal();

  factory ClientsService() {
    return _instance;
  }

  ClientsService._internal();

  final List<Client> _clients = [];

  ValueNotifier<List<Client>> clientsNotifier = ValueNotifier([]);

  List<Client> get clients => _clients;

  void addClient(Client client) {
    _clients.add(client);
    clientsNotifier.value = List.from(_clients);
    notifyListeners();
  }

  void removeClient(Client client) {
    _clients.remove(client);
    clientsNotifier.value = List.from(_clients);
    notifyListeners();
  }

  void updateClient(Client oldClient, Client newClient) {
    final index = _clients.indexOf(oldClient);
    if (index != -1) {
      _clients[index] = newClient;
      clientsNotifier.value = List.from(_clients);
      notifyListeners();
    }
  }
}
