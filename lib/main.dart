import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(ToDoListApp());
}

class ToDoListApp extends StatelessWidget {
  final ValueNotifier<bool> isDarkMode = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '2DO by DB',
          theme: isDark
              ? ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.indigo,
                  scaffoldBackgroundColor: Colors.black,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.indigo,
                  ),
                )
              : ThemeData(
                  brightness: Brightness.light,
                  primarySwatch: Colors.indigo,
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.indigo,
                  ),
                ),
          home: ToDoListScreen(isDarkMode),
        );
      },
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkMode;
  ToDoListScreen(this.isDarkMode);

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'Low';
  String _selectedCategory = 'Personal';
  String _filterPriority = 'All';
  String _filterCategory = 'All';
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> taskList =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskList);
  }

  Future<void> _selectDeadline(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        _tasks.addAll(taskList.map((task) => Task.fromJson(jsonDecode(task))));
      });
    }
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task name cannot be empty!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Capitalize the first letter of the task name
    String formattedTaskName = _taskController.text.trim();
    formattedTaskName =
        formattedTaskName[0].toUpperCase() + formattedTaskName.substring(1);

    // Check if the task already exists
    bool taskExists = _tasks.any((task) =>
        task.name == formattedTaskName &&
        task.priority == _selectedPriority &&
        task.category == _selectedCategory &&
        task.deadline == _selectedDeadline);

    if (taskExists) {
      // Show a dialog if the task already exists
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Task already exists!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
      return;
    }

    // Add the task if it doesn't exist
    setState(() {
      _tasks.add(Task(
        name: formattedTaskName,
        isDone: false,
        priority: _selectedPriority,
        category: _selectedCategory,
        deadline: _selectedDeadline,
      ));
    });

    _taskController.clear();
    _selectedDeadline = null; // Reset deadline
    _saveTasks();
  }

  void _toggleTaskStatus(int originalIndex) {
    setState(() {
      _tasks[originalIndex].isDone = !_tasks[originalIndex].isDone;
    });
    _saveTasks();
  }

  void _removeTask(int originalIndex) {
    setState(() {
      _tasks.removeAt(originalIndex);
    });
    _saveTasks();
  }

  List<Task> _getSortedTasks() {
    List<Task> sortedTasks = List.from(_tasks);
    sortedTasks.sort((a, b) {
      List<String> priorityOrder = ['High', 'Medium', 'Low'];
      return priorityOrder
          .indexOf(a.priority)
          .compareTo(priorityOrder.indexOf(b.priority));
    });
    return sortedTasks;
  }

  List<int> _getFilteredTaskIndices() {
    final sortedTasks = _getSortedTasks();
    return sortedTasks
        .where((task) =>
            (_filterPriority == 'All' || task.priority == _filterPriority) &&
            (_filterCategory == 'All' || task.category == _filterCategory))
        .map((task) => _tasks.indexOf(task))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTaskIndices = _getFilteredTaskIndices();
    return Scaffold(
      appBar: AppBar(
        title: Text('2DO by DB'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              widget.isDarkMode.value = !widget.isDarkMode.value;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyText1?.color),
                        decoration: InputDecoration(
                          labelText: 'Enter a task',
                          labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText1?.color),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _selectDeadline(context),
                      child: Text('Pick Deadline'),
                    ),
                  ],
                ),
                if (_selectedDeadline != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Deadline: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Priority: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      items: ['Low', 'Medium', 'High']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                    ),
                    Spacer(),
                    Text('Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: ['Personal', 'Household', 'Work', 'Academic']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Filter Priority: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _filterPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterPriority = newValue!;
                        });
                      },
                      items: ['All', 'Low', 'Medium', 'High']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                    ),
                    Spacer(),
                    Text('Filter Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _filterCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterCategory = newValue!;
                        });
                      },
                      items:
                          ['All', 'Personal', 'Household', 'Work', 'Academic']
                              .map((value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTaskIndices.length,
              itemBuilder: (context, index) {
                final originalIndex = filteredTaskIndices[index];
                final task = _tasks[originalIndex];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: task.isDone
                      ? (task.priority == 'High'
                          ? Colors.red[300]
                          : task.priority == 'Medium'
                              ? Colors.orange[300]
                              : Colors.green[300])
                      : (task.priority == 'High'
                          ? Colors.red[900]
                          : task.priority == 'Medium'
                              ? Colors.orange[800]
                              : Colors.green[700]),
                  child: ListTile(
                    title: Text(
                      task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Keep the text bold
                        fontSize:
                            24, // Increase the font size for a better appearance
                        letterSpacing:
                            1.2, // Add spacing between letters for better readability
                        height: 1.4, // Adjust the line height for more space
                        color: task.isDone ? Colors.grey[300] : Colors.white,
                        fontFamily:
                            'Roboto', // Use a spacious, clean font like Roboto
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        // Priority and Deadline as one column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority: ${task.priority}',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            if (task.deadline != null)
                              Text(
                                'Deadline: ${task.deadline!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                        Spacer(),
                        // Category to the extreme right
                        Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => _toggleTaskStatus(originalIndex),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _removeTask(originalIndex),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  String name;
  bool isDone;
  String priority;
  String category; // New category field
  DateTime? deadline;

  Task({
    required this.name,
    required this.isDone,
    required this.priority,
    required this.category, // Initialize category
    this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'isDone': isDone,
        'priority': priority,
        'category': category, // Serialize category
        'deadline': deadline?.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        isDone: json['isDone'],
        priority: json['priority'],
        category: json['category'], // Deserialize category
        deadline:
            json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      );
}
