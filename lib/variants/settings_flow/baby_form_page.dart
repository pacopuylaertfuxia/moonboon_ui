import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';
import 'flow_shared.dart';
import 'flow_state.dart';

enum BabyFormMode { edit, create }

/// F3 — Edit baby (name, birthdate, photo) · F6 — Add a baby (creates family).
class BabyFormPage extends StatefulWidget {
  final BabyFormMode mode;
  final Baby? baby;
  const BabyFormPage({super.key, required this.mode, this.baby});

  @override
  State<BabyFormPage> createState() => _BabyFormPageState();
}

class _BabyFormPageState extends State<BabyFormPage> {
  late final TextEditingController _name =
      TextEditingController(text: widget.baby?.name ?? '');
  late DateTime? _birthdate = widget.baby?.birthdate;
  late bool _hasPhoto = widget.baby?.hasPhoto ?? false;

  bool get _isEdit => widget.mode == BabyFormMode.edit;

  bool get _dirty =>
      _isEdit &&
      (_name.text != widget.baby!.name ||
          _birthdate != widget.baby!.birthdate ||
          _hasPhoto != widget.baby!.hasPhoto);

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    return showConfirmSheet(
      context,
      title: 'Discard changes?',
      body: 'Your edits haven\u2019t been saved yet.',
      confirmLabel: 'Discard',
      destructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return FlowScaffold(
      title: _isEdit ? '${widget.baby!.name}\u2019s profile' : 'Add your baby',
      subtitle: _isEdit ? null : 'This creates your family — you\u2019ll be its owner.',
      onWillPop: _isEdit ? _confirmLeave : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          children: [
            // Photo — placeholder is a first-class element
            GestureDetector(
              onTap: () async {
                final has =
                    await showPhotoSheet(context, allowRemove: _hasPhoto);
                setState(() => _hasPhoto = has);
              },
              child: _hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/streaming_bg.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: c.surfaceTertiary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nightlight_round,
                              size: 34, color: c.textTertiary),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: c.surfacePrimary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('Add a photo',
                                style: t.labelSmall
                                    ?.copyWith(color: c.textTertiary)),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            PillField(label: 'Name', controller: _name),
            const SizedBox(height: 14),
            _birthdateRow(),
            if (_birthdate != null) ...[
              const SizedBox(height: 8),
              Text(
                Baby(name: '', birthdate: _birthdate!).age,
                style: t.labelSmall?.copyWith(color: c.textQuaternary),
              ),
            ],
            const SizedBox(height: 32),
            PrimaryPill(
              label: _isEdit ? 'Save' : 'Create family',
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _birthdateRow() {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    final text = _birthdate == null
        ? 'Choose a date'
        : '${_birthdate!.day} ${_month(_birthdate!.month)} ${_birthdate!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 22, bottom: 6),
          child: Text('Birthdate',
              style: t.labelSmall?.copyWith(color: c.textTertiary)),
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthdate ?? DateTime.now(),
              firstDate: DateTime.now()
                  .subtract(const Duration(days: 365 * 4)),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _birthdate = picked);
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: context.color.surfacePrimary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(text,
                      style: t.bodyMedium?.copyWith(
                          color: _birthdate == null
                              ? c.textTertiary
                              : c.textPrimary)),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: c.textQuaternary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty || _birthdate == null) {
      showFlowToast(context, 'Add a name and birthdate',
          icon: Icons.info_outline_rounded);
      return;
    }
    if (_isEdit) {
      widget.baby!
        ..name = _name.text.trim()
        ..birthdate = _birthdate!
        ..hasPhoto = _hasPhoto;
      Navigator.of(context).pop();
      showFlowToast(context, 'Saved');
    } else {
      FlowState.i.createFamily(_name.text.trim(), _birthdate!, _hasPhoto);
      Navigator.of(context).pop();
      showFlowToast(context, 'Welcome, ${_name.text.trim()}');
    }
  }

  String _month(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}
