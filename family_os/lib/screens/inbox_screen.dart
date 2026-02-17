import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_provider.dart';
import '../services/parser_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  final _textController = TextEditingController();
  final _parser = ParserService();
  ParseResult? _result;
  bool _isParsing = false;
  String? _selectedChildId;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _parse() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _isParsing = true;
      _result = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _result = _parser.parse(
          _textController.text,
          childId: _selectedChildId,
        );
        _isParsing = false;
      });
      AppHelpers.hapticMedium();
    });
  }

  Future<void> _saveAll() async {
    if (_result == null || !_result!.hasContent) return;

    final service = ref.read(firebaseServiceProvider);
    final familyId = await ref.read(familyIdProvider.future);
    final userId = ref.read(currentUserProvider)?.uid ?? '';
    if (familyId == null) return;

    for (final event in _result!.events) {
      await service.addEvent(
        familyId,
        event.copyWith(familyId: familyId, createdBy: userId),
      );
    }

    for (final task in _result!.tasks) {
      await service.addTask(
        familyId,
        task.copyWith(familyId: familyId, createdBy: userId),
      );
    }

    if (mounted) {
      AppHelpers.hapticHeavy();
      AppHelpers.showSnackBar(
        context,
        'Saved ${_result!.events.length} events + ${_result!.tasks.length} tasks',
      );
      setState(() {
        _result = null;
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = ref.watch(childrenProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Inbox'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paste any message',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'I\'ll extract events, tasks & payments automatically',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Example hint
            Text(
              'Example: "מחר טיול – צריך נעלי הליכה, 50 ש"ח, חזור 17:00"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),

            const SizedBox(height: 12),

            // Text input
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Paste WhatsApp message, SMS, or teacher note here...',
                hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Child selector
            if (children.isNotEmpty)
              Wrap(
                spacing: 8,
                children: [
                  _Chip(
                    label: '👨‍👩‍👧‍👦 Family',
                    isSelected: _selectedChildId == null,
                    onTap: () => setState(() => _selectedChildId = null),
                  ),
                  ...children.map((c) => _Chip(
                        label: '${c.emoji} ${c.name}',
                        isSelected: _selectedChildId == c.id,
                        onTap: () =>
                            setState(() => _selectedChildId = c.id),
                        color: AppHelpers.hexToColor(c.colorHex),
                      )),
                ],
              ),

            const SizedBox(height: 16),

            // Parse button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isParsing ? null : _parse,
                icon: _isParsing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_fix_high_rounded),
                label: Text(_isParsing ? 'Parsing...' : 'Parse message'),
              ),
            ),

            // ─── Parse Result ─────────────────────────────────────────────
            if (_result != null && _result!.hasContent) ...[
              const SizedBox(height: 24),
              Text(
                '✨ Extracted from your message:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),

              // Parsed date
              if (_result!.parsedDate != null)
                _ResultItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date: ${AppHelpers.formatRelative(_result!.parsedDate!)}',
                  color: AppColors.accent,
                ),

              // Events
              ..._result!.events.map(
                (e) => _ResultItem(
                  icon: Icons.event_rounded,
                  label: '${e.type.emoji} ${e.title} • ${AppHelpers.formatTime(e.startDate)}',
                  color: AppHelpers.hexToColor(e.type.colorHex),
                ),
              ),

              // Items/Tasks
              ..._result!.items.map(
                (item) => _ResultItem(
                  icon: Icons.check_circle_outline_rounded,
                  label: item,
                  color: AppColors.success,
                ),
              ),

              // Amount
              if (_result!.amount != null)
                _ResultItem(
                  icon: Icons.payments_outlined,
                  label: 'Payment: ${AppHelpers.formatAmount(_result!.amount!)}',
                  color: AppColors.warning,
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _result = null),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveAll,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save all'),
                    ),
                  ),
                ],
              ),
            ],

            if (_result != null && !_result!.hasContent)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🤔', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Couldn\'t find any events, tasks, or dates in this message. Try adding dates like "מחר" or "12/03".',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ResultItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(begin: 0.05, end: 0);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c : c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : c,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
