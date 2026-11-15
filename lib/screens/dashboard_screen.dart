import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data.dart';
import '../widgets/app_nav.dart';

/// UI-02 Dashboard (FR5 daily activity, FR6 task summary).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _addActivity() async {
    final typeOptions = ['Delivery', 'Maintenance', 'Patient care', 'Note'];
    var type = typeOptions.first;
    final description = TextEditingController();
    var showError = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add activity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      for (final t in typeOptions)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => type = value ?? type),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      errorText: showError ? 'Description is required' : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (description.text.trim().isEmpty) {
                      setDialogState(() => showError = true);
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved ?? false) {
      final now = TimeOfDay.now();
      final stamp =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
      setState(() {
        AppData.activities.add(
          Activity(
            time: stamp,
            type: type,
            description: description.text.trim(),
            author: AppData.currentUser,
          ),
        );
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity saved')),
      );
    }
    description.dispose();
  }

  void _showAllDates() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            'All activity by date',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          for (final date in ['14 Nov 2026', '13 Nov 2026', '12 Nov 2026'])
            ListTile(
              dense: true,
              leading: const Icon(Icons.calendar_today, size: 18),
              title: Text(date),
              subtitle: Text(
                date == '14 Nov 2026'
                    ? '${AppData.activities.length} entries'
                    : '2 entries',
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      bottomNavigationBar: const AppNav(current: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Good morning, ${AppData.currentUser}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      value: '${AppData.unresolvedDiscrepancies}',
                      label: 'Unresolved\ndiscrepancies',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.stock),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      value: '${AppData.openTasks.length}',
                      label: '${AppData.overdueCount} overdue',
                      heading: 'Open tasks',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.tasks),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's activity",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: _showAllDates,
                    child: const Text('View all'),
                  ),
                ],
              ),
              for (final activity in AppData.activities)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${activity.time}  ${activity.type}'),
                    subtitle: Text(activity.description),
                    trailing: activity.pendingSync
                        ? const Chip(
                            label: Text(
                              'Pending sync',
                              style: TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                          )
                        : Text(
                            activity.author,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addActivity,
                      icon: const Icon(Icons.add),
                      label: const Text('Add activity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.handover),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Handover'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Activities recorded here feed report generation (FR8) and '
                'AI drafting (FR11).',
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

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.onTap,
    this.heading,
  });

  final String value;
  final String label;
  final String? heading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              if (heading != null)
                Text(
                  heading!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(
                label,
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
