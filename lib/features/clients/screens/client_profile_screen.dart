import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import '../models/client_models.dart';

class ClientProfileScreen extends ConsumerStatefulWidget {
  final String clientId;
  const ClientProfileScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Personal', 'Vehículo', 'Crédito Activo', 'Historial'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientAsync = ref.watch(clientDetailProvider(int.parse(widget.clientId)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AutomaticsAppBar(
        showBack: true,
        onBack: () => context.go('/clients'),
        actions: [
          const Text(
            'Asesor: Rodrigo Paz',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onPrimary),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: AppColors.onPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: clientAsync.when(
        data: (client) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileHeader(context, client),
                    const SizedBox(height: 16),
                    _buildTabBar(),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalTab(client),
              _buildVehicleTab(context, client),
              _buildActiveCreditTab(context),
              _buildHistoryTab(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ClientResponse client) {
    final initials = '${client.firstName.isNotEmpty ? client.firstName[0] : ''}${client.lastName.isNotEmpty ? client.lastName[0] : ''}'.toUpperCase();
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
                child: Center(child: Text(initials, style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSecondary))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(client.fullName,
                            style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(99)),
                          child: const Text('Confiable', style: TextStyle(fontFamily: 'Montserrat', fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Color(0xFF166534))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _ProfileInfoRow(icon: Icons.badge_outlined, text: '${client.documentType} ${client.documentNumber}'),
                    _ProfileInfoRow(icon: Icons.mail_outlined, text: client.email ?? 'Sin correo'),
                    _ProfileInfoRow(icon: Icons.phone_outlined, text: client.phone ?? 'Sin teléfono'),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/clients/${widget.clientId}/edit'),
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: const Text('Editar', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      unselectedLabelStyle: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.onSurfaceVariant,
      indicatorColor: AppColors.secondary,
      indicatorWeight: 2,
      dividerColor: AppColors.surfaceVariant,
      tabs: _tabs.map((t) => Tab(text: t)).toList(),
    );
  }

  Widget _buildPersonalTab(ClientResponse client) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información Personal', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
            const Divider(height: 20),
            _infoRow('Nombre completo', client.fullName),
            _infoRow('Documento', '${client.documentType} ${client.documentNumber}'),
            _infoRow('Correo', client.email ?? 'No registrado'),
            _infoRow('Teléfono', client.phone ?? 'No registrado'),
            _infoRow('Dirección', client.address ?? 'No registrada'),
            _infoRow('Ingreso mensual', 'S/ ${client.monthlyIncome.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleTab(BuildContext context, ClientResponse client) {
    if (client.vehicle == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('Sin vehículo registrado', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant)),
        )
      );
    }
    
    final v = client.vehicle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${v.brand} ${v.model} ${v.year ?? ''}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary)),
                Text(v.status.toUpperCase(), style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2,
                  children: [
                    _VehicleSpecCard(label: 'MARCA', value: v.brand),
                    _VehicleSpecCard(label: 'MODELO', value: v.model),
                    _VehicleSpecCard(label: 'AÑO', value: v.year?.toString() ?? '-'),
                    _VehicleSpecCard(label: 'COMBUSTIBLE', value: v.fuelType ?? '-'),
                    _VehicleSpecCard(label: 'TRANSMISIÓN', value: v.transmission ?? '-'),
                    _VehicleSpecCard(label: 'MOTOR', value: v.engine ?? '-'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen de Cotización', style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                const Divider(height: 20),
                _infoRow('Costo Vehículo', '${v.currency == "DÓLARES" ? "\$" : "S/"} ${v.price.toStringAsFixed(2)}'),
                _infoRow('Cuota Inicial (0%)', '${v.currency == "DÓLARES" ? "\$" : "S/"} 0.00'),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monto a Financiar', style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text('${v.currency == "DÓLARES" ? "\$" : "S/"} ${v.price.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.secondaryContainer)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.paymentSchedule),
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text('Ver Plan de Pagos'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCreditTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detalle de Crédito', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(99)),
                        child: const Text('Activo', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2, shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16, mainAxisSpacing: 12, childAspectRatio: 2.5,
                        children: const [
                          _CreditDataItem(label: 'Monto Financiado', value: '\$ 18,500', valueColor: AppColors.primary),
                          _CreditDataItem(label: 'Cuota Mensual', value: 'S/ 1,450', valueColor: AppColors.primary),
                          _CreditDataItem(label: 'Plazo Restante', value: '32 meses', valueColor: AppColors.primary),
                          _CreditDataItem(label: 'TEA', value: '9.5%', valueColor: Color(0xFF16A34A)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go(AppRoutes.paymentSchedule),
                              icon: const Icon(Icons.calendar_month_outlined, size: 16),
                              label: const Text('Ver Cronograma'),
                              style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Pagar Cuota', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Próximo vencimiento: 15 Oct 2024',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildRiskScore(),
          const SizedBox(height: 16),
          _buildRecentActivity(),
          const SizedBox(height: 16),
          _buildQuickActions(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRiskScore() {
    return const SectionCard(
      child: Column(
        children: [
          Text('INDICADORES DE RIESGO', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
          SizedBox(height: 16),
          SizedBox(
            width: 140, height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 140, height: 140,
                  child: CircularProgressIndicator(
                    value: 0.9,
                    strokeWidth: 14,
                    backgroundColor: AppColors.surfaceContainer,
                    color: Color(0xFF22C55E),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('920', style: TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    const Text('Sentinell', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Text('Excelente Pagador', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
          Text('Riesgo menor al 1.2% basado en historial de 24 meses.', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actividad Reciente', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 14),
          _activityItem(Icons.check_circle_outline, const Color(0xFFF0FDF4), const Color(0xFF22C55E), 'Pago de Cuota #16 procesado', 'S/ 1,450 pagados vía App Banca Móvil', 'Hace 3 días'),
          const Divider(height: 20),
          _activityItem(Icons.description_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'Seguro Vehicular Renovado', 'Póliza #8849-2024 emitida por Pacifico', '12 Sep 2024'),
        ],
      ),
    );
  }

  Widget _activityItem(IconData icon, Color iconBg, Color iconColor, String title, String subtitle, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.outline)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Acciones Rápidas', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onPrimary)),
          const SizedBox(height: 12),
          _quickAction(Icons.mail_outline, 'Enviar Estado de Cuenta'),
          const SizedBox(height: 8),
          _quickAction(Icons.request_quote_outlined, 'Nueva Simulación'),
          const SizedBox(height: 8),
          _quickAction(Icons.shield_outlined, 'Actualizar Documentos'),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryContainer, size: 18),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text('Historial de pagos próximamente', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant)),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProfileInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _VehicleSpecCard extends StatelessWidget {
  final String label;
  final String value;
  const _VehicleSpecCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _CreditDataItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _CreditDataItem({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant)),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: valueColor, height: 1.2)),
      ],
    );
  }
}
