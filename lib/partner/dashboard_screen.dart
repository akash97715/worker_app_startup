import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api_client.dart';
import 'package:dio/dio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? mobile;
  String? partnerId;
  String? status;
  String serviceStatus = 'available';

  bool isLoading = true;
  bool _initialized = false;

  Map<String, dynamic>? dashboardData;

  // -------------------------
  // ✅ LIFECYCLE (CORRECT)
  // -------------------------

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      mobile = args['mobile'];
      partnerId = args['partner_id'];
      status = args['status'];
      serviceStatus = args['service_status'] ?? 'available';
    }

    _loadDashboard();
    _initialized = true;
  }

  // -------------------------
  // ✅ API CALLS
  // -------------------------

  Future<void> _loadDashboard() async {
    if (mobile == null) return;

    setState(() => isLoading = true);

    try {
      final response = await ApiClient.dio.get(
        '/partner/info',
        queryParameters: {'mobile_number': mobile},
      );

      if (!mounted) return;

      setState(() {
        dashboardData = response.data;
        status = response.data['status'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load dashboard')),
        );
      }
    }
  }

  Future<void> _updateServiceStatus(String newStatus) async {
    try {
      await ApiClient.dio.post(
        '/partner/update-service-status',
        queryParameters: {
          'mobile_number': mobile,
          'service_status': newStatus,
        },
      );

      if (!mounted) return;

      setState(() {
        serviceStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status updated to ${newStatus.replaceAll('_', ' ')}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // -------------------------
  // ✅ CALL ACTIONS
  // -------------------------

  Future<void> _callCustomer(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer phone number not available')),
      );
      return;
    }

    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callSupport() async {
    const supportNumber = '888890';
    final uri = Uri.parse('tel:$supportNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // -------------------------
  // ✅ STATUS HELPERS
  // -------------------------

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending_verification':
        return Colors.orange;
      case 'approved':
      case 'active':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'not_registered':
        return 'Not Registered';
      case 'mobile_verified':
        return 'Mobile Verified';
      case 'profile_submitted':
        return 'Profile Submitted';
      case 'kyc_submitted':
        return 'KYC Submitted';
      case 'pending_verification':
        return 'Pending Verification';
      case 'approved':
        return 'Approved';
      case 'active':
        return 'Active';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  // -------------------------
  // ✅ UI
  // -------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 16),
                    _buildApplicationStatusCard(),
                    const SizedBox(height: 16),
                    _buildServiceStatusCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
    );
  }

  // -------------------------
  // ✅ UI COMPONENTS
  // -------------------------

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mobile ?? '',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusCard() {
    final color = _getStatusColor(status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 14, color: color),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
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

  Widget _buildServiceStatusCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusChip('available', 'Available', Colors.green),
                _buildStatusChip('not_available', 'Not Available', Colors.red),
                _buildStatusChip('in_service', 'In Service', Colors.blue),
                _buildStatusChip('travelling', 'Travelling', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.phone,
                title: 'Call Support',
                color: Colors.blue,
                onTap: _callSupport,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.phone_in_talk,
                title: 'Call Customer',
                color: Colors.green,
                onTap: () => _callCustomer('1234567890'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final selected = serviceStatus == value;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) {
        if (v) _updateServiceStatus(value);
      },
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? color : Colors.grey.shade300),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
