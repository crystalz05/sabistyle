import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/search_bloc.dart';
import 'package:sabistyle/features/home/presentation/widgets/product_card.dart';
import 'package:sabistyle/features/widgets/app_empty_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (query) => context.read<SearchBloc>().add(SearchQueryChanged(query)),
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              context.read<SearchBloc>().add(ClearSearch());
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchResultsLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final product = state.results[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/home/market/product/${product.id}'),
                );
              },
            );
          } else if (state is SearchEmpty) {
            return const AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: 'No products found matching your search.',
            );
          } else if (state is SearchInitial) {
            return const AppEmptyState(
              icon: Icons.search_rounded,
              title: 'Browse',
              message: 'Start typing to find products.',
            );
          } else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
