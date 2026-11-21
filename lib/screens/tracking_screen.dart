import 'package:material_ui/material_ui.dart';

import '../format.dart';
import '../main.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Live task screen from the last mockup: map, the other party's card with
/// message / call buttons, ETA, and Cancel. Workers also get "End task".
///
/// The map is a painted placeholder; swap [_MapPlaceholder] for
/// google_maps_flutter / flutter_map when you have API keys.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, required this.taskId});
  final String taskId;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _leaving = false;

  Future<void> _confirmCancel(TaskItem t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this task?'),
        content: const Text('The other person will be notified.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep it')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: KColors.danger),
            child: const Text('Cancel task'),
          ),
        ],
      ),
    );
    if (ok == true) appState.cancel(t);
  }

  void _openChat(TaskItem t, String otherName) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 0, 20, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(
          height: 360,
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) => Column(
              children: [
                Row(children: [
                  Avatar(otherName, size: 36),
                  const SizedBox(width: 10),
                  Text(otherName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ]),
                const Divider(height: 24),
                Expanded(
                  child: t.messages.isEmpty
                      ? const Center(
                          child: Text('Say hi 👋',
                              style: TextStyle(color: KColors.muted)))
                      : ListView(
                          children: [
                            for (final m in t.messages)
                              Align(
                                alignment: m.fromMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: m.fromMe ? KColors.ink : KColors.field,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(m.text,
                                      style: TextStyle(
                                          color: m.fromMe
                                              ? Colors.white
                                              : KColors.ink)),
                                ),
                              ),
                          ],
                        ),
                ),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(hintText: 'Message'),
                      onSubmitted: (v) {
                        if (v.trim().isEmpty) return;
                        appState.sendMessage(t, v.trim());
                        ctrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: KColors.ink),
                    onPressed: () {
                      if (ctrl.text.trim().isEmpty) return;
                      appState.sendMessage(t, ctrl.text.trim());
                      ctrl.clear();
                    },
                    icon: const Icon(Icons.send, size: 18),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final t = appState.taskById(widget.taskId);
        if (t == null) return const Scaffold(body: Center(child: Text('Task not found')));

        // React to status changes once.
        if (!_leaving) {
          if (t.status == TaskStatus.completed) {
            _leaving = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, Routes.receipt,
                    arguments: t.id);
              }
            });
          } else if (t.status == TaskStatus.cancelled) {
            _leaving = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.pop(context);
              showSnack(context, 'Task cancelled');
            });
          }
        }

        final user = appState.user;
        if (user == null) return const Scaffold();
        final isWorker = user.role == UserRole.worker;
        final waiting = t.status == TaskStatus.open;
        final otherName = isWorker ? t.customerName : (t.workerName ?? '');
        final otherRating =
            isWorker ? (t.customerRating ?? 4.7) : (t.workerRating ?? 4.8);

        return Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: _MapPlaceholder()),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
                  decoration: const BoxDecoration(
                    color: KColors.ink,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (waiting)
                        _WaitingBody(task: t)
                      else ...[
                        Row(
                          children: [
                            Avatar(otherName, dark: true, size: 48),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(otherName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16)),
                                  const SizedBox(height: 2),
                                  StarRow(otherRating, light: true),
                                ],
                              ),
                            ),
                            _RoundAction(
                              icon: Icons.mail_outline,
                              tooltip: 'Message',
                              onTap: () => _openChat(t, otherName),
                            ),
                            const SizedBox(width: 8),
                            _RoundAction(
                              icon: Icons.phone_outlined,
                              tooltip: 'Call',
                              onTap: () =>
                                  showSnack(context, 'Calling $otherName…'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isWorker
                              ? 'Head to ${t.address}, ${t.area}'
                              : '5 Min away estimated arrival time ${fmtTime(t.time)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${t.title} · ${t.priceLabel} ${t.method.label}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (isWorker && !waiting) ...[
                            Expanded(
                              child: FilledButton(
                                onPressed: () => appState.complete(t),
                                style: FilledButton.styleFrom(
                                    backgroundColor: KColors.accept),
                                child: const Text('End task'),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _confirmCancel(t),
                              style: FilledButton.styleFrom(
                                  backgroundColor: KColors.danger),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaitingBody extends StatelessWidget {
  const _WaitingBody({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Finding a Khedma near you…',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          '${task.title} · ${task.area} · ${task.priceLabel} ${task.method.label}',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        const LinearProgressIndicator(
          color: Colors.white,
          backgroundColor: Colors.white24,
          minHeight: 3,
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.tooltip, required this.onTap});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: KColors.ink, size: 20),
      ),
    );
  }
}

/// Stylised map: streets, a blue route and two markers.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MapPainter(), child: const SizedBox.expand());
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFEFEDE8));

    // Park blocks.
    final park = Paint()..color = const Color(0xFFD9E8D2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * .05, s.height * .12, s.width * .28, s.height * .14),
            const Radius.circular(12)),
        park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(s.width * .62, s.height * .36, s.width * .3, s.height * .12),
            const Radius.circular(12)),
        park);

    // Streets.
    final street = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 6; i++) {
      final y = s.height * i / 6;
      canvas.drawLine(Offset(0, y + (i.isEven ? 14 : -10)),
          Offset(s.width, y - (i.isEven ? 10 : -14)), street);
    }
    for (var i = 1; i < 5; i++) {
      final x = s.width * i / 5;
      canvas.drawLine(Offset(x - 8, 0), Offset(x + 12, s.height), street);
    }

    // Route.
    final from = Offset(s.width * .26, s.height * .50);
    final to = Offset(s.width * .70, s.height * .18);
    final route = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(s.width * .22, s.height * .32, s.width * .55, s.height * .40,
          s.width * .54, s.height * .26)
      ..cubicTo(s.width * .53, s.height * .20, s.width * .64, s.height * .22,
          to.dx, to.dy);
    canvas.drawPath(
        route,
        Paint()
          ..color = const Color(0xFF1A56DB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // Destination pin and worker dot.
    canvas.drawCircle(to, 10, Paint()..color = KColors.ink);
    canvas.drawCircle(to, 4, Paint()..color = Colors.white);
    canvas.drawCircle(from, 16, Paint()..color = Colors.white);
    canvas.drawCircle(from, 12, Paint()..color = KColors.ink);
    canvas.drawCircle(from, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
