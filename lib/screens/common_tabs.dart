import 'package:material_ui/material_ui.dart';

import '../main.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// "My tasks" list, shared by customers (tasks they requested) and
/// workers (tasks they accepted).
class MyTasksTab extends StatelessWidget {
  const MyTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final user = appState.user;
        if (user == null) return const SizedBox.shrink(); // logged out
        final isCustomer = user.role == UserRole.customer;
        final list = appState.myTasks;
        return Scaffold(
          appBar: AppBar(title: const Text('My tasks')),
          body: list.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined,
                            size: 48, color: KColors.muted),
                        const SizedBox(height: 12),
                        Text(
                          isCustomer
                              ? 'No tasks yet.\nRequest your first Khedma from Home.'
                              : 'No tasks yet.\nAccept one from the Nearby tab.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: KColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final t = list[i];
                    final who = isCustomer
                        ? (t.workerName == null
                            ? 'Looking for a worker…'
                            : 'Worker: ${t.workerName}')
                        : 'Customer: ${t.customerName}';
                    return TaskRow(
                      task: t,
                      subtitle: '$who · ${t.area}',
                      onTap: () {
                        if (t.status == TaskStatus.completed) {
                          Navigator.pushNamed(context, Routes.receipt,
                              arguments: t.id);
                        } else if (t.status == TaskStatus.cancelled) {
                          showSnack(context, 'This task was cancelled');
                        } else {
                          Navigator.pushNamed(context, Routes.tracking,
                              arguments: t.id);
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Profile with account info, quick stats and log out.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final u = appState.user;
        if (u == null) return const SizedBox.shrink(); // logged out
        final isCustomer = u.role == UserRole.customer;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(child: Avatar(u.name, size: 88)),
              const SizedBox(height: 12),
              Center(
                child: Text(u.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(u.role.label,
                        style: const TextStyle(color: KColors.muted)),
                    const SizedBox(width: 8),
                    StarRow(u.rating),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                        label: 'Completed', value: '${appState.completedCount}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Stat(
                      label: isCustomer ? 'Spent' : 'Earned',
                      value: '${appState.totalAmount} L.E.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _InfoTile(
                  icon: Icons.mail_outline,
                  text: u.email.isEmpty ? 'No e-mail added' : u.email),
              _InfoTile(
                  icon: Icons.phone_outlined,
                  text: u.phone.isEmpty ? 'No phone added' : u.phone),
              const _InfoTile(
                  icon: Icons.payments_outlined,
                  text: 'Payment: Cash or Visa'),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  appState.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.login, (_) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KColors.ink,
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: KColors.ink),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.field,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: KColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: KColors.muted),
          const SizedBox(width: 14),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
