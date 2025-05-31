import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class EnhancedTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final int? maxLines;
  final bool expands;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final FocusNode? focusNode;

  const EnhancedTextEditor({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.maxLines,
    this.expands = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<EnhancedTextEditor> createState() => _EnhancedTextEditorState();
}

class _EnhancedTextEditorState extends State<EnhancedTextEditor> {
  late FocusNode _focusNode;
  late StrikethroughTextEditingController _internalController;
  bool _isDesktop = false;
  bool _hasFocus = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _isDesktop = kIsWeb || (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);
    
    // Create internal controller and sync with external controller
    _internalController = StrikethroughTextEditingController();
    _internalController.text = widget.controller.text;
    
    // Sync changes from internal to external controller
    _internalController.addListener(() {
      if (_internalController.text != widget.controller.text) {
        widget.controller.text = _internalController.text;
      }
    });
    
    // Sync changes from external to internal controller
    widget.controller.addListener(() {
      if (widget.controller.text != _internalController.text) {
        _internalController.text = widget.controller.text;
      }
    });
    
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });

    // Add listener for text changes to handle automatic markers
    _internalController.addListener(_handleTextChange);
    _previousText = _internalController.text;
  }

  @override
  void dispose() {
    _internalController.removeListener(_handleTextChange);
    _internalController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (!selection.isValid || selection.start != selection.end) {
      _previousText = text;
      return;
    }
    
    final cursorPosition = selection.start;
    
    // Check if text was deleted (backspace scenario)
    if (text.length < _previousText.length) {
      _handleTextDeletion(text, cursorPosition);
      _previousText = text;
      return;
    }
    
    if (cursorPosition == 0) {
      _previousText = text;
      return;
    }
    
    // Find the current line
    final lines = text.substring(0, cursorPosition).split('\n');
    if (lines.isEmpty) {
      _previousText = text;
      return;
    }
    
    final currentLine = lines.last;
    
    // Check for automatic bullet point creation (typing "-")
    if (currentLine == '-') {
      _replaceLine(currentLine, '• ', cursorPosition);
      return;
    }
    
    // Check for automatic numbering creation (typing "1")
    if (currentLine == '1') {
      _replaceLine(currentLine, '1. ', cursorPosition);
      return;
    }
    
    // Check for Enter key handling (line continuation)
    if (lines.length > 1 && currentLine.isEmpty) {
      final previousLine = lines[lines.length - 2];
      _handleLineContinuation(previousLine, cursorPosition);
    }
    
    _previousText = text;
  }

  void _handleTextDeletion(String currentText, int cursorPosition) {
    // Check if we're at the position where a marker might have been deleted
    final lines = currentText.substring(0, cursorPosition).split('\n');
    if (lines.isEmpty) return;
    
    final currentLine = lines.last;
    final lineStartPosition = cursorPosition - currentLine.length;
    
    // Check if we just deleted part of a bullet marker
    final prevLines = _previousText.substring(0, cursorPosition + (_previousText.length - currentText.length)).split('\n');
    if (prevLines.isNotEmpty) {
      final prevLine = prevLines.last;
      
      // If previous line had a bullet marker and current line doesn't, and cursor is at the right position
      if (prevLine.startsWith('• ') && !currentLine.startsWith('• ') && cursorPosition == lineStartPosition + currentLine.length) {
        // Check if user is trying to delete the bullet marker
        if (currentLine == '•' || currentLine.isEmpty) {
          // Remove any remaining bullet marker parts
          final newText = currentText.replaceRange(lineStartPosition, cursorPosition, '');
          _internalController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: lineStartPosition),
          );
          return;
        }
      }
      
      // Check for numbered marker deletion
      final prevNumberMatch = RegExp(r'^(\s*)(\d+)\.\s').firstMatch(prevLine);
      if (prevNumberMatch != null) {
        final numberMatch = RegExp(r'^(\s*)(\d+)\.?$').firstMatch(currentLine);
        if (numberMatch != null && cursorPosition == lineStartPosition + currentLine.length) {
          // Remove the numbered marker completely
          final indent = numberMatch.group(1) ?? '';
          final newText = currentText.replaceRange(lineStartPosition, cursorPosition, indent);
          _internalController.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: lineStartPosition + indent.length),
          );
          return;
        }
      }
    }
  }

  void _handleLineContinuation(String previousLine, int cursorPosition) {
    // Check if previous line starts with bullet point
    if (previousLine.trim().startsWith('• ')) {
      final indent = _getIndentation(previousLine);
      final newMarker = '$indent• ';
      _insertAtCursor(newMarker, cursorPosition);
      return;
    }
    
    // Check if previous line starts with numbering
    final numberMatch = RegExp(r'^(\s*)(\d+)\.\s').firstMatch(previousLine);
    if (numberMatch != null) {
      final indent = numberMatch.group(1) ?? '';
      final currentNumber = int.parse(numberMatch.group(2) ?? '1');
      final nextNumber = currentNumber + 1;
      final newMarker = '$indent$nextNumber. ';
      _insertAtCursor(newMarker, cursorPosition);
      return;
    }
  }

  String _getIndentation(String line) {
    final match = RegExp(r'^(\s*)').firstMatch(line);
    return match?.group(1) ?? '';
  }

  void _insertAtCursor(String text, int cursorPosition) {
    final currentText = _internalController.text;
    final newText = currentText.replaceRange(cursorPosition, cursorPosition, text);
    
    _internalController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPosition + text.length,
      ),
    );
  }

  void _handleTabKey() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (selection.isValid) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '    ', // 4 пробела вместо табуляции для лучшей совместимости
      );
      
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + 4,
        ),
      );
    }
  }

  void _handleShiftTabKey() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (selection.isValid && selection.start >= 4) {
      final beforeCursor = text.substring(selection.start - 4, selection.start);
      if (beforeCursor == '    ') {
        final newText = text.replaceRange(
          selection.start - 4,
          selection.start,
          '',
        );
        
        _internalController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: selection.start - 4,
          ),
        );
      }
    }
  }

  void _handleStrikethrough() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (!selection.isValid || selection.start == selection.end) return;
    
    final selectedText = text.substring(selection.start, selection.end);
    
    // Check if text is already strikethrough
    if (selectedText.startsWith('~~') && selectedText.endsWith('~~') && selectedText.length > 4) {
      // Remove strikethrough
      final unstruckText = selectedText.substring(2, selectedText.length - 2);
      final newText = text.replaceRange(selection.start, selection.end, unstruckText);
      
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + unstruckText.length,
        ),
      );
    } else {
      // Add strikethrough
      final struckText = '~~$selectedText~~';
      final newText = text.replaceRange(selection.start, selection.end, struckText);
      
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + struckText.length,
        ),
      );
    }
  }

  void _insertBulletPoint() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (selection.isValid) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '• ',
      );
      
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + 2,
        ),
      );
    }
  }

  void _insertNumberedPoint() {
    final text = _internalController.text;
    final selection = _internalController.selection;
    
    if (selection.isValid) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '1. ',
      );
      
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + 3,
        ),
      );
    }
  }

  void _replaceLine(String oldLine, String newLine, int cursorPosition) {
    final text = _internalController.text;
    final startOfLine = cursorPosition - oldLine.length;
    
    final newText = text.replaceRange(startOfLine, cursorPosition, newLine);
    
    _internalController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: startOfLine + newLine.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Для мобильных устройств используем обычный TextFormField
    if (!_isDesktop) {
      return TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
        ),
        maxLines: widget.maxLines ?? 5,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        enabled: widget.enabled,
      );
    }

    // Для полноэкранного режима (expands: true) используем упрощенный редактор без панели
    if (widget.expands) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _hasFocus 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline,
                  width: _hasFocus ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.tab): _handleTabKey,
                  const SingleActivator(LogicalKeyboardKey.tab, shift: true): _handleShiftTabKey,
                  const SingleActivator(LogicalKeyboardKey.keyX, control: true, shift: true): _handleStrikethrough,
                },
                child: TextFormField(
                  controller: _internalController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  maxLines: widget.expands ? null : (widget.maxLines ?? 10),
                  expands: widget.expands,
                  keyboardType: widget.keyboardType ?? TextInputType.multiline,
                  validator: widget.validator,
                  enabled: widget.enabled,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'monospace',
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Для десктопа используем улучшенный редактор с панелью инструментов
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _hasFocus 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline,
              width: _hasFocus ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Toolbar для десктопа
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Умный редактор',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Кнопки форматирования
                    IconButton(
                      onPressed: _insertBulletPoint,
                      icon: const Icon(Icons.format_list_bulleted, size: 16),
                      tooltip: 'Добавить маркер',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                    IconButton(
                      onPressed: _insertNumberedPoint,
                      icon: const Icon(Icons.format_list_numbered, size: 16),
                      tooltip: 'Добавить нумерацию',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                    IconButton(
                      onPressed: _handleStrikethrough,
                      icon: const Icon(Icons.strikethrough_s, size: 16),
                      tooltip: 'Зачеркнуть (Ctrl+Shift+X)',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Авто-списки',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Текстовое поле
              CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.tab): _handleTabKey,
                  const SingleActivator(LogicalKeyboardKey.tab, shift: true): _handleShiftTabKey,
                  const SingleActivator(LogicalKeyboardKey.keyX, control: true, shift: true): _handleStrikethrough,
                },
                child: TextFormField(
                  controller: _internalController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Введите описание...\n\nУмные функции:\n• Наберите "-" для маркера\n• Наберите "1" для нумерации\n• Enter продолжает список\n• Tab для отступов\n• Выделите текст и Ctrl+Shift+X для зачеркивания',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  maxLines: widget.expands ? null : (widget.maxLines ?? 10),
                  expands: widget.expands,
                  keyboardType: widget.keyboardType ?? TextInputType.multiline,
                  validator: widget.validator,
                  enabled: widget.enabled,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'monospace', // Моноширинный шрифт для лучшего отображения отступов
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
        // Подсказки для десктопа
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Умные списки: "-" → маркер, "1" → нумерация, Enter продолжает список. Tab/Shift+Tab для отступов. Ctrl+Shift+X для зачеркивания.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StrikethroughTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue;
  }
}

class StrikethroughTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final text = this.text;
    final theme = Theme.of(context);
    
    if (!text.contains('~~')) {
      return TextSpan(text: text, style: style);
    }

    final List<TextSpan> spans = [];
    final RegExp strikethroughRegex = RegExp(r'~~([^~]+)~~');
    int lastMatchEnd = 0;

    for (final match in strikethroughRegex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style,
        ));
      }

      // Add strikethrough text
      spans.add(TextSpan(
        text: match.group(1),
        style: style?.copyWith(
          decoration: TextDecoration.lineThrough,
          decorationColor: theme.colorScheme.onSurfaceVariant,
          decorationThickness: 2.0,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }

    return TextSpan(children: spans);
  }
} 