import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ConsumerState<AdminVehicleFormPage> createState() =>
      _AdminVehicleFormPageState();
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
  String? _categoryId;
  String? _transmission;
  String? _fuelType;
  bool _isAvailable = true;
  bool _saving = false;

  // Dynamic image list — replaces the old single comma-separated field
  final List<TextEditingController> _imageCtrls = [];
  // Tracks which image rows have a valid URL for thumbnail preview
  final Map<int, bool> _imageValidity = {};

  static const _transmissions = [
    'Automatic',
    'Manual',
    'CVT',
    'e-CVT',
    'Dual-clutch',
    'Single-Speed',
  ];
  static const _fuels = ['Petrol', 'Hybrid', 'Electric', 'Diesel'];

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final v = ref.read(vehicleDetailProvider(widget.id!)).value;
        if (v != null) _populate(v);
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _engineCtrl.dispose();
    _colorCtrl.dispose();
    for (final c in _imageCtrls) {
      c.dispose();
    }
    super.dispose();
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
    _categoryId = v.categoryId;
    _transmission = v.transmission;
    _fuelType = v.fuelType;
    _isAvailable = v.isAvailable;

    // Populate image list
    for (final c in _imageCtrls) {
      c.dispose();
    }
    _imageCtrls.clear();
    _imageValidity.clear();
    if (v.images.isNotEmpty) {
      for (var i = 0; i < v.images.length; i++) {
        final ctrl = TextEditingController(text: v.images[i]);
        _imageCtrls.add(ctrl);
        _imageValidity[i] = _isValidImageUrl(v.images[i]);
      }
    }
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
        'images': _imageCtrls
            .map((c) => c.text.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };

  // --- Image list helpers ---

  bool _isValidImageUrl(String url) {
    final t = url.trim();
    return t.isNotEmpty &&
        (t.startsWith('http://') || t.startsWith('https://')) &&
        t.length > 10;
  }

  void _addImageRow() {
    setState(() {
      final idx = _imageCtrls.length;
      _imageCtrls.add(TextEditingController());
      _imageValidity[idx] = false;
    });
  }

  void _removeImageRow(int index) {
    setState(() {
      _imageCtrls[index].dispose();
      _imageCtrls.removeAt(index);
      _imageValidity.remove(index);
      // Re-key the validity map
      final newValidity = <int, bool>{};
      for (var i = 0; i < _imageCtrls.length; i++) {
        newValidity[i] = _imageValidity[i] ?? false;
      }
      _imageValidity.clear();
      _imageValidity.addAll(newValidity);
    });
  }

  void _onImageChanged(int index, String value) {
    final valid = _isValidImageUrl(value);
    if (_imageValidity[index] != valid) {
      setState(() => _imageValidity[index] = valid);
    }
  }

  // --- Price formatting helpers ---

  String _formatPriceDisplay(String raw) {
    final num = int.tryParse(raw.replaceAll(RegExp(r'[^\d]'), ''));
    if (num == null || num == 0) return raw;
    final formatted =
        num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  // --- Stock stepper ---

  void _adjustStock(int delta) {
    final current = int.tryParse(_stockCtrl.text) ?? 0;
    final next = (current + delta).clamp(0, 9999);
    setState(() => _stockCtrl.text = next.toString());
  }

  String _pageTitle() => _isEditing ? 'Edit Kendaraan' : 'Tambah Kendaraan';
  String _submitLabel() => _isEditing ? 'PERBARUI' : 'SIMPAN';

  // ──────────────────────────────────────────────
  //  Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AdminAppBar(title: _pageTitle()),
      body: catsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: YawColors.primary)),
        error: (e, _) => Center(
            child: Text('Gagal memuat kategori: $e',
                style: const TextStyle(color: YawColors.error))),
        data: (cats) => Form(
          key: _formKey,
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSection(
                        title: 'Informasi Dasar',
                        icon: Icons.directions_car_outlined,
                        children: [
                          _field(
                            controller: _nameCtrl,
                            label: 'Nama Kendaraan',
                            hint: 'Contoh: Toyota Avanza 1.5 G CVT',
                            validator: _required,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _brandCtrl,
                                  label: 'Brand',
                                  hint: 'Toyota',
                                  validator: _required,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field(
                                  controller: _modelCtrl,
                                  label: 'Model',
                                  hint: 'Avanza',
                                  validator: _required,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _categoryDropdown(cats),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Harga & Stok',
                        icon: Icons.payments_outlined,
                        children: [
                          _field(
                            controller: _priceCtrl,
                            label: 'Harga',
                            hint: '235000000',
                            prefix: const _PricePrefix(),
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                (double.tryParse(v?.trim() ?? '') ?? 0) <= 0
                                    ? 'Wajib angka valid'
                                    : null,
                            suffix: _priceCtrl.text.isNotEmpty
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12),
                                    child: Text(
                                      _formatPriceDisplay(
                                          _priceCtrl.text),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: YawColors.textDim,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // Stock stepper row
                          _buildLabel('Stok'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: YawColors.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: YawColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: Row(
                              children: [
                                _stepperBtn(
                                    icon: Icons.remove,
                                    onTap: () => _adjustStock(-1)),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stockCtrl,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                        color: YawColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                      contentPadding:
                                          EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly,
                                    ],
                                    validator: (v) =>
                                        (int.tryParse(v?.trim() ?? '') ??
                                                -1) <
                                            0
                                            ? 'Wajib angka valid'
                                            : null,
                                    onChanged: (_) =>
                                        setState(() {}),
                                  ),
                                ),
                                _stepperBtn(
                                    icon: Icons.add,
                                    onTap: () => _adjustStock(1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _field(
                            controller: _yearCtrl,
                            label: 'Tahun',
                            hint: '2024 (1900–2030)',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final y =
                                  int.tryParse(v?.trim() ?? '') ?? 0;
                              if (y <= 0) return 'Wajib angka valid';
                              if (y < 1900 || y > 2030) {
                                return 'Tahun harus antara 1900–2030';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Spesifikasi',
                        icon: Icons.tune_outlined,
                        children: [
                          _dropdownField(
                            value: _transmission,
                            label: 'Transmisi',
                            items: _transmissions,
                            onChanged: (v) =>
                                setState(() => _transmission = v),
                          ),
                          const SizedBox(height: 12),
                          _dropdownField(
                            value: _fuelType,
                            label: 'Bahan Bakar',
                            items: _fuels,
                            onChanged: (v) =>
                                setState(() => _fuelType = v),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  controller: _engineCtrl,
                                  label: 'Mesin / Kapasitas',
                                  hint: '1.5L Turbo',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field(
                                  controller: _colorCtrl,
                                  label: 'Warna',
                                  hint: 'Putih',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Tersedia switch
                          Container(
                            decoration: BoxDecoration(
                              color: YawColors.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: YawColors.border),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _isAvailable
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                  size: 20,
                                  color: _isAvailable
                                      ? YawColors.success
                                      : YawColors.textDim,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Status Ketersediaan',
                                    style: TextStyle(
                                      color: _isAvailable
                                          ? YawColors.textPrimary
                                          : YawColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _isAvailable,
                                  onChanged: (v) =>
                                      setState(() => _isAvailable = v),
                                  activeThumbColor: YawColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Media',
                        icon: Icons.photo_library_outlined,
                        children: [
                          if (_imageCtrls.isEmpty)
                            _emptyImagesHint(),
                          ...List.generate(_imageCtrls.length, (i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: _imageRow(i),
                            );
                          }),
                          const SizedBox(height: 4),
                          _addImageBtn(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'Deskripsi',
                        icon: Icons.description_outlined,
                        children: [
                          TextFormField(
                            controller: _descCtrl,
                            maxLines: 5,
                            style: const TextStyle(
                                color: YawColors.textPrimary,
                                fontSize: 14),
                            decoration: InputDecoration(
                              hintText:
                                  'Ceritakan detail kendaraan ini...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: YawColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: YawColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: YawColors.primary,
                                    width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Bottom padding so content isn't hidden behind sticky bar
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // ── Sticky action bar ──
              _buildActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Section & field builders
  // ──────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: YawColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: YawColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: YawColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: YawColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: YawColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: YawColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }

  Widget _categoryDropdown(List<VehicleCategory> cats) {
    return DropdownButtonFormField<String>(
      initialValue: _categoryId,
      decoration: const InputDecoration(labelText: 'Kategori'),
      dropdownColor: YawColors.surface2,
      items: cats
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: (v) => setState(() => _categoryId = v),
      validator: (v) => v == null || v.isEmpty ? 'Pilih kategori' : null,
    );
  }

  Widget _dropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: YawColors.surface2,
      items: items
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _stepperBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: YawColors.surface3,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: YawColors.primary),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Image list editor
  // ──────────────────────────────────────────────

  Widget _emptyImagesHint() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: YawColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: YawColors.border,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              color: YawColors.textDim, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Belum ada gambar.\nTekan tombol di bawah untuk menambah URL gambar.',
              style: TextStyle(
                color: YawColors.textDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageRow(int index) {
    final ctrl = _imageCtrls[index];
    final hasPreview = _imageValidity[index] == true;
    final url = ctrl.text.trim();

    return Container(
      decoration: BoxDecoration(
        color: YawColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: YawColors.border),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Thumbnail preview
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: YawColors.surface3,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasPreview
                ? CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: YawColors.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: YawColors.error,
                      size: 22,
                    ),
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: YawColors.textDim,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 10),
          // URL input
          Expanded(
            child: TextFormField(
              controller: ctrl,
              style: const TextStyle(
                  color: YawColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'https://contoh.com/gambar.jpg',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: (v) => _onImageChanged(index, v),
            ),
          ),
          // Remove button
          InkWell(
            onTap: () => _removeImageRow(index),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: YawColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close,
                  size: 16, color: YawColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addImageBtn() {
    return InkWell(
      onTap: _addImageRow,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: YawColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: YawColors.primary.withAlpha(60),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                size: 18, color: YawColors.primary),
            SizedBox(width: 8),
            Text(
              'Tambah gambar',
              style: TextStyle(
                color: YawColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Sticky action bar
  // ──────────────────────────────────────────────

  Widget _buildActionBar() {
    return Container(
      decoration: const BoxDecoration(
        color: YawColors.surface,
        border: Border(
          top: BorderSide(color: YawColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: YawColors.primary,
                disabledBackgroundColor: YawColors.surface3,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: YawColors.background,
                      ),
                    )
                  : Text(
                      _submitLabel(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: YawColors.background,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Validation & submit
  // ──────────────────────────────────────────────

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  Future<void> _submit() async {
    final f = _formKey.currentState;
    if (f == null || !f.validate()) return;
    final repo = ref.read(vehicleRepositoryProvider);
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await repo.updateVehicle(widget.id!, _toMap());
      } else {
        await repo.createVehicle(_toMap());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snack(
        _isEditing ? 'Kendaraan diperbarui' : 'Kendaraan ditambahkan',
        YawColors.success,
      ));
      ref.invalidate(vehicleListProvider);
      if (_isEditing) ref.invalidate(vehicleDetailProvider(widget.id!));
      if (mounted) context.pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _snack(e.toString(), YawColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  SnackBar _snack(String msg, Color bg) => SnackBar(
        content: Text(msg,
            style: const TextStyle(color: YawColors.textPrimary)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: YawColors.border),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
}

/// Inline Rp prefix for price field — avoids relying on InputDecorationTheme
/// which doesn't set a prefix style.
class _PricePrefix extends StatelessWidget {
  const _PricePrefix();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Text(
        'Rp',
        style: TextStyle(
          color: YawColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
