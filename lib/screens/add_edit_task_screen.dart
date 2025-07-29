import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _categoryCtrl;
  DateTime _dueDate = DateTime.now();
  TaskPriority _priority = TaskPriority.medium;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _categoryCtrl = TextEditingController(text: t?.category ?? '');
    _dueDate = t?.dueDate ?? DateTime.now();
    _priority = t?.priority ?? TaskPriority.medium;
    _isCompleted = t?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              surface: theme.colorScheme.surfaceContainerHigh,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final task = Task(
      id: widget.task?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      isCompleted: _isCompleted,
      category:
          _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
    );

    if (widget.task == null) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isEditing ? 'Edit Task' : 'Create New Task',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.save_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
              onPressed: _save,
              tooltip: 'Save task',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              _buildSectionCard(
                colorScheme,
                'Task Details',
                Icons.task_rounded,
                [
                  _buildStyledTextField(
                    controller: _titleCtrl,
                    label: 'Title',
                    hint: 'What needs to be done?',
                    icon: Icons.title_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _descCtrl,
                    label: 'Description',
                    hint: 'Add more details about this task...',
                    icon: Icons.description_rounded,
                    maxLines: 4,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _categoryCtrl,
                    label: 'Category',
                    hint: 'Work, Personal, Health...',
                    icon: Icons.folder_rounded,
                    colorScheme: colorScheme,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Date and Priority Section
              _buildSectionCard(
                colorScheme,
                'Schedule & Priority',
                Icons.schedule_rounded,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(colorScheme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPrioritySelector(colorScheme),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Completion Status (only for editing)
              if (isEditing) ...[
                _buildSectionCard(
                  colorScheme,
                  'Status',
                  Icons.check_circle_rounded,
                  [
                    Container(
                      decoration: BoxDecoration(
                        color: _isCompleted
                            ? colorScheme.primaryContainer.withAlpha(50)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCompleted
                              ? colorScheme.primary.withAlpha(30)
                              : colorScheme.outline.withAlpha(40),
                        ),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Mark as completed',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          _isCompleted
                              ? 'This task is completed'
                              : 'This task is pending',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _isCompleted,
                        onChanged: (v) => setState(() => _isCompleted = v),
                        activeColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Save Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing
                            ? Icons.update_rounded
                            : Icons.add_task_rounded,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Update Task' : 'Create Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    ColorScheme colorScheme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(30),
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          hintStyle:
              TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(60)),
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(70),
        ),
      ),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(_dueDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded,
                  color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<TaskPriority>(
          value: _priority,
          decoration: InputDecoration(
            labelText: 'Priority',
            prefixIcon: Icon(Icons.flag_rounded, color: colorScheme.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          items: TaskPriority.values.map((p) {
            final data = _getPriorityData(p);
            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Text(data['emoji']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(data['label']!),
                ],
              ),
            );
          }).toList(),
          onChanged: (p) => setState(() => _priority = p!),
        ),
      ),
    );
  }

  Map<String, String> _getPriorityData(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return {'emoji': '🟢', 'label': 'Low Priority'};
      case TaskPriority.medium:
        return {'emoji': '🟡', 'label': 'Medium Priority'};
      case TaskPriority.high:
        return {'emoji': '🔴', 'label': 'High Priority'};
    }
  }
}
