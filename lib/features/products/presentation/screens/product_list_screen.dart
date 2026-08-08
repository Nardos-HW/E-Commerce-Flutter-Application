import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../../core/widgets/state_widgets.dart';
import '../providers/product_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';


class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          Consumer(
            builder: (context, ref, _) {
              final count = ref.watch(cartItemCountProvider);

              return IconButton(
                onPressed: () => context.push('/cart'),
                icon: Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).update(value),
            ),
          ),
          categoriesAsync.when(
            loading: () => const SizedBox(height: 40),
            error: (_, _) => const SizedBox.shrink(), // categories are secondary; don't block the screen on this
            data: (categories) => SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: selectedCategory == null,
                    onTap: () =>
                        ref.read(selectedCategoryProvider.notifier).select(null),
                  ),
                  ...categories.map((c) => _CategoryChip(
                        label: c,
                        selected: selectedCategory == c,
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .select(c),
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                message: 'Could not load products.\n${error.toString()}',
                onRetry: () => ref.read(productListProvider.notifier).refresh(),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyView(message: 'No products match your filters.');
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(productListProvider.notifier).refresh(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.push('/product/${product.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: product.image,
                                  fit: BoxFit.contain,
                                  placeholder: (_, _) =>
                                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('\$${product.price.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}