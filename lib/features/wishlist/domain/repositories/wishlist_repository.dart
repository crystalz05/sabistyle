import '../entities/wishlist_item.dart';

abstract class WishlistRepository {
  /// Returns all wishlist items for the current user with embedded product data.
  Future<List<WishlistItem>> fetchWishlist();

  /// Adds a product to the current user's wishlist.
  Future<void> addToWishlist(String productId);

  /// Removes a wishlist entry by its [wishlistId].
  Future<void> removeFromWishlist(String wishlistId);

  /// Returns the set of product IDs currently in the user's wishlist.
  Future<Set<String>> getWishlistedProductIds();
}
