import 'package:flutter/material.dart';

import '../../domain/prep_models.dart';
import '../../domain/recovery_vault.dart';
import '../../state/recovery_scope.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/dawn_card.dart';
import '../../widgets/phase_dial.dart';

class PrepChecklistView extends StatefulWidget {
  const PrepChecklistView({super.key});

  @override
  State<PrepChecklistView> createState() => _PrepChecklistViewState();
}

class _PrepChecklistViewState extends State<PrepChecklistView> {
  Future<void> _addItem(RecoveryVault vault) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DawnPalette.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Add to your kit', style: DawnType.heading()),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Travel pillow'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: DawnType.label()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child:
                Text('Add', style: DawnType.label(color: DawnPalette.duskDeep)),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await vault.addItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vault = RecoveryScope.of(context);
    final signals = vault.signals;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _readinessCard(signals),
            const SizedBox(height: 18),
            _habitsCard(vault),
            const SizedBox(height: 18),
            Text('Packing checklist', style: DawnType.label()),
            const SizedBox(height: 12),
            ...vault.items.map((item) => _itemTile(vault, item)),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton(
            backgroundColor: DawnPalette.dawn,
            foregroundColor: Colors.white,
            onPressed: () => _addItem(vault),
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }

  Widget _readinessCard(ReadinessSignals signals) {
    final tint = signals.score >= 0.75
        ? DawnPalette.rested
        : signals.score >= 0.45
            ? DawnPalette.adjusting
            : DawnPalette.strained;
    return DawnCard(
      child: Row(
        children: [
          PhaseDial(
            size: 100,
            readiness: signals.score,
            stroke: 11,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(signals.score * 100).round()}',
                    style: DawnType.clock(26, color: DawnPalette.ink)),
                Text('ready', style: DawnType.caption()),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arrival readiness', style: DawnType.heading()),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(signals.band,
                      style: DawnType.label(color: tint)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your score reflects how much of the plan you have followed and how packed you are.',
                  style: DawnType.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitsCard(RecoveryVault vault) {
    return DawnCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjustment habits', style: DawnType.heading()),
          const SizedBox(height: 8),
          _habitSwitch(
            'Started shifting my sleep',
            Icons.bedtime_rounded,
            vault.sleepShiftStarted,
            (v) => vault.setSleepShift(v),
          ),
          _habitSwitch(
            'Following the light plan',
            Icons.wb_sunny_rounded,
            vault.lightPlanFollowed,
            (v) => vault.setLightPlan(v),
          ),
          _habitSwitch(
            'Staying hydrated',
            Icons.water_drop_rounded,
            vault.hydrationOnTrack,
            (v) => vault.setHydration(v),
          ),
        ],
      ),
    );
  }

  Widget _habitSwitch(
      String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DawnPalette.duskDeep),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: DawnType.bodyStrong())),
          Switch(
            value: value,
            activeThumbColor: DawnPalette.dusk,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _itemTile(RecoveryVault vault, PrepItem item) {
    final tile = GestureDetector(
      onTap: () => vault.togglePacked(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DawnPalette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.packed ? DawnPalette.rested : DawnPalette.hairline,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color:
                    item.packed ? DawnPalette.rested : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      item.packed ? DawnPalette.rested : DawnPalette.inkFaint,
                  width: 2,
                ),
              ),
              child: item.packed
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: DawnType.bodyStrong(
                  color: item.packed ? DawnPalette.inkFaint : DawnPalette.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!item.custom) return tile;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: DawnPalette.dawnWash,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: DawnPalette.dawnDeep),
      ),
      onDismissed: (_) => vault.removeItem(item.id),
      child: tile,
    );
  }
}
