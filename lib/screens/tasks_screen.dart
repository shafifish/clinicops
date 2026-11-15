import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets/app_nav.dart';

/// UI-04 Task Management (FR6).
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _filter = 'All';

  static const List<String> _statuses = ['Pending', 'In progress', 'Done'];

  Future<void> _addTask() async {
    final title = TextEditingController();
    var assignee = AppData.staff.first;
    var due = DateTime(2026, 11, 16);
    var priority = 'Normal';
    var showError = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        errorText: showError ? 'Title is required' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: assignee,
                      decoration: const InputDecoration(labelText: 'Assignee'),
                      items: [
                        for (final s in AppData.staff)
                          DropdownMenuItem(value: s, child: Text(s)),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => assignee = value ?? assignee),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: const [
                        DropdownMenuItem(value: 'High', child: Text('High')),
                        DropdownMenuItem(
                          value: 'Normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => priority = value ?? priority),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Due: ${due.day}/${due.month}/${due.year}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: due,
                              firstDate: DateTime(2026),
                              lastDate: DateTime(2027, 12, 31),
                            );
                            if (picked != null) {
                              setDialogState(() => due = picked);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (title.text.trim().isEmpty) {
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
      setState(() {
        AppData.tasks.add(
          Task(
            title: title.text.trim(),
            assignee: assignee,
            due: due,
            priority: priority,
          ),
        );
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created')),
      );
    }
    title.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    var tasks = [...AppData.tasks];
    if (_filter != 'All') {
      tasks = tasks.where((t) => t.status == _filter).toList();
    }
    tasks.sort((a, b) {
      if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
      return a.due.compareTo(b.due);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      bottomNavigationBar: const AppNav(current: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final f in ['All', ..._statuses])
                    ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No tasks here yet')),
                ),
              for (final task in tasks)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.assignee} - due '
                      '${task.due.day}/${task.due.month}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.isOverdue)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Chip(
                              label: const Text(
                                'Overdue',
                                style: TextStyle(fontSize: 11),
                              ),
                              backgroundColor: colors.errorContainer,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        PopupMenuButton<String>(
                          initialValue: task.status,
                          onSelected: (value) {
                            setState(() => task.status = value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${task.title}: $value'),
                              ),
                            );
                          },
                          itemBuilder: (context) => [
                            for (final s in _statuses)
                              PopupMenuItem(value: s, child: Text(s)),
                          ],
                          child: Chip(
                            label: Text(
                              task.status,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Overdue first. Tasks that are not Done appear in the '
                'handover (FR7).',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
