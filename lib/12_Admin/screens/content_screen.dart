import 'package:africulture/12_Admin/models/content_model.dart';
import 'package:africulture/12_Admin/widgets/common/app_bar.dart';
import 'package:africulture/12_Admin/widgets/common/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../widgets/data/data_table_widget.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContentProvider>(context, listen: false).loadContents();
    });
  }

  Color _getStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.draft:
        return Colors.grey;
      case ContentStatus.published:
        return Colors.green;
      case ContentStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'published':
        return 'Published';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'post':
        return 'Post';
      case 'video':
        return 'Video';
      case 'image':
        return 'Image';
      case 'article':
        return 'Article';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);

    return Scaffold(
      drawer: AdminDrawer(
        userName: 'userName',
        userEmail: 'userEmail',
        profileImageUrl: 'profileImageUrl',
        location: 'location',
      ),
      appBar: AdminAppBar(title: 'Content Management'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: DataTableWidget(
                columns: const ['ID', 'Title', 'Type', 'Author', 'Status', 'Actions'],
                rows: contentProvider.contents.map((content) {
                  return {
                    'ID': content.id,
                    'Title': content.title,
                    'Type': _getTypeDisplayName(content.type.toString().split('.').last),
                    'Author': content.authorName,
                    'Status': Chip(
                      label: Text(_getStatusDisplayName(content.status.toString().split('.').last)),
                      backgroundColor: _getStatusColor(content.status).withOpacity(0.2),
                      labelStyle: TextStyle(color: _getStatusColor(content.status)),
                    ),
                    'Actions': _buildActions(content),
                  };
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Content content) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {
            // view content
          },
        ),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            context.read<ContentProvider>().approveContent(content);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<ContentProvider>().rejectContent(content);
          },
        ),
      ],
    );
  }
}
