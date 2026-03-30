import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/student.dart';
import 'login_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Student> _students = <Student>[];
  int? _editingStudentId;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final students = await _dbHelper.getStudents();
    if (!mounted) {
      return;
    }
    setState(() {
      _students = students;
    });
  }

  Future<void> _saveStudent() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid name and age')),
      );
      return;
    }

    if (_editingStudentId == null) {
      await _dbHelper.insertStudent(Student(name: name, age: age));
    } else {
      await _dbHelper.updateStudent(
        Student(id: _editingStudentId, name: name, age: age),
      );
    }

    _nameController.clear();
    _ageController.clear();
    setState(() {
      _editingStudentId = null;
    });

    await _loadStudents();
  }

  void _startEdit(Student student) {
    _nameController.text = student.name;
    _ageController.text = student.age.toString();
    setState(() {
      _editingStudentId = student.id;
    });
  }

  Future<void> _deleteStudent(int id) async {
    await _dbHelper.deleteStudent(id);
    await _loadStudents();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Record App'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveStudent,
                child: Text(_editingStudentId == null ? 'Add Student' : 'Update Student'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text('No students yet'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          child: ListTile(
                            title: Text(student.name),
                            subtitle: Text('Age: ${student.age}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _startEdit(student),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (student.id != null) {
                                      _deleteStudent(student.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
