import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ai_descriptor/models/product_model.dart';
import 'package:ai_descriptor/services/firebase_service.dart';
import 'package:ai_descriptor/theme/app_colors.dart';

class ResultScreen extends StatefulWidget {
  final String productName;
  final String description;

  const ResultScreen({
    super.key,
    required this.productName,
    required this.description,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isSaving = false;
  bool _saved = false;

  void _saveToHistory() async {
    if (_saved) return;
    setState(() => _isSaving = true);
    try {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: widget.productName,
        description: widget.description,
        createdAt: DateTime.now(),
      );
      await _firebaseService.saveProduct(product);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Saved to library!'),
            backgroundColor: AppColors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.description));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  void _shareDescription() {
    Share.share('${widget.productName}\n\n${widget.description}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ambientGlow(context),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.borderColor(context)),
                          ),
                          child: Icon(Icons.arrow_back,
                              color: AppColors.textSecondary(context),
                              size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Refined Copy',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share_outlined,
                            color: AppColors.textSecondary(context)),
                        onPressed: _shareDescription,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your AI-generated description is ready.',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.borderColor(context)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: [
                                  _Badge(
                                      label: 'AI Generated',
                                      color: AppColors.teal),
                                  _Badge(
                                      label: 'High Conversion',
                                      color: AppColors.teal),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.productName,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.description,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _copyToClipboard,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon:
                                      const Icon(Icons.content_copy, size: 16),
                                  label: const Text('Copy Description'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _saveToHistory,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _saved
                                        ? AppColors.teal
                                        : AppColors.primary,
                                    side: BorderSide(
                                      color: _saved
                                          ? AppColors.teal
                                          : AppColors.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(
                                      _saved
                                          ? Icons.check
                                          : Icons.bookmark_outline,
                                      size: 16),
                                  label: Text(
                                      _saved ? 'Saved ✓' : 'Save to Library'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.borderColor(context)),
                                ),
                                child: Icon(Icons.refresh,
                                    color: AppColors.textSecondary(context),
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'GENERATE ANOTHER',
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
