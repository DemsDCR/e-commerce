import 'package:flutter/material.dart';
class CategoryPage extends StatefulWidget {
  final String title;

  const CategoryPage({super.key, required this.title});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
  
}
List<Map<String, dynamic>> categoryItems = [
  {
    'name': 'iPhone 14 Pro',
    'description': 'Description du produit 1',
  },
  {
    'name': 'iPhone 14',
    'description': 'Description du produit 2',
  },
  {
    'name': 'iPhone 13',
    'description': 'Description du produit 3',
  },
  {
    'name': 'iPhone 12',
    'description': 'Description du produit 4',
  },
  {
    'name': 'iPhone 11',
    'description': 'Description du produit 5',
  },
];
class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.cyan),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: categoryItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = categoryItems[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vous avez sélectionné ${item['name']}')),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.phone_iphone, color: Colors.cyan, size: 32),
                ),
                title: Text(
                  item['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  item['description'],
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
