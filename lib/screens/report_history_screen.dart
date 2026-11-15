import 'package:flutter/material.dart';

import '../data.dart';

/// UI-08 Report History (FR10).
class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  String _filter = 'All';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    var reports = AppData.reports.where((r) {
      final matchesFilter = _filter == 'All' || r.title.startsWith(_filter);
      final matchesSearch =
          _search.isEmpty || r.date.toLowerCase().contains(_search);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Report History')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by date',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) =>
                    setState(() => _search = value.toLowerCase()),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in ['All', 'Daily', 'Handover'])
                    ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No saved reports match')),
                ),
              for (final report in reports)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(report.title),
                    subtitle: Text(
                      '${report.date} - approved by ${report.approvedBy}',
                    ),
                    trailing: const Chip(
                      label: Text('PDF', style: TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onTap: () => _open(report),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Owner and staff can open a saved report or export it again '
                '(FR9).',
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

  void _open(SavedReport report) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${report.title}, ${report.date}'),
        content: SingleChildScrollView(
          child: Text(report.body, style: const TextStyle(fontSize: 13)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
