import 'package:material_ui/material_ui.dart';

import '../categories.dart';
import '../main.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'common_tabs.dart';

/// Customer app: Home (search + categories), My tasks, Profile.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const _CustomerHome(),
      const MyTasksTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, Routes.request),
              backgroundColor: KColors.ink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Request task'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.checklist_rtl), label: 'My tasks'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _CustomerHome extends StatelessWidget {
  const _CustomerHome();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final user = appState.user;
        if (user == null) return const SizedBox.shrink(); // logged out
        final name = user.name.split(' ').first;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            children: [
              Text('Hi $name 👋',
                  style: const TextStyle(color: KColors.muted, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Searching for a Khedma in?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              for (final a in AppState.areas)
                AreaPill(
                  label: a,
                  selected: a == appState.selectedArea,
                  onTap: () => appState.selectArea(a),
                ),
              const SizedBox(height: 20),
              const Text('What do you need help with?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
                children: [
                  for (final c in serviceCategories)
                    _CategoryTile(
                      category: c,
                      onTap: () => Navigator.pushNamed(context, Routes.request,
                          arguments: c.label),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: KColors.field,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(category.icon, color: KColors.ink),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
