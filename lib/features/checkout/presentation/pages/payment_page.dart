import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/order_item.dart';
import '../bloc/checkout_bloc.dart';

class PaymentPage extends StatefulWidget {
  final String addressId;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final String? promoCodeId;

  const PaymentPage({
    super.key,
    required this.addressId,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    this.promoCodeId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initPaystackPayment();
  }

  Future<void> _initPaystackPayment() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final email = user?.email ?? 'customer@sabistyle.com';
      
      // Force use of the Anon Key to avoid any stale user JWT 401 errors
      final token = AppConfig.supabaseAnonKey;

      final httpClient = HttpClient();
      final request = await httpClient.postUrl(Uri.parse(AppConfig.paystackInitUrl));
      
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      
      final payload = jsonEncode({
        'email': email,
        'amount': widget.totalAmount, // Edge Function multiplies ×100
        'callback_url': 'https://success.sabistyle.com',
      });
      
      request.write(payload);
      final response = await request.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}: $responseBody');
      }
      
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (data['status'] != true) {
        throw Exception(data['message'] ?? 'Failed to initialize payment');
      }

      final authorizationUrl = data['data']['authorization_url'] as String;
      final reference = data['data']['reference'] as String;

      if (!mounted) return;

      // Set up WebView to load the Paystack checkout page
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              final url = request.url;
              
              if (url.contains('success.sabistyle.com') ||
                  url.contains('trxref=') || 
                  url.contains('reference=')) {
                // Payment was successful
                _onPaymentSuccess(reference);
                return NavigationDecision.prevent;
              }

              if (url.contains('paystack.com/close') ||
                  url.contains('cancelled') ||
                  (url.contains('trxref') == false && url.contains('/close'))) {
                _onPaymentCancelled();
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            onWebResourceError: (error) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(authorizationUrl));

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onPaymentSuccess(String reference) {
    context.read<CheckoutBloc>().add(
          PlaceOrder(
            addressId: widget.addressId,
            items: widget.items,
            totalAmount: widget.totalAmount,
            discountAmount: widget.discountAmount,
            promoCodeId: widget.promoCodeId,
            paystackRef: reference,
          ),
        );
  }

  void _onPaymentCancelled() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment was cancelled'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is OrderPlacedSuccess) {
          context.read<CartBloc>().add(ClearCart());
          context.go('/home/cart/checkout/confirmation', extra: state.orderId);
        } else if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order failed: ${state.message}'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Payment'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _onPaymentCancelled,
          ),
          actions: [
            if (_hasError)
              TextButton(
                onPressed: _initPaystackPayment,
                child: const Text('Retry'),
              ),
          ],
        ),
        body: _buildBody(colorScheme),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Payment initialization failed',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'An unknown error occurred.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _initPaystackPayment,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show the Paystack WebView once initialized
    if (!_isLoading && !_hasError) {
      try {
        return Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      } catch (_) {
        // WebView not ready yet
      }
    }

    // Initial loading state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Setting up secure payment...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 14, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                'Powered by Paystack',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
