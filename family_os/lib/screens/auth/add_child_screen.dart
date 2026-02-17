import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/child.dart';
import '../../providers/auth_provider.dart';
import '../../providers/family_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/theme.dart';

class AddChildScreen extends ConsumerStatefulWidget {
  final bool isFirst;
  final Child? existingChild;

  const AddChildScreen({
    super.key,
    this.isFirst = false,
    this.existingChild,
  });

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  int _age = 8;
  String _selectedColor = Child.colors.first;
  String _selectedEmoji = Child.emojis.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingChild != null) {
      final c = widget.existingChild!;
      _nameController.text = c.name;
      _schoolController.text = c.school;
      _classController.text = c.className;
      _age = c.age;
      _selectedColor = c.colorHex;
      _selectedEmoji = c.emoji;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      final familyId = await ref.read(familyIdProvider.future);
      if (familyId == null) return;

      final child = Child(
        id: widget.existingChild?.id ?? const Uuid().v4(),
        familyId: familyId,
        name: _nameController.text.trim(),
        age: _age,
        school: _schoolController.text.trim(),
        className: _classController.text.trim(),
        colorHex: _selectedColor,
        emoji: _selectedEmoji,
        createdAt: widget.existingChild?.createdAt ?? DateTime.now(),
      );

      if (widget.existingChild != null) {
        await service.updateChild(familyId, child);
      } else {
        await service.addChild(familyId, child);
      }

      if (mounted) {
        if (widget.isFirst) {
          context.go(AppRoutes.dashboard);
        } else {
          context.pop();
        }
      }
    } on Exception catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingChild != null ? 'Edit child' : 'Add child'),
        leading: widget.isFirst
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFirst) ...[
                Text(
                  "Add your first child 👶",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 6),
                Text(
                  'You can always add more later',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                      ),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 32),
              ],

              // Emoji + Color picker
              Center(
                child: Column(
                  children: [
                    // Current selection preview
                    AnimatedContainer(
                      duration: 300.ms,
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppHelpers.hexToColor(_selectedColor)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppHelpers.hexToColor(_selectedColor),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Emoji selector
                    Wrap(
                      spacing: 8,
                      children: Child.emojis.map((e) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = e),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _selectedEmoji == e
                                  ? AppColors.accent.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedEmoji == e
                                    ? AppColors.accent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                                child: Text(e,
                                    style: const TextStyle(fontSize: 22))),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Color selector
                    Wrap(
                      spacing: 8,
                      children: Child.colors.map((hex) {
                        final color = AppHelpers.hexToColor(hex);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = hex),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == hex
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: _selectedColor == hex
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Child's name",
                  prefixIcon: Icon(Icons.child_care_outlined),
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) >= 2 ? null : 'Enter name',
              ),

              const SizedBox(height: 16),

              // Age slider
              Text(
                'Age: $_age years',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Slider(
                value: _age.toDouble(),
                min: 3,
                max: 18,
                divisions: 15,
                label: '$_age',
                onChanged: (v) => setState(() => _age = v.round()),
              ),

              const SizedBox(height: 16),

              // School
              TextFormField(
                controller: _schoolController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'School name',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) >= 2 ? null : 'Enter school',
              ),

              const SizedBox(height: 16),

              // Class
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  labelText: 'Class / Grade',
                  hintText: 'e.g., 3B, Grade 5',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) >= 1 ? null : 'Enter class',
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.existingChild != null ? 'Save changes' : 'Add child',
                        ),
                ),
              ),

              if (widget.isFirst) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    child: const Text('Skip for now →'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
