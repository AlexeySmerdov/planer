import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../models/task.dart';
import '../utils/time_formatter.dart';
import '../utils/responsive.dart';
import '../widgets/tag_chip.dart';
import '../services/tag_service.dart';
import 'task_detail_screen.dart';
import 'daily_tasks_screen.dart';
import 'tags_management_screen.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialized = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _showCalendar = true; // Toggle between calendar and upcoming tasks
  final TagService _tagService = TagService();
  Map<String, Color> _tagColors = {};

  @override
  void initState() {
    super.initState();
    if (!_initialized) {
      Provider.of<TaskProvider>(context, listen: false).initialize();
      _initialized = true;
    }
    _loadTagColors();
  }

  void _loadTagColors() {
    _tagService.getUserTags().listen((tags) {
      if (mounted) {
        setState(() {
          _tagColors = {
            for (var tag in tags)
              tag.name: Color(int.parse(tag.color.substring(1), radix: 16) + 0xFF000000)
          };
        });
      }
    });
  }

  Color? _getTagColor(String tagName) {
    return _tagColors[tagName];
  }

  List<Task> _getEventsForDay(DateTime day, List<Task> allTasks) {
    return allTasks.where((task) =>
      task.dueDate.year == day.year &&
      task.dueDate.month == day.month &&
      task.dueDate.day == day.day
    ).toList();
  }

  List<Task> _getUpcomingTasks(List<Task> allTasks) {
    final now = DateTime.now();
    final upcoming = allTasks.where((task) => 
      task.dueDate.isAfter(now.subtract(const Duration(days: 1))) && !task.isCompleted
    ).toList();
    
    // Sort by due date and time
    upcoming.sort((a, b) {
      final dateComparison = a.dueDate.compareTo(b.dueDate);
      if (dateComparison != 0) return dateComparison;
      
      // If same date, sort by time (tasks with time first)
      if (a.dueTime != null && b.dueTime == null) return -1;
      if (a.dueTime == null && b.dueTime != null) return 1;
      if (a.dueTime != null && b.dueTime != null) {
        final aMinutes = a.dueTime!.hour * 60 + a.dueTime!.minute;
        final bMinutes = b.dueTime!.hour * 60 + b.dueTime!.minute;
        return aMinutes.compareTo(bMinutes);
      }
      return 0;
    });
    
    return upcoming.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyTasksScreen(
                    title: 'Задачи на сегодня',
                    isToday: true,
                  ),
                ),
              );
            },
            tooltip: 'Задачи на сегодня',
          ),
          IconButton(
            icon: const Icon(Icons.event),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyTasksScreen(
                    title: 'Задачи на завтра',
                    isToday: false,
                  ),
                ),
              );
            },
            tooltip: 'Задачи на завтра',
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TagsManagementScreen(),
                ),
              );
            },
            tooltip: 'Управление тегами',
          ),
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode 
                ? Icons.light_mode 
                : Icons.dark_mode
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              debugPrint('AppBar + tapped, navigating to TaskDetailScreen');
              try {
                _navigateToTaskDetail(null);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigation error: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (!taskProvider.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Responsive layout
          if (Responsive.isDesktop(context)) {
            return _buildDesktopLayout(taskProvider);
          } else {
            return _buildMobileLayout(taskProvider);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB tapped, navigating to TaskDetailScreen');
          try {
            _navigateToTaskDetail(null);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation error: $e')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDesktopLayout(TaskProvider taskProvider) {
    return Row(
      children: [
        // Left sidebar
        Container(
          width: Responsive.getSidebarWidth(context),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            children: [
              // View mode toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _showCalendar ? Icons.calendar_month : Icons.list,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _showCalendar ? 'Календарь' : 'Ближайшие',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _showCalendar,
                      onChanged: (value) {
                        setState(() {
                          _showCalendar = value;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              // Calendar or upcoming tasks in sidebar
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_showCalendar)
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _focusedDay,
                              calendarFormat: CalendarFormat.month,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              eventLoader: (day) => _getEventsForDay(day, taskProvider.tasks),
                              calendarStyle: const CalendarStyle(
                                markersMaxCount: 1,
                                markerDecoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                              ),
                            ),
                          ),
                        ),
                      if (_showCalendar) const SizedBox(height: 16),
                      // Tag filters in sidebar
                      if (taskProvider.availableTags.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: _buildTagFiltersSidebar(taskProvider),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.getContentWidth(context) - Responsive.getSidebarWidth(context),
            ),
            child: _buildTasksList(taskProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(TaskProvider taskProvider) {
    return Column(
      children: [
        // View mode toggle
        Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  _showCalendar ? Icons.calendar_month : Icons.list,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  _showCalendar ? 'Календарь' : 'Ближайшие задачи',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _showCalendar,
                  onChanged: (value) {
                    setState(() {
                      _showCalendar = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
        // Calendar or upcoming tasks
        if (_showCalendar)
          Card(
            margin: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              eventLoader: (day) => _getEventsForDay(day, taskProvider.tasks),
              calendarStyle: const CalendarStyle(
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        // Tag filters
        if (taskProvider.availableTags.isNotEmpty)
          _buildTagFilters(taskProvider),
        Expanded(
          child: _buildTasksList(taskProvider),
        ),
      ],
    );
  }

  Widget _buildTasksList(TaskProvider taskProvider) {
    final tasks = _showCalendar 
        ? taskProvider.getTasksForDate(_selectedDay)
        : taskProvider.tasks;
    final allTasks = taskProvider.tasks;
    final errorMessage = taskProvider.errorMessage;
    final upcomingTasks = _getUpcomingTasks(taskProvider.tasks);
    
    // Show error state if there's a Firestore error
    if (errorMessage != null) {
      return _buildEmptyState(
        context,
        icon: Icons.cloud_off,
        title: 'Проблема с подключением',
        subtitle: 'Проверьте интернет или войдите в аккаунт заново',
        actionText: 'Создать локальную задачу',
        onAction: () => _navigateToTaskDetail(null),
      );
    }
    
    if (_showCalendar) {
      // Calendar mode - show tasks for selected day
      if (allTasks.isEmpty) {
        // No tasks at all - show welcome message
        return _buildEmptyState(
          context,
          icon: Icons.task_alt,
          title: 'Добро пожаловать!',
          subtitle: 'Создайте свою первую задачу',
          actionText: 'Создать задачу',
          onAction: () => _navigateToTaskDetail(null),
        );
      } else if (tasks.isEmpty) {
        // No tasks for selected day
        return _buildEmptyState(
          context,
          icon: Icons.event_available,
          title: 'Нет задач на этот день',
          subtitle: 'Выберите другой день или создайте новую задачу',
          actionText: 'Добавить задачу',
          onAction: () => _navigateToTaskDetail(null),
        );
      } else {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListItem(
              task: task,
              onTap: () => _navigateToTaskDetail(task),
              getTagColor: _getTagColor,
            );
          },
        );
      }
    } else {
      // Upcoming tasks mode
      if (allTasks.isEmpty) {
        // No tasks at all - show welcome message
        return _buildEmptyState(
          context,
          icon: Icons.task_alt,
          title: 'Добро пожаловать!',
          subtitle: 'Создайте свою первую задачу',
          actionText: 'Создать задачу',
          onAction: () => _navigateToTaskDetail(null),
        );
      } else if (upcomingTasks.isNotEmpty) {
        // Has upcoming tasks - show all tasks list
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: allTasks.length,
          itemBuilder: (context, index) {
            final task = allTasks[index];
            return TaskListItem(
              task: task,
              onTap: () => _navigateToTaskDetail(task),
              getTagColor: _getTagColor,
            );
          },
        );
      } else {
        // No upcoming tasks but has tasks overall
        return _buildEmptyState(
          context,
          icon: Icons.schedule,
          title: 'Нет ближайших задач',
          subtitle: 'Все текущие задачи завершены или просрочены',
          actionText: 'Создать задачу',
          onAction: () => _navigateToTaskDetail(null),
        );
      }
    }
  }

  void _navigateToTaskDetail(Task? task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: task),
      ),
    );
    
    if (result == true && mounted) {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks();
    }
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.0,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagFilters(TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter by tags:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (taskProvider.selectedTags.isNotEmpty)
                    TextButton(
                      onPressed: () => taskProvider.clearTagFilters(),
                      child: const Text('Clear all'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: taskProvider.availableTags
                    .map((tag) => TagChip(
                          tag: tag,
                          isSelected: taskProvider.selectedTags.contains(tag),
                          isSmall: true,
                          backgroundColor: _getTagColor(tag),
                          onTap: () => taskProvider.toggleTagFilter(tag),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagFiltersSidebar(TaskProvider taskProvider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Фильтры',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (taskProvider.selectedTags.isNotEmpty)
                  GestureDetector(
                    onTap: () => taskProvider.clearTagFilters(),
                    child: Text(
                      'Очистить',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: taskProvider.availableTags
                  .map((tag) => TagChip(
                        tag: tag,
                        isSelected: taskProvider.selectedTags.contains(tag),
                        isSmall: true,
                        backgroundColor: _getTagColor(tag),
                        onTap: () => taskProvider.toggleTagFilter(tag),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Color? Function(String)? getTagColor;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
    this.getTagColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine gradient and text colors based on theme and completion
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
      ? (task.isCompleted
          ? [const Color(0xFFFFCDD2), const Color(0xFFFFCDD2)]  // solid pastel red
          : [Colors.transparent, const Color(0xFFFFCDD2)]) // transparent to pastel red
      : (task.isCompleted
          ? [const Color(0xFFA8E6CF), const Color(0xFFA8E6CF)]  // pastel green solid
          : [Colors.white, const Color(0xFFA8E6CF)]);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = textColor.withValues(alpha: 0.7);
    
    return Container(
      width: double.infinity, // Ensure full width
      margin: Responsive.getCardMargin(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: GestureDetector(
            onTap: onTap,
            onLongPress: () => _showDeleteDialog(context),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  if (value != null) {
                    final updatedTask = Task(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      dueDate: task.dueDate,
                      dueTime: task.dueTime,
                      isCompleted: value,
                      images: task.images,
                      tags: task.tags,
                    );
                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTask(updatedTask);
                  }
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: TextStyle(color: textColor)),
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 2.0,
                      children: task.tags
                          .map((tag) => TagChip(
                                tag: tag,
                                isSmall: true,
                                backgroundColor: getTagColor?.call(tag),
                                onTap: () {
                                  // Toggle filter for this tag
                                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                                  taskProvider.toggleTagFilter(tag);
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
              subtitle: Text(task.description, style: TextStyle(color: subTextColor)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (task.dueTime != null)
                    TimeFormatter.buildTimeChip(
                      task.dueTime!,
                      context,
                      backgroundColor: textColor.withValues(alpha: 0.1),
                      textColor: textColor,
                    ),
                  if (task.dueTime != null && task.images.isNotEmpty)
                    const SizedBox(height: 4),
                  if (task.images.isNotEmpty)
                    Icon(Icons.image, color: textColor.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Удалить задачу'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Вы уверены, что хотите удалить эту задачу?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Это действие нельзя отменить.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteTask(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(BuildContext context) async {
    if (task.id == null) return;
    
    try {
      await Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id!);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Задача "${task.title}" удалена'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Ошибка удаления: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
} 