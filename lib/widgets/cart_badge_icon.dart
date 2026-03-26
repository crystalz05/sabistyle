import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/cart/presentation/bloc/cart_bloc.dart';

class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.local_mall_outlined, color: colorScheme.onSurface),
          onPressed: () => context.push('/home/cart'),
        ),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            int count = 0;
            if (state is CartLoaded) {
              count = state.items.fold(0, (sum, item) => sum + item.quantity);
            }
            if (count == 0) return const SizedBox.shrink();

            return Positioned(
              right: 8,
              top: 8,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onError,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ) ??
                    const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
