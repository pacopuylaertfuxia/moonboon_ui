/// Shared widgets for the V3 "refinement" settings flow
/// (Figma file rACkGGMsxHsQue8tSx1syC).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/button.dart';
import '../../common/modal_sheet.dart';
import '../../theme/theme_colors.dart';
import '../settings_flow/flow_state.dart';

/// SVG icon exported from the refinement Figma file.
class RefIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const RefIcon(this.name, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/settings_ref/$name.svg',
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

/// Circular photo from the exported Figma assets.
class RefPhoto extends StatelessWidget {
  final String asset;
  final double size;
  const RefPhoto(this.asset, {super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'assets/images/settings_ref/$asset',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

String refBabyPhoto = 'baby.png';

/// Deterministic photo per caregiver for the prototype.
String refPhotoFor(Caregiver m) {
  if (m.owner) return 'member2.png';
  if (m.firstName == 'Kasper') return 'member3.png';
  return 'me.png';
}

/// Third caregiver from the refined Figma (59:13176) — "Kasper · Bestie".
final Caregiver refKasper = Caregiver(
  firstName: 'Kasper',
  lastName: 'Holm',
  role: 'Bestie',
  country: 'Denmark',
  email: 'kasper@holm.dk',
  memberSince: 'March 2026',
);

List<Caregiver>? _refMembers;

/// Mutable member list for the refinement flow (shared across its pages
/// so a removal on the family screen shows up on the overview).
List<Caregiver> refMembers() =>
    _refMembers ??= [...FlowState.i.members, refKasper];

/// Top nav: bare back arrow, optional centered serif title, optional
/// right-aligned action (e.g. Save).
class RefTopNav extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final VoidCallback? onBack;
  const RefTopNav({super.key, this.title, this.trailing, this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Text(title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.headlineSmall?.copyWith(fontSize: 28)),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/icons/utility/chevron_left.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                        context.color.textPrimary, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      ),
    );
  }
}

/// Apricot Save chip — 32% opacity while disabled.
class RefSaveButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const RefSaveButton({super.key, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Opacity(
      opacity: enabled ? 1 : 0.32,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.surfaceTertiary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            widthFactor: 1,
            child: Text('Save',
                style: t.labelMedium?.copyWith(color: c.textPrimary)),
          ),
        ),
      ),
    );
  }
}

/// Small white circular badge (camera on avatars, pencil on fields).
class RefEditBadge extends StatelessWidget {
  final String icon;
  final double iconSize;
  const RefEditBadge({super.key, this.icon = 'edit', this.iconSize = 16});

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: RefIcon(icon, size: iconSize, color: c.textPrimary),
    );
  }
}

/// Avatar + camera badge, opens the photo sheet.
class RefAvatarWithCamera extends StatelessWidget {
  final String asset;
  final double size;
  final VoidCallback onTap;
  const RefAvatarWithCamera({
    super.key,
    required this.asset,
    this.size = 109,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            RefPhoto(asset, size: size),
            const Positioned(
              right: 0,
              bottom: 0,
              child: RefEditBadge(icon: 'camera', iconSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

/// Labelled white pill field: label 12 above, h52 pill with value +
/// trailing widget (edit badge / flag).
class RefField extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  const RefField({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 6),
          child: Text(label,
              style: t.labelSmall?.copyWith(color: c.textTertiary)),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.only(left: 16, right: 11),
            decoration: BoxDecoration(
              color: c.surfacePrimary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelMedium
                          ?.copyWith(fontSize: 16, color: c.textTertiary)),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Same pill, but with a live TextField inside (editing state).
class RefEditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool editing;
  final VoidCallback onEdit;
  final TextInputType? keyboardType;
  const RefEditableField({
    super.key,
    required this.label,
    required this.controller,
    required this.editing,
    required this.onEdit,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.color;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 6),
          child: Text(label,
              style: t.labelSmall?.copyWith(color: c.textTertiary)),
        ),
        Container(
          height: 52,
          padding: const EdgeInsets.only(left: 16, right: 11),
          decoration: BoxDecoration(
            color: c.surfacePrimary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Expanded(
                child: editing
                    ? TextField(
                        controller: controller,
                        autofocus: true,
                        keyboardType: keyboardType,
                        style: t.labelMedium
                            ?.copyWith(fontSize: 16, color: c.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onEdit,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(controller.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.labelMedium?.copyWith(
                                  fontSize: 16, color: c.textTertiary)),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const RefEditBadge(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Photo source sheet per the refined Figma (61:2797 "poto" state):
/// serif title + subtitle, white pill rows. Returns true if a photo
/// was "picked", false if removed/dismissed.
Future<bool> showRefPhotoSheet(BuildContext context,
    {bool allowRemove = false}) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  final result = await ModalSheet.show<String>(
    context: context,
    child: Builder(
      builder: (ctx) {
        Widget row(IconData icon, String label, String value) =>
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(value),
              child: Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: c.surfacePrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: c.textPrimary),
                    const SizedBox(width: 12),
                    Text(label,
                        style: t.labelMedium
                            ?.copyWith(fontSize: 16, color: c.textPrimary)),
                  ],
                ),
              ),
            );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add a photo',
                  textAlign: TextAlign.center,
                  style: t.headlineSmall?.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text('Personalize your profile',
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: c.textTertiary)),
              const SizedBox(height: 24),
              row(Icons.photo_camera_outlined, 'Take a photo', 'camera'),
              row(Icons.photo_library_outlined, 'Choose from library',
                  'library'),
              if (allowRemove)
                row(Icons.delete_outline_rounded, 'Remove photo',
                    'remove'),
            ],
          ),
        );
      },
    ),
  );
  if (result == 'remove') return false;
  return result != null;
}

/// Confirm sheet per the refined Figma (80:1737 Log out / 80:1917 Delete):
/// serif title, body in textTertiary, DS Button (primary or white pill with
/// red border when destructive) + clay Cancel. Returns true on confirm.
Future<bool> showRefConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  final ok = await ModalSheet.show<bool>(
    context: context,
    child: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: t.headlineSmall?.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(body,
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textTertiary)),
          const SizedBox(height: 22),
          if (destructive)
            Button(
              variant: ButtonVariant.outlined,
              size: ButtonSize.lg,
              backgroundColor: c.surfacePrimary,
              borderColor: c.feedbackError,
              labelStyle: t.titleMedium?.copyWith(color: c.feedbackError),
              buttonLabel: Text(confirmLabel),
              onPressed: () => Navigator.of(ctx).pop(true),
            )
          else
            Button(
              variant: ButtonVariant.primary,
              size: ButtonSize.lg,
              buttonLabel: Text(confirmLabel),
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          const SizedBox(height: 8),
          Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.lg,
            labelStyle: t.titleMedium?.copyWith(color: c.textQuaternary),
            buttonLabel: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
  return ok == true;
}

const refCountries = <(String, String)>[
  ('Denmark', '🇩🇰'),
  ('Sweden', '🇸🇪'),
  ('Norway', '🇳🇴'),
  ('Finland', '🇫🇮'),
  ('Iceland', '🇮🇸'),
  ('Germany', '🇩🇪'),
  ('Netherlands', '🇳🇱'),
  ('Belgium', '🇧🇪'),
  ('Italy', '🇮🇹'),
  ('France', '🇫🇷'),
  ('Estonia', '🇪🇪'),
  ('United Kingdom', '🇬🇧'),
];

const refLanguages = <(String, String)>[
  ('Danish', '🇩🇰'),
  ('Swedish', '🇸🇪'),
  ('Norwegian', '🇳🇴'),
  ('Finnish', '🇫🇮'),
  ('Icelandic', '🇮🇸'),
  ('German', '🇩🇪'),
  ('Dutch', '🇳🇱'),
  ('Italian', '🇮🇹'),
  ('French', '🇫🇷'),
  ('English', '🇬🇧'),
];

String refFlagFor(String name) {
  for (final e in [...refCountries, ...refLanguages]) {
    if (e.$1 == name) return e.$2;
  }
  return '🏳️';
}

/// Full-height picker sheet with search — used for Country & Language.
Future<String?> showRefPickerSheet(
  BuildContext context, {
  required String title,
  required List<(String, String)> options,
  required String selected,
}) {
  final c = context.color;
  final t = Theme.of(context).textTheme;
  // Refined Figma (40:7022): sheet under the top nav; white pill search
  // field with the field name as placeholder + search icon right; pill
  // option rows (name left, flag right); selected row = filled + border.
  String query = '';
  return ModalSheet.show<String>(
    context: context,
    hasPadding: false,
    child: StatefulBuilder(
      builder: (ctx, setSheet) {
        final filtered = options
            .where((o) => o.$1.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // — Search field —
                Container(
                  height: 52,
                  padding: const EdgeInsets.only(left: 16, right: 14),
                  decoration: BoxDecoration(
                    color: c.surfacePrimary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: false,
                          onChanged: (v) => setSheet(() => query = v),
                          style: t.bodyMedium
                              ?.copyWith(color: c.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: title,
                            hintStyle: t.bodyMedium
                                ?.copyWith(color: c.textQuaternary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        query.isEmpty
                            ? Icons.search_rounded
                            : Icons.close_rounded,
                        size: 20,
                        color: c.textSecondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // — Option pills —
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final (name, flag) = filtered[i];
                      final isSel = name == selected;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(ctx).pop(name),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          decoration: BoxDecoration(
                            // Figma: unselected = mutedApricot @50%
                            // (overlayBrand); selected = surface/tertiary
                            // + text/primary border.
                            color: isSel
                                ? c.surfaceTertiary
                                : c.overlayBrand,
                            borderRadius: BorderRadius.circular(100),
                            border: isSel
                                ? Border.all(color: c.textPrimary)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    // iOS/Label/L, text/secondary
                                    style: t.labelMedium?.copyWith(
                                        fontSize: 16,
                                        color: c.textSecondary)),
                              ),
                              Text(flag,
                                  style:
                                      const TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
        );
      },
    ),
  );
}

const monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "5 January 2026, 9:41 AM"
String refFormatBirthdate(DateTime d) {
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final min = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour < 12 ? 'AM' : 'PM';
  return '${d.day} ${monthNames[d.month - 1]} ${d.year}, $h12:$min $ampm';
}
