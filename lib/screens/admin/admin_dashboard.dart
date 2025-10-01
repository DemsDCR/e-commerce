import 'package:flutter/material.dart';
import 'package:login/services/order_service.dart';
import 'package:login/screens/admin/add_product.dart';
import 'package:login/screens/admin/products_list.dart';
import 'package:login/screens/admin/orders_list.dart';
import 'package:login/services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();
  
  Map<String, int> _orderStats = {};
  double _totalRevenue = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _orderService.getOrderStats();
      final revenue = await _orderService.getTotalRevenue();
      
      setState(() {
        _orderStats = stats;
        _totalRevenue = revenue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Protect admin area: ensure current user role is admin
    final current = _authService.currentUser;
    if (current == null) {
      // Signed out, redirect to root
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FutureBuilder<bool>(
      future: _authService.isAdmin(current.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.data!) {
          // Not an admin: navigate to client home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/client');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Authorized: show admin dashboard
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau de bord Admin'),
            backgroundColor: Colors.cyan,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadDashboardData,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques des commandes
                      _buildStatsCard(),
                      const SizedBox(height: 20),
                      // Chiffre d'affaires
                      _buildRevenueCard(),
                      const SizedBox(height: 20),
                      // Actions rapides
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      // Graphique des commandes par statut
                      _buildOrdersChart(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques des commandes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    _orderStats['total']?.toString() ?? '0',
                    Colors.blue,
                    Icons.shopping_cart,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'En attente',
                    _orderStats['pending']?.toString() ?? '0',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Confirmées',
                    _orderStats['confirmed']?.toString() ?? '0',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Livrées',
                    _orderStats['delivered']?.toString() ?? '0',
                    Colors.purple,
                    Icons.local_shipping,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.euro,
              size: 40,
              color: Colors.green[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chiffre d\'affaires total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_totalRevenue.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Ajouter un produit',
                    Icons.add,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProduct(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Gérer les produits',
                    Icons.inventory,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Voir les commandes',
                    Icons.list_alt,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Actualiser',
                    Icons.refresh,
                    Colors.cyan,
                    _loadDashboardData,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des commandes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._orderStats.entries
                .where((entry) => entry.key != 'total')
                .map((entry) => _buildChartItem(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartItem(String status, int count) {
    final total = _orderStats['total'] ?? 1;
    final percentage = (count / total * 100).round();
    
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmées';
        break;
      case 'shipped':
        color = Colors.blue;
        label = 'Expédiées';
        break;
      case 'delivered':
        color = Colors.purple;
        label = 'Livrées';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulées';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text('$count ($percentage%)'),
        ],
      ),
    );
  }
}
