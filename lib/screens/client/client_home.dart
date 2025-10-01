import 'package:flutter/material.dart';
import 'package:login/services/product_service.dart';
import 'package:login/services/cart_service.dart';
import 'package:login/models/product_model.dart';
import 'package:login/widgets/product_card.dart';
import 'package:login/widgets/loading_widget.dart' as loading_widget;
import 'package:login/screens/client/cart.dart';
import 'package:login/screens/client/orders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/services/auth_service.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Toutes';
  List<String> _categories = ['Toutes'];
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCartItemCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productService.getCategories();
      setState(() {
        _categories = ['Toutes', ...categories];
      });
    } catch (e) {
      // Ignorer l'erreur
    }
  }

  Future<void> _loadCartItemCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final count = await _cartService.getCartItemCount(user.uid);
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _cartService.addToCart(user.uid, product.id!, 1);
      await _loadCartItemCount();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ajouté au panier'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Voir le panier',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cart()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _authService.currentUser;
    if (current == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<bool>(
      future: _authService.isClient(current.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (!snapshot.data!) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/admin');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Authorized client view
        return _buildClientScaffold(context);
      },
    );
  }

  Widget _buildClientScaffold(BuildContext context) {
    return _buildClientScaffoldContent(context);
  }

  Widget _buildClientScaffoldContent(BuildContext context) {
    // original client scaffold body moved here
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEMS-STORE'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Cart()),
                  );
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Orders()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Colors.cyan.shade100,
                          checkmarkColor: Colors.cyan,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des produits
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _selectedCategory == 'Toutes'
                  ? _productService.getProducts()
                  : _productService.getProductsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const loading_widget.LoadingWidget(message: 'Chargement des produits...');
                }

                if (snapshot.hasError) {
                  return loading_widget.ErrorWidget(
                    message: 'Erreur lors du chargement: ${snapshot.error}',
                    onRetry: () => setState(() {}),
                  );
                }

                List<ProductModel> products = snapshot.data ?? [];
                
                // Filtrer par recherche
                if (_searchController.text.isNotEmpty) {
                  products = products.where((product) {
                    return product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                           product.description.toLowerCase().contains(_searchController.text.toLowerCase());
                  }).toList();
                }

                if (products.isEmpty) {
                  return loading_widget.EmptyWidget(
                    message: _searchController.text.isNotEmpty
                        ? 'Aucun produit trouvé pour "${_searchController.text}"'
                        : 'Aucun produit disponible',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        // TODO: Navigate to product details
                      },
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Orders()),
              );
              break;
            case 3:
              // TODO: Navigate to profile
              break;
          }
        },
      ),
    );
}
}