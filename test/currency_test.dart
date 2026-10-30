import 'package:flutter_test/flutter_test.dart';
import 'package:notes_generator_id/models/note_model.dart';
import 'package:notes_generator_id/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Note Model Currency Tests', () {
    test('Default currency should be MXN', () {
      final note = Note(
        clientName: 'Test Client',
        date: DateTime.now(),
        items: [
          NoteItem(description: 'Item 1', price: 100, quantity: 2),
        ],
      );

      expect(note.currency, 'MXN');
      expect(note.subtotal, 200.0);
    });

    test('Custom currency USD should be preserved', () {
      final note = Note(
        clientName: 'US Client',
        date: DateTime.now(),
        currency: 'USD',
        items: [
          NoteItem(description: 'Service A', price: 50, quantity: 3),
        ],
      );

      expect(note.currency, 'USD');
      expect(note.subtotal, 150.0);
    });

    test('Serialization and Deserialization preserve currency', () {
      final note = Note(
        clientName: 'Client USD',
        date: DateTime(2026, 10, 18),
        currency: 'USD',
        folio: 'COT-2026-001',
        addVat: true,
        items: [
          NoteItem(description: 'Dev Work', price: 500, quantity: 1),
        ],
      );

      final json = note.toJson();
      expect(json['currency'], 'USD');

      final reconstructed = Note.fromJson(json);
      expect(reconstructed.currency, 'USD');
      expect(reconstructed.clientName, 'Client USD');
      expect(reconstructed.totalAmount, 580.0);
    });

    test('Legacy json without currency defaults to MXN', () {
      final legacyJson = {
        'clientName': 'Legacy Client',
        'clientAddress': '',
        'date': DateTime(2026, 1, 1).toIso8601String(),
        'items': [
          {'description': 'Old item', 'price': 100.0, 'quantity': 1}
        ],
        'status': 'COMPLETADA',
        'folio': 'COT-2026-000',
        'addVat': false,
        'additionalNotes': '',
        'type': 'COTIZACION',
        'clientPhone': '',
        'clientEmail': '',
        'paymentMethod': '',
      };

      final note = Note.fromJson(legacyJson);
      expect(note.currency, 'MXN');
    });
  });

  group('SettingsService Currency Tests', () {
    test('Default currency is MXN and can be updated to USD', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsService();

      expect(settings.currency, 'MXN');

      await settings.updateCurrency('USD');
      expect(settings.currency, 'USD');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('currency_code'), 'USD');
    });
  });
}
