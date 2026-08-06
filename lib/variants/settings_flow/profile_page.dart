import 'package:flutter/material.dart';

import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import 'flow_shared.dart';
import 'flow_state.dart';

/// P1 — Your profile. Avatar + editable fields; email read-only with lock.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Caregiver get me => FlowState.i.me;

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return FlowScaffold(
      title: 'Your profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          children: [
            // Avatar — feeds the constellation on the root
            GestureDetector(
              onTap: () async {
                final has =
                    await showPhotoSheet(context, allowRemove: me.hasPhoto);
                setState(() => me.hasPhoto = has);
                if (context.mounted) {
                  showFlowToast(
                      context, has ? 'Photo updated' : 'Photo removed');
                }
              },
              child: Stack(
                children: [
                  Avatar(
                      initials: me.initials, size: 96, hasPhoto: me.hasPhoto),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: c.surfacePrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: c.overlayLevel1, blurRadius: 8),
                        ],
                      ),
                      child: Icon(Icons.photo_camera_outlined,
                          size: 15, color: c.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _row('Name', me.name, () => _editName()),
            const SizedBox(height: 10),
            _row('Country', me.country, () => _pickCountry()),
            const SizedBox(height: 10),
            _row('Role', me.role, () => _pickRole()),
            const SizedBox(height: 10),
            _emailRow(),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Contact support to change your email.',
                style: t.labelSmall?.copyWith(color: c.textQuaternary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: c.surfacePrimary,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: t.labelSmall?.copyWith(color: c.textTertiary)),
                  const SizedBox(height: 2),
                  Text(value, style: t.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: c.textQuaternary),
          ],
        ),
      ),
    );
  }

  Widget _emailRow() {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: c.surfacePrimary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email',
                    style: t.labelSmall?.copyWith(color: c.textTertiary)),
                const SizedBox(height: 2),
                Text(me.email,
                    style: t.bodyMedium?.copyWith(color: c.textTertiary)),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded,
              size: 16, color: c.textQuaternary),
        ],
      ),
    );
  }

  // P2 — edit name
  Future<void> _editName() async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _EditNamePage(caregiver: me)));
    setState(() {});
  }

  // P3 — country picker
  Future<void> _pickCountry() async {
    const countries = [
      'Denmark',
      'Sweden',
      'Norway',
      'Germany',
      'Netherlands',
      'Belgium',
      'United Kingdom',
    ];
    final picked = await _pickFromSheet(
        context, 'Where do you live?', countries, me.country);
    if (picked != null) {
      setState(() => me.country = picked);
      if (mounted) showFlowToast(context, 'Saved');
    }
  }

  // P4 — role picker
  Future<void> _pickRole() async {
    final picked = await _pickFromSheet(context, 'Your role in the family',
        const ['Mother', 'Father', 'Guardian'], me.role);
    if (picked != null) {
      setState(() => me.role = picked);
      if (mounted) showFlowToast(context, 'Saved');
    }
  }
}

Future<String?> _pickFromSheet(BuildContext context, String title,
    List<String> options, String current) {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  return ModalSheet.show<String>(
    context: context,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: t.headlineMedium?.copyWith(fontSize: 24, fontFamily: 'KeplerStd')),
          const SizedBox(height: 20),
          for (final o in options) ...[
            Builder(builder: (ctx) {
              final selected = o == current;
              return GestureDetector(
                onTap: () => Navigator.of(ctx).pop(o),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 15),
                  decoration: BoxDecoration(
                    color: selected ? c.surfaceTertiary : c.surfacePrimary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(o, style: t.bodyMedium)),
                      if (selected)
                        Icon(Icons.check_rounded,
                            size: 18, color: c.textPrimary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    ),
  );
}

/// P2 — Edit name form. Explicit Save pill; back with unsaved changes asks.
class _EditNamePage extends StatefulWidget {
  final Caregiver caregiver;
  const _EditNamePage({required this.caregiver});

  @override
  State<_EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<_EditNamePage> {
  late final TextEditingController _first =
      TextEditingController(text: widget.caregiver.firstName);
  late final TextEditingController _last =
      TextEditingController(text: widget.caregiver.lastName);

  bool get _dirty =>
      _first.text != widget.caregiver.firstName ||
      _last.text != widget.caregiver.lastName;

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
    return FlowScaffold(
      title: 'Your name',
      onWillPop: _confirmLeave,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          children: [
            PillField(label: 'First name', controller: _first),
            const SizedBox(height: 14),
            PillField(label: 'Last name', controller: _last),
            const Spacer(),
            PrimaryPill(
              label: 'Save',
              onTap: () {
                widget.caregiver.firstName = _first.text.trim();
                widget.caregiver.lastName = _last.text.trim();
                Navigator.of(context).pop();
                showFlowToast(context, 'Saved');
              },
            ),
          ],
        ),
      ),
    );
  }
}
