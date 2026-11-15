import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data.dart';

/// UI-05 Shift Handover (FR7).
class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  final _notes = TextEditingController();
  String _shift = 'Morning to Evening';

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  String _buildDraft() {
    final open = AppData.openTasks;
    final buffer = StringBuffer()
      ..writeln('Handover, 14 Nov 2026, $_shift.')
      ..writeln()
      ..writeln(
        '${AppData.activities.length} activities were recorded today, '
        'including ${AppData.activities.first.description.toLowerCase()}',
      )
      ..writeln()
      ..writeln('Unfinished work for the next shift:');
    for (final task in open) {
      buffer.writeln(
        '- ${task.title} (${task.assignee}, ${task.status}'
        '${task.isOverdue ? ', overdue' : ''})',
      );
    }
    if (_notes.text.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Notes from the outgoing shift: ${_notes.text.trim()}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final open = AppData.openTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Shift Handover')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('14 Nov 2026'),
                  DropdownButton<String>(
                    value: _shift,
                    items: const [
                      DropdownMenuItem(
                        value: 'Morning to Evening',
                        child: Text('Morning to Evening'),
                      ),
                      DropdownMenuItem(
                        value: 'Evening to Morning',
                        child: Text('Evening to Morning'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _shift = value ?? _shift),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Handover notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unfinished tasks (from FR6)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (open.isEmpty)
                const Text('Nothing outstanding.')
              else
                for (final task in open)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      title: Text(task.title),
                      trailing: Text(
                        task.isOverdue ? 'Overdue' : task.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isOverdue ? colors.error : null,
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.aiReview,
                        arguments: {
                          'title': 'Handover note',
                          'draft': _buildDraft(),
                        },
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Draft with AI'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Handover saved')),
                        );
                      },
                      child: const Text('Save handover'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Draft with AI opens the review screen. Nothing is saved '
                'until it is approved.',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
