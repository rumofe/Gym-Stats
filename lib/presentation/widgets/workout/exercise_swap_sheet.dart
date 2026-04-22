import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/exercise_template.dart';
import '../../providers/providers.dart';

class ExerciseSwapSheet extends ConsumerStatefulWidget {
  final Exercise originalExercise;
  final void Function({
    required int substituteLibraryId,
    required String substituteName,
    required String substituteMuscle,
    required bool permanent,
    required String reason,
  }) onConfirm;

  const ExerciseSwapSheet({
    super.key,
    required this.originalExercise,
    required this.onConfirm,
  });

  @override
  ConsumerState<ExerciseSwapSheet> createState() =>
      _ExerciseSwapSheetState();
}

class _ExerciseSwapSheetState extends ConsumerState<ExerciseSwapSheet> {
  List<ExerciseTemplate> _all = [];
  List<ExerciseTemplate> _filtered = [];
  ExerciseTemplate? _selected;
  bool _permanent = false;
  final _searchCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _loading = true;
  // Filtro activo de grupo muscular
  String? _muscleFilter;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _searchCtrl.addListener(_applyFilter);
  }

  Future<void> _loadTemplates() async {
    final repo = ref.read(exerciseRepositoryProvider);
    final all = await repo.getAllTemplates();
    // Pre-filtrar mismo grupo muscular
    setState(() {
      _all = all
          .where((t) => t.id != widget.originalExercise.libraryId)
          .toList();
      _muscleFilter = widget.originalExercise.muscleGroup;
      _applyFilterWith(_all);
      _loading = false;
    });
  }

  void _applyFilter() => _applyFilterWith(_all);

  void _applyFilterWith(List<ExerciseTemplate> source) {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = source.where((t) {
        final matchMuscle =
            _muscleFilter == null || t.muscleGroup == _muscleFilter;
        final matchSearch =
            q.isEmpty || t.name.toLowerCase().contains(q);
        return matchMuscle && matchSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cambiar ejercicio',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        widget.originalExercise.name,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.darkMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Filtros de grupo muscular
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _muscleFilter == null,
                  onTap: () {
                    setState(() => _muscleFilter = null);
                    _applyFilter();
                  },
                ),
                ...AppConstants.allMuscleGroups.map((m) => _FilterChip(
                      label: m,
                      selected: _muscleFilter == m,
                      onTap: () {
                        setState(() => _muscleFilter = m);
                        _applyFilter();
                      },
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar ejercicio…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Lista
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (_, i) {
                      final t = _filtered[i];
                      final isSel = _selected?.id == t.id;
                      return ListTile(
                        selected: isSel,
                        selectedTileColor:
                            AppTheme.primary.withValues(alpha: 0.12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Text(t.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          '${t.muscleGroup}  •  ${t.isCompound ? 'Compuesto' : 'Accesorio'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppTheme.primary)
                            : null,
                        onTap: () => setState(() => _selected = t),
                      );
                    },
                  ),
          ),
          // Panel de confirmación
          if (_selected != null) _ConfirmPanel(
            selected: _selected!,
            permanent: _permanent,
            reasonCtrl: _reasonCtrl,
            onPermanentChanged: (v) => setState(() => _permanent = v),
            onConfirm: () {
              widget.onConfirm(
                substituteLibraryId: _selected!.id!,
                substituteName: _selected!.name,
                substituteMuscle: _selected!.muscleGroup,
                permanent: _permanent,
                reason: _reasonCtrl.text,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ConfirmPanel extends StatelessWidget {
  final ExerciseTemplate selected;
  final bool permanent;
  final TextEditingController reasonCtrl;
  final ValueChanged<bool> onPermanentChanged;
  final VoidCallback onConfirm;

  const _ConfirmPanel({
    required this.selected,
    required this.permanent,
    required this.reasonCtrl,
    required this.onPermanentChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sustituir por "${selected.name}"',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(
              hintText: 'Motivo (opcional)…',
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: permanent,
                onChanged: onPermanentChanged,
                activeThumbColor: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permanent
                          ? 'Cambio permanente en la rutina'
                          : 'Solo esta sesión',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      permanent
                          ? 'Se guardará en tu rutina para siempre'
                          : 'La rutina original no cambia',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.darkMuted),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.2)
                : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.darkBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color:
                  selected ? AppTheme.primary : AppTheme.darkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
