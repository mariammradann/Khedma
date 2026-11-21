import 'package:material_ui/material_ui.dart';

import '../main.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'common_tabs.dart';

/// Worker app: Nearby tasks (accept / decline), My tasks, Profile.
class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key});

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const _NearbyTab(),
      const MyTasksTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.near_me_outlined), label: 'Nearby'),
          NavigationDestination(
              icon: Icon(Icons.checklist_rtl), label: 'My tasks'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _NearbyTab extends StatelessWidget {
  const _NearbyTab();

  void _pickArea(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose area',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final a in AppState.areas)
              AreaPill(
                label: a,
                selected: a == appState.selectedArea,
                onTap: () {
                  appState.selectArea(a);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final list = appState.nearbyTasks;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 76,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nearby'),
                InkWell(
                  onTap: () => _pickArea(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14),
                      const SizedBox(width: 2),
                      Text(appState.selectedArea,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Center(
                  child: Text('${list.length} tasks',
                      style: const TextStyle(
                          color: KColors.muted, fontSize: 12)),
                ),
              ),
            ],
          ),
          body: list.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No open tasks in this area right now.\nTry another area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KColors.muted),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final t = list[i];
                    return NearbyTaskCard(
                      task: t,
                      onDecline: () => appState.decline(t),
                      onAccept: () {
                        appState.accept(t);
                        Navigator.pushNamed(context, Routes.tracking,
                            arguments: t.id);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
