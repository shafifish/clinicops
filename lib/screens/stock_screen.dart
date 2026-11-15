import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets/app_nav.dart';

/// UI-03 Stock Counting. Count tab = FR1 to FR3, History tab = FR4.
class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  String _historyFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stock Counting'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Count'), Tab(text: 'History')],
          ),
        ),
        bottomNavigationBar: const AppNav(current: 1),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: TabBarView(
              children: [_buildCountTab(), _buildHistoryTab()],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ Count tab
  Widget _buildCountTab() {
    final session = AppData.currentSession;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Session: ${session.date}'),
            OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import not available in the prototype'),
                ),
              ),
              child: const Text('Import expected'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              flex: 4,
              child: Text(
                'Medicine',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              width: 64,
              child: Text(
                'Count',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              width: 44,
              child: Text(
                'Exp.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                'Diff',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const Divider(),
        for (final line in session.lines) _CountRow(line: line, onChanged: _refresh),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text('${session.discrepancies} discrepancies'),
              backgroundColor: session.discrepancies > 0
                  ? colors.errorContainer
                  : colors.surfaceContainerHighest,
            ),
            Text('${session.itemsCounted} of ${session.lines.length} items'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _toast('Draft saved'),
                child: const Text('Save draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => _toast('Count finished'),
                child: const Text('Finish count'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _refresh() => setState(() {});

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------- History tab
  Widget _buildHistoryTab() {
    final filters = ['All', 'With discrepancies'];
    var sessions = AppData.pastSessions;
    if (_historyFilter == 'With discrepancies') {
      sessions = sessions.where((s) => s.discrepancies > 0).toList();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final f in filters)
              ChoiceChip(
                label: Text(f),
                selected: _historyFilter == f,
                onSelected: (_) => setState(() => _historyFilter = f),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No sessions in this filter')),
          ),
        for (final session in sessions)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(session.date),
              subtitle: Text(
                '${session.counter} - ${session.itemsCounted} items counted',
              ),
              trailing: Text(
                session.discrepancies == 0
                    ? 'No discrepancies'
                    : '${session.discrepancies} diff',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => _openSession(session),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Read only. Tap a session to see counted, expected and difference.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _openSession(CountSession session) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            session.date,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('Counted by ${session.counter}'),
          const Divider(height: 24),
          for (final line in session.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(line.medicine)),
                  SizedBox(width: 48, child: Text('${line.counted ?? '-'}')),
                  SizedBox(width: 48, child: Text('${line.expected}')),
                  SizedBox(
                    width: 48,
                    child: Text(
                      line.difference == null
                          ? '-'
                          : (line.difference! > 0
                                ? '+${line.difference}'
                                : '${line.difference}'),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: line.difference != null &&
                                line.difference != 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.line, required this.onChanged});

  final CountLine line;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final diff = line.difference;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(line.medicine)),
          SizedBox(
            width: 64,
            child: TextFormField(
              initialValue: line.counted?.toString() ?? '',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                line.counted = int.tryParse(value);
                onChanged();
              },
            ),
          ),
          SizedBox(width: 44, child: Center(child: Text('${line.expected}'))),
          SizedBox(
            width: 44,
            child: Text(
              diff == null ? '-' : (diff > 0 ? '+$diff' : '$diff'),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: diff != null && diff != 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
