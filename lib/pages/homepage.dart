import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/pages/listetel.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _allItems = [
    {
      'title': 'Produits Samsung',
      'icon': Icons.phone_android,
    },
    {
      'title': 'Produits Apple',
      'icon': Icons.phone_iphone,
    },
    {
      'title': 'Ordinateurs',
      'icon': Icons.laptop_mac,
    },
    {
      'title': 'Accessoires',
      'icon': Icons.headset,
    },
  ];

  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(_allItems);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems
            .where((item) => (item['title'] as String).toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // TODO: Navigate to cart
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: const Text("DEMS-STORE"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Modern profile header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      final User? user = FirebaseAuth.instance.currentUser;
                      final String displayName = user?.displayName ?? "Utilisateur";
                      final String email = user?.email ?? "Email non défini";
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white24,
                            child: const Icon(Icons.person, size: 36, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 180,
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.white24,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
                                    },
                                    child: const Text('Voir profil', style: TextStyle(fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.logout, color: Colors.white),
                                      onPressed: () async {
                                        // sign out and return to auth wrapper
                                        await FirebaseAuth.instance.signOut();
                                        Navigator.pushReplacementNamed(context, '/');
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, size: 24),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, size: 24),
              title: const Text('Mes commandes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to orders
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, size: 24),
              title: const Text('Favoris'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to favorites
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, size: 24),
              title: const Text('Panier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to cart
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer, size: 24),
              title: const Text('Offres spéciales'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to offers
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, size: 24),
              title: const Text('Support client'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to support
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, size: 24),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, size: 24),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to about
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, size: 24, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section avec bannière promotionnelle
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Bienvenue chez DEMS-STORE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Découvrez nos dernières offres et produits tech",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "JUSQU'À -50% SUR TOUT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Barre de recherche améliorée avec filtres
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                      hintText: 'Rechercher des produits...',
                      filled: true,
                      fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.cyan),
                        onPressed: () {
                          _showFilterBottomSheet(context);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filtres rapides
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tous', true),
                        const SizedBox(width: 8),
                        _buildFilterChip('Promotions', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('Nouveautés', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('Meilleures ventes', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('Prix bas', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Section "Catégories populaires"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Catégories populaires",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all categories
                    },
                    child: const Text(
                      "Voir tout",
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),
                ],
              ),
            ),
            
            // Grid des catégories amélioré
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: _filteredItems.map((item) {
                  return _buildCategoryCard(item);
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Section "Produits populaires"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Produits populaires",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all products
                    },
                    child: const Text(
                      "Voir tout",
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste horizontale des produits populaires
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildProductCard(index);
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Nav(),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryPage(title: item['title'] as String),
                        ),
                      );
                    },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.cyan.shade50,
                Colors.cyan.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'] as IconData?,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final products = [
      {'name': 'iPhone 15 Pro', 'price': '999€', 'image': Icons.phone_iphone},
      {'name': 'MacBook Air M2', 'price': '1299€', 'image': Icons.laptop_mac},
      {'name': 'Samsung Galaxy S24', 'price': '899€', 'image': Icons.phone_android},
      {'name': 'AirPods Pro', 'price': '249€', 'image': Icons.headset},
      {'name': 'iPad Pro', 'price': '1099€', 'image': Icons.tablet_mac},
    ];
    
    final product = products[index % products.length];
    
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ajouté au panier: ${product['name']}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      product['image'] as IconData,
                      size: 40,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price'] as String,
                  style: TextStyle(
                    color: Colors.cyan[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Ajouter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // TODO: Implement filter logic
        });
      },
      selectedColor: Colors.cyan.shade100,
      checkmarkColor: Colors.cyan,
      labelStyle: TextStyle(
        color: isSelected ? Colors.cyan : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            RangeSlider(
              values: const RangeValues(0, 2000),
              min: 0,
              max: 2000,
              divisions: 20,
              labels: const RangeLabels('0€', '2000€'),
              onChanged: (values) {
                // TODO: Implement price filter
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Marque',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildBrandChip('Apple', true),
                _buildBrandChip('Samsung', false),
                _buildBrandChip('Google', false),
                _buildBrandChip('Xiaomi', false),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(String brand, bool isSelected) {
    return FilterChip(
      label: Text(brand),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // TODO: Implement brand filter
        });
      },
      selectedColor: Colors.cyan.shade100,
      checkmarkColor: Colors.cyan,
    );
  }
}

class Nav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.cyan,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: 'Panier',
      ),
      BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.favorite),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: 'Favoris',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on homepage
            break;
          case 1:
            // TODO: Navigate to search page
            break;
          case 2:
            // TODO: Navigate to cart
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Panier (3 articles)')),
            );
            break;
          case 3:
            // TODO: Navigate to favorites
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Favoris (5 articles)')),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
            break;
        }
          },
    );
  }
}



class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Utilisateur";
    final String email = user?.email ?? "Email non défini";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 56,
              backgroundColor: Colors.cyan.shade100,
              child: const Icon(Icons.person, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // open edit profile flow
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifier le profil'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            ),
          ],
        ),
      ),
    );
  }
}
