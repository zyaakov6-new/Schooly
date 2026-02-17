import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/children_provider.dart';
import '../providers/family_provider.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final String? preselectedChildId;
  final FamilyTask? existingTask;

  const AddTaskScreen({
    super.key,
    this.preselectedChildId,
    this.existingTask,
  });

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _dueDate;
  DateTime? _reminderDate;
  TaskPriority _priority = TaskPriority.medium;
  String? _selectedChildId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.preselectedChildId;
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description ?? '';
      _amountController.text = t.amount?.toString() ?? '';
      _dueDate = t.dueDate;
      _reminderDate = t.reminderDate;
      _priority = t.priority;
      _selectedChildId = t.childId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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

      final task = FamilyTask(
        id: widget.existingTask?.id ?? const Uuid().v4(),
        familyId: familyId,
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        dueDate: _dueDate,
        childId: _selectedChildId,
        priority: _priority,
        status: widget.existingTask?.status ?? TaskStatus.pending,
        reminderDate: _reminderDate,
        amount: _amountController.text.trim().isEmpty
            ? null
            : double.tryParse(_amountController.text.trim()),
        createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
        createdBy: userId,
      );

      if (widget.existingTask != null) {
        await service.updateTask(familyId, task);
      } else {
        await service.addTask(familyId, task);
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

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTask != null ? 'Edit task' : 'New task'),
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
              child: const Text('Save',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.accent)),
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
              // Title
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  prefixIcon: Icon(Icons.task_alt_rounded),
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) >= 2 ? null : 'Enter title',
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              // Priority
              Text(
                'Priority',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((p) {
                  final color = AppHelpers.hexToColor(p.colorHex);
                  final selected = _priority == p;
                  return GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text(
                        p.label,
                        style: TextStyle(
                          color: selected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Child selector
              if (children.isNotEmpty) ...[
                Text(
                  'Assign to',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      label: 'Anyone',
                      isSelected: _selectedChildId == null,
                      onTap: () => setState(() => _selectedChildId = null),
                    ),
                    ...children.map(
                      (c) => _Chip(
                        label: '${c.emoji} ${c.name}',
                        isSelected: _selectedChildId == c.id,
                        onTap: () => setState(() => _selectedChildId = c.id),
                        color: AppHelpers.hexToColor(c.colorHex),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Due date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.calendar_today_rounded,
                  color:
                      _dueDate != null ? AppColors.accent : AppColors.lightTextSecondary,
                ),
                title: Text(
                  _dueDate != null
                      ? 'Due: ${AppHelpers.formatRelative(_dueDate!)}'
                      : 'Set due date (optional)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _dueDate != null
                            ? null
                            : AppColors.lightTextSecondary,
                      ),
                ),
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _dueDate = null),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: _pickDueDate,
              ),

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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: Text(
                    widget.existingTask != null ? 'Save changes' : 'Add task',
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
