import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data.dart';
import '../widgets/app_nav.dart';

/// UI-06 Reports (FR8 generation, FR9 PDF export).
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _includeCounts = true;
  bool _includeActivities = true;
  bool _includeTasks = true;
  String? _preview;

  String _buildDraft() {
    final session = AppData.currentSession;
    final buffer = StringBuffer('Daily report, 14 Nov 2026.\n\n');

    if (_includeCounts) {
      buffer.writeln(
        'Stock: ${session.itemsCounted} of ${session.lines.length} items '
        'counted, ${session.discrepancies} discrepancies found.',
      );
      for (final line in session.lines) {
        final diff = line.difference;
        if (diff != null && diff != 0) {
          buffer.writeln(
            '  - ${line.medicine}: ${diff > 0 ? '+$diff' : '$diff'}',
          );
        }
      }
      buffer.writeln();
    }
    if (_includeActivities) {
      buffer.writeln('Activities: ${AppData.activities.length} recorded.');
      for (final a in AppData.activities) {
        buffer.writeln('  - ${a.time} ${a.type}: ${a.description}');
      }
      buffer.writeln();
    }
    if (_includeTasks) {
      buffer.writeln(
        'Tasks: ${AppData.openTasks.length} open, '
        '${AppData.overdueCount} overdue.',
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Report history',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.reportHistory),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      bottomNavigationBar: const AppNav(current: 3),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Period',
                  hintText: '14 Nov 2026 to 14 Nov 2026',
                ),
              ),
              const SizedBox(height: 16),
              Text('Include', style: Theme.of(context).textTheme.titleMedium),
              CheckboxListTile(
                dense: true,
                value: _includeCounts,
                title: const Text('Stock counts (FR1 to FR4)'),
                onChanged: (v) =>
                    setState(() => _includeCounts = v ?? true),
              ),
              CheckboxListTile(
                dense: true,
                value: _includeActivities,
                title: const Text('Daily activities (FR5)'),
                onChanged: (v) =>
                    setState(() => _includeActivities = v ?? true),
              ),
              CheckboxListTile(
                dense: true,
                value: _includeTasks,
                title: const Text('Tasks (FR6)'),
                onChanged: (v) => setState(() => _includeTasks = v ?? true),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.aiReview,
                    arguments: {
                      'title': 'Daily report',
                      'draft': _buildDraft(),
                    },
                  );
                  if (result is String) {
                    setState(() => _preview = result);
                  }
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate draft with AI'),
              ),
              const SizedBox(height: 16),
              Text('Preview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 110),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _preview ?? 'No report generated yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _preview == null ? colors.onSurfaceVariant : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _preview == null ? null : () => _toast(
                        'Report saved',
                      ),
                      child: const Text('Save report'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _preview == null ? null : () => _toast(
                        'PDF export is not wired up in the prototype',
                      ),
                      child: const Text('Export PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
