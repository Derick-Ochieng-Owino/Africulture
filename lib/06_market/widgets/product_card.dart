import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final MarketProduct product;
  final VoidCallback onTap;
  final bool isAdminView;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isAdminView = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _getSafeImageUrl(widget.product.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: widget.isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onSelectionChanged != null
            ? () => widget.onSelectionChanged!(!widget.isSelected)
            : widget.onTap,
        onLongPress: widget.onSelectionChanged != null
            ? () => widget.onSelectionChanged!(!widget.isSelected)
            : null,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FutureBuilder<String>(
                          future: _imageUrlFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                return Image.network(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return _buildImageErrorWidget();
                            }
                            return _buildImageLoadingWidget();
                          },
                        ),
                      ),
                    ),
                  ),
                  // Product Info Section
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isAdminView)
                              Icon(
                                widget.product.approved ? Icons.verified : Icons.pending,
                                color: widget.product.approved ? Colors.green : Colors.orange,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.product.priceFormatted,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: widget.product.isLowStock
                                    ? Colors.orange[50]
                                    : Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.product.stock} left',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.product.isLowStock
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: Colors.white, size: 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String> _getSafeImageUrl(String storageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(storageUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error getting image URL: $e');
      return '';
    }
  }

  Widget _buildImageLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
    );
  }
}
