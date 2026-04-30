import 'package:flutter/material.dart';
import 'noise_detection_body.dart';

class SoundMonitoringConsentBody extends StatefulWidget {
  final VoidCallback onContinue;

  const SoundMonitoringConsentBody({
    super.key,
    required this.onContinue,
  });

  @override
  State<SoundMonitoringConsentBody> createState() =>
      _SoundMonitoringConsentBodyState();
}

class _SoundMonitoringConsentBodyState
    extends State<SoundMonitoringConsentBody> {
  NoiseDetectionLevel _level = NoiseDetectionLevel.medium;
  bool _onlyBabyCries = false;

  @override
  Widget build(BuildContext context) {
    return ModeSelectionBody(
      level: _level,
      onlyBabyCries: _onlyBabyCries,
      onLevelSelected: (l) => setState(() => _level = l),
      onOnlyBabyCriesChanged: (v) => setState(() => _onlyBabyCries = v),
      onContinue: widget.onContinue,
      // prototype: pending l10n
      title: "You're all set for\nsound alerts",
      // prototype: pending l10n
      subtitle:
          "Here's what we've enabled for you to start with. You can adjust it anytime.",
    );
  }
}
