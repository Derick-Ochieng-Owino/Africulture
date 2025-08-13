import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int _selectedPlan = 1;

  IconData _getFeatureIcon(String feature) {
    if (feature.contains("weather")) return Icons.cloud;
    if (feature.contains("AI")) return Icons.smart_toy;
    if (feature.contains("transport")) return Icons.local_shipping;
    if (feature.contains("ads")) return Icons.block;
    if (feature.contains("Points")) return Icons.stars;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Choose Your Plan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPlanToggle(),
            const SizedBox(height: 24),
            _buildPlanCard(
              title: "Free",
              price: "Ksh 0",
              subtitle: "Basic features to get started",
              features: [
                "Basic weather data",
                "Limited AI queries",
                "Basic community access",
                "Standard transport booking",
                "Login streaks & badges",
                "Ad-supported"
              ],
              isSelected: _selectedPlan == 0,
              onTap: () => setState(() => _selectedPlan = 0),
              color: Colors.grey[100],
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: "Pro",
              price: "Ksh 1500",
              subtitle: "Monthly billing",
              features: [
                "Real-time weather updates",
                "Unlimited AI queries",
                "Crop image diagnosis",
                "Premium transport options",
                "No ads",
                "Points multiplier",
                "Rewards redemption"
              ],
              isSelected: _selectedPlan == 1,
              onTap: () => setState(() => _selectedPlan = 1),
              color: Colors.teal[50],
              isRecommended: true,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: "Pro Annual",
              price: "Ksh 15,300",
              subtitle: "Save 15% (Billed yearly)",
              features: [
                "Everything in Pro",
                "Annual savings",
                "Priority support"
              ],
              isSelected: _selectedPlan == 2,
              onTap: () => setState(() => _selectedPlan = 2),
              color: Colors.teal[100],
            ),
            const SizedBox(height: 24),
            _buildEnterpriseCard(),
            const SizedBox(height: 24),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.eco, color: Colors.teal, size: 64),
        const SizedBox(height: 8),
        const Text(
          "Upgrade Your Farming Game",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Access premium tools and insights to boost your productivity.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPlanToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlan = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedPlan == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedPlan == 1
                      ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Monthly",
                    style: TextStyle(
                      fontWeight: _selectedPlan == 1 ? FontWeight.bold : FontWeight.normal,
                      color: _selectedPlan == 1 ? Colors.teal : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPlan = 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedPlan == 2 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedPlan == 2
                      ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    "Annual",
                    style: TextStyle(
                      fontWeight: _selectedPlan == 2 ? FontWeight.bold : FontWeight.normal,
                      color: _selectedPlan == 2 ? Colors.teal : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
    required Color? color,
    bool isRecommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.transparent,
            width: 2,
          ),
          color: color,
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 8)]
              : [],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "RECOMMENDED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(_getFeatureIcon(feature), color: Colors.teal, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterpriseCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enterprise", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
            const SizedBox(height: 4),
            Text("For large farms & fleet owners", style: TextStyle(color: Colors.blueGrey[600])),
            const SizedBox(height: 16),
            const Divider(),
            _buildFeatureItem("Custom weather analytics & alerts"),
            _buildFeatureItem("API access to sensor data"),
            _buildFeatureItem("Bulk booking management"),
            _buildFeatureItem("Dedicated support"),
            _buildFeatureItem("Third-party integrations"),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.contact_mail),
              label: const Text("Contact Sales"),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Contact Sales"),
                  content: const Text("Our team will reach out to discuss custom Enterprise solutions."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        String plan = _selectedPlan == 0 ? "Free" : _selectedPlan == 1 ? "Pro Monthly" : "Pro Annual";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected plan: $plan")));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Continue", style: TextStyle(fontSize: 16)),
    );
  }
}
