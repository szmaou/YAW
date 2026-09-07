import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/yaw_button.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _S();
}
class _S extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'admin@yaw.id');
  final _pass = TextEditingController(text: 'admin123');
  bool _obscure = true;
  bool _loading = false;
  String? _err;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _err = null; });
    try {
      await ref.read(authProvider.notifier).login(_email.text.trim(), _pass.text);
      if (mounted) context.go('/home');
    } catch (e) { setState(() => _err = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 24),
              Center(child: Container(width: 56, height: 56,
                decoration: BoxDecoration(color: YawColors.primary, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('Y', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: YawColors.background))))),
              const SizedBox(height: 16),
              const Center(child: Text('YAW', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 6, fontSize: 20))),
              const Center(child: Text('Welcome back', style: TextStyle(color: YawColors.textMuted, fontSize: 13))),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: YawColors.border)),
                child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (_err != null) Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: YawColors.error.withValues(alpha: .12), borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.error.withValues(alpha: .3))),
                    child: Text(_err!, style: const TextStyle(color: YawColors.error, fontSize: 12)),
                  ),
                  if (_err != null) const SizedBox(height: 12),
                  TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline, size: 18)), validator: Validators.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextFormField(controller: _pass, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline, size: 18), suffixIcon: IconButton(icon: Icon(_obscure? Icons.visibility_off: Icons.visibility, size: 18), onPressed: ()=> setState(()=> _obscure=!_obscure))), validator: Validators.password),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: (){}, child: const Text('Lupa password?', style: TextStyle(color: YawColors.primary, fontSize: 12)))),
                  const SizedBox(height: 8),
                  YawButton(label: 'MASUK', isLoading: _loading, onPressed: _submit, expand: true, icon: Icons.arrow_forward_rounded),
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: YawColors.surface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: YawColors.border)),
                    child: const Text('Demo: admin@yaw.id / admin123  •  user apapun dengan pass >=6 karakter (mock offline)', style: TextStyle(fontSize: 11, color: YawColors.textMuted), textAlign: TextAlign.center)),
                ])),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Belum punya akun?', style: TextStyle(color: YawColors.textMuted, fontSize: 13)),
                TextButton(onPressed: ()=> context.go('/register'), child: const Text('Daftar', style: TextStyle(color: YawColors.primary, fontWeight: FontWeight.w700))),
              ]),
              TextButton(onPressed: ()=> context.go('/vehicles'), child: const Text('Jelajahi sebagai tamu →', style: TextStyle(color: YawColors.textDim, fontSize: 12))),
            ]),
          ),
        ),
      ),
    );
  }
}
