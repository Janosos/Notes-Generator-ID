import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/notes_service.dart';
import '../utils/localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsService>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
         title: Text(loc.translate('settings_title'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
         backgroundColor: theme.scaffoldBackgroundColor,
         elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Branding Header
          Center(
             child: Column(
               children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('IMPERIO', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                      Text('DEV', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${loc.translate('version')} 3.4.0', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(loc.translate('developed_by'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
               ],
             ),
          ),
          const SizedBox(height: 40),

          // Theme
          _SettingsSection(
            title: loc.translate('theme_title'),
            icon: Icons.dark_mode_outlined,
            children: [
               SwitchListTile(
                 title: Text(loc.translate('theme_title')),
                 value: settings.themeMode == ThemeMode.dark,
                 onChanged: (val) {
                   settings.updateThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                 },
                 secondary: Icon(settings.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: theme.colorScheme.primary),
               ),
            ],
          ),

          const SizedBox(height: 24),

          // Language
          _SettingsSection(
            title: loc.translate('lang_title'),
            icon: Icons.language,
            children: [
               ListTile(
                 leading: Icon(Icons.language, color: theme.colorScheme.primary),
                 title: Text(loc.translate('lang_title')),
                 trailing: DropdownButton<String>(
                   value: settings.locale.languageCode,
                   underline: const SizedBox(),
                   onChanged: (String? val) {
                     if (val != null) {
                       settings.updateLocale(Locale(val));
                     }
                   },
                   items: const [
                     DropdownMenuItem(value: 'es', child: Text('Español')),
                     DropdownMenuItem(value: 'en', child: Text('English')),
                   ],
                 ),
               ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Export
           _SettingsSection(
            title: 'Backup',
            icon: Icons.save,
            children: [
               ListTile(
                 leading: Icon(Icons.archive_outlined, color: theme.colorScheme.primary),
                 title: Text(loc.translate('export_title')),
                 subtitle: Text('${loc.translate('save')} / ${loc.translate('share_file')} (ZIP)'),
                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                 onTap: () async {
                    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando respaldo...')));
                    final success = await NotesService().exportAllNotesToZip(loc.locale.languageCode);
                    if (!success) {
                       if (context.mounted) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(loc.translate('export_no_notes')),
                             backgroundColor: Colors.orange,
                           ),
                         );
                       }
                    }
                 },
               ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
