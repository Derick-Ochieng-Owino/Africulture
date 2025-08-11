import 'package:flutter/material.dart';
import '../../models/content_model.dart';


class ContentForm extends StatefulWidget {
  final Content? content;

  const ContentForm({super.key, this.content});

  @override
  State<ContentForm> createState() => _ContentFormState();
}

class _ContentFormState extends State<ContentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late ContentType _type;
  late ContentStatus _status;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.content?.title ?? '');
    _descriptionController = TextEditingController(
        text: widget.content?.description ?? '');
    _type = widget.content?.type ?? ContentType.article;
    _status = widget.content?.status ?? ContentStatus.draft;
    _tags.addAll(widget.content?.tags ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          DropdownButtonFormField<ContentType>(
            value: _type,
            items: ContentType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Text(type.displayName),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Content Type'),
          ),
          DropdownButtonFormField<ContentStatus>(
            value: _status,
            items: ContentStatus.values.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: 10),
          const Text('Tags'),
          Wrap(
            spacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            )).toList(),
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Add Tag',
              suffixIcon: Icon(Icons.add),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty && !_tags.contains(value)) {
                setState(() {
                  _tags.add(value);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}