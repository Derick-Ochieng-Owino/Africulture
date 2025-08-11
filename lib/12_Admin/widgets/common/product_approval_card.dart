import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductApprovalCard extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;
  final bool isSelected;
  final void Function(bool selected)? onSelectionChanged;

  const ProductApprovalCard({
    super.key,
    required this.productId,
    required this.productData,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = productData['imageUrl'] as String?;
    final name = productData['name'] ?? 'No Name';
    final description = productData['description'] ?? 'No Description';
    final price = productData['price'] is num ? (productData['price'] as num).toDouble() : 0.0;
    final category = productData['category'] ?? 'Uncategorized';

    return GestureDetector(
      onTap: () {
        if (onSelectionChanged != null) {
          onSelectionChanged!(!isSelected);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                      ),
                    )
                  else
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  Text(name,
                      style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(description,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text('Category: $category',
                      style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (bool? selected) {
                        if (onSelectionChanged != null) {
                          onSelectionChanged!(selected ?? false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, color: Colors.white, size: 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
