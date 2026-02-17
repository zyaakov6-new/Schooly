import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/theme.dart';

class CreateFamilyScreen extends ConsumerStatefulWidget {
  const CreateFamilyScreen({super.key});

  @override
  ConsumerState<CreateFamilyScreen> createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends ConsumerState<CreateFamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _isLoading = false;
  bool _showJoin = false;

  @override
  void dispose() {
    _nameController.dispose();
    _inviteController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      final family = await service.createFamily(_nameController.text.trim());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFamilyId, family.id);

      if (mounted) {
        context.go('${AppRoutes.addChild}?first=true');
      }
    } on Exception catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinFamily() async {
    if (_inviteController.text.trim().length != 6) {
      AppHelpers.showSnackBar(context, 'Enter a valid 6-character code',
          isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      final service = ref.read(firebaseServiceProvider);
      final code = _inviteController.text.trim().toUpperCase();
      final family = await service.getFamilyByInviteCode(code);

      if (family == null) {
        if (mounted) {
          AppHelpers.showSnackBar(context, 'Invalid invite code', isError: true);
        }
        return;
      }

      await service.joinFamily(family.id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyFamilyId, family.id);

      if (mounted) context.go(AppRoutes.dashboard);
    } on Exception catch (e) {
      if (mounted) AppHelpers.showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏠', style: const TextStyle(fontSize: 56))
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 20),

              Text(
                _showJoin ? 'Join family' : 'Create your family',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 6),

              Text(
                _showJoin
                    ? 'Enter the invite code your partner shared'
                    : 'Set up your family space in FamilyOS',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
              ).animate(delay: 150.ms).fadeIn(),

              const SizedBox(height: 40),

              if (!_showJoin) ...[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Family name',
                      hintText: 'e.g., The Cohen Family',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    validator: (v) =>
                        (v?.trim().length ?? 0) >= 2 ? null : 'Enter family name',
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createFamily,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Family'),
                  ),
                ).animate(delay: 250.ms).fadeIn(),
              ] else ...[
                TextFormField(
                  controller: _inviteController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Invite code',
                    hintText: 'ABC123',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _joinFamily,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Join Family'),
                  ),
                ).animate(delay: 250.ms).fadeIn(),
              ],

              const SizedBox(height: 32),

              Center(
                child: TextButton(
                  onPressed: () => setState(() => _showJoin = !_showJoin),
                  child: Text(
                    _showJoin
                        ? 'Create a new family instead'
                        : 'Have an invite code? Join family →',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
