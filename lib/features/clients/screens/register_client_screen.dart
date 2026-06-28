import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../models/client_models.dart';
import '../providers/client_provider.dart';

class RegisterClientScreen extends ConsumerStatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  ConsumerState<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends ConsumerState<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _docController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _incomeController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _priceController;
  late TextEditingController _fuelTypeController;
  late TextEditingController _transmissionController;
  late TextEditingController _engineController;

  String _docType = 'DNI';
  String _currency = 'SOLES';
  bool _available = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _docController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _incomeController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _priceController = TextEditingController();
    _fuelTypeController = TextEditingController();
    _transmissionController = TextEditingController();
    _engineController = TextEditingController();
  }

  @override
  void dispose() {
    _docController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _incomeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _fuelTypeController.dispose();
    _transmissionController.dispose();
    _engineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AutomaticsAppBar(
        showBack: true,
        onBack: () => context.go('/clients'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildInfoBanner(),
              const SizedBox(height: 20),
              _buildPersonalDataSection(),
              const SizedBox(height: 20),
              _buildVehicleSection(),
              const SizedBox(height: 28),
              _buildSubmitButton(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registrar Cliente',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Complete los datos para iniciar la simulación de crédito vehicular y evaluación crediticia.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.secondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTADO DE PROCESO',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'El cliente será registrado en el sistema central para validación de ingresos mensuales netos.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.person_outlined, 'Datos Personales'),
          const SizedBox(height: 16),
          _buildDocTypeField(),
          const SizedBox(height: 14),
          _buildTextField('Número de Documento', 'Ej. 72635481', _docController, TextInputType.number),
          const SizedBox(height: 14),
          _buildTextField('Nombres', 'Nombres completos', _firstNameController, TextInputType.name),
          const SizedBox(height: 14),
          _buildTextField('Apellidos', 'Apellidos completos', _lastNameController, TextInputType.name),
          const SizedBox(height: 14),
          _buildTextField('Email', 'ejemplo@correo.com', _emailController, TextInputType.emailAddress, required: false),
          const SizedBox(height: 14),
          _buildTextField('Teléfono', '+51 900 000 000', _phoneController, TextInputType.phone, required: false),
          const SizedBox(height: 14),
          _buildTextField('Dirección', 'Av. Principal 123, Lima', _addressController, TextInputType.streetAddress, required: false),
          const SizedBox(height: 14),
          _buildIncomeField(),
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
          _sectionHeader(Icons.directions_car_outlined, 'Vehículo de Interés'),
          const SizedBox(height: 16),
          _buildTextField('Marca', 'Ej. Toyota', _brandController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildTextField('Modelo', 'Ej. Corolla', _modelController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildTextField('Año', 'Ej. 2024', _yearController, TextInputType.number, required: false),
          const SizedBox(height: 14),
          _buildCurrencyPriceField(),
          const SizedBox(height: 14),
          _buildTextField('Tipo de Combustible', 'Ej. Gasolina', _fuelTypeController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildTextField('Transmisión', 'Ej. Automática', _transmissionController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildTextField('Motor', 'Ej. 1.8L', _engineController, TextInputType.text, required: false),
          const SizedBox(height: 14),
          _buildVehicleStatusField(),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo de Documento', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _docType,
              isExpanded: true,
              items: ['DNI', 'CE', 'Pasaporte'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontFamily: 'Inter', fontSize: 15)))).toList(),
              onChanged: (v) => setState(() => _docType = v!),
              icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, TextInputType type, {bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant, size: 18),
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
          decoration: const InputDecoration(
            prefixText: 'S/ ',
            prefixStyle: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
            hintText: '0.00',
            suffixIcon: Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant, size: 18),
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
                children: ['SOLES', 'DÓLARES'].map((c) {
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
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Precio'),
              ),
            ),
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
          Radio<bool>(
            value: value,
            groupValue: _available,
            onChanged: (v) => setState(() => _available = v!),
            activeColor: AppColors.secondary,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(99)),
            child: Text(label, style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.onSecondary, strokeWidth: 2))
            : const Text('Guardar Cliente'),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final request = ClientCreateRequest(
        documentType: _docType,
        documentNumber: _docController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        monthlyIncome: double.tryParse(_incomeController.text) ?? 0,
        vehicle: _brandController.text.isNotEmpty ? VehicleCreateRequest(
          brand: _brandController.text,
          model: _modelController.text,
          year: int.tryParse(_yearController.text),
          price: double.tryParse(_priceController.text) ?? 0,
          currency: _currency,
          status: _available ? 'disponible' : 'no_disponible',
          fuelType: _fuelTypeController.text.isNotEmpty ? _fuelTypeController.text : null,
          transmission: _transmissionController.text.isNotEmpty ? _transmissionController.text : null,
          engine: _engineController.text.isNotEmpty ? _engineController.text : null,
        ) : null,
      );

      final repo = ref.read(clientRepositoryProvider);
      await repo.createClient(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente guardado correctamente'), backgroundColor: AppColors.primary),
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
        setState(() => _isLoading = false);
      }
    }
  }
}
