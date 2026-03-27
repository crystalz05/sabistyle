import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabistyle/features/home/presentation/bloc/search_bloc.dart';
import 'package:sabistyle/features/widgets/product_card.dart';
import 'package:sabistyle/features/widgets/app_empty_state.dart';
import 'package:sabistyle/features/widgets/app_error_widget.dart';

import 'package:sabistyle/features/home/domain/repositories/product_repository.dart';
import 'package:sabistyle/features/widgets/filter_sort_bottom_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  double? _minPrice;
  double? _maxPrice;
  SortByPrice _sortBy = SortByPrice.none;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(LoadSearchHistory());
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

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchQueryChanged(
            query,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            sortByPrice: _sortBy,
          ));
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSortBottomSheet(
        initialMinPrice: _minPrice,
        initialMaxPrice: _maxPrice,
        initialSortBy: _sortBy,
        onApply: (min, max, sort) {
          setState(() {
            _minPrice = min;
            _maxPrice = max;
            _sortBy = sort;
          });
          if (_searchController.text.isNotEmpty) {
            _onSearch(_searchController.text);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        surfaceTintColor: colorScheme.surface,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearch,
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              context.read<SearchBloc>().add(AddToSearchHistory(query));
            }
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Icon(
              (_minPrice != null || _maxPrice != null || _sortBy != SortByPrice.none)
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: (_minPrice != null || _maxPrice != null || _sortBy != SortByPrice.none)
                  ? colorScheme.primary
                  : null,
            ),
          ),
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
            return AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: (_minPrice != null || _maxPrice != null)
                  ? 'No products found within this price range.'
                  : 'No products found matching your search.',
            );
          } else if (state is SearchInitial) {
            if (state.history.isEmpty) {
              return const AppEmptyState(
                icon: Icons.search_rounded,
                title: 'Browse',
                message: 'Start typing to find products.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    'RECENT SEARCHES',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.history.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final term = state.history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        title: Text(
                          term,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          Icons.north_west_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        onTap: () {
                          _searchController.text = term;
                          _onSearch(term);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is SearchError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => _onSearch(_searchController.text),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
