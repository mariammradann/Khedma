import 'package:material_ui/material_ui.dart';

import '../categories.dart';
import '../format.dart';
import '../main.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Customer: request a task. Covers the deck's inputs: kind of task,
/// time, location, payment method and price (+ duration).
class RequestTaskScreen extends StatefulWidget {
  const RequestTaskScreen({super.key, this.presetCategory});
  final String? presetCategory;

  @override
  State<RequestTaskScreen> createState() => _RequestTaskScreenState();
}

class _RequestTaskScreenState extends State<RequestTaskScreen> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();
  final _address = TextEditingController();
  final _price = TextEditingController();
  late String _kind = widget.presetCategory ?? serviceCategories.first.label;
  late String _area = appState.selectedArea;
  PaymentMethod _method = PaymentMethod.cash;
  TimeOfDay _time = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(hours: 1)));
  double _duration = 60;

  @override
  void dispose() {
    _desc.dispose();
    _address.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  void _useCurrentLocation() {
    setState(() => _address.text = 'Current location ($_area)');
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));
    final t = appState.addTask(
      title: _kind,
      description: _desc.text.trim(),
      area: _area,
      address: _address.text.trim(),
      price: int.parse(_price.text.trim()),
      method: _method,
      time: when,
      durationMinutes: _duration.round(),
    );
    Navigator.pushReplacementNamed(context, Routes.tracking, arguments: t.id);
  }

  @override
  Widget build(BuildContext context) {
    final when = DateTime(2000, 1, 1, _time.hour, _time.minute);
    return Scaffold(
      appBar: AppBar(title: const Text('Request a task')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Label('Kind of task'),
                DropdownButtonFormField<String>(
                  value: _kind, // ignore: deprecated_member_use
                  borderRadius: BorderRadius.circular(10),
                  decoration: const InputDecoration(),
                  items: [
                    for (final c in serviceCategories)
                      DropdownMenuItem(value: c.label, child: Text(c.label)),
                  ],
                  onChanged: (v) => setState(() => _kind = v!),
                ),
                const _Label('Details'),
                TextFormField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'Describe what you need done'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Add a short description'
                      : null,
                ),
                const _Label('Location'),
                DropdownButtonFormField<String>(
                  value: _area, // ignore: deprecated_member_use
                  borderRadius: BorderRadius.circular(10),
                  decoration: const InputDecoration(),
                  items: [
                    for (final a in AppState.areas)
                      DropdownMenuItem(value: a, child: Text(a)),
                  ],
                  onChanged: (v) => setState(() => _area = v!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _address,
                  decoration: InputDecoration(
                    hintText: 'Street / landmark',
                    suffixIcon: IconButton(
                      tooltip: 'Use my location',
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: _useCurrentLocation,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Put the location'
                      : null,
                ),
                const _Label('When'),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.schedule, size: 20)),
                    child: Text(fmtTime(when)),
                  ),
                ),
                _Label('Duration · ${fmtDuration(_duration.round())}'),
                Slider(
                  value: _duration,
                  min: 15,
                  max: 240,
                  divisions: 15,
                  activeColor: KColors.ink,
                  inactiveColor: KColors.line,
                  onChanged: (v) => setState(() => _duration = v),
                ),
                const _Label('Price (L.E.)'),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 50'),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n <= 0) ? 'Enter a valid price' : null;
                  },
                ),
                const _Label('Payment method'),
                SegmentedButton<PaymentMethod>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: PaymentMethod.cash,
                        icon: Icon(Icons.payments_outlined),
                        label: Text('Cash')),
                    ButtonSegment(
                        value: PaymentMethod.visa,
                        icon: Icon(Icons.credit_card),
                        label: Text('Visa')),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: KColors.ink,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(onPressed: _submit, child: const Text('Post task')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );
}
