import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MTAlchemyApp());
}


const Color navy = Color(0xFF151515);
const Color blue = Color(0xFF2C2B29);
const Color yellow = Color(0xFFD6B15D);
const Color purple = Color(0xFF8A6A25);
const Color pageBg = Color(0xFFF7F4EC);


/// Writes a prototype activity record. Firestore rules restrict who may create
/// each action; server-side logging is recommended for tamper-resistant audits.
Future<void> writeActivityLog({
  required String action,
  required String targetUid,
  required String targetName,
  required String targetEmail,
  String? oldValue,
  String? newValue,
}) async {
  final actor = FirebaseAuth.instance.currentUser;
  if (actor == null) return;
  try {
    await FirebaseFirestore.instance.collection('activity_logs').add({
      'action': action,
      'actorUid': actor.uid,
      'actorEmail': actor.email ?? '',
      'targetUid': targetUid,
      'targetName': targetName,
      'targetEmail': targetEmail,
      if (oldValue != null) 'oldValue': oldValue,
      if (newValue != null) 'newValue': newValue,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
// Activity logging must not break registration or account management.
  }
}

class MTAlchemyApp extends StatelessWidget {
  const MTAlchemyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MT Alchemy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: yellow,
          surface: Colors.white,
        ),
        fontFamily: 'Arial',
        visualDensity: VisualDensity.standard,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: navy,
          elevation: 0,
          scrolledUnderElevation: 2,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE7D9B6)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFCF5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8C99F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8C99F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: purple, width: 1.7),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFCC4343)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFCC4343), width: 1.7),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 220),
            elevation: const WidgetStatePropertyAll(0),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            animationDuration: const Duration(milliseconds: 220),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xFFD8C99F)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF171717),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE7D9B6),
          thickness: 1,
          space: 1,
        ),
      ),
      home: const MainWebsite(),
    );
  }
}

class Course {
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;

  const Course(
      this.title,
      this.category,
      this.description,
      this.icon,
      this.color,
      );
}

class Product {
  final String title;
  final String description;
  final String price;
  final IconData icon;
  final Color color;
  final String type;

  const Product(
      this.title,
      this.description,
      this.price,
      this.icon,
      this.color, {
        this.type = 'Digital',
      });
}

const List<Course> courses = [
  Course(
    'Leadership Essentials',
    'Leadership',
    'Build confidence, communication and leadership skills.',
    Icons.groups_rounded,
    navy,
  ),
  Course(
    'Digital Transformation',
    'Digital Skills',
    'Understand modern digital tools and business transformation.',
    Icons.devices_rounded,
    purple,
  ),
  Course(
    'Workplace Communication',
    'Professional Skills',
    'Improve teamwork, communication and collaboration.',
    Icons.forum_rounded,
    blue,
  ),
  Course(
    'Project Management',
    'Business',
    'Learn planning, delivery and project coordination.',
    Icons.task_alt_rounded,
    Color(0xFF00A99D),
  ),
];

const List<Product> products = [
  Product(
    'Digital Learning Guide',
    'A practical guide for professional development.',
    'RM 29.00',
    Icons.menu_book_rounded,
    purple,
  ),
  Product(
    'Leadership Workbook',
    'Exercises and activities for developing leaders.',
    'RM 39.00',
    Icons.auto_stories_rounded,
    navy,
  ),
  Product(
    'Corporate Training Pack',
    'Resources for team learning and development.',
    'RM 59.00',
    Icons.inventory_2_rounded,
    blue,
  ),
];

class MainWebsite extends StatefulWidget {
  const MainWebsite({super.key});

  @override
  State<MainWebsite> createState() => _MainWebsiteState();
}

class _MainWebsiteState extends State<MainWebsite> {
  String currentPage = 'Home';
  final List<String> _pageHistory = [];
  String? latestOrderId;
  String? signedInRole;
  String? signedInName;
  final List<Product> cart = [];
  bool _isRestoringSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isRestoringSession = false);
      return;
    }

    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = profile.data();
      final role = (data?['role'] as String?)?.trim() ?? '';
      final status = (data?['status'] ?? 'Active').toString();
      final profileName = (data?['name'] as String?)?.trim() ?? '';

      if (!mounted) return;

      const validRoles = ['Super Admin', 'Individual', 'Employer', 'Trainer', 'Employee'];
      if (!profile.exists || !validRoles.contains(role) || status == 'Suspended') {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() {
          signedInRole = null;
          signedInName = null;
          currentPage = 'Home';
          _pageHistory.clear();
          _isRestoringSession = false;
        });
        return;
      }

      final targetPage = _dashboardForRole(role);
      setState(() {
        signedInRole = role;
        signedInName = profileName.isNotEmpty ? profileName : (user.email ?? 'Account');
        currentPage = targetPage;
        _isRestoringSession = false;
      });
      await _loadCart();
    } catch (_) {
// Keep the Firebase session intact if profile loading temporarily fails.
// The user can retry by refreshing after the connection is restored.
      if (mounted) setState(() => _isRestoringSession = false);
    }
  }

  String _dashboardForRole(String role) {
    switch (role) {
      case 'Super Admin': return 'Super Admin Dashboard';
      case 'Individual': return 'Individual Dashboard';
      case 'Employer': return 'Employer Dashboard';
      case 'Trainer': return 'Trainer Dashboard';
      case 'Employee': return 'Employee Dashboard';
      default: return 'Home';
    }
  }

  void navigate(String page) {
    if (page == currentPage) return;
    setState(() {
      _pageHistory.add(currentPage);
      currentPage = page;
    });
  }

  void goBack() {
    setState(() {
      if (_pageHistory.isNotEmpty) {
        currentPage = _pageHistory.removeLast();
      } else {
        currentPage = 'Home';
      }
    });
  }

  // Persist the signed-in user's cart in Firestore. Guest cart remains in memory
  // until the user signs in.
  Future<void> _saveCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('current')
          .set({
        'productTitles': cart.map((product) => product.title).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cart could not be saved. Check Firestore rules and connection.')),
        );
      }
    }
  }

  Future<void> _loadCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc('current')
          .get();
      final titles = (snapshot.data()?['productTitles'] as List<dynamic>?)
          ?.whereType<String>()
          .toList() ?? <String>[];
      if (!mounted) return;
      final restored = <Product>[];
      for (final title in titles) {
        for (final product in products) {
          if (product.title == title) {
            restored.add(product);
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        cart
          ..clear()
          ..addAll(restored);
      });
    } catch (_) {
      // Keep the in-memory cart available if a saved cart cannot be loaded.
    }
  }

  Future<void> handleLoginSuccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      navigate('Home');
      return;
    }

    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = (profile.data()?['role'] as String?)?.trim() ?? '';
      final profileName = (profile.data()?['name'] as String?)?.trim() ?? '';

      if (!mounted) return;
      setState(() {
        signedInRole = role;
        signedInName = profileName.isNotEmpty ? profileName : (user.email ?? 'Account');
      });
      await _loadCart();
      switch (role) {
        case 'Super Admin':
          navigate('Super Admin Dashboard');
          break;
        case 'Individual':
          navigate('Individual Dashboard');
          break;
        case 'Employer':
          navigate('Employer Dashboard');
          break;
        case 'Trainer':
          navigate('Trainer Dashboard');
          break;
        case 'Employee':
          navigate('Employee Dashboard');
          break;
        default:
          await FirebaseAuth.instance.signOut();
          setState(() { signedInRole = null; signedInName = null; });
          navigate('Login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account role is missing or invalid. Please contact the administrator.')),
          );
      }
    } catch (e) {
      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
      setState(() { signedInRole = null; signedInName = null; });
      navigate('Login');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load your account role. Please check your connection and try again.')),
      );
    }
  }

  String get dashboardPage {
    switch (signedInRole) {
      case 'Super Admin': return 'Super Admin Dashboard';
      case 'Employer': return 'Employer Dashboard';
      case 'Trainer': return 'Trainer Dashboard';
      case 'Individual': return 'Individual Dashboard';
      case 'Employee': return 'Employee Dashboard';
      default: return 'Home';
    }
  }

  Future<void> signOutFromWebsite() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    setState(() {
      signedInRole = null;
      signedInName = null;
      currentPage = 'Home';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have been signed out.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <String, Widget>{
      'Home': HomePage(
        onNavigate: navigate,
      ),
      'Employer Home': EmployerLandingPage(onNavigate: navigate),
      'About Us': AboutPage(),
      'Services': ServicesPage(
        onNavigate: navigate,
      ),
      'Learning Hub': LearningPage(
        onNavigate: navigate,
      ),
      'Insights': const InsightsPage(),
      'Verify Certificate': const CertificateVerificationPage(),
      'Digital Store': StorePage(
        cart: cart,
        onAdd: (product) {
          setState(() => cart.add(product));
          _saveCart();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} added to your cart'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onCart: () => navigate('Cart'),
      ),
      'Cart': CartPage(
        cart: cart,
        onRemove: (index) {
          setState(() => cart.removeAt(index));
          _saveCart();
        },
        onShop: () => navigate('Digital Store'),
        onCheckout: () {
          if (FirebaseAuth.instance.currentUser == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in before checkout. Your cart will be saved after sign-in.')),
            );
            navigate('Login');
          } else {
            navigate('Checkout');
          }
        },
      ),
      'My Orders': MyOrdersPage(onShop: () => navigate('Digital Store')),
      'My Digital Products': MyDigitalProductsPage(onShop: () => navigate('Digital Store')),
      'Product Management': ProductManagementPage(onBack: () => navigate('Super Admin Dashboard')),
      'Checkout': CheckoutPage(
        cart: cart,
        onOrderCreated: (orderId) async {
          setState(() {
            latestOrderId = orderId;
            cart.clear();
          });
          await _saveCart();
          if (!mounted) return;
          navigate('Demo Payment');
        },
      ),
      'Demo Payment': DemoPaymentPage(
        orderId: latestOrderId,
        onFinished: (status) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Demo payment status: $status')),
          );
          navigate('Order Confirmation');
        },
      ),
      'Order Confirmation': OrderConfirmationPage(onDone: () => navigate('Digital Store')),
      'Login': LoginPage(
        onRegister: () => navigate('Register'),
        onLoginSuccess: handleLoginSuccess,
      ),
      'Register': RegisterPage(
        onLogin: () => navigate('Login'),
      ),
      'Super Admin Dashboard': RoleDashboardPage(role: 'Super Admin', onManageProducts: () => navigate('Product Management')),
      'Individual Dashboard': const RoleDashboardPage(role: 'Individual'),
      'Employer Dashboard': const RoleDashboardPage(role: 'Employer'),
      'Trainer Dashboard': const RoleDashboardPage(role: 'Trainer'),
      'Employee Dashboard': const RoleDashboardPage(role: 'Employee'),
      'Contact': const ContactPage(),
    };

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 16,
        title: InkWell(
          onTap: () => navigate('Home'),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: purple, size: 30),
              SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MT ALCHEMY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: navy,
                    ),
                  ),
                  Text(
                    'LEARN • GROW • TRANSFORM',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1,
                      color: purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (currentPage != 'Home')
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 4),
              child: TextButton.icon(
                onPressed: goBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(foregroundColor: navy),
              ),
            ),
          if (MediaQuery.sizeOf(context).width > 850)
            ...[
              'Home',
              'About Us',
              'Services',
              'Learning Hub',
              'Insights',
              'Digital Store',
              'For Corporates',
            ].map(
                  (page) => TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => navigate(
                  page == 'For Corporates' ? 'Employer Home' : page,
                ),
                child: Text(
                  page,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: currentPage == page ? purple : navy,
                    fontWeight: currentPage == page
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Shopping cart',
            onPressed: () => navigate('Cart'),
            icon: Badge(
              label: Text('${cart.length}'),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(Icons.shopping_bag_outlined, color: navy),
            ),
          ),
          if (FirebaseAuth.instance.currentUser != null && signedInRole != null) ...[
            if (MediaQuery.sizeOf(context).width > 850)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Chip(
                  avatar: const Icon(Icons.account_circle, color: purple, size: 20),
                  label: Text('${signedInName ?? 'Account'} • $signedInRole'),
                  backgroundColor: const Color(0xFFF4E9CC),
                  side: BorderSide.none,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: OutlinedButton.icon(
                onPressed: () => navigate(dashboardPage),
                icon: const Icon(Icons.dashboard_outlined, size: 18),
                label: const Text('Dashboard'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 2),
              child: IconButton(
                tooltip: 'Sign out',
                onPressed: signOutFromWebsite,
                icon: const Icon(Icons.logout_rounded, color: navy),
              ),
            ),
          ] else if (_isRestoringSession)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6, left: 4),
              child: OutlinedButton(
                onPressed: () => navigate('Login'),
                child: const Text('Sign In'),
              ),
            ),
          if (FirebaseAuth.instance.currentUser == null && !_isRestoringSession)
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 4),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => navigate('Register'),
                child: const Text('Register'),
              ),
            ),
        ],
      ),
      drawer: MediaQuery.sizeOf(context).width <= 850
          ? Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const ListTile(
                leading: Icon(Icons.auto_awesome, color: purple),
                title: Text(
                  'MT ALCHEMY',
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              if (FirebaseAuth.instance.currentUser != null && signedInRole != null)
                ListTile(
                  leading: const Icon(Icons.account_circle, color: purple),
                  title: Text(signedInName ?? 'Signed in'),
                  subtitle: Text(signedInRole!),
                ),
              for (final page in [
                'Home',
                'About Us',
                'Services',
                'Learning Hub',
                'Insights',
                'Digital Store',
                'For Corporates',
                'Cart',
                if (FirebaseAuth.instance.currentUser != null && signedInRole != null) 'Verify Certificate',
                if (FirebaseAuth.instance.currentUser != null && signedInRole != null) 'My Orders',
                if (FirebaseAuth.instance.currentUser != null && signedInRole != null) 'My Digital Products',
                if (FirebaseAuth.instance.currentUser != null && signedInRole != null) 'Dashboard' else 'Sign In',
                if (FirebaseAuth.instance.currentUser == null && !_isRestoringSession) 'Register',
                if (FirebaseAuth.instance.currentUser != null && signedInRole != null) 'Sign out',
              ])
                ListTile(
                  leading: Icon(page == 'Dashboard' ? Icons.dashboard_outlined : page == 'Sign out' ? Icons.logout : _pageIcon(page)),
                  title: Text(page),
                  selected: currentPage == page,
                  onTap: () async {
                    Navigator.pop(context);
                    if (page == 'Dashboard') {
                      navigate(dashboardPage);
                    } else if (page == 'Sign out') {
                      await signOutFromWebsite();
                    } else if (page == 'For Corporates') {
                      navigate('Employer Home');
                    } else if (page == 'Sign In') {
                      navigate('Login');
                    } else {
                      navigate(page);
                    }
                  },
                ),
            ],
          ),
        ),
      )
          : null,
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slide,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(currentPage),
                child: pages[currentPage] ?? pages['Home']!,
              ),
            ),
          ),
          if (FirebaseAuth.instance.currentUser == null &&
              !_isRestoringSession &&
              !['Login', 'Register'].contains(currentPage))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F4EE),
                border: Border(top: BorderSide(color: Color(0xFFE8E0CF))),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  const Text(
                    '© MT Alchemy | Learn • Grow • Transform',
                    style: TextStyle(color: navy, fontSize: 12),
                  ),
                  Wrap(
                    spacing: 16,
                    children: [
                      TextButton(
                        onPressed: () => navigate('Contact'),
                        child: const Text('Contact'),
                      ),
                      TextButton(
                        onPressed: () => navigate('Verify Certificate'),
                        child: const Text('Verify Certificate'),
                      ),
                      TextButton.icon(
                        onPressed: () => navigate('Login'),
                        icon: const Icon(Icons.lock_outline, size: 16),
                        label: const Text('Staff Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _pageIcon(String page) {
    switch (page) {
      case 'Home':
        return Icons.home_outlined;
      case 'About Us':
        return Icons.info_outline;
      case 'Services':
        return Icons.business_center_outlined;
      case 'Learning Hub':
        return Icons.school_outlined;
      case 'Insights':
        return Icons.article_outlined;
      case 'Verify Certificate':
        return Icons.verified_outlined;
      case 'My Orders':
        return Icons.receipt_long_outlined;
      case 'My Digital Products':
        return Icons.download_for_offline_outlined;
      case 'Digital Store':
        return Icons.storefront_outlined;
      case 'Cart':
        return Icons.shopping_cart_outlined;
      case 'Contact':
        return Icons.mail_outline;
      default:
        return Icons.login;
    }
  }
}

// -------------------- EMPLOYER LANDING PAGE --------------------

class EmployerLandingPage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const EmployerLandingPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 22.0 : 64.0;
    final challenges = [
      ('Employee burnout', Icons.battery_alert_outlined),
      ('Rising workplace stress', Icons.psychology_alt_outlined),
      ('Communication gaps', Icons.forum_outlined),
      ('Team conflicts', Icons.groups_2_outlined),
      ('Leadership gaps', Icons.leaderboard_outlined),
      ('Low employee engagement', Icons.sentiment_dissatisfied_outlined),
    ];
    final solutions = [
      ('Leadership Development', 'Build confident, emotionally intelligent leaders.', Icons.workspace_premium_outlined),
      ('Emotional Intelligence', 'Strengthen self-awareness, empathy and relationships.', Icons.psychology_outlined),
      ('Team Effectiveness', 'Create connected teams that work better together.', Icons.groups_outlined),
      ('Communication', 'Improve collaboration and meaningful conversations.', Icons.record_voice_over_outlined),
      ('Workplace Well-being', 'Support healthier and more resilient workplace cultures.', Icons.favorite_border_rounded),
      ('CSR & ESG', 'Connect people development with responsible impact.', Icons.eco_outlined),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: width < 600 ? 54 : 82),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF151515), Color(0xFF30291C), Color(0xFF6E5425)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: yellow.withValues(alpha: .55)),
                    ),
                    child: const Text('CORPORATE LEARNING & DEVELOPMENT', style: TextStyle(color: yellow, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Build emotionally intelligent leaders and resilient workplace cultures.',
                    style: TextStyle(color: Colors.white, fontSize: width < 600 ? 34 : 48, height: 1.15, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 720,
                    child: Text(
                      'Develop your people. Strengthen your organisation. MT Alchemy works with organisations to support leadership, team effectiveness and workplace well-being through people-centred learning experiences.',
                      style: TextStyle(color: Color(0xFFE9E3D7), height: 1.8, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: yellow, foregroundColor: navy, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
                      onPressed: () => onNavigate('Contact'),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Talk to MT Alchemy'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
                      onPressed: () => onNavigate('Services'),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Explore Services'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          SectionHeading(
            eyebrow: 'UNDERSTANDING YOUR WORKPLACE',
            title: 'Challenges organisations face',
            subtitle: 'People and workplace challenges can affect performance, engagement and culture.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: challenges.map((item) => SizedBox(
                  width: width < 600 ? width - 44 : 285,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(children: [
                        Icon(item.$2, color: purple, size: 26),
                        const SizedBox(width: 12),
                        Expanded(child: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700, color: navy))),
                      ]),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 54),
          SectionHeading(
            eyebrow: 'HOW WE CAN HELP',
            title: 'People development solutions',
            subtitle: 'Programmes can be shaped around your organisation, people and learning goals.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                children: solutions.map((item) => SizedBox(
                  width: width < 600 ? width - 44 : 390,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(item.$3, color: purple, size: 32),
                        const SizedBox(height: 14),
                        Text(item.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy)),
                        const SizedBox(height: 8),
                        Text(item.$2, style: const TextStyle(color: Color(0xFF625D53), height: 1.6)),
                      ]),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1250),
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: const Color(0xFF201F1C), borderRadius: BorderRadius.circular(24)),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 18,
                children: [
                  const SizedBox(width: 620, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('LET’S WORK TOGETHER', style: TextStyle(color: yellow, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    SizedBox(height: 10),
                    Text('Let’s build a thriving workplace together.', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text('Tell us about your organisation and the outcomes you want to achieve.', style: TextStyle(color: Color(0xFFD7D1C5), height: 1.6)),
                  ])),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: yellow, foregroundColor: navy, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17)),
                    onPressed: () => onNavigate('Contact'),
                    child: const Text('Get a Free Consultation'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  const FloatingIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -7, end: 7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      child: Icon(widget.icon, size: widget.size, color: widget.color),
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _floatAnimation.value),
        child: child,
      ),
    );
  }
}


// Full-bleed looping background video for the Home page hero.
class HeroBackgroundVideo extends StatefulWidget {
  const HeroBackgroundVideo({super.key});

  @override
  State<HeroBackgroundVideo> createState() => _HeroBackgroundVideoState();
}

class _HeroBackgroundVideoState extends State<HeroBackgroundVideo> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final controller = VideoPlayerController.asset(
      'assets/videos/hero_background.mp4',
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [navy, blue, purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    return ClipRect(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}

// -------------------- HOME PAGE --------------------

class HomePage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const HomePage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 600 ? 22.0 : 64.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned.fill(child: HeroBackgroundVideo()),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          navy.withValues(alpha: 0.90),
                          blue.withValues(alpha: 0.78),
                          purple.withValues(alpha: 0.70),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: width < 600 ? 45 : 76,
                  ),
                  child: Wrap(
                    spacing: 40,
                    runSpacing: 35,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: width < 600 ? width - 44 : 520,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Text(
                                'YOUR PARTNER IN LEARNING & GROWTH',
                                style: TextStyle(
                                  color: yellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Text(
                              'Unlock Your Potential.\nTransform Your Future.',
                              style: TextStyle(
                                fontSize: width < 600 ? 34 : 46,
                                height: 1.12,
                                letterSpacing: -0.8,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Discover learning experiences, professional development '
                                  'programmes and digital resources designed to help '
                                  'individuals and organisations grow.',
                              style: TextStyle(
                                color: Color(0xFFE4E9F6),
                                height: 1.8,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: yellow,
                                    foregroundColor: navy,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                  ),
                                  onPressed: () => onNavigate('Learning Hub'),
                                  child: const Text('Explore Learning'),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white70),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 18,
                                    ),
                                  ),
                                  onPressed: () => onNavigate('Employer Home'),
                                  child: const Text('For Corporates'),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(color: yellow.withValues(alpha: .8)),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                  onPressed: () => onNavigate('Employer Home'),
                                  icon: const Icon(Icons.business_outlined, size: 18),
                                  label: const Text('I’m an Employer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 42),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 760;
                  final image = ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1400&q=85',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) => progress == null
                              ? child
                              : Container(
                            color: const Color(0xFF28251F),
                            child: const Center(
                              child: CircularProgressIndicator(color: yellow),
                            ),
                          ),
                          errorBuilder: (context, error, stack) => Container(
                            color: const Color(0xFF28251F),
                            child: const Center(
                              child: Icon(Icons.groups_rounded, color: yellow, size: 90),
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: .78), Colors.transparent],
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 22,
                          right: 22,
                          bottom: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LEARN TOGETHER', style: TextStyle(color: yellow, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 11)),
                              SizedBox(height: 7),
                              Text('Build skills that move you forward.', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                  final copy = Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201F1C),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: yellow.withValues(alpha: .38)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: yellow, size: 34),
                        SizedBox(height: 18),
                        Text('GROW WITH PURPOSE', style: TextStyle(color: yellow, letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text('A better you starts with one new skill.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.2, fontWeight: FontWeight.w800)),
                        SizedBox(height: 12),
                        Text('Explore practical learning, expert-led development and resources designed to turn ambition into progress.', style: TextStyle(color: Color(0xFFD7D1C5), height: 1.7)),
                      ],
                    ),
                  );
                  return stacked
                      ? Column(children: [SizedBox(height: 270, child: image), const SizedBox(height: 16), copy])
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 340,
                          child: image,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 4,
                        child: copy,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 48),
          SectionHeading(
            eyebrow: 'WHAT WE OFFER',
            title: 'Everything you need to grow',
            subtitle:
            'Explore learning opportunities and resources for your next step.',
          ),
          const SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                FeatureCard(
                  icon: Icons.school_rounded,
                  title: 'Online Learning',
                  description:
                  'Explore courses and develop practical professional skills.',
                  color: navy,
                  imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=85',
                  onTap: () => onNavigate('Learning Hub'),
                ),
                FeatureCard(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Digital Store',
                  description:
                  'Discover digital learning materials and useful resources.',
                  color: purple,
                  imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=900&q=85',
                  onTap: () => onNavigate('Digital Store'),
                ),
                FeatureCard(
                  icon: Icons.apartment_rounded,
                  title: 'Corporate Training',
                  description:
                  'Find learning solutions designed for organisations and teams.',
                  color: const Color(0xFF8A6A25),
                  imageUrl: 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=900&q=85',
                  onTap: () => onNavigate('Services'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          SectionHeading(
            eyebrow: 'FEATURED COURSES',
            title: 'Learning for your next chapter',
            subtitle: 'Start exploring our sample learning catalogue.',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: courses.take(3).map((course) {
                return CourseCard(
                  course: course,
                  onTap: () => onNavigate('Learning Hub'),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontal),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: const LearningVideoSection(),
            ),
          ),
          const SizedBox(height: 45),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: 42,
            ),
            color: const Color(0xFFF3E5BF),
            child: Wrap(
              spacing: 25,
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to take the next step?',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Explore learning programmes or talk to us about '
                            'your organisation’s training needs.',
                        style: TextStyle(height: 1.7),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(20),
                  ),
                  onPressed: () => onNavigate('Contact'),
                  child: const Text('Get in Touch'),
                ),
              ],
            ),
          ),
          SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- FEATURE VIDEO --------------------

class LearningVideoSection extends StatefulWidget {
  const LearningVideoSection({super.key});

  @override
  State<LearningVideoSection> createState() => _LearningVideoSectionState();
}

class _LearningVideoSectionState extends State<LearningVideoSection> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _ready = true;
        _isPlaying = _controller.value.isPlaying;
      });
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
    _controller.addListener(_handleVideoUpdate);
    _controller.setLooping(false);
  }

  // Do not rebuild this entire video section on every playback frame.
  // VideoProgressIndicator listens to the controller itself; rebuild only when
  // play/pause state changes. This avoids unnecessary web layout and mouse work.
  void _handleVideoUpdate() {
    if (!mounted) return;
    final playing = _controller.value.isPlaying;
    if (playing != _isPlaying) {
      setState(() => _isPlaying = playing);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WATCH • LEARN • GROW', style: TextStyle(color: Color(0xFF9A762B), letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 9),
        Text('Learning in motion', style: TextStyle(color: navy, fontSize: width < 600 ? 27 : 34, fontWeight: FontWeight.w900, letterSpacing: -.5)),
        const SizedBox(height: 8),
        const Text('A featured video experience for your learning journey.', style: TextStyle(color: Color(0xFF6F6A60), height: 1.6)),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: const Color(0xFF171717),
            child: AspectRatio(
              aspectRatio: _ready ? _controller.value.aspectRatio : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_ready)
                    VideoPlayer(_controller)
                  else if (_failed)
                    const Center(child: Text('Video could not load. Check your internet connection.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center))
                  else
                    const Center(child: CircularProgressIndicator(color: Color(0xFFD6B15D))),
                  if (_ready)
                    Positioned(
                      left: 12, right: 12, bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .68), borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          IconButton(
                            tooltip: _isPlaying ? 'Pause video' : 'Play video',
                            onPressed: () {
                              if (_isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: yellow),
                          ),
                          Expanded(child: VideoProgressIndicator(_controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Color(0xFFD6B15D), bufferedColor: Colors.white38, backgroundColor: Colors.white24))),
                          const SizedBox(width: 12),
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _controller,
                            builder: (context, value, child) => Text(
                              _formatDuration(value.position),
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(children: [Icon(Icons.verified_rounded, color: Color(0xFF9A762B), size: 18), SizedBox(width: 8), Expanded(child: Text('Embedded sample video player — replace the sample URL with an approved MT Alchemy training video.', style: TextStyle(color: Color(0xFF6F6A60), fontSize: 12, height: 1.5)))]),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// -------------------- ABOUT PAGE --------------------

class AboutPage extends StatelessWidget {
  AboutPage({super.key});

  static const Color _gold = Color(0xFFE0B85F);
  static const Color _ink = Color(0xFF20201E);
  static const Color _cream = Color(0xFFF7F3EA);
  static const Color _muted = Color(0xFF68645D);

  Widget _eyebrow(String text, {Color color = _gold}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 22, height: 2, color: color),
      const SizedBox(width: 9),
      Text(text.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.7)),
    ],
  );

  Widget _heading(String eyebrow, String title, String subtitle, {bool centered = false}) => Column(
    crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    children: [
      _eyebrow(eyebrow),
      const SizedBox(height: 12),
      Text(title, textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(color: navy, fontSize: 30, height: 1.15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Text(subtitle, textAlign: centered ? TextAlign.center : TextAlign.left,
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.8)),
      ),
    ],
  );

  Widget _valueCard(IconData icon, String number, String title, String body) => Container(
    width: 250,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE5D8)),
        boxShadow: const [BoxShadow(color: Color(0x0A17130D), blurRadius: 22, offset: Offset(0, 9))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: const Color(0xFF9A762B), size: 24)),
      const SizedBox(height: 18),
      Text(number, style: const TextStyle(color: Color(0xFF9A762B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(body, style: const TextStyle(color: _muted, height: 1.65, fontSize: 13)),
    ]),
  );

  Widget _serviceTile(IconData icon, String title, String description) => Container(
    width: 300,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE3D7))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 42, height: 42, decoration: BoxDecoration(color: _cream, borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: const Color(0xFF9A762B), size: 21)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.6)),
      ])),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 760;
    return SingleChildScrollView(
      child: Column(children: [
        // Editorial-style hero
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 70, vertical: compact ? 48 : 72),
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF142C50), Color(0xFF354D83), Color(0xFF6954A5)]),
          ),
          child: Stack(children: [
            Positioned(right: -20, top: -45, child: Container(width: 190, height: 190,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.10), width: 26)))),
            Positioned(left: 0, bottom: 0, child: Icon(Icons.auto_awesome, color: _gold.withOpacity(.25), size: 70)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _eyebrow('The people behind the progress'),
              const SizedBox(height: 20),
              ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Text(
                  'We help people grow,\nand workplaces thrive.',
                  style: TextStyle(color: Colors.white, fontSize: compact ? 34 : 52, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.1))),
              const SizedBox(height: 18),
              SizedBox(width: 650, child: Text(
                  'MT Alchemy is a people-development consultancy supporting individuals, teams and organisations through human-centred learning and development.',
                  style: TextStyle(color: Colors.white.withOpacity(.86), fontSize: 15, height: 1.8))),
              const SizedBox(height: 25),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _heroTag(Icons.psychology_alt_outlined, 'Emotional intelligence'),
                _heroTag(Icons.groups_2_outlined, 'Connected teams'),
                _heroTag(Icons.trending_up, 'Meaningful growth'),
              ]),
            ]),
          ]),
        ),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Who we are feature split
              _heading('Who we are', 'People development with purpose',
                  'We bring learning, coaching and practical development experiences together to help people build self-awareness, strengthen relationships and create positive change.'),
              const SizedBox(height: 25),
              LayoutBuilder(builder: (context, constraints) {
                final image = ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(
                    'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1200&q=85',
                    height: compact ? 220 : 330, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 260, color: const Color(0xFFE9E2D5), child: const Icon(Icons.groups_rounded, size: 70, color: navy))));
                final story = Container(padding: EdgeInsets.all(compact ? 22 : 32), decoration: BoxDecoration(
                    color: _cream, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _eyebrow('Our belief', color: const Color(0xFF9A762B)),
                  const SizedBox(height: 14),
                  const Text('Real growth starts with people.', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 25, height: 1.2)),
                  const SizedBox(height: 12),
                  const Text('We believe stronger workplaces are built when people understand themselves, communicate with empathy and work together with purpose.', style: TextStyle(color: _muted, height: 1.8, fontSize: 14)),
                  const SizedBox(height: 18),
                  const Row(children: [Icon(Icons.check_circle, color: Color(0xFF9A762B), size: 18), SizedBox(width: 8), Expanded(child: Text('A human-centred approach', style: TextStyle(color: navy, fontWeight: FontWeight.w600))) ]),
                  const SizedBox(height: 9),
                  const Row(children: [Icon(Icons.check_circle, color: Color(0xFF9A762B), size: 18), SizedBox(width: 8), Expanded(child: Text('Learning that can be applied in real life', style: TextStyle(color: navy, fontWeight: FontWeight.w600))) ]),
                ]));
                return constraints.maxWidth < 760
                    ? Column(children: [image, const SizedBox(height: 16), story])
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 11, child: image), const SizedBox(width: 22), Expanded(flex: 9, child: story)]);
              }),
              const SizedBox(height: 58),
              _heading('What guides us', 'Our vision, mission & approach',
                  'The principles that shape how we work with individuals, teams and organisations.'),
              const SizedBox(height: 24),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _valueCard(Icons.visibility_outlined, '01', 'Our Vision', 'To help create emotionally intelligent people, connected teams and thriving workplace cultures.'),
                _valueCard(Icons.flag_outlined, '02', 'Our Mission', 'To support meaningful personal and organisational growth through learning, coaching and practical development experiences.'),
                _valueCard(Icons.favorite_outline, '03', 'Our Approach', 'A human-centred approach that encourages self-awareness, meaningful connection and positive behaviour change.'),
              ]),
              const SizedBox(height: 58),
              // Services on a tinted panel
              Container(width: double.infinity, padding: EdgeInsets.all(compact ? 22 : 34),
                  decoration: BoxDecoration(color: const Color(0xFFF7F3EA), borderRadius: BorderRadius.circular(26)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _heading('What we do', 'Development for people and organisations',
                        'Our work spans key areas that help individuals and workplaces learn, connect and grow.'),
                    const SizedBox(height: 24),
                    Wrap(spacing: 13, runSpacing: 13, children: [
                      _serviceTile(Icons.psychology_outlined, 'Emotional Intelligence & Mindfulness', 'Build self-awareness, empathy and mindful habits.'),
                      _serviceTile(Icons.record_voice_over_outlined, 'Leadership & Communication', 'Strengthen leadership capability and everyday communication.'),
                      _serviceTile(Icons.health_and_safety_outlined, 'Organisation Well-being Assessment', 'Understand well-being needs across the workplace.'),
                      _serviceTile(Icons.groups_outlined, 'Team Engagement & Effectiveness', 'Support collaboration, trust and team connection.'),
                      _serviceTile(Icons.public_outlined, 'CSR & ESG', 'Connect people development with responsible impact.'),
                      _serviceTile(Icons.tune_rounded, 'Customised Programmes', 'Shape learning experiences around organisational needs.'),
                    ]),
                  ])),
              const SizedBox(height: 58),
              // Impact statement
              Container(width: double.infinity, padding: EdgeInsets.all(compact ? 24 : 38),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [_ink, Color(0xFF34312B)]), borderRadius: BorderRadius.circular(26)),
                  child: Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 24, runSpacing: 20, children: [
                    SizedBox(width: compact ? 280 : 650, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _eyebrow('Our impact'), const SizedBox(height: 13),
                      const Text('Learning that creates meaningful change.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.2, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      const Text('MT Alchemy’s development work is centred on helping people strengthen skills, relationships and workplace culture.', style: TextStyle(color: Colors.white70, height: 1.7, fontSize: 14)),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22), decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.12))),
                        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('1,100+', style: TextStyle(color: _gold, fontSize: 42, fontWeight: FontWeight.w900)),
                          Text('participants impacted', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ])),
                  ])),
              const SizedBox(height: 58),
              _heading('Leadership', 'Meet the founder', 'The person guiding MT Alchemy’s people-development vision.'),
              const SizedBox(height: 22),
              Container(width: double.infinity, padding: EdgeInsets.all(compact ? 20 : 30),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFEAE3D7)),
                      boxShadow: const [BoxShadow(color: Color(0x0A17130D), blurRadius: 20, offset: Offset(0, 8))]),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(width: compact ? 66 : 92, height: compact ? 66 : 92, decoration: const BoxDecoration(shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFFE9D39A), Color(0xFF9A762B)])),
                        child: Center(child: Text('MT', style: TextStyle(color: Colors.white, fontSize: compact ? 23 : 30, fontWeight: FontWeight.w800)))),
                    const SizedBox(width: 20),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Mabel Tan KH', style: TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.w800)),
                      SizedBox(height: 5),
                      Text('Founder  •  EQ Coach  •  HRDC Certified Trainer', style: TextStyle(color: Color(0xFF9A762B), fontSize: 13, fontWeight: FontWeight.w700)),
                      SizedBox(height: 9),
                      Text('Founder profile and approved biography can be added here when the official company details are available.', style: TextStyle(color: _muted, height: 1.65, fontSize: 13)),
                    ])),
                  ])),
              const SizedBox(height: 45),
              Container(width: double.infinity, padding: EdgeInsets.all(compact ? 22 : 30), decoration: BoxDecoration(
                  color: const Color(0xFFEEF0F7), borderRadius: BorderRadius.circular(24)),
                  child: Row(children: [
                    const Icon(Icons.diversity_3_outlined, color: Color(0xFF455A86), size: 38),
                    const SizedBox(width: 18),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Our Team', style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('A collaborative team supporting learning, professional development and organisational growth. Team member profiles and photographs can be added when approved company information is available.', style: TextStyle(color: _muted, height: 1.65, fontSize: 13)),
                    ])),
                  ])),
              const SizedBox(height: 48),
            ]),
          ),
        ),
        SiteFooter(),
      ]),
    );
  }

  Widget _heroTag(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.10), borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.20))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: _gold, size: 16), const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))]),
  );
}

// -------------------- SERVICES PAGE --------------------

class ServicesPage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const ServicesPage({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(
            title: 'Our Services',
            subtitle:
            'Learning and development experiences for individuals and organisations.',
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1600&q=85',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: navy,
                          child: const Icon(Icons.groups_rounded, color: yellow, size: 70),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.78),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Text(
                              'Build stronger teams through continuous learning.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                ServiceCard(
                  icon: Icons.cast_for_education,
                  title: 'Learning Programmes',
                  text:
                  'Explore structured learning experiences and professional development.',
                  imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=900&q=85',
                ),
                ServiceCard(
                  icon: Icons.groups_2_outlined,
                  title: 'Corporate Training',
                  text:
                  'Plan training opportunities around organisational needs.',
                  imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=900&q=85',
                ),
                ServiceCard(
                  icon: Icons.analytics_outlined,
                  title: 'Learning Progress',
                  text:
                  'Support learning oversight and progress reporting for teams.',
                  imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=900&q=85',
                ),
                ServiceCard(
                  icon: Icons.devices_outlined,
                  title: 'Digital Resources',
                  text:
                  'Access digital materials that support learning and development.',
                  imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=900&q=85',
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              padding: const EdgeInsets.all(20),
            ),
            onPressed: () => onNavigate('Contact'),
            child: const Text('Enquire About Training'),
          ),
          const SizedBox(height: 45),
          SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- LEARNING HUB --------------------

class LearningPage extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const LearningPage({super.key, required this.onNavigate});

  String _courseId(Course course) => course.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Future<void> _enrolInCourse(BuildContext context, Course course) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      onNavigate('Login');
      return;
    }

    try {
      final profileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final profile = profileSnapshot.data() ?? <String, dynamic>{};
      final role = (profile['role'] ?? '').toString();
      final status = (profile['status'] ?? 'Active').toString();

      if (status == 'Suspended') {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This account is suspended. Please contact the administrator.')),
        );
        return;
      }

      if (role != 'Individual') {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course enrolment is available for Individual accounts.')),
        );
        return;
      }

      final enrollmentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('enrollments')
          .doc(_courseId(course));
      final existing = await enrollmentRef.get();

      if (existing.exists) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are already enrolled in ${course.title}. Open your Dashboard to continue learning.')),
        );
        onNavigate('Individual Dashboard');
        return;
      }

      await enrollmentRef.set({
        'courseId': _courseId(course),
        'title': course.title,
        'category': course.category,
        'progress': 0,
        'enrolledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully enrolled in ${course.title}!')),
      );
      onNavigate('Individual Dashboard');
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Firestore denied enrolment. Please check the enrollment security rules.'
                : 'Could not enrol in this course. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong while enrolling. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(
            title: 'Learning Hub',
            subtitle:
            'Explore courses designed to support personal and professional growth.',
          ),
          const SizedBox(height: 30),
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final profile = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .get();
                      final role = (profile.data()?['role'] ?? '').toString();
                      if (!context.mounted) return;
                      if (role == 'Individual') {
                        onNavigate('Individual Dashboard');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('My Learning is available for Individual accounts.')),
                        );
                      }
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not load your account. Please try again.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('My Learning'),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: courses.map((course) {
                return CourseCard(
                  course: course,
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        icon: Icon(course.icon, color: course.color, size: 40),
                        title: Text(course.title),
                        content: Text(
                          '${course.description}\n\n'
                              'Enrol in this course to add it to My Learning. You can track your progress from your Individual Dashboard.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _enrolInCourse(context, course),
                            icon: const Icon(Icons.school_outlined),
                            label: Text(currentUser == null ? 'Sign in to enrol' : 'Enrol in course'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 35),
          SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- DIGITAL STORE --------------------

class StorePage extends StatelessWidget {
  final List<Product> cart;
  final ValueChanged<Product> onAdd;
  final VoidCallback onCart;

  const StorePage({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseFirestore.instance
        .collection('products')
        .where('available', isEqualTo: true);

    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(
            title: 'Digital Store',
            subtitle: 'Discover learning guides, workbooks and digital resources.',
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: productsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 42),
                            const SizedBox(height: 12),
                            const Text('Unable to load store products.'),
                            const SizedBox(height: 6),
                            const Text(
                              'Check your Firestore products read rules and connection.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const Icon(Icons.storefront_outlined, size: 56, color: purple),
                            const SizedBox(height: 12),
                            const Text(
                              'No products available yet',
                              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy),
                            ),
                            const SizedBox(height: 8),
                            const Text('Published products added by the Super Admin will appear here.'),
                          ],
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: docs.map((doc) {
                      final data = doc.data();
                      final title = (data['title'] ?? 'Untitled product').toString();
                      final description = (data['description'] ?? '').toString();
                      final priceValue = (data['price'] as num?)?.toDouble() ?? 0.0;
                      final type = (data['type'] ?? 'Digital').toString();
                      final isPhysical = type.toLowerCase() == 'physical';
                      final product = Product(
                        title,
                        description,
                        'RM ${priceValue.toStringAsFixed(2)}',
                        isPhysical ? Icons.inventory_2_outlined : Icons.menu_book_outlined,
                        isPhysical ? blue : purple,
                        type: type,
                      );

                      return Container(
                        width: 280,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E0CF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: product.color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(product.icon, size: 55, color: product.color),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.title,
                                    style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(type, style: TextStyle(color: product.color, fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(product.description, style: const TextStyle(height: 1.6, color: Colors.black54)),
                            const SizedBox(height: 14),
                            Text(product.price, style: const TextStyle(fontWeight: FontWeight.bold, color: purple, fontSize: 19)),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: navy),
                                onPressed: () => onAdd(product),
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add to cart'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 25),
          OutlinedButton.icon(
            onPressed: onCart,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text('View Cart (${cart.length})'),
          ),
          const SizedBox(height: 45),
          SiteFooter(),
        ],
      ),
    );
  }
}

// -------------------- CART --------------------

class CartPage extends StatelessWidget {
  final List<Product> cart;
  final ValueChanged<int> onRemove;
  final VoidCallback onShop;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onShop,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(
            title: 'Your Cart',
            subtitle: 'Review your selected digital learning resources.',
          ),
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: cart.isEmpty
                  ? Column(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 75,
                    color: purple,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Explore the store to find learning resources.'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: onShop,
                    child: const Text('Browse Store'),
                  ),
                ],
              )
                  : Column(
                children: [
                  for (int i = 0; i < cart.length; i++)
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(
                          cart[i].icon,
                          color: cart[i].color,
                          size: 32,
                        ),
                        title: Text(cart[i].title),
                        subtitle: Text(cart[i].price),
                        trailing: IconButton(
                          tooltip: 'Remove item',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onRemove(i),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Checkout is a prototype screen. No real payment will be taken.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onCheckout,
                    child: const Text('Continue to Sign In'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 45),
          SiteFooter(),
        ],
      ),
    );
  }
}


// -------------------- CHECKOUT --------------------

class CheckoutPage extends StatefulWidget {
  final List<Product> cart;
  final ValueChanged<String> onOrderCreated;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.onOrderCreated,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _billingController = TextEditingController();
  final _shippingController = TextEditingController();
  bool _submitting = false;

  bool get _containsPhysical => widget.cart.any((product) => product.type.toLowerCase() == 'physical');

  double get _total => widget.cart.fold<double>(
    0,
        (sum, product) =>
    sum + (double.tryParse(product.price.replaceAll('RM', '').trim()) ?? 0),
  );

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data() ?? <String, dynamic>{};
      if (!mounted) return;
      _nameController.text = (data['name'] ?? '').toString();
      if (_emailController.text.isEmpty) {
        _emailController.text = (data['email'] ?? user.email ?? '').toString();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _billingController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before placing an order.')),
      );
      return;
    }
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Add a product first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final profile = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if ((profile.data()?['status'] ?? 'Active') == 'Suspended') {
        throw Exception('This account is suspended.');
      }

      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc();

      final orderItems = widget.cart.map((product) {
        final price = double.tryParse(
          product.price.replaceAll('RM', '').trim(),
        ) ??
            0.0;
        return {
          'title': product.title,
          'description': product.description,
          'price': price,
          'quantity': 1,
          'digital': product.type.toLowerCase() != 'physical',
          'type': product.type,
        };
      }).toList();

      await orderRef.set({
        'orderId': orderRef.id,
        'userId': user.uid,
        'customerName': _nameController.text.trim(),
        'customerEmail': _emailController.text.trim(),
        'customerPhone': _phoneController.text.trim(),
        'billingAddress': _billingController.text.trim(),
        'containsPhysical': _containsPhysical,
        'shippingAddress': _containsPhysical ? _shippingController.text.trim() : '',
        'shippingStatus': _containsPhysical ? 'Pending Dispatch' : 'Not Applicable',
        'items': orderItems,
        'total': _total,
        'currency': 'MYR',
        'orderStatus': 'Awaiting Payment',
        'paymentStatus': 'Pending',
        'paymentMethod': 'Demo payment',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      widget.onOrderCreated(orderRef.id);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'Firestore denied the order. Add the orders security rule first.'
              : 'Could not create the order: ${e.message ?? e.code}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageBanner(
                title: 'Checkout',
                subtitle: 'Confirm your details and create your demo order.',
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Customer details',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full name *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email address *', border: OutlineInputBorder()),
                          validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Enter a valid email address' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Phone number *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().length < 7 ? 'Enter a valid phone number' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _billingController,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Billing address (optional)', border: OutlineInputBorder()),
                        ),
                        if (_containsPhysical) ...[
                          const SizedBox(height: 14),
                          const Text('Shipping details', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _shippingController,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Full shipping address *', hintText: 'Street, city, state, postcode', border: OutlineInputBorder(), prefixIcon: Icon(Icons.local_shipping_outlined)),
                            validator: (v) => _containsPhysical && (v == null || v.trim().length < 10) ? 'Enter a complete shipping address' : null,
                          ),
                          const SizedBox(height: 8),
                          const Text('Shipping status will begin as Pending Dispatch after a successful demo payment.', style: TextStyle(color: Colors.black54)),
                        ],
                        const SizedBox(height: 24),
                        const Text('Order summary',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                        const SizedBox(height: 10),
                        if (widget.cart.isEmpty)
                          const Text('Your cart is empty. Return to the Digital Store to add products.')
                        else
                          ...widget.cart.map((product) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(product.icon, color: product.color),
                            title: Text(product.title),
                            subtitle: Text(product.type),
                            trailing: Text(product.price),
                          )),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('RM ${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: purple, fontSize: 20)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Demo checkout only. No real payment is taken. The order will be saved as Awaiting Payment.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _submitting || widget.cart.isEmpty ? null : _placeOrder,
                          icon: _submitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.receipt_long_outlined),
                          label: Text(_submitting ? 'Creating order...' : 'Create Order'),
                          style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.all(18)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}


// -------------------- MY ORDERS --------------------

class MyOrdersPage extends StatelessWidget {
  final VoidCallback onShop;
  const MyOrdersPage({super.key, required this.onShop});

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate().toLocal();
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return 'Date unavailable';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Successful':
      case 'Processing (Demo)':
        return Colors.green.shade700;
      case 'Failed':
      case 'Payment Failed':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Please sign in to view your orders.'),
      ));
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('users').doc(user.uid).collection('orders');

    return SingleChildScrollView(
      child: Column(children: [
        PageBanner(
          title: 'My Orders',
          subtitle: 'View your order history, totals and demo payment status.',
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ordersRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Card(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Could not load orders. Check your Firestore rules and connection.'),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Card(color: Colors.white, child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(children: [
                      const Icon(Icons.receipt_long_outlined, size: 58, color: purple),
                      const SizedBox(height: 12),
                      const Text('No orders yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
                      const SizedBox(height: 8),
                      const Text('Your orders will appear here after checkout.'),
                      const SizedBox(height: 18),
                      FilledButton(onPressed: onShop, child: const Text('Browse Digital Store')),
                    ]),
                  ));
                }
                return Column(children: docs.map((doc) {
                  final data = doc.data();
                  final items = (data['items'] as List<dynamic>?) ?? [];
                  final payment = (data['paymentStatus'] ?? 'Pending').toString();
                  final orderStatus = (data['orderStatus'] ?? 'Awaiting Payment').toString();
                  final total = (data['total'] as num?)?.toDouble() ?? 0;
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 520;
                            return Flex(
                              direction: narrow ? Axis.vertical : Axis.horizontal,
                              crossAxisAlignment: narrow
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Order ${doc.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),
                                ),
                                if (narrow) const SizedBox(height: 5),
                                Text(
                                  _dateLabel(data['createdAt']),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(items.map((e) => e is Map ? '${e['title'] ?? 'Product'} × ${e['quantity'] ?? 1}' : '$e').join(', ')),
                        const SizedBox(height: 12),
                        Wrap(spacing: 10, runSpacing: 8, children: [
                          Chip(label: Text('Payment: $payment'), backgroundColor: _statusColor(payment).withValues(alpha: .10), side: BorderSide.none),
                          Chip(label: Text('Order: $orderStatus'), backgroundColor: _statusColor(orderStatus).withValues(alpha: .10), side: BorderSide.none),
                          if (data['containsPhysical'] == true)
                            Chip(label: Text('Shipping: ${(data['shippingStatus'] ?? 'Pending Dispatch').toString()}'), backgroundColor: Colors.blue.withValues(alpha: .10), side: BorderSide.none),
                        ]),
                        if (data['containsPhysical'] == true && (data['shippingAddress'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Shipping to: ${data['shippingAddress']}', style: const TextStyle(color: Colors.black54)),
                        ],
                        const Divider(height: 24),
                        Row(children: [
                          Expanded(child: Text('Total: RM ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: purple))),
                          TextButton.icon(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Order details'),
                                content: SizedBox(width: 420, child: SingleChildScrollView(child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText('Order ID: ${doc.id}'),
                                    const SizedBox(height: 8),
                                    Text('Date: ${_dateLabel(data['createdAt'])}'),
                                    Text('Customer: ${data['customerName'] ?? ''}'),
                                    Text('Email: ${data['customerEmail'] ?? ''}'),
                                    const SizedBox(height: 12),
                                    const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ...items.map((item) {
                                      final map = item is Map ? item : <String, dynamic>{'title': item.toString()};
                                      final price = (map['price'] as num?)?.toDouble() ?? 0;
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text('${map['title'] ?? 'Product'}'),
                                        subtitle: Text('Quantity: ${map['quantity'] ?? 1}'),
                                        trailing: Text('RM ${price.toStringAsFixed(2)}'),
                                      );
                                    }),
                                    const Divider(),
                                    Text('Total: RM ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('Payment status: $payment'),
                                    Text('Order status: $orderStatus'),
                                    if (data['containsPhysical'] == true) ...[
                                      Text('Shipping status: ${(data['shippingStatus'] ?? 'Pending Dispatch').toString()}'),
                                      Text('Shipping address: ${(data['shippingAddress'] ?? '').toString()}'),
                                    ],
                                  ],
                                ))),
                                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
                              ),
                            ),
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('View details'),
                          ),
                        ]),
                      ]),
                    ),
                  );
                }).toList());
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        SiteFooter(),
      ]),
    );
  }
}

// -------------------- MY DIGITAL PRODUCTS --------------------
// Demo digital-product library. For successful demo orders, users can generate
// a sample PDF locally without Firebase Storage. These are demonstration files,
// not official MT Alchemy product assets or proof of real payment.

class MyDigitalProductsPage extends StatelessWidget {
  final VoidCallback onShop;
  const MyDigitalProductsPage({super.key, required this.onShop});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Please sign in to view your digital products.'),
      ));
    }

    final ordersRef = FirebaseFirestore.instance
        .collection('users').doc(user.uid).collection('orders');

    return SingleChildScrollView(
      child: Column(children: [
        PageBanner(
          title: 'My Digital Products',
          subtitle: 'Resources associated with successful demo orders.',
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ordersRef.where('paymentStatus', isEqualTo: 'Successful').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Card(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Could not load purchased products. Please check your Firestore rules.'),
                  ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(35),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final productsByTitle = <String, Map<String, dynamic>>{};
                for (final doc in snapshot.data?.docs ?? []) {
                  final items = doc.data()['items'];
                  if (items is List) {
                    for (final item in items) {
                      if (item is Map) {
                        final title = (item['title'] ?? 'Digital product').toString();
                        productsByTitle.putIfAbsent(title, () => {
                          'title': title,
                          'description': (item['description'] ?? '').toString(),
                          'orderId': doc.id,
                        });
                      }
                    }
                  }
                }
                if (productsByTitle.isEmpty) {
                  return Card(color: Colors.white, child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(children: [
                      const Icon(Icons.download_for_offline_outlined, size: 58, color: purple),
                      const SizedBox(height: 12),
                      const Text('No eligible digital products yet', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: navy)),
                      const SizedBox(height: 8),
                      const Text('Products appear here after a demo order has a Successful payment status.'),
                      const SizedBox(height: 18),
                      FilledButton(onPressed: onShop, child: const Text('Browse Digital Store')),
                    ]),
                  ));
                }
                return Column(children: productsByTitle.values.map((product) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFF4E9CC), child: Icon(Icons.menu_book_outlined, color: purple)),
                    title: Text(product['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
                    subtitle: Text((product['description'] as String).isEmpty
                        ? 'Order ${product['orderId']}'
                        : '${product['description']}\nOrder ${product['orderId']}'),
                    isThreeLine: true,
                    trailing: FilledButton.icon(
                      onPressed: () async {
                        try {
                          await _downloadDigitalProductSample(
                            title: product['title'] as String,
                            description: product['description'] as String,
                          );
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not create sample PDF: $error')),
                          );
                        }
                      },
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Download sample'),
                    ),
                  ),
                )).toList());
              },
            ),
          ),
        ),
        SiteFooter(),
      ]),
    );
  }
}

// Generates a demonstration PDF for a product in a successful demo order.
// On Flutter Web, Printing.layoutPdf opens the browser print/save workflow.
Future<void> _downloadDigitalProductSample({
  required String title,
  required String description,
}) async {
  final document = pw.Document();
  const darkNavy = PdfColor.fromInt(0xFF142B55);
  const accentPurple = PdfColor.fromInt(0xFF7555B7);
  const gold = PdfColor.fromInt(0xFFFFD66B);

  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 16),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: gold, width: 3)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MT ALCHEMY', style: pw.TextStyle(
                color: accentPurple, fontSize: 13, fontWeight: pw.FontWeight.bold,
              )),
              pw.SizedBox(height: 14),
              pw.Text(title, style: pw.TextStyle(
                color: darkNavy, fontSize: 25, fontWeight: pw.FontWeight.bold,
              )),
              if (description.trim().isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(description, style: const pw.TextStyle(fontSize: 11)),
              ],
            ],
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Text('Digital product sample', style: pw.TextStyle(
          color: darkNavy, fontSize: 16, fontWeight: pw.FontWeight.bold,
        )),
        pw.SizedBox(height: 8),
        pw.Text(
          'This sample PDF demonstrates the MT Alchemy digital download flow. '
              'It is a generated prototype document, not the official purchased product.',
          style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Reflection activity', style: pw.TextStyle(
          color: accentPurple, fontSize: 14, fontWeight: pw.FontWeight.bold,
        )),
        pw.SizedBox(height: 8),
        pw.Text('1. What is one skill or behaviour you would like to strengthen?',
            style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 10),
        pw.Container(height: 36, decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
        )),
        pw.SizedBox(height: 12),
        pw.Text('2. What is one small action you can practise this week?',
            style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 10),
        pw.Container(height: 36, decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400)),
        )),
        pw.SizedBox(height: 24),
        pw.Text('MT Alchemy - Learn - Grow - Transform', style: const pw.TextStyle(
          color: PdfColors.grey700, fontSize: 9,
        )),
      ],
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => document.save(),
    name: '${title.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')}_sample.pdf',
  );
}

// -------------------- DEMO PAYMENT --------------------

class DemoPaymentPage extends StatefulWidget {
  final String? orderId;
  final ValueChanged<String> onFinished;

  const DemoPaymentPage({
    super.key,
    required this.orderId,
    required this.onFinished,
  });

  @override
  State<DemoPaymentPage> createState() => _DemoPaymentPageState();
}

class _DemoPaymentPageState extends State<DemoPaymentPage> {
  bool _processing = false;

  Future<void> _setDemoStatus(String status) async {
    final user = FirebaseAuth.instance.currentUser;
    final orderId = widget.orderId;
    if (user == null || orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order not found. Please create an order first.')),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final orderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId);

      final orderSnapshot = await orderRef.get();
      if (!orderSnapshot.exists) {
        throw Exception('This order could not be found.');
      }
      final order = orderSnapshot.data() ?? <String, dynamic>{};
      if (order['paymentStatus'] != 'Pending') {
        throw Exception('This order already has a payment result.');
      }

      final hasPhysical = order['containsPhysical'] == true;
      final orderStatus = status == 'Successful'
          ? (hasPhysical ? 'Processing' : 'Processing (Demo)')
          : status == 'Failed'
          ? 'Payment Failed'
          : 'Awaiting Payment';

      await orderRef.update({
        'paymentStatus': status,
        'orderStatus': orderStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      widget.onFinished(status);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'Firestore denied the payment update. Add the demo payment update rule.'
              : 'Could not update demo payment: ${e.message ?? e.code}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageBanner(
                title: 'Demo Payment',
                subtitle: 'Choose a simulated result to test the checkout workflow.',
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.payment_outlined, size: 58, color: purple),
                      const SizedBox(height: 12),
                      const Text(
                        'Coursework demo only',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No real payment method is used and no money will be charged. Select a result below to test how the order status changes.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      Text('Order ID: ${widget.orderId ?? 'Not available'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: _processing ? null : () => _setDemoStatus('Successful'),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Simulate Successful Payment'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _processing ? null : () => _setDemoStatus('Failed'),
                        icon: const Icon(Icons.error_outline, color: Colors.red),
                        label: const Text('Simulate Failed Payment'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _processing ? null : () => _setDemoStatus('Pending'),
                        icon: const Icon(Icons.hourglass_empty),
                        label: const Text('Keep Payment Pending'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                      ),
                      if (_processing) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                      const SizedBox(height: 16),
                      const Text(
                        'Important: a successful result here is only a simulation for coursework. It is not proof of a real payment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderConfirmationPage extends StatelessWidget {
  final VoidCallback onDone;
  const OrderConfirmationPage({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 72),
                const SizedBox(height: 16),
                const Text('Order Created Successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 12),
                const Text(
                  'Your order has been saved. Payment is still pending because this is a demo checkout. You can now continue to the next step: demo payment and order history.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: onDone,
                  child: const Text('Return to Store'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- LOGIN PAGE --------------------


// -------------------- LOGIN PAGE --------------------

class LoginPage extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onLoginSuccess;

  const LoginPage({
    super.key,
    required this.onRegister,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;
  String selectedRole = 'Individual';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      final signedInUser = credential.user;
      if (signedInUser != null) {
        final profile = await FirebaseFirestore.instance
            .collection('users')
            .doc(signedInUser.uid)
            .get();
        final status = (profile.data()?['status'] ?? 'Active').toString();
        if (status == 'Suspended') {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This account is suspended. Please contact the administrator.'),
            ),
          );
          return;
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login Success: Welcome ${credential.user?.email ?? ''}',
          ),
        ),
      );
      widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          message = 'Invalid email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Sign-in failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E0CF)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.lock_person_outlined,
                  size: 55,
                  color: purple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue your learning journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 28),
                const Text('Account type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Individual'),
                    ),
                    DropdownMenuItem(
                      value: 'Employer',
                      child: Text('Employer'),
                    ),
                    DropdownMenuItem(
                      value: 'Trainer',
                      child: Text('Trainer'),
                    ),
                    DropdownMenuItem(
                      value: 'Super Admin',
                      child: Text('Super Admin'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Sign In'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: widget.onRegister,
                      child: const Text('Create account'),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Sign in securely with your MT Alchemy account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// -------------------- ROLE DASHBOARDS --------------------

class RoleDashboardPage extends StatefulWidget {
  final String role;
  final VoidCallback? onManageProducts;
  const RoleDashboardPage({super.key, required this.role, this.onManageProducts});

  @override
  State<RoleDashboardPage> createState() => _RoleDashboardPageState();
}

class _RoleDashboardPageState extends State<RoleDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isUpdatingRole = false;
  bool _isUpdatingStatus = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _changeUserRole(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      String newRole,
      ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || doc.id == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot change your own role here.')),
      );
      return;
    }

    final data = doc.data();
    final oldRole = (data['role'] ?? 'Unassigned').toString();
    if (oldRole == newRole) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change account role?'),
        content: Text(
          'Change ${(data['name'] ?? data['email'] ?? 'this user').toString()} '
              'from $oldRole to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm change'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isUpdatingRole = true);
    try {
      await doc.reference.update({'role': newRole});
      await writeActivityLog(
        action: 'Role changed',
        targetUid: doc.id,
        targetName: (data['name'] ?? 'Name not provided').toString(),
        targetEmail: (data['email'] ?? '').toString(),
        oldValue: oldRole,
        newValue: newRole,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User role updated successfully.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. Update your Firestore rules for Super Admin role changes.'
                : 'Could not update this role. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update this role. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingRole = false);
    }
  }

  Future<void> _changeUserStatus(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      String newStatus,
      ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || doc.id == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot suspend or reactivate your own account here.')),
      );
      return;
    }

    final data = doc.data();
    final oldStatus = (data['status'] ?? 'Active').toString();
    if (oldStatus == newStatus) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(newStatus == 'Suspended' ? 'Suspend account?' : 'Reactivate account?'),
        content: Text(
          '${(data['name'] ?? data['email'] ?? 'This user').toString()} will be marked $newStatus. '
              'A suspended account will be blocked at the next sign-in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(newStatus == 'Suspended' ? 'Suspend' : 'Reactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _isUpdatingStatus = true);
    try {
      await doc.reference.update({'status': newStatus});
      await writeActivityLog(
        action: newStatus == 'Suspended' ? 'Account suspended' : 'Account reactivated',
        targetUid: doc.id,
        targetName: (data['name'] ?? 'Name not provided').toString(),
        targetEmail: (data['email'] ?? '').toString(),
        oldValue: oldStatus,
        newValue: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User account marked $newStatus.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'Permission denied. Update your Firestore rules to allow Super Admin status changes.'
              : 'Could not update account status. Please try again.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update account status. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final isAdmin = role == 'Super Admin';
    final user = FirebaseAuth.instance.currentUser;
    final title = isAdmin ? 'Super Admin Dashboard' : '$role Dashboard';
    const allowedRoles = ['Individual', 'Employer', 'Trainer', 'Employee', 'Super Admin'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [navy, blue, purple]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 650,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome, ${user?.displayName?.isNotEmpty == true ? user!.displayName : (user?.email ?? role)}!',
                            style: const TextStyle(
                              color: yellow,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAdmin
                                ? 'Manage registered users, search accounts, and maintain account roles.'
                                : 'Access your MT Alchemy ${role.toLowerCase()} workspace.',
                            style: const TextStyle(color: Colors.white70, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: yellow,
                      size: 64,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                isAdmin ? 'User Management' : 'Your workspace',
                style: const TextStyle(
                  fontSize: 24,
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAdmin
                    ? 'Live account profiles from Firestore. Search by name or email and change a user’s role.'
                    : _roleDescription(role),
                style: const TextStyle(color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 18),
              if (isAdmin) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: widget.onManageProducts,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('Manage Products'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchText = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or role',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isEmpty
                        ? null
                        : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8E0CF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8E0CF)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Could not load users. Check your Firestore security rules and internet connection.'),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final allDocs = snapshot.data?.docs ?? [];
                    final filteredDocs = allDocs.where((doc) {
                      final data = doc.data();
                      final searchable = [
                        data['name'] ?? '',
                        data['email'] ?? '',
                        data['role'] ?? '',
                        data['status'] ?? 'Active',
                      ].join(' ').toLowerCase();
                      return searchable.contains(_searchText);
                    }).toList();

                    final counts = <String, int>{};
                    var activeCount = 0;
                    var suspendedCount = 0;
                    for (final doc in allDocs) {
                      final data = doc.data();
                      final userRole = (data['role'] ?? 'Unassigned').toString();
                      final status = (data['status'] ?? 'Active').toString();
                      counts[userRole] = (counts[userRole] ?? 0) + 1;
                      if (status == 'Suspended') {
                        suspendedCount++;
                      } else {
                        activeCount++;
                      }
                    }
                    final recentDocs = [...allDocs]
                      ..sort((a, b) {
                        final aDate = a.data()['createdAt'];
                        final bDate = b.data()['createdAt'];
                        final aMillis = aDate is Timestamp ? aDate.millisecondsSinceEpoch : 0;
                        final bMillis = bDate is Timestamp ? bDate.millisecondsSinceEpoch : 0;
                        return bMillis.compareTo(aMillis);
                      });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _AdminStatCard(
                              label: 'Total profiles',
                              value: '${allDocs.length}',
                              icon: Icons.people_alt_outlined,
                            ),
                            _AdminStatCard(
                              label: 'Active accounts',
                              value: '$activeCount',
                              icon: Icons.verified_user_outlined,
                            ),
                            _AdminStatCard(
                              label: 'Suspended accounts',
                              value: '$suspendedCount',
                              icon: Icons.block_outlined,
                            ),
                            _AdminStatCard(
                              label: 'Super Admins',
                              value: "${counts['Super Admin'] ?? 0}",
                              icon: Icons.admin_panel_settings_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _AdminAnalyticsPanel(
                          totalUsers: allDocs.length,
                          roleCounts: counts,
                          recentDocs: recentDocs.take(5).toList(),
                        ),
                        const SizedBox(height: 20),
                        if (filteredDocs.isEmpty)
                          Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                allDocs.isEmpty
                                    ? 'No user profiles found yet.'
                                    : 'No users match “${_searchController.text}”.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          Card(
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Showing ${filteredDocs.length} of ${allDocs.length} users',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                for (final doc in filteredDocs)
                                  _AdminUserRow(
                                    doc: doc,
                                    currentUserId: user?.uid,
                                    allowedRoles: allowedRoles,
                                    isUpdating: _isUpdatingRole,
                                    isUpdatingStatus: _isUpdatingStatus,
                                    onRoleChanged: (newRole) => _changeUserRole(doc, newRole),
                                    onStatusChanged: (newStatus) => _changeUserStatus(doc, newStatus),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _ActivityLogPanel(),
                const SizedBox(height: 24),
                const _AdminCoachingRequestsPanel(),
                const SizedBox(height: 24),
                const _AdminCorporateEnquiriesPanel(),
                if (_isUpdatingRole || _isUpdatingStatus) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
              ] else if (role == 'Individual')
                IndividualLearningDashboard(userId: user?.uid)
              else if (role == 'Employer')
                  EmployerWorkspaceDashboard(user: user)
                else if (role == 'Employee')
                    EmployeeLearningDashboard(userId: user?.uid)
                  else
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _DashboardTile(
                          icon: Icons.school_outlined,
                          title: role == 'Trainer' ? 'Training programmes' : 'Learning Hub',
                          description: role == 'Trainer' ? 'Your training-management area.' : 'Explore learning content.',
                        ),
                        _DashboardTile(
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          description: 'Signed in as ${user?.email ?? 'your account'}.',
                        ),
                        if (role == 'Employer')
                          const _DashboardTile(
                            icon: Icons.groups_outlined,
                            title: 'Team Training',
                            description: 'Your organisation training area.',
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  static String _roleDescription(String role) {
    switch (role) {
      case 'Individual':
        return 'Continue your learning journey and manage your profile.';
      case 'Employer':
        return 'Explore team learning and corporate training features.';
      case 'Employee':
        return 'Access courses assigned by your organisation and track your learning.';
      case 'Trainer':
        return 'Manage your training workspace and learning programmes.';
      default:
        return 'Your MT Alchemy workspace.';
    }
  }
}



// -------------------- CORPORATE COURSE ASSIGNMENT --------------------

class CorporateCourseAssignmentPanel extends StatefulWidget {
  final User? user;
  const CorporateCourseAssignmentPanel({super.key, required this.user});

  @override
  State<CorporateCourseAssignmentPanel> createState() =>
      _CorporateCourseAssignmentPanelState();
}

class _CorporateCourseAssignmentPanelState
    extends State<CorporateCourseAssignmentPanel> {
  String? _selectedCourseId;
  DateTime? _deadline;
  final Set<String> _selectedEmployees = {};
  bool _isAssigning = false;

  String _courseId(Course course) => course.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Future<void> _pickDeadline() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? today.add(const Duration(days: 14)),
      firstDate: today,
      lastDate: DateTime(today.year + 3),
    );
    if (picked != null && mounted) setState(() => _deadline = picked);
  }

  Future<void> _assignCourse(List<QueryDocumentSnapshot<Map<String, dynamic>>> employees) async {
    final employer = widget.user;
    final course = courses.where((c) => _courseId(c) == _selectedCourseId).firstOrNull;
    if (employer == null || course == null || _selectedEmployees.isEmpty || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a course, at least one employee, and a deadline.')),
      );
      return;
    }

    setState(() => _isAssigning = true);
    try {
      final batch = FirebaseFirestore.instance.batch();
      final courseId = _courseId(course);
      final deadline = Timestamp.fromDate(DateTime(_deadline!.year, _deadline!.month, _deadline!.day, 23, 59, 59));
      for (final employee in employees.where((e) => _selectedEmployees.contains(e.id))) {
        final data = employee.data();
        final ref = FirebaseFirestore.instance.collection('corporate_course_assignments').doc();
        batch.set(ref, {
          'assignmentId': ref.id,
          'courseId': courseId,
          'courseTitle': course.title,
          'category': course.category,
          'description': course.description,
          'employeeUid': employee.id,
          'employeeName': (data['name'] ?? 'Employee').toString(),
          'employeeEmail': (data['email'] ?? '').toString(),
          'department': (data['department'] ?? '').toString(),
          'employerUid': employer.uid,
          'employerEmail': employer.email ?? '',
          'status': 'Assigned',
          'progress': 0,
          'deadline': deadline,
          'assignedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      if (!mounted) return;
      setState(() => _selectedEmployees.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedEmployees.length == 0 ? 'Course' : 'Course'} assigned successfully to selected employees.')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'permission-denied'
            ? 'Permission denied. Publish the corporate course assignment Firestore rules first.'
            : 'Could not assign the course (${e.code}).'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not assign the course. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  String _dateLabel(Timestamp? timestamp) {
    if (timestamp == null) return 'No deadline';
    final d = timestamp.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final employer = widget.user;
    if (employer == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9DFC9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Corporate Course Assignment', style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Choose a programme, select employees, set a deadline and assign the course to your team.', style: TextStyle(color: Colors.black54, height: 1.5)),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: _selectedCourseId,
          decoration: const InputDecoration(labelText: 'Select course', border: OutlineInputBorder(), prefixIcon: Icon(Icons.school_outlined)),
          items: courses.map((course) => DropdownMenuItem(value: _courseId(course), child: Text(course.title))).toList(),
          onChanged: (value) => setState(() => _selectedCourseId = value),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _pickDeadline,
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(_deadline == null ? 'Choose assignment deadline' : 'Deadline: ${_dateLabel(Timestamp.fromDate(_deadline!))}'),
        ),
        const SizedBox(height: 18),
        const Text('Select employees', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').where('employerUid', isEqualTo: employer.uid).where('role', isEqualTo: 'Employee').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Could not load employees. Check the employee profile read rules.');
            if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            final employees = snapshot.data?.docs ?? [];
            if (employees.isEmpty) return const Text('No active employees yet. Invite employees and ask them to register first.');
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Align(alignment: Alignment.centerLeft, child: Text('${_selectedEmployees.length} selected', style: const TextStyle(color: purple, fontWeight: FontWeight.w600))),
              ...employees.map((employee) {
                final data = employee.data();
                return CheckboxListTile(
                  value: _selectedEmployees.contains(employee.id),
                  onChanged: (checked) => setState(() { if (checked == true) { _selectedEmployees.add(employee.id); } else { _selectedEmployees.remove(employee.id); } }),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text((data['name'] ?? 'Employee').toString()),
                  subtitle: Text('${data['email'] ?? ''} • ${data['department'] ?? 'Department not set'}'),
                );
              }),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerLeft, child: FilledButton.icon(
                onPressed: _isAssigning ? null : () => _assignCourse(employees),
                icon: _isAssigning ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.assignment_turned_in_outlined),
                label: Text(_isAssigning ? 'Assigning...' : 'Assign Course'),
              )),
            ]);
          },
        ),
        const Divider(height: 32),
        const Text('Assignment history', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('corporate_course_assignments').where('employerUid', isEqualTo: employer.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Could not load assignment history. Check Firestore rules.');
            if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return const Text('No courses assigned yet.');
            return Column(children: docs.map((doc) {
              final data = doc.data();
              final progress = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Color(0xFFF2E8CC), child: Icon(Icons.menu_book_outlined, color: purple)),
                title: Text((data['courseTitle'] ?? 'Course').toString()),
                subtitle: Text('${data['employeeName'] ?? 'Employee'} • Due ${_dateLabel(data['deadline'] as Timestamp?)} • $progress%'),
                trailing: Chip(label: Text((data['status'] ?? 'Assigned').toString())),
              );
            }).toList());
          },
        ),
      ]),
    );
  }
}

// -------------------- EMPLOYER WORKSPACE --------------------

class EmployerWorkspaceDashboard extends StatefulWidget {
  final User? user;

  const EmployerWorkspaceDashboard({super.key, required this.user});

  @override
  State<EmployerWorkspaceDashboard> createState() =>
      _EmployerWorkspaceDashboardState();
}

class _EmployerWorkspaceDashboardState
    extends State<EmployerWorkspaceDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organisationController = TextEditingController();
  final _messageController = TextEditingController();

  String _enquiryType = 'Corporate Training';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user?.displayName ?? '';
    _emailController.text = widget.user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organisationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitTrainingRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('enquiries').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'organization': _organisationController.text.trim(),
        'enquiryType': _enquiryType,
        'message': _messageController.text.trim(),
        'status': 'New',
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'Website Contact Form',
      });

      if (!mounted) return;
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corporate training request submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Permission denied. Please check the Firestore enquiries rules.'
                : 'Could not submit your request. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: purple),
      filled: true,
      fillColor: const Color(0xFFFAF8F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE8E0CF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE8E0CF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: yellow, width: 1.6),
      ),
    );
  }

  Widget _workspaceCard({
    required IconData icon,
    required String title,
    required String description,
    required String tag,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9DFC9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0E5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: purple, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                color: purple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user?.displayName?.trim().isNotEmpty == true
        ? widget.user!.displayName!.trim()
        : (widget.user?.email?.split('@').first ?? 'Employer');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF151515), Color(0xFF30291C), Color(0xFF806126)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 18,
                  children: [
                    SizedBox(
                      width: 690,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EMPLOYER WORKSPACE',
                            style: TextStyle(
                              color: yellow,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Develop your people. Strengthen your organisation.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome, $userName. Plan learning and development opportunities for your team with MT Alchemy.',
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.business_center_rounded,
                      color: yellow,
                      size: 66,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Your corporate workspace',
                style: TextStyle(
                  color: navy,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Explore the key areas for managing your organisation’s learning needs.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 18),
              EmployeeManagementPanel(user: widget.user),
              const SizedBox(height: 24),
              CorporateCourseAssignmentPanel(user: widget.user),
              const SizedBox(height: 24),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _workspaceCard(
                    icon: Icons.groups_2_outlined,
                    title: 'Team Training',
                    description:
                    'Identify skills your employees want to develop and plan suitable learning programmes.',
                    tag: 'TEAM DEVELOPMENT',
                  ),
                  _workspaceCard(
                    icon: Icons.school_outlined,
                    title: 'Training Programmes',
                    description:
                    'Explore leadership, communication and professional development options.',
                    tag: 'LEARNING & DEVELOPMENT',
                  ),
                  _workspaceCard(
                    icon: Icons.insights_outlined,
                    title: 'Training Progress',
                    description:
                    'Use this workspace to discuss employee learning goals and future progress reporting.',
                    tag: 'PROGRESS PLANNING',
                  ),
                  _workspaceCard(
                    icon: Icons.apartment_outlined,
                    title: 'Company Profile',
                    description:
                    'Your account is currently signed in with the employer email shown below.',
                    tag: 'ACCOUNT DETAILS',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9DFC9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Corporate Training Request',
                      style: TextStyle(
                        color: navy,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tell the MT Alchemy team what your organisation needs. We will use these details to follow up.',
                      style: TextStyle(color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final fieldWidth = constraints.maxWidth > 650
                              ? (constraints.maxWidth - 14) / 2
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: _fieldDecoration(
                                    'Contact name',
                                    Icons.person_outline,
                                  ),
                                  validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter your name'
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _fieldDecoration(
                                    'Email address',
                                    Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(email)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _fieldDecoration(
                                    'Phone number',
                                    Icons.phone_outlined,
                                  ),
                                  validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter your phone number'
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: TextFormField(
                                  controller: _organisationController,
                                  decoration: _fieldDecoration(
                                    'Organisation',
                                    Icons.apartment_outlined,
                                  ),
                                  validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter your organisation'
                                      : null,
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _enquiryType,
                                  decoration: _fieldDecoration(
                                    'Training requirement',
                                    Icons.school_outlined,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Corporate Training',
                                      child: Text('Corporate Training'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Leadership Development',
                                      child: Text('Leadership Development'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Team Development',
                                      child: Text('Team Development'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _enquiryType = value);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth,
                                child: TextFormField(
                                  controller: _messageController,
                                  maxLines: 4,
                                  decoration: _fieldDecoration(
                                    'Tell us about your team’s training needs',
                                    Icons.message_outlined,
                                  ),
                                  validator: (value) =>
                                  value == null || value.trim().length < 10
                                      ? 'Please enter at least 10 characters'
                                      : null,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed:
                      _isSubmitting ? null : _submitTrainingRequest,
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 17,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        _isSubmitting
                            ? 'Submitting...'
                            : 'Submit Training Request',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2E8CC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Invite employees using their work email. They must create their own password and register with the invited email address before appearing as an active team member.',
                        style: TextStyle(
                          color: navy.withValues(alpha: .82),
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// -------------------- EMPLOYER EMPLOYEE MANAGEMENT --------------------

class EmployeeManagementPanel extends StatefulWidget {
  final User? user;

  const EmployeeManagementPanel({super.key, required this.user});

  @override
  State<EmployeeManagementPanel> createState() => _EmployeeManagementPanelState();
}

class _EmployeeManagementPanelState extends State<EmployeeManagementPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _organizationController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _organizationController.text = 'MT Alchemy Employer Team';
    _loadEmployerName();
  }

  Future<void> _loadEmployerName() async {
    final uid = widget.user?.uid;
    if (uid == null) return;
    try {
      final profile = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = (profile.data()?['organizationName'] ?? profile.data()?['name'] ?? '').toString();
      if (mounted && name.isNotEmpty && _organizationController.text == 'MT Alchemy Employer Team') {
        setState(() => _organizationController.text = name);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;
    final employer = widget.user;
    if (employer == null) return;

    final email = _emailController.text.trim().toLowerCase();
    if (email == (employer.email ?? '').toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot invite your own employer email.')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final invitationRef = FirebaseFirestore.instance.collection('employee_invitations').doc(email);
      // Query only this employer's invitations. A direct get() on a missing
      // document is denied by rules that protect invitations belonging to others.
      final existingInvitations = await FirebaseFirestore.instance
          .collection('employee_invitations')
          .where('emailLower', isEqualTo: email)
          .where('employerUid', isEqualTo: employer.uid)
          .limit(1)
          .get();
      if (existingInvitations.docs.isNotEmpty) {
        if (!mounted) return;
        final existingStatus = (existingInvitations.docs.first.data()['status'] ?? 'Pending').toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingStatus == 'Accepted'
                ? 'This email is already linked to an employee account.'
                : 'An invitation for this email already exists.'),
          ),
        );
        return;
      }
      await invitationRef.set({
        'invitationId': invitationRef.id,
        'invitedName': _nameController.text.trim(),
        'email': email,
        'emailLower': email,
        'phone': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        'organizationName': _organizationController.text.trim(),
        'employerUid': employer.uid,
        'employerEmail': employer.email ?? '',
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _departmentController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation created. Ask the employee to register using this exact email address.'),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'Permission denied. Publish the employee invitation Firestore rules first.'
              : 'Could not create invitation (${e.code}).'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the invitation. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employer = widget.user;
    if (employer == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9DFC9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Employee Management',
              style: TextStyle(color: navy, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'Invite employees to join your organisation. Employees create and manage their own passwords.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth > 650
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                Widget field(TextEditingController controller, String label,
                    IconData icon, {TextInputType keyboardType = TextInputType.text}) {
                  return SizedBox(
                    width: width,
                    child: TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        labelText: label,
                        prefixIcon: Icon(icon, color: purple),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter $label'
                          : null,
                    ),
                  );
                }

                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    field(_nameController, 'Employee name', Icons.person_outline),
                    field(_emailController, 'Employee email', Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    field(_phoneController, 'Phone number', Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    field(_departmentController, 'Department', Icons.business_outlined),
                    field(_organizationController, 'Organisation name', Icons.apartment_outlined),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _isSending ? null : _sendInvitation,
              icon: _isSending
                  ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.mail_outline),
              label: Text(_isSending ? 'Creating invitation...' : 'Create Employee Invitation'),
            ),
          ),
          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Invitations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('employee_invitations')
                .where('employerUid', isEqualTo: employer.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load invitations. Check Firestore rules.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return const Text('No employee invitations yet.');
              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  final status = (data['status'] ?? 'Pending').toString();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFF2E8CC),
                      child: const Icon(Icons.person_outline, color: purple),
                    ),
                    title: Text((data['invitedName'] ?? 'Employee').toString()),
                    subtitle: Text(
                      '${data['email'] ?? ''} • ${data['department'] ?? 'Department not set'}',
                    ),
                    trailing: Chip(
                      label: Text(status),
                      backgroundColor: status == 'Accepted'
                          ? const Color(0xFFE2F3E7)
                          : const Color(0xFFFFF2D6),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Active team members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('employerUid', isEqualTo: employer.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load team members. Check employee profile read rules.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return const Text('Employees will appear here after accepting an invitation.');
              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8E3D7),
                      child: Icon(Icons.badge_outlined, color: navy),
                    ),
                    title: Text((data['name'] ?? 'Employee').toString()),
                    subtitle: Text(
                      '${data['email'] ?? ''} • ${data['department'] ?? 'Department not set'}',
                    ),
                    trailing: const Chip(
                      label: Text('Active'),
                      backgroundColor: Color(0xFFE2F3E7),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminCorporateEnquiriesPanel extends StatelessWidget {
  const _AdminCorporateEnquiriesPanel();

  String _dateLabel(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate().toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return 'Date not available';
  }

  Future<void> _changeStatus(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      String status,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await doc.reference.update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': user?.uid ?? '',
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Corporate enquiry marked "$status".')),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      final message = e.code == 'permission-denied'
          ? 'Permission denied. Update and publish the enquiries rules for Super Admin.'
          : 'Could not update this enquiry (${e.code}).';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update this enquiry. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Corporate Enquiries',
          style: TextStyle(fontSize: 24, color: navy, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'View organisation training requests and manage their follow-up status.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('enquiries').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Could not load corporate enquiries. Check that Super Admin has read permission for the enquiries collection. Details: ${snapshot.error}',
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final docs = [...?snapshot.data?.docs];
            docs.sort((a, b) {
              final aValue = a.data()['createdAt'];
              final bValue = b.data()['createdAt'];
              final aTime = aValue is Timestamp ? aValue.millisecondsSinceEpoch : 0;
              final bTime = bValue is Timestamp ? bValue.millisecondsSinceEpoch : 0;
              return bTime.compareTo(aTime);
            });

            if (docs.isEmpty) {
              return const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text('No corporate enquiries have been submitted yet.'),
                ),
              );
            }

            final newCount = docs.where((doc) => (doc.data()['status'] ?? 'New') == 'New').length;
            final progressCount = docs.where((doc) => doc.data()['status'] == 'In Progress').length;
            final completedCount = docs.where((doc) => doc.data()['status'] == 'Completed').length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AdminStatCard(label: 'Total enquiries', value: '${docs.length}', icon: Icons.business_center_outlined),
                    _AdminStatCard(label: 'New', value: '$newCount', icon: Icons.mark_email_unread_outlined),
                    _AdminStatCard(label: 'In Progress', value: '$progressCount', icon: Icons.pending_actions_outlined),
                    _AdminStatCard(label: 'Completed', value: '$completedCount', icon: Icons.task_alt_outlined),
                  ],
                ),
                const SizedBox(height: 14),
                for (final doc in docs)
                  _AdminCorporateEnquiryCard(
                    data: doc.data(),
                    dateLabel: _dateLabel(doc.data()['createdAt']),
                    onStatusChanged: (status) => _changeStatus(context, doc, status),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminCorporateEnquiryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String dateLabel;
  final ValueChanged<String> onStatusChanged;

  const _AdminCorporateEnquiryCard({
    required this.data,
    required this.dateLabel,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'New').toString();
    final statusColor = status == 'Completed'
        ? Colors.green
        : status == 'In Progress'
        ? Colors.blue
        : purple;

    Widget detail(IconData icon, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: purple),
            const SizedBox(width: 8),
            Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
          ],
        ),
      );
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8D9B8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  (data['organization'] ?? 'Organisation not provided').toString(),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: navy),
                ),
                Chip(
                  label: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                  backgroundColor: statusColor.withValues(alpha: .10),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 10),
            detail(Icons.person_outline, (data['name'] ?? 'Name not provided').toString()),
            detail(Icons.email_outlined, (data['email'] ?? 'No email').toString()),
            detail(Icons.phone_outlined, (data['phone'] ?? 'No phone number').toString()),
            detail(Icons.school_outlined, (data['enquiryType'] ?? 'Training type not specified').toString()),
            detail(Icons.calendar_today_outlined, 'Submitted: $dateLabel'),
            const SizedBox(height: 6),
            const Text('Training requirements', style: TextStyle(fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 4),
            Text((data['message'] ?? 'No message provided').toString(), style: const TextStyle(color: Colors.black87, height: 1.45)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: status == 'In Progress' ? null : () => onStatusChanged('In Progress'),
                  icon: const Icon(Icons.pending_actions_outlined),
                  label: const Text('In Progress'),
                ),
                OutlinedButton.icon(
                  onPressed: status == 'Completed' ? null : () => onStatusChanged('Completed'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Completed'),
                ),
                TextButton.icon(
                  onPressed: status == 'New' ? null : () => onStatusChanged('New'),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Mark New'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _AdminCoachingRequestsPanel extends StatelessWidget {
  const _AdminCoachingRequestsPanel();

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return 'Not provided';
  }

  Future<void> _updateStatus(
      BuildContext context,
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      String status,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$status coaching request?'),
        content: Text('Update the request from ${(doc.data()['name'] ?? 'this learner').toString()} to $status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final user = FirebaseAuth.instance.currentUser;
    try {
      await doc.reference.update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': user?.uid ?? '',
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coaching request marked $status.')),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code == 'permission-denied'
              ? 'Permission denied. Publish the updated coaching request Firestore rules.'
              : 'Could not update request. Please try again.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Coaching & Mentorship Requests',
          style: TextStyle(fontSize: 24, color: navy, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review individual coaching requests and update their status.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collectionGroup('coaching_requests')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Could not load coaching requests. Check that the updated Firestore rules are published. Details: ${snapshot.error}',
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final docs = [...?snapshot.data?.docs];
            docs.sort((a, b) {
              final aValue = a.data()['createdAt'];
              final bValue = b.data()['createdAt'];
              final aTime = aValue is Timestamp ? aValue.millisecondsSinceEpoch : 0;
              final bTime = bValue is Timestamp ? bValue.millisecondsSinceEpoch : 0;
              return bTime.compareTo(aTime);
            });

            if (docs.isEmpty) {
              return const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Text('No coaching requests have been submitted yet.'),
                ),
              );
            }

            final pendingCount = docs.where((doc) => doc.data()['status'] == 'Pending').length;
            final approvedCount = docs.where((doc) => doc.data()['status'] == 'Approved').length;
            final rejectedCount = docs.where((doc) => doc.data()['status'] == 'Rejected').length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AdminStatCard(label: 'Total requests', value: '${docs.length}', icon: Icons.diversity_3_outlined),
                    _AdminStatCard(label: 'Pending', value: '$pendingCount', icon: Icons.hourglass_top_rounded),
                    _AdminStatCard(label: 'Approved', value: '$approvedCount', icon: Icons.check_circle_outline),
                    _AdminStatCard(label: 'Rejected', value: '$rejectedCount', icon: Icons.cancel_outlined),
                  ],
                ),
                const SizedBox(height: 14),
                for (final doc in docs)
                  _AdminCoachingRequestCard(
                    data: doc.data(),
                    dateLabel: _formatDate(doc.data()['preferredDate']),
                    onStatusChanged: (status) => _updateStatus(context, doc, status),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminCoachingRequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String dateLabel;
  final ValueChanged<String> onStatusChanged;

  const _AdminCoachingRequestCard({
    required this.data,
    required this.dateLabel,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'Pending').toString();
    final statusColor = status == 'Approved'
        ? Colors.green
        : status == 'Rejected'
        ? Colors.red
        : purple;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE8D9B8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  (data['name'] ?? 'Name not provided').toString(),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: navy),
                ),
                Chip(
                  label: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                  backgroundColor: statusColor.withValues(alpha: 0.10),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _detail(Icons.email_outlined, (data['email'] ?? 'No email').toString()),
            _detail(Icons.psychology_alt_outlined, (data['coachingType'] ?? 'Not specified').toString()),
            _detail(Icons.calendar_month_outlined, 'Preferred date: $dateLabel'),
            const SizedBox(height: 8),
            const Text('Learner message', style: TextStyle(fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 4),
            Text((data['message'] ?? 'No message provided').toString(), style: const TextStyle(color: Colors.black87, height: 1.45)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: status == 'Approved' ? null : () => onStatusChanged('Approved'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve'),
                ),
                OutlinedButton.icon(
                  onPressed: status == 'Rejected' ? null : () => onStatusChanged('Rejected'),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Reject'),
                ),
                TextButton.icon(
                  onPressed: status == 'Pending' ? null : () => onStatusChanged('Pending'),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Mark Pending'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: purple),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}

class _ActivityLogPanel extends StatelessWidget {
  const _ActivityLogPanel();

  String _timeLabel(dynamic value) {
    if (value is! Timestamp) return 'Just now';
    final date = value.toDate().toLocal();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} $hour:$minute';
  }

  IconData _iconFor(String action) {
    if (action == 'Registered') return Icons.person_add_alt_1_outlined;
    if (action == 'Role changed') return Icons.manage_accounts_outlined;
    if (action == 'Account suspended') return Icons.block_outlined;
    if (action == 'Account reactivated') return Icons.check_circle_outline;
    return Icons.history;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history_rounded, color: purple),
                SizedBox(width: 10),
                Expanded(child: Text('Activity Log', style: TextStyle(color: navy, fontSize: 19, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 5),
            const Text('Recent registrations and administrator account changes.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('activity_logs')
                  .orderBy('createdAt', descending: true)
                  .limit(15)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Could not load activity logs. Check the activity_logs Firestore rules.'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final logs = snapshot.data?.docs ?? [];
                if (logs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('No activity recorded yet. New registrations and admin changes will appear here.'),
                  );
                }
                return Column(
                  children: [
                    for (final doc in logs) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: purple.withValues(alpha: 0.10),
                          child: Icon(_iconFor((doc.data()['action'] ?? '').toString()), color: purple, size: 21),
                        ),
                        title: Text((doc.data()['action'] ?? 'Activity').toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${(doc.data()['targetName'] ?? doc.data()['targetEmail'] ?? 'User').toString()}'
                              '${doc.data()['oldValue'] != null ? ' • ${doc.data()['oldValue']} → ${doc.data()['newValue']}' : ''}\n'
                              'By ${(doc.data()['actorEmail'] ?? 'Unknown account').toString()}',
                        ),
                        trailing: SizedBox(
                          width: 112,
                          child: Text(_timeLabel(doc.data()['createdAt']), textAlign: TextAlign.end, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ),
                        isThreeLine: true,
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class _AdminAnalyticsPanel extends StatelessWidget {
  final int totalUsers;
  final Map<String, int> roleCounts;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> recentDocs;

  const _AdminAnalyticsPanel({
    required this.totalUsers,
    required this.roleCounts,
    required this.recentDocs,
  });

  @override
  Widget build(BuildContext context) {
    const roleDetails = <String, IconData>{
      'Individual': Icons.person_outline,
      'Employer': Icons.business_outlined,
      'Trainer': Icons.school_outlined,
      'Super Admin': Icons.admin_panel_settings_outlined,
    };
    final roleColors = <String, Color>{
      'Individual': navy,
      'Employer': blue,
      'Trainer': const Color(0xFF00A99D),
      'Super Admin': purple,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final roleChart = Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User distribution', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Registered profiles by account role', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                for (final role in roleDetails.keys) ...[
                  Row(
                    children: [
                      Icon(roleDetails[role], size: 19, color: roleColors[role]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(role, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Text('${roleCounts[role] ?? 0}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: totalUsers == 0 ? 0 : (roleCounts[role] ?? 0) / totalUsers,
                      backgroundColor: const Color(0xFFEEE8DA),
                      valueColor: AlwaysStoppedAnimation<Color>(roleColors[role]!),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );

        final recentPanel = Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent registrations', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Latest profiles based on their creation date', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                if (recentDocs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No registrations to display yet.'),
                  )
                else
                  for (final doc in recentDocs)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: purple.withValues(alpha: 0.10),
                        child: const Icon(Icons.person_outline, color: purple),
                      ),
                      title: Text((doc.data()['name'] ?? 'Name not provided').toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text((doc.data()['email'] ?? 'Email not provided').toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text((doc.data()['role'] ?? 'Unassigned').toString(), style: const TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
              ],
            ),
          ),
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: roleChart),
              const SizedBox(width: 16),
              Expanded(child: recentPanel),
            ],
          );
        }
        return Column(children: [roleChart, recentPanel]);
      },
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: purple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(value, style: const TextStyle(color: navy, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminUserRow extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final String? currentUserId;
  final List<String> allowedRoles;
  final bool isUpdating;
  final bool isUpdatingStatus;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onStatusChanged;

  const _AdminUserRow({
    required this.doc,
    required this.currentUserId,
    required this.allowedRoles,
    required this.isUpdating,
    required this.isUpdatingStatus,
    required this.onRoleChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();
    final name = (data['name'] ?? 'Name not provided').toString();
    final email = (data['email'] ?? 'Email not provided').toString();
    final role = (data['role'] ?? 'Unassigned').toString();
    final status = (data['status'] ?? 'Active').toString();
    final isCurrentUser = doc.id == currentUserId;
    final roleOptions = allowedRoles.contains(role)
        ? allowedRoles
        : [...allowedRoles, role];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: purple.withValues(alpha: 0.12),
                foregroundColor: purple,
                child: Text(
                  name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: Colors.black54)),
                    if (isCurrentUser)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Your account', style: TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Role: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: roleOptions.contains(role) ? role : 'Individual',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  items: roleOptions
                      .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
                      .toList(),
                  onChanged: isCurrentUser || isUpdating
                      ? null
                      : (newRole) {
                    if (newRole != null) onRoleChanged(newRole);
                  },
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 8),
                const Tooltip(
                  message: 'Your own role cannot be changed here.',
                  child: Icon(Icons.lock_outline, color: Colors.black45),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'Suspended' ? const Color(0xFFFFE7E7) : const Color(0xFFE4F6EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Suspended' ? Colors.red.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: isCurrentUser || isUpdatingStatus
                    ? null
                    : () => onStatusChanged(status == 'Suspended' ? 'Active' : 'Suspended'),
                icon: Icon(status == 'Suspended' ? Icons.check_circle_outline : Icons.block),
                label: Text(status == 'Suspended' ? 'Reactivate' : 'Suspend'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'User ID: ${doc.id}',
            style: const TextStyle(fontSize: 10, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class IndividualLearningDashboard extends StatelessWidget {
  final String? userId;
  const IndividualLearningDashboard({super.key, required this.userId});

  Future<void> _showCertificate(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) async {
    final data = doc.data() ?? <String, dynamic>{};
    final progress = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final passed = data['quizPassed'] == true;
    if (!passed || progress < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete the course and pass its quiz to earn a certificate.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final profileName = (user?.displayName ?? '').trim();
    final learnerName = profileName.isNotEmpty
        ? profileName
        : ((user?.email ?? 'Learner').split('@').first);
    final courseTitle = (data['title'] ?? 'Course').toString();
    final completedAt = data['lastQuizAt'];
    final date = completedAt is Timestamp ? completedAt.toDate() : DateTime.now();
    final dateText = '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
    final uidPart = (user?.uid ?? 'USER').replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final coursePart = doc.id.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    final certificateId = 'MTA-${uidPart.substring(0, uidPart.length > 6 ? 6 : uidPart.length)}-'
        '${coursePart.substring(0, coursePart.length > 8 ? 8 : coursePart.length)}';

    // Store the minimal details needed for public certificate verification.
    // In production, certificate issuance should be validated by trusted server code.
    try {
      final certificateRef = FirebaseFirestore.instance
          .collection('certificates')
          .doc(certificateId);
      final existingCertificate = await certificateRef.get();

      // Firestore rules make issued certificates immutable. Create the record
      // once; opening the same certificate again must not attempt an update.
      if (!existingCertificate.exists) {
        await certificateRef.set({
          'certificateId': certificateId,
          'learnerName': learnerName,
          'courseTitle': courseTitle,
          'dateAwarded': dateText,
          'userId': user!.uid,
          'courseId': doc.id,
          'valid': true,
          'awardedAt': FieldValue.serverTimestamp(),
        });
      } else if (existingCertificate.data()?['userId'] != user?.uid ||
          existingCertificate.data()?['courseId'] != doc.id) {
        throw StateError('Certificate ID is already associated with another record.');
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate preview is available, but verification details could not be saved. Check Firestore rules.')),
      );
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEFA),
              border: Border.all(color: yellow, width: 5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium_rounded, color: purple, size: 56),
                const SizedBox(height: 8),
                const Text('MT ALCHEMY', style: TextStyle(color: navy, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 12),
                const Text('CERTIFICATE OF COMPLETION', textAlign: TextAlign.center, style: TextStyle(color: navy, fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                const Text('This certificate is proudly presented to', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 8),
                Text(learnerName, textAlign: TextAlign.center, style: const TextStyle(color: purple, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('for successfully completing the course', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(courseTitle, textAlign: TextAlign.center, style: const TextStyle(color: navy, fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified_rounded, color: Colors.green, size: 20), SizedBox(width: 6), Text('Course completed and quiz passed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
                const SizedBox(height: 20),
                Text('Date awarded: $dateText', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                SelectableText('Certificate ID: $certificateId', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 22),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _downloadCertificatePdf(
                        context: context,
                        learnerName: learnerName,
                        courseTitle: courseTitle,
                        dateText: dateText,
                        certificateId: certificateId,
                      ),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Download PDF'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close certificate'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _downloadCertificatePdf({
    required BuildContext context,
    required String learnerName,
    required String courseTitle,
    required String dateText,
    required String certificateId,
  }) async {
    final document = pw.Document();
    const darkNavy = PdfColor.fromInt(0xFF142B55);
    const accentPurple = PdfColor.fromInt(0xFF7555B7);
    const gold = PdfColor.fromInt(0xFFFFD66B);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pageContext) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: gold, width: 5),
          ),
          padding: const pw.EdgeInsets.all(30),
          child: pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'MT ALCHEMY',
                  style: pw.TextStyle(
                    color: accentPurple,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  'CERTIFICATE OF COMPLETION',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: darkNavy,
                    fontSize: 27,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 22),
                pw.Text(
                  'This certificate is proudly presented to',
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  learnerName,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: accentPurple,
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'for successfully completing the course',
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  courseTitle,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    color: darkNavy,
                    fontSize: 21,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'COURSE COMPLETED - QUIZ PASSED',
                  style: pw.TextStyle(
                    color: PdfColors.green700,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Date awarded: $dateText',
                    style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 6),
                pw.Text('Certificate ID: $certificateId',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await Printing.layoutPdf(
        name: 'MT_Alchemy_Certificate_${certificateId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '')}.pdf',
        onLayout: (format) async => document.save(),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create the PDF. Please try again.'),
        ),
      );
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }


  String _courseId(Course course) => course.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Future<void> _enrol(BuildContext context, Course course) async {
    final uid = userId;
    if (uid == null) return;
    final id = _courseId(course);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('enrollments')
          .doc(id)
          .set({
        'courseId': id,
        'title': course.title,
        'category': course.category,
        'progress': 0,
        'enrolledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrolled in ${course.title}.')),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.code == 'permission-denied'
            ? 'Enrollment was blocked by Firestore rules. Add the enrollment rules shown with this update.'
            : 'Could not enrol in this course. Please try again.')),
      );
    }
  }

  Future<void> _openLessons(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) async {
    final data = doc.data() ?? <String, dynamic>{};
    final title = (data['title'] ?? 'Course').toString();
    final progress = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
    final completedLessons = (progress ~/ 25).clamp(0, 4);
    final lessons = <Map<String, String>>[
      {'title': 'Lesson 1: Introduction', 'body': 'Understand the course goals, key concepts, and how the topic applies in a professional setting.'},
      {'title': 'Lesson 2: Core principles', 'body': 'Explore the main principles and vocabulary. Identify two ideas you can apply in your work or studies.'},
      {'title': 'Lesson 3: Practical application', 'body': 'Work through a practical scenario and identify the steps needed to apply what you have learned.'},
      {'title': 'Lesson 4: Review and action plan', 'body': 'Review the key takeaways and create a short action plan for applying these skills.'},
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Course lessons', style: TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 17)),
                const SizedBox(height: 8),
                Text('Progress: $progress%', style: const TextStyle(color: purple, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                for (var i = 0; i < lessons.length; i++)
                  Card(
                    color: i < completedLessons ? const Color(0xFFEAF7EF) : Colors.white,
                    child: ExpansionTile(
                      leading: Icon(i < completedLessons ? Icons.check_circle : Icons.play_circle_outline, color: i < completedLessons ? Colors.green : purple),
                      title: Text(lessons[i]['title']!),
                      subtitle: Text(i < completedLessons ? 'Completed' : 'Lesson ${i + 1}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(lessons[i]['body']!, style: const TextStyle(height: 1.6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                const Text('These are sample reading lessons for the course prototype. Progress is saved to Firestore.', style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
          OutlinedButton.icon(
            onPressed: progress >= 100 ? () {
              Navigator.pop(dialogContext);
              _openQuiz(context, doc);
            } : null,
            icon: Icon(progress >= 100 ? Icons.quiz_outlined : Icons.lock_outline),
            label: const Text('Take quiz'),
          ),
          if (progress < 100)
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _advanceProgress(context, doc);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: Text(progress == 75 ? 'Complete course' : 'Complete next lesson'),
            )
          else
            const Chip(avatar: Icon(Icons.verified, size: 18), label: Text('Course completed')),
        ],
      ),
    );
  }

  Future<void> _openQuiz(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) async {
    final uid = userId;
    if (uid == null) return;
    final data = doc.data() ?? <String, dynamic>{};
    final title = (data['title'] ?? 'Course').toString();
    final progress = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
    if (progress < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all four lessons before taking the quiz.')),
      );
      return;
    }
    final questions = <Map<String, dynamic>>[
      {
        'question': 'What is the main purpose of learning objectives?',
        'options': ['To clarify what learners should achieve', 'To make a course longer', 'To replace practice', 'To avoid feedback'],
        'answer': 0,
      },
      {
        'question': 'Which action best supports applying a new skill?',
        'options': ['Ignore it after reading', 'Practise it in a realistic scenario', 'Memorise the heading only', 'Skip reflection'],
        'answer': 1,
      },
      {
        'question': 'What is constructive feedback intended to do?',
        'options': ['Blame the learner', 'Compare people unfairly', 'Help identify improvements', 'End the learning process'],
        'answer': 2,
      },
      {
        'question': 'What is a useful final step after a course?',
        'options': ['Forget the content', 'Create an action plan', 'Delete all notes', 'Avoid using the skills'],
        'answer': 1,
      },
    ];
    final answers = List<int?>.filled(questions.length, null);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('$title — Course Quiz'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Answer all four questions. You need at least 3 correct answers (75%) to pass.'),
                  const SizedBox(height: 14),
                  for (var i = 0; i < questions.length; i++) ...[
                    Text('${i + 1}. ${questions[i]['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    for (var j = 0; j < (questions[i]['options'] as List<String>).length; j++)
                      RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text((questions[i]['options'] as List<String>)[j]),
                        value: j,
                        groupValue: answers[i],
                        onChanged: (value) => setDialogState(() => answers[i] = value),
                      ),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: answers.any((answer) => answer == null) ? null : () async {
                final score = List<int>.generate(questions.length, (i) => answers[i] == questions[i]['answer'] ? 1 : 0).fold<int>(0, (sum, value) => sum + value);
                final percent = ((score / questions.length) * 100).round();
                final passed = percent >= 75;
                Navigator.pop(dialogContext);
                try {
                  await doc.reference.update({
                    'quizScore': percent,
                    'quizPassed': passed,
                    'quizAttempts': FieldValue.increment(1),
                    'lastQuizAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  if (!context.mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (resultContext) => AlertDialog(
                      icon: Icon(passed ? Icons.emoji_events_rounded : Icons.menu_book_rounded, color: passed ? Colors.green : purple, size: 44),
                      title: Text(passed ? 'Quiz passed!' : 'Keep practising'),
                      content: Text('Your score: $score/${questions.length} ($percent%). ${passed ? 'You passed this course quiz.' : 'You need at least 75% to pass. Review the lessons and try again.'}'),
                      actions: [FilledButton(onPressed: () => Navigator.pop(resultContext), child: const Text('Done'))],
                    ),
                  );
                } on FirebaseException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code == 'permission-denied' ? 'Quiz result was blocked by Firestore rules. Update the enrollment rules to allow quiz fields.' : 'Could not save your quiz result. Please try again.')));
                }
              },
              child: const Text('Submit quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _advanceProgress(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) async {
    final uid = userId;
    if (uid == null) return;
    final current = (doc.data()?['progress'] as num?)?.toInt() ?? 0;
    final next = (current + 25).clamp(0, 100);
    try {
      await doc.reference.update({
        'progress': next,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next == 100 ? 'Course completed!' : 'Learning progress updated to $next%.')),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.code == 'permission-denied'
            ? 'Progress update was blocked by Firestore rules. Add the enrollment rules shown with this update.'
            : 'Could not update progress. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = userId;
    if (uid == null) {
      return const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Please sign in to view your learning dashboard.')));
    }
    final enrollmentCollection = FirebaseFirestore.instance
        .collection('users').doc(uid).collection('enrollments');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: enrollmentCollection.snapshots(),
          builder: (context, snapshot) {
            final enrolled = snapshot.data?.docs ?? [];
            final completed = enrolled.where((doc) => ((doc.data()['progress'] as num?)?.toInt() ?? 0) >= 100).length;
            final inProgress = enrolled.length - completed;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AdminStatCard(label: 'Enrolled courses', value: '${enrolled.length}', icon: Icons.menu_book_outlined),
                _AdminStatCard(label: 'In progress', value: '$inProgress', icon: Icons.timelapse_rounded),
                _AdminStatCard(label: 'Completed', value: '$completed', icon: Icons.task_alt_rounded),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('My Learning', style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: enrollmentCollection.orderBy('enrolledAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Could not load your courses. Check the enrollment Firestore rules.')));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(20), child: Text('You have not enrolled in a course yet. Choose a course below to get started.')));
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data();
                final progress = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.menu_book_rounded, color: purple, size: 30),
                        const SizedBox(width: 12),
                        Expanded(child: Text((data['title'] ?? 'Course').toString(), style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.bold))),
                        Text('$progress%', style: const TextStyle(color: purple, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 12),
                      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress / 100, minHeight: 8, backgroundColor: const Color(0xFFE5DDCC), color: purple)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(progress >= 100 ? 'Completed' : 'Keep learning', style: const TextStyle(color: Colors.black54)),
                          OutlinedButton.icon(
                            onPressed: () => _openLessons(context, doc),
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text('Open lessons'),
                          ),
                          if (progress >= 100)
                            const Chip(avatar: Icon(Icons.verified, size: 18), label: Text('Completed')),
                        ],
                      ),
                    ]),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Quiz Results', style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: enrollmentCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Could not load quiz results. Please check your Firestore rules.'),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final results = (snapshot.data?.docs ?? [])
                .where((doc) => doc.data().containsKey('quizScore'))
                .toList()
              ..sort((a, b) {
                final aDate = a.data()['lastQuizAt'];
                final bDate = b.data()['lastQuizAt'];
                if (aDate is Timestamp && bDate is Timestamp) {
                  return bDate.compareTo(aDate);
                }
                return 0;
              });
            if (results.isEmpty) {
              return const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.quiz_outlined, color: purple, size: 30),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('No quiz results yet. Complete a course and submit its quiz to see your score here.'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: results.map((doc) {
                final data = doc.data();
                final score = (data['quizScore'] as num?)?.toInt() ?? 0;
                final passed = data['quizPassed'] == true;
                final attempts = (data['quizAttempts'] as num?)?.toInt() ?? 1;
                final lastQuizAt = data['lastQuizAt'];
                final dateText = lastQuizAt is Timestamp
                    ? '${lastQuizAt.toDate().day.toString().padLeft(2, '0')}/'
                    '${lastQuizAt.toDate().month.toString().padLeft(2, '0')}/'
                    '${lastQuizAt.toDate().year}'
                    : 'Just submitted';
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              passed ? Icons.emoji_events_rounded : Icons.quiz_outlined,
                              color: passed ? Colors.green : purple,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (data['title'] ?? 'Course').toString(),
                                style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '$score%',
                              style: TextStyle(
                                color: passed ? Colors.green.shade700 : Colors.deepOrange.shade700,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: (score.clamp(0, 100)) / 100,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFE5DDCC),
                            color: passed ? Colors.green : Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              avatar: Icon(passed ? Icons.check_circle : Icons.refresh, size: 18),
                              label: Text(passed ? 'Passed' : 'Not passed'),
                            ),
                            Chip(label: Text('Attempts: $attempts')),
                            Chip(label: Text('Last attempt: $dateText')),
                            if (passed && ((data['progress'] as num?)?.toInt() ?? 0) >= 100)
                              FilledButton.icon(
                                onPressed: () => _showCertificate(context, doc),
                                icon: const Icon(Icons.workspace_premium_outlined),
                                label: const Text('View certificate'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 28),
        CoachingRequestSection(
          uid: uid,
          userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
          userEmail: FirebaseAuth.instance.currentUser?.email ?? '',
        ),
        const SizedBox(height: 20),
        MyCoachingRequestsSection(uid: uid),
        const SizedBox(height: 24),
        const Text('Explore Courses', style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: courses.map((course) {
            final id = _courseId(course);
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: enrollmentCollection.doc(id).snapshots(),
              builder: (context, snapshot) {
                final isEnrolled = snapshot.data?.exists ?? false;
                final progress = ((snapshot.data?.data()?['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
                return SizedBox(
                  width: 310,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 48, height: 48, decoration: BoxDecoration(color: course.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(course.icon, color: course.color)),
                        const SizedBox(height: 14),
                        Text(course.title, style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(course.category, style: const TextStyle(color: purple, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(course.description, style: const TextStyle(color: Colors.black54, height: 1.5)),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: isEnrolled
                              ? OutlinedButton.icon(onPressed: null, icon: Icon(progress >= 100 ? Icons.task_alt : Icons.check_circle_outline), label: Text(progress >= 100 ? 'Completed' : 'Enrolled'))
                              : FilledButton.icon(onPressed: () => _enrol(context, course), icon: const Icon(Icons.add_circle_outline), label: const Text('Enrol in course')),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Progress is a prototype tracker: each lesson-complete action advances progress by 25%.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}


// -------------------- EMPLOYEE ASSIGNED LEARNING --------------------

class EmployeeLearningDashboard extends StatelessWidget {
  final String? userId;

  const EmployeeLearningDashboard({super.key, required this.userId});

  String _dateLabel(dynamic value) {
    if (value is! Timestamp) return 'No deadline set';
    final date = value.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _completeNextLesson(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> assignment,
      ) async {
    final data = assignment.data() ?? <String, dynamic>{};
    final current = ((data['progress'] as num?)?.toInt() ?? 0).clamp(0, 100);
    if (current >= 100) return;

    final next = (current + 25).clamp(0, 100);
    try {
      await assignment.reference.update({
        'progress': next,
        'status': next >= 100 ? 'Completed' : 'In Progress',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            next >= 100
                ? 'Great work! You completed ${data['courseTitle'] ?? 'this course'}.'
                : 'Your learning progress is now $next%.',
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'permission-denied'
                ? 'Progress update was blocked. Check the employee assignment update rules in Firestore.'
                : 'Could not update progress. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update progress. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = userId;
    if (uid == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Please sign in to view your assigned learning.'),
        ),
      );
    }

    final assignments = FirebaseFirestore.instance
        .collection('corporate_course_assignments')
        .where('employeeUid', isEqualTo: uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: assignments.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Could not load your assigned courses. Check the employee assignment read rules in Firestore.',
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final completed = docs.where((doc) {
              final data = doc.data();
              return ((data['progress'] as num?)?.toInt() ?? 0) >= 100 ||
                  data['status'] == 'Completed';
            }).length;
            final inProgress = docs.where((doc) {
              final data = doc.data();
              final progress = (data['progress'] as num?)?.toInt() ?? 0;
              return progress > 0 && progress < 100;
            }).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _AdminStatCard(
                      label: 'Assigned courses',
                      value: '${docs.length}',
                      icon: Icons.menu_book_outlined,
                    ),
                    _AdminStatCard(
                      label: 'In progress',
                      value: '$inProgress',
                      icon: Icons.timelapse_rounded,
                    ),
                    _AdminStatCard(
                      label: 'Completed',
                      value: '$completed',
                      icon: Icons.task_alt_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Courses Assigned by Your Organisation',
                  style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (docs.isEmpty)
                  const Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'You do not have any assigned courses yet. Your employer will add courses to your learning workspace.',
                      ),
                    ),
                  )
                else
                  ...docs.map((doc) {
                    final data = doc.data();
                    final progress = ((data['progress'] as num?)?.toInt() ?? 0)
                        .clamp(0, 100);
                    final isCompleted = progress >= 100 || data['status'] == 'Completed';
                    final status = isCompleted
                        ? 'Completed'
                        : progress > 0
                        ? 'In Progress'
                        : 'Assigned';
                    final deadline = _dateLabel(data['deadline']);

                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFF2E8CC),
                                  child: Icon(Icons.menu_book_rounded, color: purple),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (data['courseTitle'] ?? 'Assigned course').toString(),
                                        style: const TextStyle(
                                          color: navy,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (data['category'] ?? 'Professional Development').toString(),
                                        style: const TextStyle(
                                          color: purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(status),
                                  avatar: Icon(
                                    isCompleted ? Icons.check_circle : Icons.assignment_outlined,
                                    size: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (data['description'] ?? '').toString(),
                              style: const TextStyle(color: Colors.black54, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 18, color: purple),
                                const SizedBox(width: 7),
                                Text('Due: $deadline'),
                                const Spacer(),
                                Text(
                                  '$progress%',
                                  style: const TextStyle(color: purple, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                minHeight: 9,
                                backgroundColor: const Color(0xFFE5DDCC),
                                color: isCompleted ? Colors.green : purple,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: isCompleted
                                  ? const Chip(
                                avatar: Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                                label: Text('Course completed'),
                              )
                                  : FilledButton.icon(
                                onPressed: () => _completeNextLesson(context, doc),
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(progress == 75 ? 'Complete course' : 'Complete next lesson'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        CoachingRequestSection(
          uid: uid,
          userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
          userEmail: FirebaseAuth.instance.currentUser?.email ?? '',
        ),
        const SizedBox(height: 20),
        MyCoachingRequestsSection(uid: uid),
      ],
    );
  }
}

class MyCoachingRequestsSection extends StatelessWidget {
  final String uid;

  const MyCoachingRequestsSection({super.key, required this.uid});

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF218A43);
      case 'Rejected':
        return const Color(0xFFC0392B);
      default:
        return const Color(0xFF9A741F);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle_outline_rounded;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  String _dateText(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return 'Date not available';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'My Coaching Requests',
          style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track the review status of your coaching session requests.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('coaching_requests')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Could not load your coaching request status. Please check your Firestore read rules.',
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = [...?snapshot.data?.docs];
            docs.sort((a, b) {
              final aCreated = a.data()['createdAt'];
              final bCreated = b.data()['createdAt'];
              final aTime = aCreated is Timestamp ? aCreated.millisecondsSinceEpoch : 0;
              final bTime = bCreated is Timestamp ? bCreated.millisecondsSinceEpoch : 0;
              return bTime.compareTo(aTime);
            });

            if (docs.isEmpty) {
              return const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Icon(Icons.event_note_outlined, color: purple, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('You have not submitted a coaching request yet.'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final data = doc.data();
                final status = (data['status'] ?? 'Pending').toString();
                final statusColor = _statusColor(status);
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE8D9B8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              (data['coachingType'] ?? 'Coaching session').toString(),
                              style: const TextStyle(
                                color: navy,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon(status), size: 15, color: statusColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 17, color: purple),
                            const SizedBox(width: 8),
                            Text(
                              'Preferred date: ${_dateText(data['preferredDate'])}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        if ((data['message'] ?? '').toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 9),
                          const Text(
                            'Your message',
                            style: TextStyle(fontWeight: FontWeight.w600, color: navy),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data['message'].toString(),
                            style: const TextStyle(color: Colors.black54, height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          status == 'Approved'
                              ? 'Your request has been approved. The MT Alchemy team can follow up with you about the session.'
                              : status == 'Rejected'
                              ? 'This request was not approved. Please contact the MT Alchemy team if you need assistance.'
                              : 'Your request is awaiting review by the MT Alchemy team.',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class CoachingRequestSection extends StatefulWidget {
  final String uid;
  final String userName;
  final String userEmail;

  const CoachingRequestSection({
    super.key,
    required this.uid,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<CoachingRequestSection> createState() => _CoachingRequestSectionState();
}

class _CoachingRequestSectionState extends State<CoachingRequestSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _messageController = TextEditingController();
  String _coachingType = 'Personal Growth';
  DateTime? _preferredDate;
  bool _isSubmitting = false;

  static const List<String> _coachingTypes = [
    'Personal Growth',
    'Communication Skills',
    'Leadership Development',
    'Mindfulness & Well-being',
    'Career Guidance',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? today.add(const Duration(days: 1)),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Choose your preferred coaching date',
    );
    if (selected != null && mounted) {
      setState(() => _preferredDate = selected);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_preferredDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose your preferred date.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('coaching_requests')
          .add({
        'userId': widget.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'coachingType': _coachingType,
        'preferredDate': Timestamp.fromDate(_preferredDate!),
        'message': _messageController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _formKey.currentState!.reset();
      _messageController.clear();
      setState(() {
        _preferredDate = null;
        _coachingType = _coachingTypes.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your coaching request has been submitted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? 'Request could not be saved. Firestore rules must allow users to create their own coaching requests.'
          : 'Could not submit your request. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _preferredDate == null
        ? 'Choose a date'
        : '${_preferredDate!.day.toString().padLeft(2, '0')}/'
        '${_preferredDate!.month.toString().padLeft(2, '0')}/'
        '${_preferredDate!.year}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8D9B8)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EBD5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.diversity_3_rounded, color: purple, size: 26),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coaching & Mentorship',
                      style: TextStyle(fontSize: 21, color: navy, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Get personalised support for your next step.',
                      style: TextStyle(color: Colors.black54, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Request a coaching session',
            style: TextStyle(fontSize: 16, color: navy, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Share your goals and preferred date. The MT Alchemy team can follow up with you.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address *',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
                      ? 'Please enter a valid email address'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _coachingType,
                  decoration: const InputDecoration(
                    labelText: 'Coaching area *',
                    prefixIcon: Icon(Icons.psychology_alt_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _coachingTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _coachingType = value);
                  },
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _chooseDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('Preferred date: $dateLabel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                    alignment: Alignment.centerLeft,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What would you like help with? *',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().length < 10
                      ? 'Please enter at least 10 characters'
                      : null,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.send_rounded),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Request a session'),
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your request will be saved privately under your account with Pending status.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _DashboardTile({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: purple, size: 34),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.black54, height: 1.5)),
        ]),
      ),
    ),
  );
}

// -------------------- CONTACT PAGE --------------------

// Reusable website widgets restored from the previous working source.

class PageBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageBanner({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 600;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102449), Color(0xFF244A86), Color(0xFF7555B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: compact ? -75 : 30,
            top: -95,
            child: Container(
              width: compact ? 190 : 260,
              height: compact ? 190 : 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 28),
              ),
            ),
          ),
          Positioned(
            left: -65,
            bottom: -105,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellow.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 22 : 40, vertical: compact ? 42 : 58),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 14, color: yellow),
                          SizedBox(width: 7),
                          Text('MT ALCHEMY  •  LEARN & GROW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 30 : 40,
                        height: 1.12,
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 690),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFF1E5C8),
                          fontSize: compact ? 14 : 16,
                          height: 1.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 54,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(colors: [yellow, Color(0xFFFFF0C2)]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 25 : 31,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF65718A), height: 1.7, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? imageUrl;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.imageUrl,
    this.onTap,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 285,
        transform: Matrix4.translationValues(0, _hovering ? -8 : 0, 0),
        child: Card(
          elevation: _hovering ? 10 : 1,
          shadowColor: widget.color.withValues(alpha: _hovering ? 0.20 : 0.05),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: _hovering
                  ? widget.color.withValues(alpha: 0.40)
                  : const Color(0xFFE7E3F7),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null
                            ? child
                            : Container(
                          color: const Color(0xFFF1E8D2),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: yellow),
                        ),
                        errorBuilder: (context, error, stack) => Container(
                          color: const Color(0xFF28251F),
                          alignment: Alignment.center,
                          child: Icon(widget.icon, color: yellow, size: 48),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withValues(alpha: _hovering ? 0.20 : 0.13),
                              widget.color.withValues(alpha: _hovering ? 0.09 : 0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(_hovering ? 20 : 16),
                          border: Border.all(color: widget.color.withValues(alpha: 0.10)),
                        ),
                        child: Icon(widget.icon, color: widget.color, size: 29),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: Colors.black54,
                          height: 1.7,
                        ),
                      ),
                      if (widget.onTap != null) ...[
                        const SizedBox(height: 15),
                        const Row(
                          children: [
                            Text(
                              'Explore',
                              style: TextStyle(
                                color: purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, color: purple, size: 17),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


String _courseImage(String title) {
  if (title.toLowerCase().contains('leadership')) {
    return 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=900&q=80';
  }
  if (title.toLowerCase().contains('digital')) {
    return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80';
  }
  if (title.toLowerCase().contains('communication')) {
    return 'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=900&q=80';
  }
  return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=900&q=80';
}

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 285,
        transform: Matrix4.translationValues(0, _hovering ? -8 : 0, 0),
        child: Card(
          elevation: _hovering ? 10 : 1,
          shadowColor: course.color.withValues(alpha: _hovering ? 0.20 : 0.05),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: _hovering
                  ? course.color.withValues(alpha: 0.35)
                  : const Color(0xFFE8E0CF),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 142,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      course.color.withValues(alpha: _hovering ? 0.22 : 0.15),
                      course.color.withValues(alpha: _hovering ? 0.10 : 0.05),
                      const Color(0xFFFBF8F0),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      _courseImage(course.title),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              course.color.withValues(alpha: 0.22),
                              const Color(0xFFFBF8F0),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(course.icon, color: course.color, size: 58),
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 12,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          course.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.category.toUpperCase(),
                      style: const TextStyle(
                        color: purple,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      course.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: widget.onTap,
                        child: const Text('View Course'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final String? imageUrl;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FeatureCard(
      icon: icon,
      title: title,
      description: text,
      color: purple,
      imageUrl: imageUrl,
    );
  }
}

class SiteFooter extends StatelessWidget {
  SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome, color: yellow, size: 30),
          SizedBox(height: 12),
          Text(
            'MT ALCHEMY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Learn • Grow • Transform',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 18),
          Text(
            'Corporate Learning & Development Platform',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            '© MT Alchemy — Prototype',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final VoidCallback onLogin;

  const RegisterPage({
    super.key,
    required this.onLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedRole = 'Individual';
  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

// Public registration must never create a Super Admin account.
    const allowedRegistrationRoles = <String>{
      'Individual',
      'Employer',
      'Trainer',
      'Employee',
    };
    if (!allowedRegistrationRoles.contains(selectedRole)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This account type cannot be selected during registration.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );

      final user = credential.user;

      if (user != null) {
        final emailLower = emailController.text.trim().toLowerCase();
        Map<String, dynamic>? employeeInvitation;

        if (selectedRole == 'Employee') {
          final invitationQuery = await FirebaseFirestore.instance
              .collection('employee_invitations')
              .where('emailLower', isEqualTo: emailLower)
              .where('status', isEqualTo: 'Pending')
              .limit(1)
              .get();

          if (invitationQuery.docs.isEmpty) {
            await user.delete();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No pending employee invitation was found for this email. Ask your employer to invite you first.'),
              ),
            );
            return;
          }

          employeeInvitation = invitationQuery.docs.first.data();
          if ((employeeInvitation['emailLower'] ?? '') != emailLower) {
            await user.delete();
            throw Exception('Invitation email does not match.');
          }
        }

        final profileData = <String, dynamic>{
          'uid': user.uid,
          'name': nameController.text.trim(),
          'email': emailLower,
          'emailLower': emailLower,
          'role': selectedRole,
          'status': 'Active',
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (selectedRole == 'Employee' && employeeInvitation != null) {
          profileData.addAll({
            'employerUid': employeeInvitation['employerUid'],
            'organizationName': employeeInvitation['organizationName'] ?? '',
            'department': employeeInvitation['department'] ?? '',
            'phone': employeeInvitation['phone'] ?? '',
            'invitedBy': employeeInvitation['employerUid'],
            'invitationAcceptedAt': FieldValue.serverTimestamp(),
          });
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(profileData);

        if (selectedRole == 'Employee' && employeeInvitation != null) {
          final invitationDoc = FirebaseFirestore.instance
              .collection('employee_invitations')
              .doc(employeeInvitation['invitationId'] as String);
          await invitationDoc.update({
            'status': 'Accepted',
            'acceptedUid': user.uid,
            'acceptedAt': FieldValue.serverTimestamp(),
          });
        }

        if (selectedRole != 'Employee') {
          await writeActivityLog(
            action: 'Registered',
            targetUid: user.uid,
            targetName: nameController.text.trim(),
            targetEmail: emailLower,
            newValue: selectedRole,
          );
        }
        await user.updateDisplayName(nameController.text.trim());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! You can now sign in.'),
        ),
      );

      await navigateToLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please sign in.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Choose a stronger password.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The account may have been created, but saving the profile failed. Check Firestore rules and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }





  Future<void> navigateToLogin() async {
// Firebase automatically signs in the user after account creation.
// Sign out so they can use the Sign In page normally.
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    widget.onLogin();
  }





  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8E0CF)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 52,
                  color: purple,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Create Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join MT Alchemy and start your learning journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Text('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Account type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Individual',
                      child: Text('Individual'),
                    ),
                    DropdownMenuItem(
                      value: 'Employer',
                      child: Text('Employer'),
                    ),
                    DropdownMenuItem(
                      value: 'Trainer',
                      child: Text('Trainer'),
                    ),
                    DropdownMenuItem(
                      value: 'Employee',
                      child: Text('Employee (invitation required)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
                if (selectedRole == 'Employee') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Use the exact email address your employer invited. Your employer cannot see or set your password.',
                    style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidePassword = !hidePassword);
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Confirm password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.all(18),
                  ),
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





class CertificateVerificationPage extends StatefulWidget {
  const CertificateVerificationPage({super.key});

  @override
  State<CertificateVerificationPage> createState() => _CertificateVerificationPageState();
}

class _CertificateVerificationPageState extends State<CertificateVerificationPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  bool _searched = false;
  Map<String, dynamic>? _certificate;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final id = _controller.text.trim().toUpperCase();
    if (id.isEmpty) {
      setState(() { _searched = true; _certificate = null; _error = 'Enter a certificate ID.'; });
      return;
    }
    setState(() { _loading = true; _searched = true; _certificate = null; _error = null; });
    try {
      final result = await FirebaseFirestore.instance.collection('certificates').doc(id).get();
      if (!mounted) return;
      final data = result.data();
      setState(() {
        _certificate = result.exists && data?['valid'] == true ? data : null;
        _error = (result.exists && data?['valid'] == true)
            ? null
            : 'No valid certificate was found for this ID.';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Could not verify this certificate. Please try again later.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final certificate = _certificate;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.verified_user_outlined, color: purple, size: 58),
              const SizedBox(height: 12),
              const Text('Certificate Verification', textAlign: TextAlign.center,
                  style: TextStyle(color: navy, fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Check whether an MT Alchemy certificate ID exists in our verification records.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 15)),
              const SizedBox(height: 28),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Certificate ID', style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Example: MTA-ABC123-COURSE01',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        onSubmitted: (_) => _verify(),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _loading ? null : _verify,
                        icon: _loading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.search),
                        label: Text(_loading ? 'Checking...' : 'Verify certificate'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_searched && !_loading) ...[
                const SizedBox(height: 18),
                if (certificate != null)
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 30), SizedBox(width: 10), Expanded(child: Text('Certificate record found', style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)))]),
                          const Divider(height: 28),
                          _verificationDetail('Learner', (certificate['learnerName'] ?? 'Not available').toString()),
                          _verificationDetail('Course', (certificate['courseTitle'] ?? 'Not available').toString()),
                          _verificationDetail('Date awarded', (certificate['dateAwarded'] ?? 'Not available').toString()),
                          _verificationDetail('Certificate ID', (certificate['certificateId'] ?? '').toString()),
                          const SizedBox(height: 12),
                          const Text('This confirms a matching record exists in the MT Alchemy database. For high-stakes verification, contact the issuing organisation.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(children: [const Icon(Icons.error_outline, color: Colors.deepOrange, size: 28), const SizedBox(width: 12), Expanded(child: Text(_error ?? 'No valid certificate was found.'))]),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _verificationDetail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 135, child: Text(label, style: const TextStyle(color: Colors.black54))),
      Expanded(child: SelectableText(value, style: const TextStyle(color: navy, fontWeight: FontWeight.w600))),
    ]),
  );
}

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  static const _articles = <Map<String, String>>[
    {
      'category': 'Emotional Intelligence',
      'image': 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=900&q=80',
      'title': 'Building Emotional Intelligence at Work',
      'summary': 'Practical ways to recognise emotions, respond thoughtfully, and strengthen workplace relationships.',
      'read': '5 min read',
    },
    {
      'category': 'Leadership',
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=900&q=80',
      'title': 'Leading with Empathy and Clarity',
      'summary': 'Create trust through active listening, clear expectations, and consistent communication.',
      'read': '4 min read',
    },
    {
      'category': 'Mindfulness',
      'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=900&q=80',
      'title': 'Small Mindfulness Practices for Busy Teams',
      'summary': 'Simple pauses that can help teams reset attention and approach challenges more intentionally.',
      'read': '3 min read',
    },
    {
      'category': 'Communication',
      'image': 'https://images.unsplash.com/photo-1556761175-b413da4baf72?auto=format&fit=crop&w=900&q=80',
      'title': 'Making Feedback More Constructive',
      'summary': 'A respectful framework for sharing specific observations and agreeing on next steps.',
      'read': '6 min read',
    },
    {
      'category': 'Workplace Well-being',
      'image': 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80',
      'title': 'Creating Space for Team Well-being',
      'summary': 'How regular check-ins and shared norms can support a healthier working environment.',
      'read': '5 min read',
    },
    {
      'category': 'Personal Development',
      'image': 'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=900&q=80',
      'title': 'Turn Reflection into Action',
      'summary': 'Use a short reflection routine to identify learning, choose a next step, and review progress.',
      'read': '4 min read',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(
            title: 'Insights',
            subtitle: 'Ideas and resources for emotional intelligence, leadership, mindfulness, and thriving workplaces.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Explore our latest thinking', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: navy)),
                    const SizedBox(height: 8),
                    const Text('Browse practical learning ideas for individuals, teams, and organisations.', style: TextStyle(color: Colors.black54, height: 1.5)),
                    const SizedBox(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850 ? 3 : constraints.maxWidth >= 560 ? 2 : 1;
                      final width = (constraints.maxWidth - (columns - 1) * 18) / columns;
                      return Wrap(
                        spacing: 18,
                        runSpacing: 18,
                        children: _articles.map((article) => SizedBox(
                          width: width,
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0xFFE8E0CF))),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  article['image']!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: double.infinity,
                                    height: 150,
                                    color: const Color(0xFF24211B),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.auto_awesome, size: 42, color: yellow),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(22),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF5EAD0), borderRadius: BorderRadius.circular(20)), child: Text(article['category']!, style: const TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.bold))),
                                      const SizedBox(height: 18),
                                      Text(article['title']!, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy, height: 1.3)),
                                      const SizedBox(height: 10),
                                      Text(article['summary']!, style: const TextStyle(color: Colors.black54, height: 1.55)),
                                      const SizedBox(height: 18),
                                      Row(children: [const Icon(Icons.schedule, size: 15, color: purple), const SizedBox(width: 6), Text(article['read']!, style: const TextStyle(color: Colors.black54, fontSize: 12))]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      );
                    }),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [navy, blue, purple]), borderRadius: BorderRadius.circular(20)),
                      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Learning is a journey', style: TextStyle(color: yellow, fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Bring these ideas into your next conversation, team session, or personal reflection.', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SiteFooter(),
        ],
      ),
    );
  }
}


// -------------------- ADMIN PRODUCT MANAGEMENT --------------------
class ProductManagementPage extends StatefulWidget {
  final VoidCallback onBack;
  const ProductManagementPage({super.key, required this.onBack});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final _collection = FirebaseFirestore.instance.collection('products');

  Future<void> _showProductDialog({DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final data = doc?.data() ?? <String, dynamic>{};
    final title = TextEditingController(text: (data['title'] ?? '').toString());
    final description = TextEditingController(text: (data['description'] ?? '').toString());
    final price = TextEditingController(text: (data['price'] ?? '').toString());
    String type = (data['type'] ?? 'Digital').toString();
    bool available = (data['available'] ?? true) == true;
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(doc == null ? 'Add Product' : 'Edit Product'),
        content: SizedBox(width: 420, child: SingleChildScrollView(child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Product name'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a product name' : null),
            const SizedBox(height: 10),
            TextFormField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter a description' : null),
            const SizedBox(height: 10),
            TextFormField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (MYR)'), validator: (v) { final n = double.tryParse((v ?? '').trim()); return n == null || n < 0 ? 'Enter a valid non-negative price' : null; }),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(value: type, decoration: const InputDecoration(labelText: 'Product type'), items: const [DropdownMenuItem(value: 'Digital', child: Text('Digital')), DropdownMenuItem(value: 'Physical', child: Text('Physical'))], onChanged: (v) { if (v != null) setDialogState(() => type = v); }),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Available in store'), value: available, onChanged: (v) => setDialogState(() => available = v)),
          ]),
        ))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final parsedPrice = double.parse(price.text.trim());
            final payload = <String, dynamic>{'title': title.text.trim(), 'description': description.text.trim(), 'price': parsedPrice, 'currency': 'MYR', 'type': type, 'available': available, 'updatedAt': FieldValue.serverTimestamp()};
            try {
              if (doc == null) { payload['createdAt'] = FieldValue.serverTimestamp(); await _collection.add(payload); }
              else { await doc.reference.update(payload); }
              if (!mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(doc == null ? 'Product added.' : 'Product updated.')));
            } on FirebaseException catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(e.code == 'permission-denied' ? 'Permission denied. Firestore rules must allow authorized admins to manage products.' : 'Could not save product: ${e.message ?? e.code}')));
            }
          }, child: const Text('Save Product')),
        ],
      ),
    ));
    title.dispose(); description.dispose(); price.dispose();
  }

  Future<void> _deleteProduct(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final yes = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Delete product?'), content: Text('Delete "${doc.data()?['title'] ?? 'this product'}"?'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete'))],
    ));
    if (yes != true) return;
    try { await doc.reference.delete(); }
    on FirebaseException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code == 'permission-denied' ? 'Permission denied by Firestore rules.' : 'Could not delete product.'))); }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return SingleChildScrollView(child: Column(children: [
      PageBanner(title: 'Product Management', subtitle: 'Create, edit and publish digital or physical products.'),
      Padding(padding: const EdgeInsets.all(22), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1050), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [Expanded(child: Text('Store products', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: navy))), FilledButton.icon(onPressed: () => _showProductDialog(), icon: const Icon(Icons.add), label: const Text('Add Product'))]),
        const SizedBox(height: 14),
        if (user == null) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Sign in as Super Admin to manage products.')))
        else StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _collection.orderBy('createdAt', descending: true).snapshots(), builder: (context, snapshot) {
          if (snapshot.hasError) return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Could not load products. Check Firestore rules for the products collection.')));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(25), child: CircularProgressIndicator()));
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No products saved yet. Add a product to create its Firestore record. Existing demo store items remain separate until the store is connected to this collection.')));
          return Column(
            children: docs.map<Widget>((doc) {
              final d = doc.data();
              final p = (d['price'] as num?)?.toDouble() ?? 0;
              final available = d['available'] == true;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF4E9CC),
                    child: Icon(
                      d['type'] == 'Physical'
                          ? Icons.inventory_2_outlined
                          : Icons.menu_book_outlined,
                      color: purple,
                    ),
                  ),
                  title: Text(
                    (d['title'] ?? 'Untitled product').toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${d['type'] ?? 'Digital'} - RM ${p.toStringAsFixed(2)} - ${available ? 'Available' : 'Unpublished'}\n${d['description'] ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Edit product',
                        onPressed: () => _showProductDialog(doc: doc),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete product',
                        onPressed: () => _deleteProduct(doc),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 28),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Physical order fulfilment', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: navy)),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Update shipping progress for paid physical-product orders.', style: TextStyle(color: Colors.black54)),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collectionGroup('orders').where('containsPhysical', isEqualTo: true).snapshots(),
          builder: (context, shippingSnapshot) {
            if (shippingSnapshot.hasError) {
              final shippingError = shippingSnapshot.error;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Could not load physical orders.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Copy the diagnostic details below and send them for troubleshooting:',
                      ),
                      const SizedBox(height: 8),
                      SelectableText(shippingError?.toString() ?? 'Unknown Firestore error'),
                    ],
                  ),
                ),
              );
            }
            if (shippingSnapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            }
            final physicalOrders = (shippingSnapshot.data?.docs ?? []).where((doc) => doc.data()['paymentStatus'] == 'Successful').toList();
            if (physicalOrders.isEmpty) {
              return const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No paid physical-product orders yet.')));
            }
            return Column(children: physicalOrders.map<Widget>((doc) {
              final data = doc.data();
              final status = (data['shippingStatus'] ?? 'Pending Dispatch').toString();
              final items = (data['items'] as List<dynamic>? ?? []);
              final ownerPath = doc.reference.parent.parent?.id ?? 'Unknown customer';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_shipping_outlined)),
                  title: Text('Order ${doc.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Customer: $ownerPath\n${items.map((item) => item is Map ? (item['title'] ?? 'Product').toString() : item.toString()).join(', ')}\nShipping: $status\nAddress: ${(data['shippingAddress'] ?? '').toString()}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Update shipping status',
                    onSelected: (nextStatus) async {
                      final nextOrderStatus = nextStatus == 'Pending Dispatch' ? 'Processing' : nextStatus;
                      try {
                        await doc.reference.update({
                          'shippingStatus': nextStatus,
                          'orderStatus': nextOrderStatus,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shipping updated to $nextStatus.')));
                      } on FirebaseException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update shipping: ${e.message ?? e.code}')));
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Pending Dispatch', child: Text('Pending Dispatch')),
                      PopupMenuItem(value: 'Shipped', child: Text('Shipped')),
                      PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
                    ],
                    child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.more_vert)),
                  ),
                ),
              );
            }).toList());
          },
        ),
        const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back), label: const Text('Back to Dashboard'))),
      ]))),
      SiteFooter(),
    ]));
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final organizationController = TextEditingController();
  final messageController = TextEditingController();
  String enquiryType = 'Corporate Training';
  bool isSubmitting = false;

  static const enquiryTypes = [
    'Individual Coaching',
    'Corporate Training',
    'Leadership Development',
    'Team Development',
    'Products',
    'Partnership',
    'Other',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    organizationController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submitEnquiry() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('enquiries').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'organization': organizationController.text.trim(),
        'enquiryType': enquiryType,
        'message': messageController.text.trim(),
        'status': 'New',
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'Website Contact Form',
      });
      if (!mounted) return;
      formKey.currentState!.reset();
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      organizationController.clear();
      messageController.clear();
      setState(() { enquiryType = 'Corporate Training'; isSubmitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Your enquiry has been submitted successfully.')));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code == 'permission-denied'
          ? 'The enquiry could not be saved. Please publish the enquiries Firestore rule shown in the setup instructions.'
          : 'Could not submit your enquiry. Please try again.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit your enquiry. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageBanner(title: 'Contact Us', subtitle: 'Let’s build a thriving workplace together. Tell us about your learning goals or corporate training needs.'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 760),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE8E0CF))),
              child: Form(
                key: formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('Send us an enquiry', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 8),
                  const Text('Complete the form below and our team can follow up with you.', style: TextStyle(color: Colors.black54, height: 1.5)),
                  const SizedBox(height: 22),
                  TextFormField(controller: nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? 'Please enter a valid email address' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined))),
                  const SizedBox(height: 16),
                  TextFormField(controller: organizationController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Organization / company', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business_outlined))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(value: enquiryType, decoration: const InputDecoration(labelText: 'Enquiry type *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category_outlined)), items: enquiryTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(), onChanged: (value) { if (value != null) setState(() => enquiryType = value); }),
                  const SizedBox(height: 16),
                  TextFormField(controller: messageController, maxLines: 5, decoration: const InputDecoration(labelText: 'Message *', alignLabelWithHint: true, border: OutlineInputBorder(), prefixIcon: Icon(Icons.message_outlined)), validator: (v) => v == null || v.trim().length < 10 ? 'Please enter at least 10 characters' : null),
                  const SizedBox(height: 20),
                  FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: navy, padding: const EdgeInsets.all(18)), onPressed: isSubmitting ? null : submitEnquiry, icon: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded), label: Text(isSubmitting ? 'Submitting...' : 'Submit Enquiry')),
                  const SizedBox(height: 12),
                  const Text('Your information will be stored securely for the MT Alchemy team to follow up.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
                ]),
              ),
            ),
          ),
          SiteFooter(),
        ],
      ),
    );
  }
}

