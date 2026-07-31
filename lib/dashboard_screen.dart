import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'add_product_screen.dart';
import 'notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
// Local Mock Database Layer for Real-Time Sync without Cloud Delay
final List<Map<String, dynamic>> _localProducts = [
{'id': 1, 'name': 'Wireless Headphones', 'price': 2999, 'stock': 45, 'category': 'Electronics'},
{'id': 2, 'name': 'Running Shoes', 'price': 4500, 'stock': 5, 'category': 'Fashion'},
{'id': 3, 'name': 'Smart Watch', 'price': 5500, 'stock': 12, 'category': 'Electronics'},
];

void _deleteProduct(int index) {
setState(() {
_localProducts.removeAt(index);
});
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Product Deleted!'), backgroundColor: Colors.orange),
);
}

void _showEditSheet(Map<String, dynamic> product, int index) {
final priceController = TextEditingController(text: product['price'].toString());
final stockController = TextEditingController(text: product['stock'].toString());

showModalBottomSheet(
context: context,
isScrollControlled: true,
builder: (context) {
return Padding(
padding: EdgeInsets.only(
top: 16.0, left: 16.0, right: 16.0,
bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Text('Edit ${product['name']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
const SizedBox(height: 16),
TextField(
controller: priceController,
decoration: const InputDecoration(labelText: 'Update Price (Rs.)', border: OutlineInputBorder()),
keyboardType: TextInputType.number,
),
const SizedBox(height: 12),
TextField(
controller: stockController,
decoration: const InputDecoration(labelText: 'Update Stock', border: OutlineInputBorder()),
keyboardType: TextInputType.number,
),
const SizedBox(height: 16),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7)),
onPressed: () {
setState(() {
_localProducts[index]['price'] = double.parse(priceController.text);
_localProducts[index]['stock'] = int.parse(stockController.text);
});
Provider.of<NotificationService>(context, listen: false)
.checkAndAddAlert(product['name'], int.parse(stockController.text));
Navigator.pop(context);
},
child: const Text('Update Changes', style: TextStyle(color: Colors.white)),
)
],
),
);
},
);
}

@override
Widget build(BuildContext context) {
final notifService = Provider.of<NotificationService>(context);
final bool isDark = notifService.isDarkMode;

return Scaffold(
backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
appBar: AppBar(
title: const Text('Smart Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
elevation: 0,
actions: [
IconButton(
icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFF673AB7)),
onPressed: () => notifService.toggleTheme(),
),
Stack(
children: [
IconButton(
icon: const Icon(Icons.notifications, color: Color(0xFF673AB7)),
onPressed: () => _showNotificationDialog(context, notifService),
),
if (notifService.unreadCount > 0)
Positioned(
right: 8, top: 8,
child: Container(
padding: const EdgeInsets.all(2),
decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
child: Text(
'${notifService.unreadCount}',
style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
textAlign: TextAlign.center,
),
),
),
],
),
IconButton(
icon: const Icon(Icons.refresh, color: Color(0xFF673AB7)),
onPressed: () => setState(() {}),
)
],
),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 16),

        // Static Business Insights Metrics Calculation
        Row(
          children: [
            _buildAnalyticsCard('Total Revenue', 'Rs. 57,000', Icons.monetization_on, Colors.green, isDark),
            const SizedBox(width: 12),
            _buildAnalyticsCard('Total Orders', '340', Icons.shopping_bag, Colors.blue, isDark),
          ],
        ),
        const SizedBox(height: 24),

        Text('Sales Performance Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),
        Container(
          height: 220, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: BarChart(BarChartData(
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 12, color: const Color(0xFF673AB7), width: 14)]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 15, color: const Color(0xFF673AB7), width: 14)]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 18, color: const Color(0xFF673AB7), width: 14)]),
              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 22, color: const Color(0xFF673AB7), width: 14)]),
            ],
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
          )),
        ),
        const SizedBox(height: 24),

        Text('Inventory Stock Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 12),

        // Dynamic Re-rendering List synchronized with local additions
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _localProducts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = _localProducts[index];
              final int stock = p['stock'];
              final bool isLowStock = stock <= 10;

              return ListTile(
                onTap: () => _showEditSheet(p, index),
                title: Text(p['name'], style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text('Rs. ${p['price']} | ${p['category']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Stock: $stock', style: TextStyle(color: isLowStock ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteProduct(index),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(
    backgroundColor: const Color(0xFF673AB7),
    child: const Icon(Icons.add, color: Colors.white),
    onPressed: () async {
      // Add product screen se data pull karne ki routing logic
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddProductScreen()),
      );
      // Future functionality mapping hook
    },
  ),
);
}

Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color, bool isDark) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void _showNotificationDialog(BuildContext context, NotificationService service) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notifications Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: service.notifications.isEmpty
              ? const Text('No new alerts.')
              : ListView.builder(
            shrinkWrap: true,
            itemCount: service.notifications.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: Text(service.notifications[index], style: const TextStyle(fontSize: 13)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () { service.clearNotifications(); Navigator.pop(context); }, child: const Text('Clear All', style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      );
    },
  );
}
}
