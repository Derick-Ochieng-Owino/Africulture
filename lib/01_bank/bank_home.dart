import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

class BankScreen extends HookConsumerWidget {
  const BankScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final currentBalance = 12548.00; // Mock data

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.deepOrangeAccent,
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Good Morning, Alex',
                style: TextStyle(
                  color: Colors.grey.shade100,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              background: Container(color: Colors.blueGrey),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey.shade200,
                ),
                onPressed: () {},
                tooltip: 'Notifications',
              ),
            ],
          ),

          // Balance Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.indigo.shade900,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.more_horiz, color: Colors.white70),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '\$${currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Lottie.asset(
                          'assets/animations/wave.json',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildActionItem(context, index),
                childCount: 4,
              ),
            ),
          ),

          // Recent Transactions
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 5,
                    separatorBuilder: (_, _) => Divider(
                      color: Colors.grey.shade300,
                      height: 24,
                      thickness: 1,
                    ),
                    itemBuilder: (_, index) => _buildTransactionItem(index),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, int index) {
    final actions = [
      {'icon': Icons.send, 'label': 'Transfer', 'color': Colors.blue},
      {'icon': Icons.qr_code, 'label': 'Pay', 'color': Colors.orange},
      {'icon': Icons.download, 'label': 'Deposit', 'color': Colors.green},
      {'icon': Icons.pie_chart, 'label': 'Budget', 'color': Colors.purple},
    ];

    final action = actions[index];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Handle action tap
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: (action['color'] as Color?)?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action['icon'] as IconData,
                color: action['color'] as Color,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              action['label'] as String,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(int index) {
    final transactions = [
      {
        'title': 'Grocery Store',
        'amount': '- \$48.75',
        'time': '10:45 AM',
        'icon': Icons.local_grocery_store,
        'color': Colors.redAccent,
      },
      {
        'title': 'Salary Deposit',
        'amount': '+ \$2,450.00',
        'time': 'Aug 1',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Netflix',
        'amount': '- \$14.99',
        'time': 'Jul 30',
        'icon': Icons.movie,
        'color': Colors.redAccent,
      },
      {
        'title': 'Coffee Shop',
        'amount': '- \$5.20',
        'time': 'Jul 28',
        'icon': Icons.local_cafe,
        'color': Colors.redAccent,
      },
      {
        'title': 'Bank Transfer',
        'amount': '+ \$300.00',
        'time': 'Jul 27',
        'icon': Icons.account_balance,
        'color': Colors.green,
      },
    ];

    final transaction = transactions[index];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: (transaction['color'] as Color).withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          transaction['icon'] as IconData,
          color: transaction['color'] as Color,
          size: 28,
        ),
      ),
      title: Text(
        transaction['title'] as String,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        transaction['time'] as String,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: Text(
        transaction['amount'] as String,
        style: TextStyle(
          color: (transaction['amount'] as String).contains('-')
              ? Colors.red.shade700
              : Colors.green.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      horizontalTitleGap: 12,
      minVerticalPadding: 12,
      onTap: () {
        // Optional: handle tap on transaction
      },
    );
  }
}
