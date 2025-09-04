import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
    'tasks',
  );
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(Icons.task, color: Colors.deepPurple),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: _addTask,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.deepPurple,
                            size: 28,
                          ),
                        ),
                ),
                onSubmitted: (value) => _addTask(),
                maxLines: 2,
              ),
            ),
          ),

          Expanded(
            child: currentUser == null
                ? const Center(child: Text("Please login first"))
                : StreamBuilder<QuerySnapshot>(
                    stream: tasks
                        .where('created_by', isEqualTo: currentUser!.uid)
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final taskDocs = snapshot.data?.docs ?? [];
                      if (taskDocs.isEmpty) {
                        return const Center(
                          child: Text("No tasks yet, add your first task!"),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: taskDocs.length,
                        itemBuilder: (context, index) {
                          final taskData = taskDocs[index];
                          final timestamp =
                              taskData['created_at'] as Timestamp?;
                          final date = timestamp != null
                              ? DateFormat(
                                  'MMM dd, yyyy - HH:mm',
                                ).format(timestamp.toDate())
                              : 'Unknown date';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(
                                Icons.task,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                taskData['task'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Created: $date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _editTask(
                                      taskData.reference,
                                      taskData['task'],
                                    ),
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteTask(
                                      taskData.reference,
                                      taskData['task'],
                                    ),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) {
      _showSnackBar('Please enter a task', Colors.orange);
      return;
    }
    if (currentUser == null) {
      _showSnackBar('Please login first', Colors.red);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await tasks.add({
        'task': _taskController.text.trim(),
        'status': 'Pending',
        'created_at': FieldValue.serverTimestamp(),
        'created_by': currentUser!.uid,
      });
      _taskController.clear();
      _showSnackBar('Task added successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Error adding task', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editTask(DocumentReference taskRef, String currentTask) async {
    final editedTask = await showDialog<String>(
      context: context,
      builder: (context) => EditTaskDialog(currentTask: currentTask),
    );

    if (editedTask != null && editedTask.isNotEmpty) {
      try {
        await taskRef.update({'task': editedTask});
        _showSnackBar('Task updated successfully', Colors.green);
      } catch (e) {
        _showSnackBar('Error updating task', Colors.red);
      }
    }
  }

  Future<void> _deleteTask(DocumentReference taskRef, String taskName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Task"),
          ],
        ),
        content: Text("Are you sure you want to delete '$taskName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await taskRef.delete();
        _showSnackBar('Task deleted successfully', Colors.green);
      } catch (e) {
        _showSnackBar('Error deleting task', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  final String currentTask;

  const EditTaskDialog({super.key, required this.currentTask});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.currentTask);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Task"),
      content: TextField(
        controller: _editController,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _editController.text),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
