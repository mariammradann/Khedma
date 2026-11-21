import 'package:flutter/material.dart';

import 'format.dart';
import 'models.dart';
import 'theme.dart';

/// Black circle with a handshake, "Khedma" wordmark and tagline.
class KhedmaLogo extends StatelessWidget {
  const KhedmaLogo({super.key, this.size = 112, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: KColors.ink, shape: BoxShape.circle),
          child: Icon(Icons.handshake, color: Colors.white, size: size * 0.5),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 16),
          Text(
            'Khedma',
            style: TextStyle(
              fontFamily: kSerif,
              fontSize: size * 0.5,
              fontWeight: FontWeight.w700,
              color: KColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Empowering Teenagers, assisting busy lives',
            style: TextStyle(
              fontFamily: kSerif,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 44, this.dark = false});

  final String name;
  final double size;

  /// White circle on dark surfaces, black on light.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? Colors.white : KColors.ink,
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: dark ? KColors.ink : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class StarRow extends StatelessWidget {
  const StarRow(this.rating, {super.key, this.size = 14, this.light = false});
  final double rating;
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size + 2, color: KColors.star),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w600,
            color: light ? Colors.white : KColors.ink,
          ),
        ),
      ],
    );
  }
}

/// Tappable 1–5 star input used for "Rate the worker / customer".
class StarPicker extends StatelessWidget {
  const StarPicker({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          onPressed: () => onChanged(i + 1),
          iconSize: 40,
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled ? KColors.star : KColors.muted,
          ),
        );
      }),
    );
  }
}

/// Dark task card from the "Nearby" mockup: avatar, title, location,
/// price + payment method, time and a green Accept button.
class NearbyTaskCard extends StatelessWidget {
  const NearbyTaskCard({
    super.key,
    required this.task,
    required this.onAccept,
    required this.onDecline,
    this.onTap,
  });

  final TaskItem task;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KColors.ink,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Avatar(task.customerName, dark: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.title,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.white70),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                task.address,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Decline',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDecline,
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${task.priceLabel} ${task.method.label}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'At ${fmtTime(task.time)} · ${fmtDuration(task.durationMinutes)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: KColors.accept,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(92, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Light list row for "My tasks".
class TaskRow extends StatelessWidget {
  const TaskRow({super.key, required this.task, required this.onTap, required this.subtitle});
  final TaskItem task;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KColors.field,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(color: KColors.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      '${task.priceLabel} · ${task.method.label} · ${fmtTime(task.time)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(task.status),
              const Icon(Icons.chevron_right, color: KColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TaskStatus.open => ('Waiting', KColors.muted),
      TaskStatus.accepted => ('In progress', KColors.ink),
      TaskStatus.completed => ('Done', KColors.accept),
      TaskStatus.cancelled => ('Cancelled', KColors.danger),
    };
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Black pill used for the area picker ("Mokattam", "Maadi"...).
class AreaPill extends StatelessWidget {
  const AreaPill({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? KColors.ink : KColors.field,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18, color: selected ? Colors.white : KColors.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : KColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (selected) const Icon(Icons.check, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: KColors.ink,
    ));
}
