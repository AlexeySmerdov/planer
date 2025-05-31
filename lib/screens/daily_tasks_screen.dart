import 'package:flutter/material.dart';
import 'dart:async';
import '../services/user_service.dart';
import '../widgets/enhanced_text_editor.dart';

class DailyTasksScreen extends StatefulWidget {
  final String title;
  final bool isToday;

  const DailyTasksScreen({
    super.key,
    required this.title,
    required this.isToday,
  });

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final UserService _userService = UserService();
  Timer? _saveTimer;
  bool _isLoading = true;
  bool _isSaving = false;
  String _lastSavedText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Сохраняем при закрытии страницы, если есть несохраненные изменения
    if (_controller.text != _lastSavedText) {
      _saveTextSync();
    }
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    // Сохраняем при потере фокуса (окончание печати)
    if (!_focusNode.hasFocus && _controller.text != _lastSavedText) {
      _saveText();
    }
  }

  // Синхронное сохранение для dispose
  void _saveTextSync() {
    if (widget.isToday) {
      _userService.updateTaskToday(_controller.text);
    } else {
      _userService.updateTaskTomorrow(_controller.text);
    }
    _lastSavedText = _controller.text;
  }

  Future<void> _loadData() async {
    try {
      final text = widget.isToday 
          ? await _userService.getTaskToday()
          : await _userService.getTaskTomorrow();
      
      if (mounted) {
        setState(() {
          _controller.text = text;
          _lastSavedText = text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  void _onTextChanged() {
    // Cancel previous timer
    _saveTimer?.cancel();
    
    // Start new timer for auto-save (backup save after 3 seconds of inactivity)
    _saveTimer = Timer(const Duration(seconds: 3), () {
      if (_controller.text != _lastSavedText) {
        _saveText();
      }
    });
  }

  Future<void> _saveText() async {
    if (!mounted || _controller.text == _lastSavedText) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isToday) {
        await _userService.updateTaskToday(_controller.text);
      } else {
        await _userService.updateTaskTomorrow(_controller.text);
      }
      _lastSavedText = _controller.text;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EnhancedTextEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    hintText: widget.isToday 
                        ? 'Введите ваши планы и заметки на сегодня...\n\nУмные функции:\n• Наберите "-" для маркера\n• Наберите "1" для нумерации\n• Enter продолжает список\n• Tab для отступов\n\nТекст сохраняется автоматически при окончании ввода'
                        : 'Введите ваши планы и заметки на завтра...\n\nУмные функции:\n• Наберите "-" для маркера\n• Наберите "1" для нумерации\n• Enter продолжает список\n• Tab для отступов\n\nТекст сохраняется автоматически при окончании ввода',
                  ),
                ),
              ),
            ),
    );
  }
} 