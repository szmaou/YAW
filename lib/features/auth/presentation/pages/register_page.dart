import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/yaw_button.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _S();
}
class _S extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool _loading=false; String? _err;
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(()=> _loading=true);
    try { await ref.read(authProvider.notifier).register(_name.text.trim(), _email.text.trim(), _pass.text, phone: _phone.text.trim().isEmpty? null : _phone.text.trim()); if(mounted) context.go('/home'); }
    catch(e){ setState(()=> _err=e.toString()); }
    finally{ if(mounted) setState(()=> _loading=false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 12),
          Center(child: Container(width:56,height:56,decoration: BoxDecoration(color: YawColors.primary, borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('Y', style: TextStyle(fontWeight: FontWeight.w900, fontSize:28, color: YawColors.background))))),
          const SizedBox(height:12),
          const Center(child: Text('Buat Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize:18))),
          const Center(child: Text('Bergabung dengan YAW', style: TextStyle(color: YawColors.textMuted, fontSize:12))),
          const SizedBox(height:20),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: YawColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: YawColors.border)),
            child: Form(key:_form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if(_err!=null) Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: YawColors.error.withValues(alpha:.12), borderRadius: BorderRadius.circular(10)), child: Text(_err!, style: const TextStyle(color: YawColors.error, fontSize:12))),
              if(_err!=null) const SizedBox(height:12),
              TextFormField(controller:_name, decoration: const InputDecoration(labelText:'Nama lengkap', prefixIcon: Icon(Icons.person_outline,size:18)), validator: (v)=> Validators.required(v,'Nama')),
              const SizedBox(height:12),
              TextFormField(controller:_email, decoration: const InputDecoration(labelText:'Email', prefixIcon: Icon(Icons.mail_outline,size:18)), validator: Validators.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height:12),
              TextFormField(controller:_phone, decoration: const InputDecoration(labelText:'No. HP (opsional)', prefixIcon: Icon(Icons.phone_outlined,size:18)), validator: Validators.phone, keyboardType: TextInputType.phone),
              const SizedBox(height:12),
              TextFormField(controller:_pass, obscureText:true, decoration: const InputDecoration(labelText:'Password', prefixIcon: Icon(Icons.lock_outline,size:18)), validator: Validators.password),
              const SizedBox(height:16),
              YawButton(label:'DAFTAR', isLoading:_loading, onPressed:_submit, expand:true),
            ]))),
          const SizedBox(height:12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Sudah punya akun?', style: TextStyle(color: YawColors.textMuted,fontSize:13)),
            TextButton(onPressed: ()=> context.go('/login'), child: const Text('Masuk', style: TextStyle(color: YawColors.primary, fontWeight: FontWeight.w700))),
          ])
        ])))),
    );
  }
}
