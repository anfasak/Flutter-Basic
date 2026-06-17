import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/vlog.dart';
import '../services/vlog_provider.dart';
import 'package:provider/provider.dart';

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
  late DateTime _uploadDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.vlog?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.vlog?.description ?? '');
    _category = widget.vlog?.category ?? 'Travel';
    _status = widget.vlog?.status ?? 'Idea';
    _uploadDate = widget.vlog?.uploadDate ?? DateTime.now();
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
        title: Text(widget.vlog == null ? 'Add Vlog' : 'Edit Vlog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Vlog Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  'Travel',
                  'Food',
                  'Technology',
                  'Lifestyle',
                  'Education'
                ].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: const ['Idea', 'Recording', 'Editing', 'Uploaded']
                    .map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (value) => setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _uploadDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _uploadDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Planned Upload Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM d, yyyy').format(_uploadDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveVlog,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Vlog'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      uploadDate: _uploadDate,
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
