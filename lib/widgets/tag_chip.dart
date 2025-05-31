import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSmall;
  final Color? backgroundColor;
  
  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.isSmall = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    Color effectiveBackgroundColor;
    Color textColor;
    Color borderColor;
    
    if (backgroundColor != null) {
      effectiveBackgroundColor = backgroundColor!;
      textColor = Colors.white;
      borderColor = backgroundColor!;
    } else if (isSelected) {
      effectiveBackgroundColor = theme.primaryColor;
      textColor = Colors.white;
      borderColor = theme.primaryColor;
    } else {
      effectiveBackgroundColor = isDark 
          ? Colors.grey[800]! 
          : Colors.grey[100]!;
      textColor = isDark 
          ? Colors.grey[300]! 
          : Colors.grey[700]!;
      borderColor = isDark 
          ? Colors.grey[600]! 
          : Colors.grey[300]!;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8.0 : 12.0,
          vertical: isSmall ? 4.0 : 6.0,
        ),
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(
                color: textColor,
                fontSize: isSmall ? 11 : 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: isSmall ? 14 : 16,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TagInputWidget extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final String hintText;
  
  const TagInputWidget({
    super.key,
    required this.initialTags,
    required this.onTagsChanged,
    this.hintText = 'Add tag...',
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  late List<String> _tags;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
      });
      widget.onTagsChanged(_tags);
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _tags
                .map((tag) => TagChip(
                      tag: tag,
                      onDelete: () => _removeTag(tag),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
        ),
      ],
    );
  }
} 