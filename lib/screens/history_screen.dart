import 'package:flutter/material.dart';
import 'package:ai_descriptor/models/product_model.dart';
import 'package:ai_descriptor/services/firebase_service.dart';
import 'package:ai_descriptor/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<ProductModel> _items = [];
  bool _isLoading = true;

  final List<String> _tags = [
    'CELESTIAL',
    'KINETIC',
    'NEURAL',
    'LEGACY',
    'VOID',
    'PRIME'
  ];
  final List<Color> _tagColors = [
    Color(0xFF4648D4),
    Color(0xFF8127CF),
    Color(0xFF006B5F),
    Color(0xFF767586),
    Color(0xFF313031),
    Color(0xFFBA1A1A),
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final items = await _firebaseService.getSavedProducts();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _deleteItem(ProductModel item) async {
    await _firebaseService.deleteProduct(item.id);
    setState(() => _items.remove(item));
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generation\nHistory',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review and manage your past AI-synthesized explorations.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : _items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history,
                                  size: 48,
                                  color: AppColors.textSecondary(context)),
                              const SizedBox(height: 16),
                              Text('No records yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 16,
                                  )),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Create First',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final tagColor =
                                _tagColors[index % _tagColors.length];
                            final tag = _tags[index % _tags.length];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cardColor(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.borderColor(context)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: tagColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(tag,
                                            style: TextStyle(
                                              color: tagColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            )),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => _deleteItem(item),
                                        child: Icon(Icons.delete_outline,
                                            color: AppColors.textSecondary(
                                                context),
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(item.name,
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textSecondary(context),
                                        fontSize: 13,
                                        height: 1.5,
                                      )),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(_formatDate(item.createdAt),
                                          style: TextStyle(
                                            color: AppColors.textSecondary(
                                                context),
                                            fontSize: 11,
                                          )),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/result',
                                          arguments: {
                                            'productName': item.name,
                                            'description': item.description,
                                          },
                                        ),
                                        child: const Row(
                                          children: [
                                            Text('VIEW DATA',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                )),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward,
                                                color: AppColors.primary,
                                                size: 12),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar(context),
        border: Border(top: BorderSide(color: AppColors.borderColor(context))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.add_circle_outline,
                  label: 'CREATE',
                  isActive: false,
                  onTap: () => Navigator.pop(context)),
              _NavItem(
                  icon: Icons.history,
                  label: 'HISTORY',
                  isActive: true,
                  onTap: () {}),
              _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'SETTINGS',
                  isActive: false,
                  onTap: () => Navigator.pushNamed(context, '/profile')),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
              size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              )),
        ],
      ),
    );
  }
}
