import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart'; // ✨ IMPORTANTE: Para consumir la API de tipo de cambio

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // ✨ ESTADO DEL TOGGLE DE MONEDA (Por defecto en Dólares)
  bool _isDolares = true;

  // ✨ TIPO DE CAMBIO (Empieza en 3.40 como respaldo, pero se actualizará con la API)
  double _exchangeRate = 3.40;

  @override
  void initState() {
    super.initState();
    // ✨ Llamamos a la API apenas se construye la pantalla
    _fetchLiveExchangeRate();
  }

  // ✨ FUNCIÓN QUE CONSUME LA API EN TIEMPO REAL
  Future<void> _fetchLiveExchangeRate() async {
    try {
      // API pública y gratuita que actualiza los tipos de cambio diarios
      final response = await Dio().get('https://open.er-api.com/v6/latest/USD');

      if (response.statusCode == 200 && response.data != null) {
        final rates = response.data['rates'];
        if (rates != null && rates['PEN'] != null) {
          if (mounted) {
            setState(() {
              // Actualizamos nuestra variable con el valor real del mercado (USD a PEN)
              _exchangeRate = (rates['PEN'] as num).toDouble();
            });
          }
        }
      }
    } catch (e) {
      // Si el celular no tiene internet, simplemente se mantiene el 3.40 por defecto
      debugPrint('No se pudo obtener el TC en vivo, usando respaldo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: dashboardAsync.when(
        data: (data) => _buildBody(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(error.toString(), style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.registerClient),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DashboardResponse data) {
    final bool isBrandNewUser = data.totalFinanced == 0 && data.recentActivity.isEmpty;

    // ✨ LÓGICA DE DIVISAS (Usa la tasa de la API si estás en Soles)
    final double rate = _isDolares ? 1.0 : _exchangeRate;
    final String prefix = _isDolares ? '\$' : 'S/';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(ref),
          const SizedBox(height: 24),

          if (isBrandNewUser)
            _buildGlobalEmptyState(context)
          else ...[
            _buildKpiGrid(context, data, rate, prefix),
            const SizedBox(height: 32),
            _buildChartsSection(context, data, rate, prefix),
            const SizedBox(height: 32),
            _buildRecentActivity(context, data, rate, prefix),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final nombre = user?.name ?? 'Asesor Financiero';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $nombre',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Resumen de gestión para hoy',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),

        // ✨ CONTENEDOR DEL TOGGLE Y EL TEXTO DE LA TASA EN VIVO
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildCurrencyToggle(),
            const SizedBox(height: 6),
            Text(
              'TC Activo: S/ ${_exchangeRate.toStringAsFixed(3)}',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrencyToggle() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: ['DÓLARES', 'SOLES'].map((c) {
          final bool isSoles = c == 'SOLES';
          final bool sel = isSoles ? !_isDolares : _isDolares;
          return GestureDetector(
            onTap: () => setState(() => _isDolares = !isSoles),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  Widget _buildGlobalEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF1A3A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Bienvenido a AutoMatics!',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tu tablero está vacío porque aún no has registrado ninguna simulación ni cliente. Comienza a evaluar créditos vehiculares para desbloquear todas las analíticas y gráficos de tu cartera.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.registerClient),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
              label: const Text(
                'Registrar mi primer cliente',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardResponse data, double rate, String prefix) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return GridView.count(
      crossAxisCount: isSmall ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isSmall ? 1.15 : 1.55,
      children: [
        KpiCard(
          label: 'Monto Financiado',
          value: _formatNumber(data.totalFinanced * rate), // ✨ Aplicando la API
          prefix: prefix,
          badge: 'Actualizado',
          icon: Icons.payments_outlined,
        ),
        KpiCard(
          label: 'Contratos Activos',
          value: data.activeContracts.toString(),
          badge: 'Actualizado',
          icon: Icons.description_outlined,
        ),
        KpiCard(
          label: 'En Evaluación',
          value: data.inEvaluation.toString(),
          badge: 'Actualizado',
          icon: Icons.pending_actions_outlined,
        ),
        KpiCard(
          label: 'Aprobación',
          value: '${data.approvalRate}%',
          badge: 'Actualizado',
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  Widget _buildChartsSection(BuildContext context, DashboardResponse data, double rate, String prefix) {
    final isSmall = MediaQuery.of(context).size.width < 900;

    if (isSmall) {
      return Column(
        children: [
          _buildVanChart(context, data.vanHistory, data.vanLabels, rate, prefix),
          const SizedBox(height: 16),
          _buildTirChart(context, data.tirHistory, data.tirLabels),
        ],
      );
    }

    return Column(
      children: [
        _buildVanChart(context, data.vanHistory, data.vanLabels, rate, prefix),
        const SizedBox(height: 16),
        _buildTirChart(context, data.tirHistory, data.tirLabels),
      ],
    );
  }

  Widget _buildVanChart(BuildContext context, List<double> historyData, List<String> labels, double rate, String prefix) {
    final bool isEmpty = historyData.isEmpty || historyData.every((element) => element == 0);

    // Calculamos min/max aplicando la API
    double maxVal = 0;
    double minVal = 0;
    if (!isEmpty) {
      maxVal = historyData.reduce((a, b) => a > b ? a : b) * rate;
      minVal = historyData.reduce((a, b) => a < b ? a : b) * rate;
      if (maxVal == minVal) { maxVal += 1; minVal -= 1; }
    }

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Evolución del VAN',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  Text(
                    'Valor Actual Neto de las simulaciones',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              if (!isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(6)),
                  child: Text('En ${_isDolares ? "Dólares" : "Soles"}', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                ),
            ],
          ),
          const SizedBox(height: 32),

          if (isEmpty)
            Container(height: 150, alignment: Alignment.center, child: const Text('Sin datos suficientes', style: TextStyle(color: AppColors.onSurfaceVariant)))
          else ...[
            Row(
              children: [
                // ✨ EJE Y con Tipo de Cambio
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$prefix${_formatNumber(maxVal)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 50),
                    Text('$prefix${_formatNumber((maxVal + minVal) / 2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 50),
                    Text('$prefix${_formatNumber(minVal)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (innerContext) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final box = innerContext.findRenderObject() as RenderBox;
                        final width = box.size.width;
                        final stepX = width / (historyData.length <= 1 ? 1 : historyData.length - 1);

                        int indexTocado = (details.localPosition.dx / stepX).round();
                        if (indexTocado >= 0 && indexTocado < historyData.length) {
                          _showDetailSheet(
                              context,
                              'Detalle VAN',
                              labels[indexTocado],
                              '$prefix ${(historyData[indexTocado] * rate).toStringAsFixed(2)}' // ✨ Aplicando API al tooltip
                          );
                        }
                      },
                      child: SizedBox(
                        height: 130,
                        child: CustomPaint(
                          painter: _DynamicLinePainter(historyData), // La curva es la misma, los números cambian
                          size: const Size(double.infinity, 130),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels.map((label) => Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTirChart(BuildContext context, List<double> rawData, List<String> labels) {
    final bool isEmpty = rawData.isEmpty || rawData.every((element) => element == 0);
    final maxVal = isEmpty ? 1.0 : rawData.reduce((a, b) => a > b ? a : b);
    final bars = rawData.map((e) => maxVal == 0 ? 0.1 : (e / maxVal)).toList();

    // El TIR es un % puro, no le afecta el tipo de cambio.
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rendimiento TIR Promedio',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  Text(
                    'Tasa Interna de Retorno mensual de tu portafolio',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (isEmpty)
            Container(height: 150, alignment: Alignment.center, child: const Text('Sin datos suficientes', style: TextStyle(color: AppColors.onSurfaceVariant)))
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((e) {
                  final isLast = e.key == bars.length - 1;
                  final label = labels.length > e.key ? labels[e.key] : '';
                  final valueString = '${rawData[e.key].toStringAsFixed(1)}%';

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GestureDetector(
                        onTap: () {
                          _showDetailSheet(context, 'Detalle TIR', label, valueString);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              valueString,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isLast ? AppColors.secondary : AppColors.primary
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              height: 120 * e.value,
                              decoration: BoxDecoration(
                                color: isLast ? AppColors.secondary : AppColors.primaryContainer,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              label,
                              style: const TextStyle(fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DashboardResponse data, double rate, String prefix) {
    return SectionCard(
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
                const Text(
                  'Últimas Acciones de Clientes',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.clients),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryFixed,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (data.recentActivity.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Aún no tienes clientes o simulaciones.', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
            ),

          for (var i = 0; i < data.recentActivity.length; i++) ...[
            _buildActivityItem(
              initials: _getInitials(data.recentActivity[i].clientName),
              name: data.recentActivity[i].clientName,
              subtitle: data.recentActivity[i].description,
              amount: '$prefix ${(data.recentActivity[i].amount * rate).toStringAsFixed(2)}', // ✨ Divisa aplicada por la API
              time: data.recentActivity[i].timeAgo,
              onTap: () {
                if (data.recentActivity[i].description.toLowerCase().contains("aprobado")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.download_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Abriendo el reporte del crédito de ${data.recentActivity[i].clientName}...')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                context.go('/simulator/indicators', extra: data.recentActivity[i].id);
              },
            ),
            if (i < data.recentActivity.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildActivityItem({
    required String initials,
    required String name,
    required String subtitle,
    required String amount,
    required String time,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.secondaryFixed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showDetailSheet(BuildContext context, String titulo, String periodo, String valor) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.insights, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
                      Text('Periodo: $periodo', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Valor Alcanzado', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant)),
            Text(valor, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.onPrimary),
                child: const Text('Cerrar Detalle'),
              ),
            )
          ],
        ),
      );
    },
  );
}

class _DynamicLinePainter extends CustomPainter {
  final List<double> data;
  _DynamicLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (data.length <= 1 ? 1 : data.length - 1);

    double maxVal = data.reduce((a, b) => a > b ? a : b);
    double minVal = data.reduce((a, b) => a < b ? a : b);
    if (maxVal == minVal) { maxVal += 1; minVal -= 1; }
    final range = maxVal - minVal;

    double prevX = 0;
    double prevY = 0;

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - minVal) / range;
      final y = size.height - (normalizedY * size.height * 0.7 + size.height * 0.15);
      final x = i * stepX;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final controlX = prevX + (x - prevX) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
      }
      prevX = x;
      prevY = y;
    }

    canvas.drawPath(path, linePaint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withValues(alpha: 0.35),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    for (final point in points) {
      canvas.drawCircle(point, 4.5, dotPaint);
      canvas.drawCircle(point, 4.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}