import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_provider.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final String? preselectedChildId;
  final FamilyEvent? existingEvent;

  const AddEventScreen({
    super.key,
    this.preselectedChildId,
    this.existingEvent,
  });

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  EventType _selectedType = EventType.school;
  String? _selectedChildId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.preselectedChildId;
    if (widget.existingEvent != null) {
      final e = widget.existingEvent!;
      _titleController.text = e.title;
      _locationController.text = e.location ?? '';
      _notesController.text = e.notes ?? '';
      _amountController.text = e.amount?.toString() ?? '';
      _startDate = e.startDate;
      _endDate = e.endDate;
      _selectedType = e.type;
      _selectedChildId = e.childId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      final familyId = await ref.read(familyIdProvider.future);
      final userId = ref.read(currentUserProvider)?.uid ?? '';
      if (familyId == null) return;

      final event = FamilyEvent(
        id: widget.existingEvent?.id ?? const Uuid().v4(),
        familyId: familyId,
        title: _titleController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        childId: _selectedChildId,
        type: _selectedType,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        amount: _amountController.text.trim().isEmpty
            ? null
            : double.tryParse(_amountController.text.trim()),
        createdAt: widget.existingEvent?.createdAt ?? DateTime.now(),
        createdBy: userId,
      );

      if (widget.existingEvent != null) {
        await service.updateEvent(familyId, event);
      } else {
        await service.addEvent(familyId, event);
      }

      if (mounted) {
        AppHelpers.hapticMedium();
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate({bool isEnd = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isEnd ? (_endDate ?? _startDate) : _startDate),
    );

    if (time == null) return;
    final dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);

    setState(() {
      if (isEnd) {
        _endDate = dt;
      } else {
        _startDate = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider).valueOrNull ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEvent != null ? 'Edit event' : 'New event'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.accent),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event type selector
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: EventType.values.map((type) {
                    final selected = _selectedType == type;
                    final color = AppHelpers.hexToColor(type.colorHex);
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color
                              : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? color : color.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(type.emoji,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              type.label,
                              style: TextStyle(
                                color: selected ? Colors.white : color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Event title',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) >= 2 ? null : 'Enter title',
              ),

              const SizedBox(height: 16),

              // Start date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded,
                    color: AppColors.accent),
                title: Text(
                  'Starts: ${AppHelpers.formatDate(_startDate)} ${AppHelpers.formatTime(_startDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _pickDate(),
              ),

              // End date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.schedule_outlined,
                    color: _endDate != null
                        ? AppColors.accent
                        : AppColors.lightTextSecondary),
                title: Text(
                  _endDate != null
                      ? 'Ends: ${AppHelpers.formatDate(_endDate!)} ${AppHelpers.formatTime(_endDate!)}'
                      : 'Add end time (optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _endDate != null
                            ? null
                            : AppColors.lightTextSecondary,
                      ),
                ),
                trailing: _endDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _endDate = null),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () => _pickDate(isEnd: true),
              ),

              const Divider(),

              // Child selector
              if (children.isNotEmpty) ...[
                Text(
                  'Assign to child',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChildChip(
                      label: 'All',
                      isSelected: _selectedChildId == null,
                      onTap: () => setState(() => _selectedChildId = null),
                    ),
                    ...children.map(
                      (c) => _ChildChip(
                        label: '${c.emoji} ${c.name}',
                        isSelected: _selectedChildId == c.id,
                        onTap: () =>
                            setState(() => _selectedChildId = c.id),
                        color: AppHelpers.hexToColor(c.colorHex),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Payment amount (optional)',
                  prefixText: '₪ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: Text(
                    widget.existingEvent != null
                        ? 'Save changes'
                        : 'Add event',
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _ChildChip({
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
        duration: 200.ms,
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

extension on Duration {
  Duration get ms => Duration(milliseconds: inMilliseconds);
}
