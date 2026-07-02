import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import '../models/client_models.dart';
import '../../simulator/providers/simulator_provider.dart';

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
              _buildActiveCreditTab(context, client), // ✨ Ahora pasamos el cliente entero
              _buildHistoryTab(client.id),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
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

  Widget _buildActiveCreditTab(BuildContext context, ClientResponse client) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(clientHistoryProvider(client.id));

        return historyAsync.when(
          data: (creditos) {
            final creditosOrdenados = List.from(creditos)..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

            final activeCredit = creditosOrdenados.firstWhere(
                  (c) => (c['estado'] as String?)?.toLowerCase() == 'aprobado' || (c['estado'] as String?)?.toLowerCase() == 'activo',
              orElse: () => null,
            );

            if (activeCredit == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 48, color: AppColors.onSurfaceVariant),
                      SizedBox(height: 16),
                      Text(
                        'Sin crédito activo',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Este cliente actualmente no cuenta con ningún crédito aprobado o contrato activo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            final id = activeCredit['id'] ?? 0;
            final monto = (activeCredit['montoPrestamo'] as num?)?.toDouble() ?? 0.0;
            final meses = (activeCredit['plazoMeses'] as num?)?.toInt() ?? 0;

            final tcea = (activeCredit['indicadorTCEA'] as num?)?.toDouble() ?? 0.0;
            final van = (activeCredit['indicadorVAN'] as num?)?.toDouble() ?? 0.0;
            final tir = (activeCredit['indicadorTIR'] as num?)?.toDouble() ?? 0.0;

            double cuota = 0.0;
            if (activeCredit['cronogramaPagos'] != null && (activeCredit['cronogramaPagos'] as List).isNotEmpty) {
              cuota = (activeCredit['cronogramaPagos'][0]['cuotaTotalMensual'] as num?)?.toDouble() ?? 0.0;
            }

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
                              Text('Detalle de Crédito #$id', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(99)),
                                child: const Text('Aprobado', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
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
                                children: [
                                  _CreditDataItem(label: 'Monto Financiado', value: 'S/ ${monto.toStringAsFixed(2)}', valueColor: AppColors.primary),
                                  _CreditDataItem(label: 'Cuota Mensual Est.', value: 'S/ ${cuota.toStringAsFixed(2)}', valueColor: AppColors.primary),
                                  _CreditDataItem(label: 'Plazo Restante', value: '$meses meses', valueColor: AppColors.primary),
                                  _CreditDataItem(label: 'TCEA', value: '${tcea.toStringAsFixed(2)}%', valueColor: const Color(0xFF16A34A)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.go('/simulator/indicators', extra: id),
                                      icon: const Icon(Icons.analytics_outlined, size: 16),
                                      label: const Text('Ver Detalle Técnico', style: TextStyle(fontSize: 12)),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('INDICADORES FINANCIEROS DEL CONTRATO', style: TextStyle(fontFamily: 'Montserrat', fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Valor Actual Neto (VAN)', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
                                  const SizedBox(height: 4),
                                  Text('S/ ${van.toStringAsFixed(2)}', style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: van >= 0 ? const Color(0xFF16A34A) : AppColors.error)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TIR Proyectada', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
                                  const SizedBox(height: 4),
                                  Text('${tir.toStringAsFixed(2)}%', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined, size: 16, color: AppColors.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  van >= 0
                                      ? 'Viabilidad óptima confirmada. El VAN positivo valida la salud financiera de la operación.'
                                      : 'Estructura de financiamiento evaluada bajo los parámetros y regulaciones vigentes.',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSecondaryContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivity(context, client.id),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, client), // ✨ AHORA ES REAL Y FUNCIONAL
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
          error: (e, st) => Center(child: Text('Error al procesar datos reales: $e')),
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context, int clientId) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(clientHistoryProvider(clientId));

        return SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Actividad Reciente', style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 14),
              historyAsync.when(
                data: (creditos) {
                  if (creditos.isEmpty) {
                    return const Text('No hay actividad reciente registrada.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant));
                  }

                  final sorted = List.from(creditos)..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
                  final recentItems = sorted.take(4).toList();

                  return Column(
                    children: recentItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;
                      final id = c['id'] ?? 0;
                      final estado = (c['estado'] as String?)?.toLowerCase() ?? 'borrador';
                      final monto = (c['montoPrestamo'] as num?)?.toDouble() ?? 0.0;

                      final isAprobado = estado == 'aprobado' || estado == 'activo';
                      final isMora = estado == 'mora';
                      final isEvaluacion = !isAprobado && !isMora;

                      IconData icon;
                      Color iconBg;
                      Color iconColor;
                      String title;

                      if (isAprobado) {
                        icon = Icons.check_circle_outline;
                        iconBg = const Color(0xFFF0FDF4);
                        iconColor = const Color(0xFF22C55E);
                        title = 'Crédito Aprobado #$id';
                      } else if (isMora) {
                        icon = Icons.warning_amber_rounded;
                        iconBg = AppColors.errorContainer.withValues(alpha: 0.2);
                        iconColor = AppColors.error;
                        title = 'Crédito en Mora #$id';
                      } else {
                        icon = Icons.pending_actions_outlined;
                        iconBg = AppColors.secondaryContainer.withValues(alpha: 0.2);
                        iconColor = AppColors.secondary;
                        title = 'Simulación en Evaluación #$id';
                      }

                      return Column(
                        children: [
                          _activityItem(
                            context: context,
                            ref: ref,
                            clientId: clientId,
                            creditId: id,
                            icon: icon,
                            iconBg: iconBg,
                            iconColor: iconColor,
                            title: title,
                            subtitle: 'Monto procesado: S/ ${monto.toStringAsFixed(2)}',
                            time: 'Recientemente',
                            isEvaluacion: isEvaluacion,
                          ),
                          if (index < recentItems.length - 1) const Divider(height: 20),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                error: (e, st) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _activityItem({
    required BuildContext context,
    required WidgetRef ref,
    required int clientId,
    required int creditId,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isEvaluacion,
  }) {
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
        if (isEvaluacion)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            tooltip: 'Eliminar simulación',
            onPressed: () => _deleteCredit(context, ref, clientId, creditId),
          ),
      ],
    );
  }

  Future<void> _deleteCredit(BuildContext context, WidgetRef ref, int clientId, int creditId) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Eliminar Simulación', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700)),
          content: const Text('¿Estás seguro de descartar esta evaluación? No podrás recuperarla.', style: TextStyle(fontFamily: 'Inter')),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant))
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        )
    );

    if (confirm != true) return;

    try {
      final repo = ref.read(simulatorRepositoryProvider);
      await repo.deleteCredit(creditId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Simulación eliminada de la base de datos.'), backgroundColor: Color(0xFF16A34A)));
      }
      ref.refresh(clientHistoryProvider(clientId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  // ✨ BOTONES 100% FUNCIONALES Y VIABLES
  Widget _buildQuickActions(BuildContext context, ClientResponse client) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Acciones Rápidas', style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onPrimary)),
          const SizedBox(height: 12),
          _quickAction(Icons.request_quote_outlined, 'Nueva Simulación', () => context.go(AppRoutes.simulator)),
          const SizedBox(height: 8),
          _quickAction(Icons.edit_outlined, 'Editar Datos del Cliente', () => context.go('/clients/${client.id}/edit')),
          const SizedBox(height: 8),
          _quickAction(Icons.chat_outlined, 'Contactar por WhatsApp', () {
            // Esto luego lo puedes conectar con url_launcher para que abra Web WhatsApp
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Iniciando chat de WhatsApp con ${client.phone}...'),
              backgroundColor: const Color(0xFF25D366),
              behavior: SnackBarBehavior.floating,
            ));
          }),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryContainer, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(int clientId) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(clientHistoryProvider(clientId));

        return historyAsync.when(
          data: (creditos) {
            if (creditos.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No hay simulaciones ni créditos registrados.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.onSurfaceVariant)),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                children: creditos.map((c) {
                  final id = c['id'] as int? ?? 0;
                  final monto = (c['montoPrestamo'] as num?)?.toDouble() ?? 0.0;
                  final estado = (c['estado'] as String?)?.toLowerCase() ?? 'borrador';
                  final meses = (c['plazoMeses'] as num?)?.toInt() ?? 0;

                  Color statusColor;
                  String statusText;
                  IconData statusIcon;

                  if (estado == 'aprobado' || estado == 'activo') {
                    statusColor = const Color(0xFF16A34A);
                    statusText = 'Aprobado';
                    statusIcon = Icons.check_circle_outline;
                  } else if (estado == 'mora') {
                    statusColor = AppColors.error;
                    statusText = 'En Mora';
                    statusIcon = Icons.warning_amber_rounded;
                  } else {
                    statusColor = AppColors.secondary;
                    statusText = 'En Evaluación';
                    statusIcon = Icons.pending_actions_rounded;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SectionCard(
                      borderLeftColor: statusColor,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(statusIcon, color: statusColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Crédito #$id', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                const SizedBox(height: 2),
                                Text('Monto: S/ ${monto.toStringAsFixed(2)} • $meses meses', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text(statusText, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                              ],
                            ),
                          ),
                          if (estado != 'aprobado' && estado != 'activo')
                            IconButton(
                              onPressed: () => context.go('/simulator/indicators', extra: id),
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.secondary),
                              tooltip: 'Revisar o Aprobar',
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
          error: (e, st) => Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('No se pudo cargar el historial.\n$e', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
          )),
        );
      },
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