class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({required this.code, required this.name, required this.flag});
}

class CountryCodes {
  static const List<CountryCode> list = [
    // Latin America
    CountryCode(code: '+52', name: 'México', flag: '🇲🇽'),
    CountryCode(code: '+54', name: 'Argentina', flag: '🇦🇷'),
    CountryCode(code: '+55', name: 'Brasil', flag: '🇧🇷'),
    CountryCode(code: '+56', name: 'Chile', flag: '🇨🇱'),
    CountryCode(code: '+57', name: 'Colombia', flag: '🇨🇴'),
    CountryCode(code: '+506', name: 'Costa Rica', flag: '🇨🇷'),
    CountryCode(code: '+53', name: 'Cuba', flag: '🇨🇺'),
    CountryCode(code: '+593', name: 'Ecuador', flag: '🇪🇨'),
    CountryCode(code: '+503', name: 'El Salvador', flag: '🇸🇻'),
    CountryCode(code: '+502', name: 'Guatemala', flag: '🇬🇹'),
    CountryCode(code: '+504', name: 'Honduras', flag: '🇭🇳'),
    CountryCode(code: '+505', name: 'Nicaragua', flag: '🇳🇮'),
    CountryCode(code: '+507', name: 'Panamá', flag: '🇵🇦'),
    CountryCode(code: '+595', name: 'Paraguay', flag: '🇵🇾'),
    CountryCode(code: '+51', name: 'Perú', flag: '🇵🇪'),
    CountryCode(code: '+598', name: 'Uruguay', flag: '🇺🇾'),
    CountryCode(code: '+58', name: 'Venezuela', flag: '🇻🇪'),
    CountryCode(code: '+591', name: 'Bolivia', flag: '🇧🇴'),
    CountryCode(code: '+1', name: 'Rep. Dominicana', flag: '🇩🇴'),

    // North America (partial)
    CountryCode(code: '+1', name: 'USA/Canada', flag: '🇺🇸'),

    // Europe
    CountryCode(code: '+49', name: 'Alemania', flag: '🇩🇪'),
    CountryCode(code: '+43', name: 'Austria', flag: '🇦🇹'),
    CountryCode(code: '+32', name: 'Bélgica', flag: '🇧🇪'),
    CountryCode(code: '+359', name: 'Bulgaria', flag: '🇧🇬'),
    CountryCode(code: '+385', name: 'Croacia', flag: '🇭🇷'),
    CountryCode(code: '+45', name: 'Dinamarca', flag: '🇩🇰'),
    CountryCode(code: '+421', name: 'Eslovaquia', flag: '🇸🇰'),
    CountryCode(code: '+386', name: 'Eslovenia', flag: '🇸🇮'),
    CountryCode(code: '+34', name: 'España', flag: '🇪🇸'),
    CountryCode(code: '+372', name: 'Estonia', flag: '🇪🇪'),
    CountryCode(code: '+358', name: 'Finlandia', flag: '🇫🇮'),
    CountryCode(code: '+33', name: 'Francia', flag: '🇫🇷'),
    CountryCode(code: '+30', name: 'Grecia', flag: '🇬🇷'),
    CountryCode(code: '+36', name: 'Hungría', flag: '🇭🇺'),
    CountryCode(code: '+353', name: 'Irlanda', flag: '🇮🇪'),
    CountryCode(code: '+39', name: 'Italia', flag: '🇮🇹'),
    CountryCode(code: '+371', name: 'Letonia', flag: '🇱🇻'),
    CountryCode(code: '+370', name: 'Lituania', flag: '🇱🇹'),
    CountryCode(code: '+352', name: 'Luxemburgo', flag: '🇱🇺'),
    CountryCode(code: '+356', name: 'Malta', flag: '🇲🇹'),
    CountryCode(code: '+31', name: 'Países Bajos', flag: '🇳🇱'),
    CountryCode(code: '+48', name: 'Polonia', flag: '🇵🇱'),
    CountryCode(code: '+351', name: 'Portugal', flag: '🇵🇹'),
    CountryCode(code: '+44', name: 'Reino Unido', flag: '🇬🇧'),
    CountryCode(code: '+420', name: 'Rep. Checa', flag: '🇨🇿'),
    CountryCode(code: '+40', name: 'Rumania', flag: '🇷🇴'),
    CountryCode(code: '+46', name: 'Suecia', flag: '🇸🇪'),
    CountryCode(code: '+41', name: 'Suiza', flag: '🇨🇭'),
  ];
}
