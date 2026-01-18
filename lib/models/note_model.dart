class NoteItem {
  String description;
  double price;
  int quantity;

  NoteItem({
    required this.description,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class Note {
  String clientName;
  String clientAddress;
  DateTime date;
  List<NoteItem> items;
  String status;
  String folio;
  bool addVat;
  String additionalNotes;

  Note({
    required this.clientName,
    this.clientAddress = '',
    required this.date,
    required this.items,
    this.status = 'DRAFT',
    this.folio = '',
    this.addVat = false,
    this.additionalNotes = '',
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get vatAmount => addVat ? subtotal * 0.16 : 0.0;
  double get totalAmount => subtotal + vatAmount;

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'clientAddress': clientAddress,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'status': status,
      'folio': folio,
      'addVat': addVat,
      'additionalNotes': additionalNotes,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      clientName: json['clientName'] ?? '',
      clientAddress: json['clientAddress'] ?? '',
      date: DateTime.parse(json['date']),
      items: (json['items'] as List).map((i) => NoteItem.fromJson(i)).toList(),
      status: json['status'] ?? 'DRAFT',
      folio: json['folio'] ?? '',
      addVat: json['addVat'] ?? false,
      additionalNotes: json['additionalNotes'] ?? '',
    );
  }
}

