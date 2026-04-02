import 'package:flutter/material.dart';
import 'package:shoescomm/pages/aboutus.dart';
import 'package:shoescomm/pages/add_product_page.dart';
import 'package:shoescomm/pages/blog.dart';
import 'package:shoescomm/pages/cart_page.dart';
import 'package:shoescomm/pages/contact_us_page.dart';
import 'package:shoescomm/pages/login_page.dart';
import 'package:shoescomm/pages/order_page.dart';
import 'package:shoescomm/pages/product_detail_page.dart';
import 'package:shoescomm/pages/product_list_page.dart';
import 'package:shoescomm/pages/signup_page.dart';
import 'package:shoescomm/pages/splashscreen.dart';
import 'package:shoescomm/pages/userdashboard.dart';
import 'package:shoescomm/pages/user_list_page.dart';
import 'package:shoescomm/pages/wishlist_page.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String productList = '/productlist';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
  static const String admin = '/admin';
  static const String addProduct = '/addproduct';
  static const String aboutUs = '/Aboutus';
  static const String contactUs = '/Contactus';
  static const String blog = '/Blog';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        signup: (_) => const SignupPage(),
        productList: (_) => const ProductListPage(),
        home: (_) => const ProductListPage(),
        cart: (_) => const CartPage(),
        profile: (_) => const DashboardPage(),
        orders: (_) => const DashboardPage(),
        wishlist: (_) => const WishlistPage(),
        admin: (_) => const UserListPage(),
        addProduct: (_) => const AddProductPage(),
        aboutUs: (_) => const AboutUsPage(),
        contactUs: (_) => const ContactUsPage(),
        blog: (_) => const BlogPage(),
      };

  static Widget get splash => const Splashscreen();
}
