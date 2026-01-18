import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'create_note_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Use a Stack to position the custom bottom nav if we want total control, 
      // or use standard Scaffold properties. The design has a transparent sticky header.
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Header (Sticky-ish)
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Text(
                        'Imperio',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0f172a),
                        ),
                      ),
                      Text(
                        'Dev',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Greeting Section
                        Text(
                          'Hello, Alex 👋',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Here's your sales overview for today.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Placeholders for other sections
                        const _StatsGrid(), 
                        const SizedBox(height: 32),
                        const _CreateNoteButton(),
                        const SizedBox(height: 32),
                        const _RecentNotesHeader(),
                        const _RecentNotesList(),
                        const SizedBox(height: 32),
                        const _QuickTemplatesHeader(),
                        const SizedBox(height: 16),
                        const _QuickTemplatesList(),
                         const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
           // Bottom Nav Positioned
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CustomBottomNavBar(),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Sales',
            value: '\$12,450',
            icon: Icons.analytics_outlined,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Pending',
            value: '3 Quotes',
            icon: Icons.pending_actions_outlined,
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
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
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
                    const Text(
                      'Create New Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                     Text(
                      'Draft a quote or log a meeting',
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
          'Recent Notes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _RecentNotesList extends StatelessWidget {
  const _RecentNotesList();

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final notes = [
      (
        title: 'Nakama Embroidery',
        desc: 'E-commerce redesign & inventory setup.',
        date: 'Oct 24, 2023',
        amount: '\$8,500',
        status: 'SENT',
        color: Colors.teal,
        icon: Icons.web,
      ),
      (
        title: 'Boutique Cafe',
        desc: 'Landing page for seasonal promo.',
        date: 'Oct 22, 2023',
        amount: '\$6,000',
        status: 'DRAFT',
        color: Colors.indigo,
        icon: Icons.storefront,
      ),
      (
        title: 'Caption MX',
        desc: 'Annual maintenance & hosting renewal.',
        date: 'Oct 20, 2023',
        amount: '\$500/mo',
        status: 'ACCEPTED',
        color: Colors.purple,
        icon: Icons.build_outlined,
      ),
    ];

    return Column(
      children: notes.map((note) => _NoteCard(note: note)).toList(),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final dynamic note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    Color statusBg;
    if (note.status == 'SENT') {
      statusColor = Colors.teal;
      statusBg = Colors.teal.withOpacity(0.1);
    } else if (note.status == 'DRAFT') {
      statusColor = Colors.grey;
      statusBg = isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.shade200;
    } else {
      statusColor = Colors.green;
      statusBg = Colors.green.withOpacity(0.1);
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
              color: note.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(note.icon, color: note.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note.status,
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
                  note.desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      note.date,
                      style: const TextStyle(
                         color: Colors.grey,
                         fontSize: 12,
                         fontWeight: FontWeight.w500,
                      ),
                    ),
                     Text(
                      note.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                         fontWeight: FontWeight.bold,
                      ),
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

class _QuickTemplatesHeader extends StatelessWidget {
  const _QuickTemplatesHeader();
  @override
  Widget build(BuildContext context) {
     return Text(
       'Quick Templates',
       style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _QuickTemplatesList extends StatelessWidget {
  const _QuickTemplatesList();
  
  @override
  Widget build(BuildContext context) {
    final templates = [
      (title: 'Web Design', sub: 'Standard Plan', icon: Icons.rocket_launch, color: Colors.teal),
      (title: 'E-commerce', sub: 'Pro Plan', icon: Icons.shopping_cart, color: Colors.blue),
      (title: 'Maintenance', sub: 'Monthly', icon: Icons.security, color: Colors.purple),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: templates.map((t) => Container(
          width: 140,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
             color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
             boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(t.icon, color: t.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                t.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
               const SizedBox(height: 4),
              Text(
                t.sub,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, top: 8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.dashboard_rounded, label: 'Home', isActive: true),
              _NavItem(icon: Icons.description_rounded, label: 'Notes'),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(icon: Icons.people_rounded, label: 'Clients'),
              _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
            ],
          ),
           Positioned(
            top: -40,
            child: Material(
              color: Colors.transparent,
              elevation: 10,
              shape: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFF1e293b),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Theme.of(context).colorScheme.primary : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
