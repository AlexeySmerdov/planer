import 'package:flutter/material.dart';
import '../services/tag_service.dart';
import 'tag_chip.dart';

class EnhancedTagInputWidget extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final String hintText;
  
  const EnhancedTagInputWidget({
    super.key,
    required this.initialTags,
    required this.onTagsChanged,
    this.hintText = 'Add tag...',
  });

  @override
  State<EnhancedTagInputWidget> createState() => _EnhancedTagInputWidgetState();
}

class _EnhancedTagInputWidgetState extends State<EnhancedTagInputWidget> {
  late List<String> _selectedTags;
  final TagService _tagService = TagService();
  List<UserTag> _availableTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
    _loadAvailableTags();
  }

  void _loadAvailableTags() {
    _tagService.getUserTags().listen((tags) {
      if (mounted) {
        setState(() {
          _availableTags = tags;
        });
      }
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    widget.onTagsChanged(_selectedTags);
  }

  void _selectExistingTag(UserTag tag) {
    if (!_selectedTags.contains(tag.name)) {
      setState(() {
        _selectedTags.add(tag.name);
      });
      widget.onTagsChanged(_selectedTags);
    }
  }

  Color _getTagColor(String tagName) {
    final tag = _availableTags.firstWhere(
      (t) => t.name == tagName,
      orElse: () => UserTag(name: '', color: '#2196F3'),
    );
    
    try {
      return Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tags
        if (_selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _selectedTags
                .map((tag) => Container(
                      decoration: BoxDecoration(
                        color: _getTagColor(tag),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: TagChip(
                        tag: tag,
                        onDelete: () => _removeTag(tag),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Available tags pills
        if (_availableTags.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Доступные теги:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 6.0,
                children: _availableTags
                    .where((tag) => !_selectedTags.contains(tag.name))
                    .map((tag) => GestureDetector(
                          onTap: () => _selectExistingTag(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000)
                                    .withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              tag.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }
} 