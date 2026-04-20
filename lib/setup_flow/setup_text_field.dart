import 'package:flutter/material.dart';
import '../common/button.dart';
import '../common/circular_loading_bar.dart';
import '../theme/theme_colors.dart';
import '../strings/app_strings.dart';

class SetupTextController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isReadOnly = false;
  final TextEditingController _textController = TextEditingController();

  bool get isLoading => _isLoading;
  bool get isReadOnly => _isReadOnly;
  TextEditingController get textController => _textController;

  void setText(String text) {
    _textController.text = text;
    notifyListeners();
  }

  void setReadOnly(bool readOnly) {
    _isReadOnly = readOnly;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class SetupTextField extends StatefulWidget {
  final SetupTextController controller;
  final Function(String) onSubmitted;
  final bool Function(String) validationRule;
  final String hintText;
  final bool isObscured;
  final bool withInputField;
  final TextCapitalization textCapitalization;

  const SetupTextField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.validationRule,
    required this.hintText,
    this.isObscured = false,
    this.withInputField = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<SetupTextField> createState() => _SetupTextFieldState();
}

class _SetupTextFieldState extends State<SetupTextField> {
  bool _isValid = false;
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _isObscured = widget.isObscured;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _validateInput(String value) {
    setState(() {
      _isValid = widget.validationRule(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller.isLoading;
    final isReadOnly = widget.controller.isReadOnly;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 16),
        if (widget.withInputField)
          TextField(
            enabled: !isLoading && !isReadOnly,
            readOnly: isReadOnly,
            controller: widget.controller.textController,
            obscureText: _isObscured,
            textCapitalization: widget.textCapitalization,
            decoration: InputDecoration(
              hintText: widget.hintText,
              fillColor: isDarkMode
                  ? context.color.surfacePrimary
                  : context.color.surfaceSecondary,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              hintStyle: TextStyle(color: context.color.textQuaternary),
              suffixIcon: widget.isObscured
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: context.color.textTertiary.withValues(alpha: 0.6),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _isObscured = !_isObscured);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    )
                  : null,
            ),
            onChanged: _validateInput,
          ),
        const SizedBox(height: 16),
        Button(
          onPressed: isLoading
              ? null
              : () => widget.onSubmitted(
                    widget.controller.textController.text,
                  ),
          buttonLabel: isLoading
              ? const CircularLoadingBar()
              : Text(context.text.monitor_pair_continue),
          variant: ButtonVariant.primary,
          size: ButtonSize.lg,
          disabled: (!_isValid && !isReadOnly) || isLoading,
        ),
      ],
    );
  }
}
