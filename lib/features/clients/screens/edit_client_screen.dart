import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../models/client_models.dart';
import '../providers/client_provider.dart';

class EditClientScreen extends ConsumerStatefulWidget {
  final String clientId;
  const EditClientScreen({super.key, required this.clientId});

  @override
  ConsumerState<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends ConsumerState<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docNumController;
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _incomeController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _fuelTypeController;
  late TextEditingController _transmissionController;
  late TextEditingController _engineController;

  String _docType = 'DNI';
  String _currency = 'SOLES';
  bool _available = true;
  String _status = 'activo';

  String _normalizeStatus(String status) {
    final s = status.toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e')
        .replaceAll('í', 'i').replaceAll('ó', 'o')
        .replaceAll('ú', 'u').replaceAll(' ', '');
    switch (s) {
      case 'activo':       return 'activo';
      case 'enevaluacion':
      case 'evaluacion':   return 'evaluacion';
      case 'mora':         return 'mora';
      case 'pendiente':    return 'pendiente';
      default:             return 'activo';
    }
  }

  String _normalizeCurrency(String currency) {
    final c = currency.toUpperCase()
        .replaceAll('Ó', 'O').replaceAll('ó', 'o');
    return c.contains('SOL') ? 'SOLES' : 'DOLARES';
  }

  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _docNumController = TextEditingController();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _incomeController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _priceController = TextEditingController();
    _fuelTypeController = TextEditingController();
    _transmissionController = TextEditingController();
    _engineController = TextEditingController();
  }

  void _initializeControllers(ClientResponse client) {
    if (_isInitialized) return;
    _isInitialized = true;

    _docNumController.text = client.documentNumber;
    _nameController.text = client.firstName;
    _lastNameController.text = client.lastName;
    _emailController.text = client.email ?? '';
    _phoneController.text = client.phone ?? '';
    _addressController.text = client.address ?? '';
    _incomeController.text = client.monthlyIncome.toString();
    _docType = client.documentType;
    _status = _normalizeStatus(client.status);

    if (client.vehicle != null) {
      _brandController.text = client.vehicle!.brand;
      _modelController.text = client.vehicle!.model;
      _priceController.text = client.vehicle!.price.toString();
      _currency = _normalizeCurrency(client.vehicle!.currency);
      _available = client.vehicle!.status == 'disponible';
      _fuelTypeController.text = client.vehicle!.fuelType ?? '';
      _transmissionController.text = client.vehicle!.transmission ?? '';
      _engineController.text = client.vehicle!.engine ?? '';
    }
  }

  @override
  void dispose() {
    _docNumController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _incomeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _fuelTypeController.dispose();
    _transmissionController.dispose();
    _engineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientId = int.tryParse(widget.clientId) ?? 0;
    final clientAsync = ref.watch(clientDetailProvider(clientId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AutomaticsAppBar(
        showBack: true,
        onBack: () => context.go('/clients/${widget.clientId}'),
      ),
      body: clientAsync.when(
        data: (client) {
          _initializeControllers(client);
          return _buildForm(client);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (err, stack) => Center(child: Text(err.toString(), style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Widget _buildForm(ClientResponse client) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientIdentityCard(client),
            const SizedBox(height: 16),
            _buildEditModeBanner(),
            const SizedBox(height: 20),
            _buildEditHeader(),
            const SizedBox(height: 20),
            _buildPersonalSection(),
            const SizedBox(height: 20),
            _buildVehicleSection(),
            const SizedBox(height: 28),
            _buildActionButtons(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildClientIdentityCard(ClientResponse client) {
    final parts = client.fullName.split(' ');
    final initials = parts.length > 1 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : parts[0][0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFF0A1F44).withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
            child: Center(child: Text(initials, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.fullName, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
                Text('${client.documentType} ${client.documentNumber}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                _statusBadge(client.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'activo': return StatusBadge.active();
      case 'evaluacion': return StatusBadge.evaluation();
      case 'pendiente': return StatusBadge.pending();
      case 'mora': return StatusBadge.overdue();
      default: return StatusBadge.active();
    }
  }

  Widget _buildEditModeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note, color: AppColors.secondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MODO EDICIÓN', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.secondary)),
                SizedBox(height: 4),
                Text('Modifica los campos necesarios y presiona "Guardar Cambios" para actualizar el registro.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSecondaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditHeader() {
    return Row(
      children: [
        const Text('Editar Cliente', style: TextStyle(fontFamily: 'Montserrat', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryContainer)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(99)),
          child: const Row(
            children: [
              Icon(Icons.edit_outlined, size: 12, color: Color(0xFF854D0E)),
              SizedBox(width: 4),
              Text('Editando', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF854D0E))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outlined, color: AppColors.primaryContainer, size: 20),
              SizedBox(width: 8),
              Text('Datos Personales', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
            ],
          ),
          const Divider(height: 20),
          _buildDropdown('Tipo de Documento', _docType, ['DNI', 'CE', 'Pasaporte'], (v) => setState(() => _docType = v!)),
          const SizedBox(height: 14),
          _buildEditableField('Número de Documento', _docNumController, TextInputType.number),
          const SizedBox(height: 14),
          _buildEditableField('Nombres', _nameController, TextInputType.name),
          const SizedBox(height: 14),
          _buildEditableField('Apellidos', _lastNameController, TextInputType.name),
          const SizedBox(height: 14),
          _buildEditableField('Correo Electrónico', _emailController, TextInputType.emailAddress, required: false),
          const SizedBox(height: 14),
          _buildEditableField('Teléfono', _phoneController, TextInputType.phone, required: false),
          const SizedBox(height: 14),
          _buildEditableField('Dirección', _addressController, TextInputType.streetAddress, required: false),
          const SizedBox(height: 14),
          _buildIncomeField(),
          const SizedBox(height: 14),
          _buildDropdown('Estado del Cliente', _status, ['activo', 'evaluacion', 'pendiente', 'mora'], (v) => setState(() => _status = v!)),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return SectionCard(
      borderLeftColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_car_outlined, color: AppColors.secondary, size: 20),
              SizedBox(width: 8),
              Text('Vehículo de Interés', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
            ],
          ),
          const Divider(height: 20),
          _buildEditableField('Marca', _brandController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildEditableField('Modelo', _modelController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildCurrencyPriceField(),
          const SizedBox(height: 14),
          _buildEditableField('Tipo de Combustible', _fuelTypeController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildEditableField('Transmisión', _transmissionController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildEditableField('Motor', _engineController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildVehicleStatusField(),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Inter', fontSize: 15)))).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, TextInputType type, {bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x4D005FAF), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
            suffixIcon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 18),
          ),
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null : null,
        ),
      ],
    );
  }

  Widget _buildIncomeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingreso Mensual Neto', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _incomeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: 'S/ ',
            prefixStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x4D005FAF), width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
            suffixIcon: const Icon(Icons.edit_outlined, color: AppColors.secondary, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Moneda y Precio de Venta', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: ['SOLES', 'DOLARES'].map((c) {
                  final sel = _currency == c;
                  return GestureDetector(
                    onTap: () => setState(() => _currency = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.surfaceContainerLowest : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: sel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)] : null,
                      ),
                      child: Text(c, style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: sel ? AppColors.secondary : AppColors.onSurfaceVariant)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Precio'))),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado del Vehículo', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          children: [
            _radioOption('Disponible', true, const Color(0xFFDCFCE7), const Color(0xFF166534)),
            const SizedBox(width: 16),
            _radioOption('No disponible', false, AppColors.errorContainer, AppColors.onErrorContainer),
          ],
        ),
      ],
    );
  }

  Widget _radioOption(String label, bool value, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () => setState(() => _available = value),
      child: Row(
        children: [
          // ignore: deprecated_member_use
          Radio<bool>(value: value, groupValue: _available, onChanged: (v) => setState(() => _available = v!), activeColor: AppColors.secondary),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(99)),
            child: Text(label, style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: _isDeleting ? null : () => _showDeleteDialog(context),
          icon: _isDeleting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
          label: const Text('Eliminar Cliente', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.error)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => context.go('/clients/${widget.clientId}'),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.onSecondary, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 18),
                label: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final request = ClientUpdateRequest(
        documentType: _docType,
        documentNumber: _docNumController.text,
        firstName: _nameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        monthlyIncome: double.tryParse(_incomeController.text) ?? 0,
        status: _status,
        vehicle: _brandController.text.isNotEmpty ? VehicleUpdateRequest(
          brand: _brandController.text,
          model: _modelController.text,
          price: double.tryParse(_priceController.text) ?? 0,
          currency: _currency,
          status: _available ? 'disponible' : 'no_disponible',
          fuelType: _fuelTypeController.text.isNotEmpty ? _fuelTypeController.text : null,
          transmission: _transmissionController.text.isNotEmpty ? _transmissionController.text : null,
          engine: _engineController.text.isNotEmpty ? _engineController.text : null,
        ) : null,
      );

      final repo = ref.read(clientRepositoryProvider);
      final clientId = int.parse(widget.clientId);
      await repo.updateClient(clientId, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados'), backgroundColor: AppColors.primary),
        );
        ref.invalidate(clientDetailProvider(clientId));
        ref.invalidate(clientsListProvider);
        context.go('/clients/$clientId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cliente', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, color: AppColors.error)),
        content: const Text('¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer.', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _handleDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    
    try {
      final repo = ref.read(clientRepositoryProvider);
      final clientId = int.parse(widget.clientId);
      await repo.deleteClient(clientId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente eliminado'), backgroundColor: AppColors.primary),
        );
        ref.invalidate(clientsListProvider);
        context.go('/clients');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}
