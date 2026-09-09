import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaw/app/theme.dart';
import 'package:yaw/features/admin/shared/admin_app_bar.dart';
import 'package:yaw/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:yaw/shared/models/vehicle.dart';

class AdminVehicleFormPage extends ConsumerStatefulWidget {
  const AdminVehicleFormPage({super.key, this.id});
  final String? id;

  @override
  ConsumerState<AdminVehicleFormPage> createState() => _AdminVehicleFormPageState();
}

class _AdminVehicleFormPageState extends ConsumerState<AdminVehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _imagesCtrl = TextEditingController();
  String? _categoryId;
  String? _transmission;
  String? _fuelType;
  bool _isAvailable = true;
  bool _saving = false;

  static const _transmissions = ['Automatic', 'Manual', 'CVT', 'e-CVT', 'Dual-clutch', 'Single-Speed'];
  static const _fuels = ['Petrol', 'Hybrid', 'Electric', 'Diesel'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final v = ref.read(vehicleDetailProvider(widget.id!)).value;
        if (v != null) _populate(v);
      });
    }
  }

  void _populate(Vehicle v) {
    _nameCtrl.text = v.name;
    _brandCtrl.text = v.brand;
    _modelCtrl.text = v.model;
    _yearCtrl.text = v.year.toString();
    _priceCtrl.text = v.price.toStringAsFixed(0);
    _stockCtrl.text = v.stock.toString();
    _descCtrl.text = v.description ?? '';
    _engineCtrl.text = v.engine ?? '';
    _colorCtrl.text = v.color ?? '';
    _imagesCtrl.text = v.images.join(', ');
    _categoryId = v.categoryId;
    _transmission = v.transmission;
    _fuelType = v.fuelType;
    _isAvailable = v.isAvailable;
    setState(() {});
  }

  Map<String, dynamic> _toMap() => {
        'category_id': _categoryId,
        'name': _nameCtrl.text.trim(),
        'brand': _brandCtrl.text.trim(),
        'model': _modelCtrl.text.trim(),
        'year': int.tryParse(_yearCtrl.text.trim()) ?? 0,
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
        'description': _descCtrl.text.trim(),
        'engine': _engineCtrl.text.trim(),
        'transmission': _transmission,
        'fuel_type': _fuelType,
        'color': _colorCtrl.text.trim(),
        'is_available': _isAvailable,
        'images': _imagesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      };

  String _priceLabel() => widget.id == null ? 'Tambah Kendaraan' : 'Edit Kendaraan';

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AdminAppBar(title: _priceLabel()),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: YawColors.primary)),
        error: (e, _) => Center(child: Text('Gagal memuat kategori: $e', style: const TextStyle(color: YawColors.error))),
        data: (cats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kendaraan'), validator: _required),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'Brand'), validator: _required)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _modelCtrl, decoration: const InputDecoration(labelText: 'Model'), validator: _required)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null || v.isEmpty ? 'Pilih kategori' : null,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFormField(controller: _yearCtrl, decoration: const InputDecoration(labelText: 'Tahun'), keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v?.trim() ?? '') ?? 0) <= 0 ? 'Wajib angka valid' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Harga', prefixText: 'Rp '), keyboardType: TextInputType.number, validator: (v) => (double.tryParse(v?.trim() ?? '') ?? 0) <= 0 ? 'Wajib angka valid' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number, validator: (v) => (int.tryParse(v?.trim() ?? '') ?? -1) < 0 ? 'Wajib angka valid' : null)),
                ]),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: _transmission, decoration: const InputDecoration(labelText: 'Transmisi'), items: _transmissions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _transmission = v)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: _fuelType, decoration: const InputDecoration(labelText: 'Bahan Bakar'), items: _fuels.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(), onChanged: (v) => setState(() => _fuelType = v)),
                const SizedBox(height: 12),
                TextFormField(controller: _engineCtrl, decoration: const InputDecoration(labelText: 'Mesin / Kapasitas'), validator: _optionalStr),
                const SizedBox(height: 12),
                TextFormField(controller: _colorCtrl, decoration: const InputDecoration(labelText: 'Warna')),
                const SizedBox(height: 12),
                TextFormField(controller: _imagesCtrl, decoration: const InputDecoration(labelText: 'Gambar (URL, pisahkan koma)', hintText: 'https://example.com/img1.jpg, https://example.com/img2.jpg')),
                const SizedBox(height: 12),
                TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 4, validator: _optionalStr),
                const SizedBox(height: 20),
                Row(children: [
                  Switch(value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v), activeColor: YawColors.primary),
                  const SizedBox(width: 8),
                  const Text('Tersedia', style: TextStyle(color: YawColors.textMuted)),
                  const Spacer(),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: YawColors.background))
                          : Text(widget.id == null ? 'SIMPAN' : 'PERBARUI'),
                    ),
                  ),
                ],
            ),
              ]),
            ),
          );
        },
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;
  String? _optionalStr(String? v) => null;

  Future<void> _submit() async {
    final f = _formKey.currentState;
    if (f == null || !f.validate()) return;
    final repo = ref.read(vehicleRepositoryProvider);
    setState(() => _saving = true);
    try {
      if (widget.id == null) {
        await repo.createVehicle(_toMap());
      } else {
        await repo.updateVehicle(widget.id!, _toMap());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(widget.id == null ? 'Kendaraan ditambahkan' : 'Kendaraan diperbarui', YawColors.success));
      ref.invalidate(vehicleListProvider);
      if (widget.id != null) ref.invalidate(vehicleDetailProvider(widget.id!));
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(e.toString(), YawColors.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  SnackBar _snack(String msg, Color bg) => SnackBar(
        content: Text(msg, style: const TextStyle(color: YawColors.textPrimary)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: YawColors.border)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
}
