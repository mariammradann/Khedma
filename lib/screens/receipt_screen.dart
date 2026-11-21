import 'package:material_ui/material_ui.dart';

import '../format.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Payment receipt (shown to both sides) + rating of the other party.
class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.taskId});
  final String taskId;

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  int _stars = 0;

  void _done(TaskItem t, bool isCustomer) {
    if (_stars > 0) {
      appState.rate(t, ratingTheWorker: isCustomer, stars: _stars);
    }
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final t = appState.taskById(widget.taskId);
    if (t == null) return const Scaffold(body: Center(child: Text('Not found')));
    final isCustomer = appState.user!.role == UserRole.customer;
    final other = isCustomer ? (t.workerName ?? 'the worker') : t.customerName;
    final existing = isCustomer ? t.ratingForWorker : t.ratingForCustomer;
    if (existing != null && _stars == 0) _stars = existing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment receipt'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KColors.field,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: KColors.accept,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isCustomer ? 'Task completed' : 'Payment collected',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(t.priceLabel,
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          fontFamily: kSerif)),
                  const SizedBox(height: 16),
                  const Divider(),
                  _Row('Task', t.title),
                  _Row('Customer', t.customerName),
                  _Row('Worker', t.workerName ?? '-'),
                  _Row('Payment method', t.method.label),
                  _Row('Location', '${t.address}, ${t.area}'),
                  _Row('Date', fmtDate(t.time)),
                  _Row('Time', fmtTime(t.time)),
                  _Row('Reference', 'KH-${t.id.toUpperCase()}'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isCustomer ? 'Rate the worker' : 'Rate the customer',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text('How was your experience with $other?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KColors.muted, fontSize: 13)),
            StarPicker(
              value: _stars,
              onChanged: (v) => setState(() => _stars = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _done(t, isCustomer),
              child: Text(_stars == 0 ? 'Skip' : 'Submit & finish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: const TextStyle(color: KColors.muted)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
