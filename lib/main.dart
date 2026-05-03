import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/style_selector_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ong_screen.dart';
import 'screens/seller_profile_screen.dart';
import 'screens/map_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_step1_screen.dart';
import 'screens/checkout_step2_screen.dart';
import 'screens/checkout_step3_screen.dart';
import 'screens/order_confirmed_screen.dart';
import 'screens/order_tracking_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_ong_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/addresses_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/create_product_screen.dart';
import 'screens/followers_screen.dart';
import 'screens/my_sales_screen.dart';
import 'screens/my_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final user = FirebaseAuth.instance.currentUser;
  runApp(RevisteApp(initialRoute: user != null ? '/home' : '/'));
}

class RevisteApp extends StatelessWidget {
  final String initialRoute;
  const RevisteApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WearEver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB5976A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/style-selector': (context) => const StyleSelectorScreen(),
        '/home': (context) => const HomeScreen(),
        '/ong': (context) => const OngScreen(),
        '/seller-profile': (context) => const SellerProfileScreen(),
        '/map': (context) => const MapScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/saved': (context) => const SavedScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout-1': (context) => const CheckoutStep1Screen(),
        '/checkout-2': (context) => const CheckoutStep2Screen(),
        '/checkout-3': (context) => const CheckoutStep3Screen(),
        '/order-confirmed': (context) => const OrderConfirmedScreen(),
        '/order-tracking': (context) => const OrderTrackingScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/chat': (context) => const ChatScreen(),
        '/chats-list': (context) => const ChatsListScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/register-ong': (context) => const RegisterOngScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/addresses': (context) => const AddressesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/create-product': (context) => const CreateProductScreen(),
        '/followers': (context) => const FollowersScreen(),
        '/my-sales': (context) => const MySalesScreen(),
        '/my-products': (context) => const MyProductsScreen(),
      },
    );
  }
}