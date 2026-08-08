import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_widgets.dart';
import '../providers/product_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: productAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load this product.',
          onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        ),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 260,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined, size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(product.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${product.rating.rate} (${product.rating.count} reviews)'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addProduct(
                          product,
                          quantity: quantity,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $quantity × ${product.title} to cart',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                    ),
                                      ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}