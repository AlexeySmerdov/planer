import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tag_service.dart';
import '../providers/task_provider.dart';

class TagsManagementScreen extends StatefulWidget {
  const TagsManagementScreen({super.key});

  @override
  State<TagsManagementScreen> createState() => _TagsManagementScreenState();
}

class _TagsManagementScreenState extends State<TagsManagementScreen> {
  final TagService _tagService = TagService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = '#2196F3';
  UserTag? _editingTag;
  Map<String, int> _usageStats = {};

  final List<String> _colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#E91E63', // Pink
    '#3F51B5', // Indigo
    '#009688', // Teal
    '#8BC34A', // Light Green
  ];

  @override
  void initState() {
    super.initState();
    _loadUsageStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUsageStats() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final stats = await _tagService.getTagUsageStats(taskProvider.availableTags.toList());
    setState(() {
      _usageStats = stats;
    });
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _selectedColor = '#2196F3';
    _editingTag = null;
  }

  void _editTag(UserTag tag) {
    setState(() {
      _editingTag = tag;
      _nameController.text = tag.name;
      _descriptionController.text = tag.description;
      _selectedColor = tag.color;
    });
  }

  Future<void> _saveTag() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Название тега обязательно')),
      );
      return;
    }

    // Check if tag already exists (for new tags)
    if (_editingTag == null) {
      final exists = await _tagService.tagExists(name);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тег с таким названием уже существует')),
        );
        return;
      }
    }

    try {
      final tag = UserTag(
        id: _editingTag?.id,
        name: name,
        color: _selectedColor,
        description: _descriptionController.text.trim(),
        createdAt: _editingTag?.createdAt ?? DateTime.now(),
      );

      await _tagService.saveTag(tag);
      
      _clearForm();
      _loadUsageStats();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingTag != null ? 'Тег обновлен' : 'Тег создан'),
        ),
      );

      // Refresh task provider to get updated tags
      if (mounted) {
        Provider.of<TaskProvider>(context, listen: false).loadTasks();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _deleteTag(UserTag tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить тег?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тег "${tag.name}" будет удален.'),
            const SizedBox(height: 8),
            if (_usageStats[tag.name] != null && _usageStats[tag.name]! > 0)
              Text(
                'Внимание: Этот тег используется в ${_usageStats[tag.name]} задачах. При удалении тега он будет убран из всех задач.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _tagService.deleteTag(tag.id!);
        _loadUsageStats();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тег удален')),
        );

        // Refresh task provider
        if (mounted) {
          Provider.of<TaskProvider>(context, listen: false).loadTasks();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление тегами'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsageStats,
            tooltip: 'Обновить статистику',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tag creation/editing form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _editingTag != null ? Icons.edit : Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _editingTag != null ? 'Редактировать тег' : 'Создать новый тег',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (_editingTag != null)
                        TextButton(
                          onPressed: _clearForm,
                          child: const Text('Отмена'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название тега',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Цвет тега:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color 
                                  ? Colors.white 
                                  : Colors.grey.shade300,
                              width: _selectedColor == color ? 3 : 1,
                            ),
                            boxShadow: _selectedColor == color
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: _selectedColor == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveTag,
                      icon: Icon(_editingTag != null ? Icons.save : Icons.add),
                      label: Text(_editingTag != null ? 'Сохранить' : 'Создать тег'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tags list
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.label),
                        SizedBox(width: 8),
                        Text(
                          'Мои теги',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<UserTag>>(
                      stream: _tagService.getUserTags(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Ошибка: ${snapshot.error}'),
                          );
                        }

                        final tags = snapshot.data ?? [];

                        if (tags.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.label_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Теги пока не созданы',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Создайте первый тег выше',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: tags.length,
                          itemBuilder: (context, index) {
                            final tag = tags[index];
                            final usageCount = _usageStats[tag.name] ?? 0;

                            return ListTile(
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              title: Text(tag.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (tag.description.isNotEmpty)
                                    Text(tag.description),
                                  Text(
                                    'Используется в $usageCount задачах',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _editTag(tag),
                                    tooltip: 'Редактировать',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deleteTag(tag),
                                    tooltip: 'Удалить',
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 