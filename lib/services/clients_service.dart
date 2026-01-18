import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client_model.dart';

class ClientsService extends ChangeNotifier {
  static final ClientsService _instance = ClientsService._internal();

  factory ClientsService() {
    return _instance;
  }

  ClientsService._internal() {
    _loadClients();
  }

  final List<Client> _clients = [];

  ValueNotifier<List<Client>> clientsNotifier = ValueNotifier([]);

  List<Client> get clients => _clients;

  Future<void> _loadClients() async {
    final prefs = await SharedPreferences.getInstance();
    final clientsJson = prefs.getStringList('clients_data');

    if (clientsJson != null) {
      _clients.clear();
      _clients.addAll(clientsJson.map((e) => Client.fromJson(jsonDecode(e))).toList());
      clientsNotifier.value = List.from(_clients);
      notifyListeners();
    }
  }

  Future<void> _saveClients() async {
    final prefs = await SharedPreferences.getInstance();
    final clientsJson = _clients.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('clients_data', clientsJson);
  }

  void addClient(Client client) {
    _clients.add(client);
    clientsNotifier.value = List.from(_clients);
    notifyListeners();
    _saveClients();
  }

  void removeClient(Client client) {
    _clients.remove(client);
    clientsNotifier.value = List.from(_clients);
    notifyListeners();
    _saveClients();
  }

  void updateClient(Client oldClient, Client newClient) {
    final index = _clients.indexOf(oldClient);
    if (index != -1) {
      _clients[index] = newClient;
      clientsNotifier.value = List.from(_clients);
      notifyListeners();
      _saveClients();
    }
  }
}
