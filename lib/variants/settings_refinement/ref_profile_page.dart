import 'package:flutter/material.dart';

import '../../theme/theme_colors.dart';
import '../settings_flow/flow_shared.dart';
import '../settings_flow/flow_state.dart';
import 'ref_shared.dart';

/// V3 refinement — Your profile (Figma 20:2560 + 40:10065 states).
class RefProfilePage extends StatefulWidget {
  /// Screenshot hook: 'country' | 'language' opens that picker
  /// right after the first frame.
  final String? autoOpen;
  const RefProfilePage({super.key, this.autoOpen});

  @override
  State<RefProfilePage> createState() => _RefProfilePageState();
}

class _RefProfilePageState extends State<RefProfilePage> {
  final s = FlowState.i;

  late final TextEditingController _name =
      TextEditingController(text: s.me.firstName);
  late final TextEditingController _role =
      TextEditingController(text: s.me.role);
  late final TextEditingController _email =
      TextEditingController(text: s.me.email);
  late String _country = s.me.country;
  late String _language = s.me.language;

  String? _editing; // 'name' | 'role' | 'email'

  @override
  void initState() {
    super.initState();
    for (final ctl in [_name, _role, _email]) {
      ctl.addListener(() {
        if (mounted) setState(() {});
      });
    }
    if (widget.autoOpen != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        switch (widget.autoOpen) {
          case 'country':
            _pickCountry();
          case 'language':
            _pickLanguage();
        }
      });
    }
  }

  bool get _dirty =>
      _name.text.trim() != s.me.firstName ||
      _role.text.trim() != s.me.role ||
      _email.text.trim() != s.me.email ||
      _country != s.me.country ||
      _language != s.me.language;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    s.me
      ..firstName = _name.text.trim()
      ..role = _role.text.trim()
      ..email = _email.text.trim()
      ..country = _country
      ..language = _language;
    FocusScope.of(context).unfocus();
    setState(() => _editing = null);
    showFlowToast(context, 'Saved');
    Navigator.of(context).pop();
  }

  void _toggleEdit(String field) {
    setState(() => _editing = _editing == field ? null : field);
  }

  Future<void> _pickCountry() async {
    final v = await showRefPickerSheet(context,
        title: 'Country', options: refCountries, selected: _country);
    if (v != null) setState(() => _country = v);
  }

  Future<void> _pickLanguage() async {
    final v = await showRefPickerSheet(context,
        title: 'Language', options: refLanguages, selected: _language);
    if (v != null) setState(() => _language = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Scaffold(
      backgroundColor: c.surfaceSecondary,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            RefTopNav(
              title: 'Your profile',
              trailing: RefSaveButton(enabled: _dirty, onTap: _save),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    RefAvatarWithCamera(
                      asset: refPhotoFor(s.me),
                      onTap: () async {
                        final picked = await showRefPhotoSheet(context,
                            allowRemove: s.me.hasPhoto);
                        if (picked && context.mounted) {
                          showFlowToast(context, 'Photo updated');
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                    RefEditableField(
                      label: 'Name',
                      controller: _name,
                      editing: _editing == 'name',
                      onEdit: () => _toggleEdit('name'),
                    ),
                    const SizedBox(height: 12),
                    RefField(
                      label: 'Country',
                      value: _country,
                      trailing: Text(refFlagFor(_country),
                          style: const TextStyle(fontSize: 20)),
                      onTap: _pickCountry,
                    ),
                    const SizedBox(height: 12),
                    RefField(
                      label: 'Language',
                      value: _language,
                      trailing: Text(refFlagFor(_language),
                          style: const TextStyle(fontSize: 20)),
                      onTap: _pickLanguage,
                    ),
                    const SizedBox(height: 12),
                    RefEditableField(
                      label: 'Role',
                      controller: _role,
                      editing: _editing == 'role',
                      onEdit: () => _toggleEdit('role'),
                    ),
                    const SizedBox(height: 12),
                    RefEditableField(
                      label: 'Email',
                      controller: _email,
                      editing: _editing == 'email',
                      onEdit: () => _toggleEdit('email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
