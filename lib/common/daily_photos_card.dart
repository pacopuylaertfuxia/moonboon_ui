import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/theme_colors.dart';

/// Baby photo grid for the day — tiles flow via Wrap so the card height
/// matches exactly how many photos there are (no empty padding columns).
class DailyPhotosCard extends StatelessWidget {
  final List<Uint8List> photos;
  final VoidCallback onAddPhoto;

  const DailyPhotosCard({
    super.key,
    required this.photos,
    required this.onAddPhoto,
  });

  static const double _tileSize = 88.0;

  @override
  Widget build(BuildContext context) {
    final c = context.color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.borderSubdued),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Daily photo',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: c.textPrimary),
              ),
              const Spacer(),
              if (photos.isNotEmpty)
                Text(
                  '${photos.length}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: c.textTertiary),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Tiles ───────────────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...photos.map((b) => _PhotoTile(bytes: b)),
              _AddTile(onTap: onAddPhoto, c: c, context: context),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Photo tile ────────────────────────────────────────────────────────────────

class _PhotoTile extends StatelessWidget {
  final Uint8List bytes;
  const _PhotoTile({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        bytes,
        width: DailyPhotosCard._tileSize,
        height: DailyPhotosCard._tileSize,
        fit: BoxFit.cover,
      ),
    );
  }
}

// ── Add tile ──────────────────────────────────────────────────────────────────

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  final ThemeColors c;
  final BuildContext context;
  const _AddTile({required this.onTap, required this.c, required this.context});

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: DailyPhotosCard._tileSize,
        height: DailyPhotosCard._tileSize,
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 20, color: c.textTertiary),
              const SizedBox(height: 4),
              Text(
                'Add',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: c.textTertiary, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Source picker ─────────────────────────────────────────────────────────────

Future<Uint8List?> pickBabyPhoto(BuildContext context) async {
  final c = context.color;
  ImageSource? source;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: c.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: c.borderNormal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _SheetTile(
              icon: Icons.photo_library_outlined,
              label: 'Photo library',
              c: c,
              onTap: () {
                source = ImageSource.gallery;
                Navigator.of(ctx).pop();
              },
            ),
            _SheetTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              c: c,
              onTap: () {
                source = ImageSource.camera;
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (source == null) return null;

  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: source!,
    maxWidth: 1200,
    maxHeight: 1200,
    imageQuality: 85,
  );
  return file?.readAsBytes();
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeColors c;
  final VoidCallback onTap;
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: c.textSecondary, size: 20),
      ),
      title: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: c.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
