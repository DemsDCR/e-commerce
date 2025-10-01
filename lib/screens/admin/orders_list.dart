import 'package:flutter/material.dart';
import 'package:login/services/order_service.dart';
import 'package:login/models/order_model.dart';
import 'package:login/widgets/loading_widget.dart' as loading_widget;

class OrdersList extends StatefulWidget {
  const OrdersList({Key? key}) : super(key: key);

  @override
  State<OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  final OrderService _orderService = OrderService();
  OrderStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des commandes'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<OrderStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Toutes les commandes'),
              ),
              ...OrderStatus.values.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          if (_selectedStatus != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.cyan.shade50,
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.cyan[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Filtre: ${_getStatusText(_selectedStatus!)}',
                    style: TextStyle(
                      color: Colors.cyan[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                    },
                    child: const Text('Effacer'),
                  ),
                ],
              ),
            ),
          
          // Liste des commandes
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _selectedStatus == null
                  ? _orderService.getAllOrders()
                  : _orderService.getOrdersByStatus(_selectedStatus!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const loading_widget.LoadingWidget(message: 'Chargement des commandes...');
                }

                if (snapshot.hasError) {
                  return loading_widget.ErrorWidget(
                    message: 'Erreur lors du chargement: ${snapshot.error}',
                    onRetry: () => setState(() {}),
                  );
                }

                List<OrderModel> orders = snapshot.data ?? [];

                if (orders.isEmpty) {
                  return loading_widget.EmptyWidget(
                    message: _selectedStatus == null
                        ? 'Aucune commande trouvée'
                        : 'Aucune commande avec le statut "${_getStatusText(_selectedStatus!)}"',
                    icon: Icons.shopping_cart_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(order.status),
                          child: Icon(
                            _getStatusIcon(order.status),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          'Commande #${order.id?.substring(0, 8) ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${order.totalAmount.toStringAsFixed(2)}€'),
                            Text(
                              'Date: ${_formatDate(order.createdAt)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Informations de la commande
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Informations',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('ID: ${order.id}'),
                                          Text('Client: ${order.userId}'),
                                          Text('Adresse: ${order.shippingAddress}'),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Actions',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (order.status == OrderStatus.pending) ...[
                                              IconButton(
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                onPressed: () => _updateOrderStatus(order, OrderStatus.confirmed),
                                                tooltip: 'Confirmer',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.cancel, color: Colors.red),
                                                onPressed: () => _updateOrderStatus(order, OrderStatus.cancelled),
                                                tooltip: 'Annuler',
                                              ),
                                            ],
                                            if (order.status == OrderStatus.confirmed)
                                              IconButton(
                                                icon: const Icon(Icons.local_shipping, color: Colors.blue),
                                                onPressed: () => _updateOrderStatus(order, OrderStatus.shipped),
                                                tooltip: 'Marquer comme expédiée',
                                              ),
                                            if (order.status == OrderStatus.shipped)
                                              IconButton(
                                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                                onPressed: () => _updateOrderStatus(order, OrderStatus.delivered),
                                                tooltip: 'Marquer comme livrée',
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Articles de la commande
                                const Text(
                                  'Articles',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text('${item.product.name} x${item.quantity}'),
                                      ),
                                      Text('${item.totalPrice.toStringAsFixed(2)}€'),
                                    ],
                                  ),
                                )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${order.totalAmount.toStringAsFixed(2)}€',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      await _orderService.updateOrderStatus(order.id!, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande ${_getStatusText(newStatus).toLowerCase()}'),
            backgroundColor: Colors.green,
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
}
