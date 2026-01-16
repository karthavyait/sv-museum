import 'package:flutter/material.dart';

import '../../data/repositories/exhibit_repository.dart';
import '../../models/exhibit.dart';
import 'exhibit_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.repository});

  final ExhibitRepository repository;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<Exhibit> _exhibits = [];

  @override
  void initState() {
    super.initState();
    _loadExhibits();
  }

  Future<void> _loadExhibits() async {
    final exhibits = await widget.repository.fetchExhibits();
    setState(() {
      _exhibits = exhibits;
      _isLoading = false;
    });
  }

  Future<void> _openForm({Exhibit? exhibit}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExhibitFormScreen(
          repository: widget.repository,
          exhibit: exhibit,
        ),
      ),
    );
    await _loadExhibits();
  }

  Future<void> _deleteExhibit(Exhibit exhibit) async {
    if (exhibit.id == null) {
      return;
    }
    await widget.repository.deleteExhibit(exhibit.id!);
    await _loadExhibits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Exhibit'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exhibits.isEmpty
              ? const Center(child: Text('No exhibits yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _exhibits.length,
                  itemBuilder: (context, index) {
                    final exhibit = _exhibits[index];
                    return ListTile(
                      title: Text(exhibit.title),
                      subtitle: Text(
                        exhibit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openForm(exhibit: exhibit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteExhibit(exhibit),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
