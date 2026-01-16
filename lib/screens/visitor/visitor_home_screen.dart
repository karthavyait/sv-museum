import 'package:flutter/material.dart';

import '../../data/repositories/exhibit_repository.dart';
import '../../models/exhibit.dart';
import '../../widgets/exhibit_card.dart';
import 'exhibit_details_screen.dart';

class VisitorHomeScreen extends StatefulWidget {
  const VisitorHomeScreen({super.key, required this.repository});

  final ExhibitRepository repository;

  @override
  State<VisitorHomeScreen> createState() => _VisitorHomeScreenState();
}

class _VisitorHomeScreenState extends State<VisitorHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Exhibit> _exhibits = [];
  List<Exhibit> _filteredExhibits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExhibits();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExhibits() async {
    await widget.repository.ensureSeedData();
    final exhibits = await widget.repository.fetchExhibits();
    setState(() {
      _exhibits = exhibits;
      _filteredExhibits = exhibits;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredExhibits = _exhibits;
      });
      return;
    }

    setState(() {
      _filteredExhibits = _exhibits.where((exhibit) {
        return exhibit.title.toLowerCase().contains(query) ||
            exhibit.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search exhibits...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredExhibits.isEmpty
                  ? const Center(child: Text('No exhibits found.'))
                  : ListView.builder(
                      itemCount: _filteredExhibits.length,
                      itemBuilder: (context, index) {
                        final exhibit = _filteredExhibits[index];
                        return ExhibitCard(
                          exhibit: exhibit,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExhibitDetailsScreen(exhibit: exhibit),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
