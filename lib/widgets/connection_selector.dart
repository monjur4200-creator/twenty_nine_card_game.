import 'package:flutter/material.dart';
import '../models/connection_type.dart';

class ConnectionSelector extends StatelessWidget {
  final void Function(ConnectionType type) onSelected;

  const ConnectionSelector({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Connection Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ConnectionType.values.map((type) {
            final keyMap = {
              ConnectionType.local: const Key('connection_local'),
              ConnectionType.bluetooth: const Key('connection_bluetooth'), // ✅ Matches test
              ConnectionType.online: const Key('connection_online'),
            };

            return ElevatedButton(
              key: keyMap[type],
              onPressed: () => onSelected(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: type.offlineCapable ? Colors.green[600] : Colors.grey[600],
                foregroundColor: Colors.white,
              ),
              child: Column(
                children: [
                  Text(type.label, style: const TextStyle(fontSize: 16)),
                  Text(
                    type.offlineCapable ? 'Offline Ready' : 'Requires Internet',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}