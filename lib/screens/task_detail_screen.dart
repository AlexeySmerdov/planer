import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/enhanced_tag_input.dart';
import '../widgets/enhanced_text_editor.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final FocusNode _titleFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  late List<dynamic> _images;
  late List<String> _tags;
  final ImagePicker _picker = ImagePicker();
  bool _isCompleted = false;  // track completion status

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _selectedTime = widget.task?.dueTime;
    _isCompleted = widget.task?.isCompleted ?? false;
    _tags = List.from(widget.task?.tags ?? []);
    // Initialize images: decode base64 strings or use path strings
    _images = [];
    if (widget.task != null) {
      for (var img in widget.task!.images) {
        // Try to decode base64
        try {
          final bytes = base64Decode(img);
          _images.add(bytes);
        } catch (_) {
          // Not base64, treat as file path
          _images.add(img);
        }
      }
    }
    
    // Request focus after build completes safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _images.add(bytes);
          });
        } else {
          setState(() {
            _images.add(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Widget _buildImageWidget(dynamic image) {
    if (kIsWeb) {
      // Only display newly picked images on web (Uint8List)
      if (image is Uint8List) {
        return Image.memory(
          image,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(
            width: 100,
            height: 100,
            child: Center(child: Icon(Icons.broken_image)),
          ),
        );
      }
      // Unsupported on web
      return const SizedBox(
        width: 100,
        height: 100,
        child: Center(child: Icon(Icons.broken_image)),
      );
    }
    // Mobile and desktop
    return Image.file(
      File(image as String),
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        width: 100,
        height: 100,
        child: Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow scaffold to resize when keyboard appears
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                focusNode: _titleFocusNode,
                autofocus: false,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              EnhancedTextEditor(
                controller: _descriptionController,
                labelText: 'Описание',
                hintText: 'Введите подробное описание задачи...\n\nВ режиме десктопа доступны:\n• Tab - добавить отступ\n• Shift+Tab - убрать отступ\n• Моноширинный шрифт для структурированного текста',
                maxLines: 8,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Due Time (Optional)'),
                  subtitle: Text(
                    _selectedTime != null 
                        ? _selectedTime!.format(context)
                        : 'No time set',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedTime = null;
                            });
                          },
                          tooltip: 'Clear time',
                        ),
                      const Icon(Icons.schedule),
                    ],
                  ),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedTime = picked;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Images',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    _buildImageWidget(_images[index]),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _images.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.label, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Теги',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/tags_management');
                            },
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text(
                              'Управление',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      EnhancedTagInputWidget(
                        initialTags: _tags,
                        onTagsChanged: (tags) {
                          setState(() {
                            _tags = tags;
                          });
                        },
                        hintText: 'Добавить тег (Enter для создания)',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Convert images: encode bytes to base64, keep file paths
      final List<String> imagesToSave = _images.map((e) {
        if (e is Uint8List) {
          return base64Encode(e);
        } else {
          return e as String;
        }
      }).toList();

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _selectedDate,
        dueTime: _selectedTime,
        isCompleted: _isCompleted,
        images: imagesToSave,
        tags: _tags,
      );

      if (widget.task == null) {
        Provider.of<TaskProvider>(context, listen: false).addTask(task);
      } else {
        Provider.of<TaskProvider>(context, listen: false).updateTask(task);
      }

      Navigator.pop(context, true);
    }
  }
} 