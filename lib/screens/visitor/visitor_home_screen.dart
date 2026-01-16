import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/repositories/exhibit_repository.dart';
import '../../models/exhibit.dart';
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
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search exhibits...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredExhibits.isEmpty
                  ? const Center(child: Text('No exhibits found.'))
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: GridView.builder(
                        itemCount: _filteredExhibits.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 per row
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.82, // tile shape
                        ),
                        itemBuilder: (context, index) {
                          final exhibit = _filteredExhibits[index];
                          return _ExhibitTile(
                            exhibit: exhibit,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ExhibitDetailsScreen(exhibit: exhibit),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ExhibitTile extends StatelessWidget {
  final Exhibit exhibit;
  final VoidCallback onTap;

  const _ExhibitTile({
    required this.exhibit,
    required this.onTap,
  });

  bool _hasValidImage(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _hasValidImage(exhibit.imagePath);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: hasImage
                    ? Image.file(
                        File(exhibit.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.black.withOpacity(0.06),
                        child: const Center(
                          child: Icon(
                            Icons.museum_outlined,
                            size: 42,
                            color: Colors.black54,
                          ),
                        ),
                      ),
              ),
            ),

            // Title area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                exhibit.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
