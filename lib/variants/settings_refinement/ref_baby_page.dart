import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';
import '../settings_flow/flow_shared.dart';
import '../settings_flow/flow_state.dart';
import 'ref_shared.dart';

/// V3 refinement — Edit baby profile (Figma 61:2798 + date-picker state).
class RefBabyPage extends StatefulWidget {
  const RefBabyPage({super.key});

  @override
  State<RefBabyPage> createState() => _RefBabyPageState();
}

class _RefBabyPageState extends State<RefBabyPage> {
  final s = FlowState.i;

  late final TextEditingController _name =
      TextEditingController(text: s.baby?.name ?? '');
  late DateTime _birthdate = s.baby?.birthdate ?? DateTime.now();
  bool _editingName = false;
  bool _pickingDate = false;

  bool get _dirty =>
      s.baby != null &&
      (_name.text.trim() != s.baby!.name ||
          _birthdate != s.baby!.birthdate);

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    s.baby
      ?..name = _name.text.trim()
      ..birthdate = _birthdate;
    FocusScope.of(context).unfocus();
    showFlowToast(context, 'Saved');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      body: SafeArea(
        child: Column(
          children: [
            RefTopNav(
              title: s.baby?.name ?? 'Baby',
              trailing: RefSaveButton(enabled: _dirty, onTap: _save),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    RefAvatarWithCamera(
                      asset: refBabyPhoto,
                      onTap: () async {
                        final picked = await showRefPhotoSheet(context,
                            allowRemove: s.baby?.hasPhoto ?? false);
                        if (picked && context.mounted) {
                          showFlowToast(context, 'Photo updated');
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                    RefEditableField(
                      label: 'Name',
                      controller: _name,
                      editing: _editingName,
                      onEdit: () =>
                          setState(() => _editingName = !_editingName),
                    ),
                    const SizedBox(height: 12),
                    RefField(
                      label: 'Birthdate',
                      value: refFormatBirthdate(_birthdate),
                      trailing: const RefEditBadge(),
                      onTap: () =>
                          setState(() => _pickingDate = !_pickingDate),
                    ),
                    if (_pickingDate) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: c.surfacePrimary,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Column(
                          children: [
                            CalendarDatePicker(
                              initialDate: _birthdate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              onDateChanged: (d) => setState(() {
                                _birthdate = DateTime(d.year, d.month,
                                    d.day, _birthdate.hour,
                                    _birthdate.minute);
                              }),
                            ),
                            Divider(height: 1, color: c.borderSubdued),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _pickTime,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Text('Time', style: t.bodyMedium),
                                    const Spacer(),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6),
                                      decoration: BoxDecoration(
                                        color: c.surfaceSecondary,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        _formatTime(_birthdate),
                                        style: t.labelMedium?.copyWith(
                                            fontSize: 16,
                                            color: c.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_birthdate),
    );
    if (t != null) {
      setState(() {
        _birthdate = DateTime(_birthdate.year, _birthdate.month,
            _birthdate.day, t.hour, t.minute);
      });
    }
  }

  String _formatTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    return '$h12:$min ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
