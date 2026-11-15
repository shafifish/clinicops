import 'package:flutter/material.dart';

import '../data.dart';

/// UI-07 AI Review (FR11 drafting, FR12 language, FR13 approval).
///
/// The draft is passed in as a route argument. Nothing here calls a real
/// AI service; the text is assembled from the stored records.
class AiReviewScreen extends StatefulWidget {
  const AiReviewScreen({super.key});

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  final _draft = TextEditingController();
  bool _editing = false;
  bool _loaded = false;
  String _language = 'English';
  String _title = 'Draft';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _title = args['title'] as String? ?? _title;
      _draft.text = args['draft'] as String? ?? '';
    }
    _loaded = true;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  void _approve() {
    final messenger = ScaffoldMessenger.of(context);
    AppData.reports.insert(
      0,
      SavedReport(
        title: _title,
        date: '14 Nov 2026',
        approvedBy: AppData.currentUser,
        body: _draft.text,
      ),
    );
    Navigator.pop(context, _draft.text);
    messenger.showSnackBar(
      SnackBar(content: Text('$_title approved and saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Review')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.onSecondaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Draft, not saved. Check every figure against the '
                        'records before approving.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Language'),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'English', label: Text('English')),
                      ButtonSegment(value: 'BM', label: Text('B. Malaysia')),
                    ],
                    selected: {_language},
                    onSelectionChanged: (selection) {
                      setState(() => _language = selection.first);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language set to $_language'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _editing ? 'Draft (editing)' : 'Draft',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _draft,
                readOnly: !_editing,
                maxLines: 12,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text('Regenerated from stored records'),
                            ),
                          ),
                      child: const Text('Regenerate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _editing = !_editing),
                      child: Text(_editing ? 'Done' : 'Edit'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _approve,
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Nothing is stored until Approve is tapped (NFR5, '
                'constraint C7).',
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
