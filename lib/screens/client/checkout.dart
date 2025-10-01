import 'package:flutter/material.dart';
import 'package:login/models/cart_item_model.dart';
import 'package:login/services/order_service.dart';
import 'package:login/services/cart_service.dart';
import 'package:login/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Checkout extends StatefulWidget {
  final List<CartItemModel> cartItems;

  const Checkout({
    Key? key,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();
  final _cartService = CartService();
  
  final _shippingAddressController = TextEditingController();
  bool _isLoading = false;

  double get _totalAmount => widget.cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  @override
  void dispose() {
    _shippingAddressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Créer la commande
      await _orderService.createOrder(
        userId: user.uid,
        items: widget.cartItems,
        shippingAddress: _shippingAddressController.text.trim(),
      );

      // Vider le panier
      await _cartService.clearCart(user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande passée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Naviguer vers la page des commandes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/client/orders',
          (route) => false,
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la commande'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Récapitulatif de la commande
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Récapitulatif de la commande',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...widget.cartItems.map((item) => Padding(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_totalAmount.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Adresse de livraison
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adresse de livraison',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                       TextFormField(
                         controller: _shippingAddressController,
                         maxLines: 3,
                         decoration: const InputDecoration(
                           labelText: 'Adresse complète',
                           hintText: 'Rue, ville, code postal, pays',
                           border: OutlineInputBorder(),
                         ),
                         validator: (value) {
                           if (value == null || value.isEmpty) {
                             return 'L\'adresse de livraison est requise';
                           }
                           if (value.length < 10) {
                             return 'Veuillez fournir une adresse plus détaillée';
                           }
                           return null;
                         },
                       ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Informations de paiement
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de paiement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Le paiement sera traité lors de la livraison (paiement à la réception)',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Annuler',
                      backgroundColor: Colors.grey,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Confirmer la commande',
                      isLoading: _isLoading,
                      onPressed: _placeOrder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
