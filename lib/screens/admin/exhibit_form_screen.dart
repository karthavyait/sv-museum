import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/exhibit_repository.dart';
import '../../models/exhibit.dart';

class ExhibitFormScreen extends StatefulWidget {
  const ExhibitFormScreen({super.key, required this.repository, this.exhibit});

  final ExhibitRepository repository;
  final Exhibit? exhibit;

  @override
  State<ExhibitFormScreen> createState() => _ExhibitFormScreenState();
}

class _ExhibitFormScreenState extends State<ExhibitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _imagePath;
  String? _audioPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.exhibit != null) {
      _titleController.text = widget.exhibit!.title;
      _descriptionController.text = widget.exhibit!.description;
      _imagePath = widget.exhibit!.imagePath;
      _audioPath = widget.exhibit!.audioPath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    final copiedPath = await widget.repository.copyFileToAppStorage(picked.path);
    setState(() {
      _imagePath = copiedPath;
    });
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );
    if (result == null || result.files.single.path == null) {
      return;
    }

    final copiedPath = await widget.repository.copyFileToAppStorage(result.files.single.path!);
    setState(() {
      _audioPath = copiedPath;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final now = DateTime.now().toIso8601String();
    final updatedExhibit = Exhibit(
      id: widget.exhibit?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _imagePath,
      audioPath: _audioPath,
      createdAt: widget.exhibit?.createdAt ?? now,
    );

    if (widget.exhibit == null) {
      await widget.repository.addExhibit(updatedExhibit);
    } else {
      await widget.repository.updateExhibit(updatedExhibit);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exhibit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exhibit' : 'Add Exhibit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick Photo'),
                  ),
                  const SizedBox(width: 12),
                  if (_imagePath != null)
                    Expanded(
                      child: Text(
                        _imagePath!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_imagePath!),
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.audiotrack_outlined),
                    label: const Text('Pick Audio'),
                  ),
                  const SizedBox(width: 12),
                  if (_audioPath != null)
                    Expanded(
                      child: Text(
                        _audioPath!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
