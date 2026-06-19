import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/vlog.dart';
import '../services/vlog_provider.dart';

class VlogFormScreen extends StatefulWidget {
  final Vlog? vlog;

  const VlogFormScreen({super.key, this.vlog});

  @override
  State<VlogFormScreen> createState() => _VlogFormScreenState();
}

class _VlogFormScreenState extends State<VlogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late String _status;
  late String _platform;
  late DateTime _uploadDate;
  String _thumbnailPath = '';

  final List<String> _categories = const [
    'Marketing',
    'Education',
    'Lifestyle',
    'Tech',
    'Entertainment',
    'Business'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.vlog?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.vlog?.description ?? '');
    _category = widget.vlog?.category ?? 'Marketing';
    _status = widget.vlog?.status ?? 'Idea';
    _platform = widget.vlog?.platform ?? 'YouTube';
    _uploadDate = widget.vlog?.uploadDate ?? DateTime.now();
    _thumbnailPath = widget.vlog?.thumbnailPath ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vlog == null ? 'Add New Content' : 'Edit Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _platform,
                      decoration: const InputDecoration(
                        labelText: 'Platform',
                        prefixIcon: Icon(Icons.video_library),
                      ),
                      items: VlogProvider.platformOptions
                          .where((item) => item != 'All')
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _platform = value ?? _platform),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value ?? _category),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: VlogProvider.statusOptions
                          .where((item) => item != 'All')
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _status = value ?? _status),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Publish Date',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_uploadDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveVlog,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save Content'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: _thumbnailPath.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to add thumbnail'),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(_thumbnailPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _thumbnailPath = picked.path);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _uploadDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _uploadDate = picked);
    }
  }

  Future<void> _saveVlog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<VlogProvider>();
    final vlog = Vlog(
      id: widget.vlog?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      status: _status,
      platform: _platform,
      uploadDate: _uploadDate,
      thumbnailPath: _thumbnailPath,
      isFavorite: widget.vlog?.isFavorite ?? false,
    );

    if (widget.vlog == null) {
      await provider.addVlog(vlog);
    } else {
      await provider.updateVlog(vlog);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }
}
