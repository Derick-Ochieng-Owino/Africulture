import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/data/data_table_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Order Management', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Expanded(
              child: DataTableWidget(
                columns: const ['ID', 'Customer', 'Amount', 'Date', 'Status', 'Actions'],
                rows: orderProvider.orders.map((order) {
                  return {
                    'ID': order.id.toString(),
                    'Customer': order.customerName,
                    'Amount': '\$${order.totalAmount.toStringAsFixed(2)}',
                    'Date': order.orderDate.toString().substring(0, 10),
                    'Status': _buildStatusChip(order.status),
                    'Actions': _buildActions(order),
                  };
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    return Chip(
      label: Text(
        status.displayName,
        style: TextStyle(color: status.color),
      ),
      backgroundColor: status.color.withOpacity(0.1),
    );
  }

  Widget _buildActions(Order order) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () {},
        ),
        if (order.status == OrderStatus.pending)
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {},
          ),
      ],
    );
  }
}