import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/client_provider.dart';
import '../models/client_models.dart';

class ClientsListScreen extends ConsumerStatefulWidget {
  const ClientsListScreen({super.key});

  @override
  ConsumerState<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends ConsumerState<ClientsListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'Todos los estados';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(clientsFilterProvider.notifier).update((state) {
        return {
          ...state,
          'search': _searchController.text,
          'page': 1,
        };
      });
    });
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    ref.read(clientsFilterProvider.notifier).update((state) {
      return {
        ...state,
        'status': status == 'Todos los estados' ? null : status.toLowerCase(),
        'page': 1,
      };
    });
  }

  void _changePage(int newPage) {
    ref.read(clientsFilterProvider.notifier).update((state) {
      return {
        ...state,
        'page': newPage,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AutomaticsAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(context),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  clientsAsync.when(
                    data: (data) => _buildClientTable(context, data),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                            const SizedBox(height: 16),
                            Text(error.toString(), style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.registerClient),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.onSecondary,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(
          'Nuevo Cliente',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clientes',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryContainer,
          ),
        ),
        Text(
          'Gestión del portafolio de clientes y créditos vehiculares',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SectionCard(
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre, documento o vehículo...',
              prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'Todos los estados',
                'Activo',
                'Evaluacion',
                'Mora',
              ].map((s) {
                final isSelected = _selectedStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: isSelected,
                    onSelected: (_) => _onStatusChanged(s),
                    selectedColor: AppColors.secondary,
                    backgroundColor: AppColors.surfaceContainerLow,
                    labelStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.onSecondary : AppColors.onSurfaceVariant,
                    ),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientTable(BuildContext context, PagedResponse<ClientListResponse> data) {
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
                Text(
                  '${data.totalCount} clientes encontrados',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (data.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No se encontraron clientes.', style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          ...data.items.map((c) => _buildClientRow(context, c)),
          _buildPagination(data),
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

  Widget _buildClientRow(BuildContext context, ClientListResponse client) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.go('/clients/${client.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(client.fullName),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryContainer,
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
                        client.fullName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        client.documentNumber,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        client.vehicleName ?? 'Sin vehículo',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (client.vehiclePrice != null)
                        Text(
                          '${client.vehicleCurrency ?? 'S/'} ${client.vehiclePrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _statusBadge(client.status),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _actionButton(Icons.visibility_outlined, AppColors.secondary, () => context.go('/clients/${client.id}')),
                        _actionButton(Icons.edit_outlined, AppColors.onSurfaceVariant, () => context.go('/clients/${client.id}/edit')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.outlineVariant),
      ],
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    if (s == 'activo') return StatusBadge.active();
    if (s == 'evaluacion' || s == 'evaluación') return StatusBadge.evaluation();
    if (s == 'pendiente') return StatusBadge.pending();
    if (s == 'mora') return StatusBadge.overdue();
    return StatusBadge.active();
  }

  Widget _buildPagination(PagedResponse<ClientListResponse> data) {
    final start = ((data.page - 1) * data.pageSize) + 1;
    final end = (start + data.items.length - 1).clamp(0, data.totalCount);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: const Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $start–$end de ${data.totalCount}',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
          Row(
            children: [
              _pageButton('<', false, () {
                if (data.page > 1) _changePage(data.page - 1);
              }),
              const SizedBox(width: 4),
              for (int i = 1; i <= data.totalPages; i++) ...[
                _pageButton(i.toString(), i == data.page, () => _changePage(i)),
              ],
              const SizedBox(width: 4),
              _pageButton('>', false, () {
                if (data.page < data.totalPages) _changePage(data.page + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: selected ? null : Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.onSecondary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
