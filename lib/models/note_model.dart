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
}
