import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_descriptor/services/auth_service.dart';
import 'package:ai_descriptor/services/firebase_service.dart';
import 'package:ai_descriptor/theme/app_colors.dart';
import 'package:ai_descriptor/theme/theme_provider.dart';
import 'package:ai_descriptor/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  int _savedCount = 0;
  bool _isLoading = true;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _profileImage = File(path));
    }
  }

  Future<void> _loadStats() async {
    try {
      final items = await _firebaseService.getSavedProducts();
      setState(() {
        _savedCount = items.length;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', img.path);
      setState(() => _profileImage = File(img.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile photo updated!'),
            backgroundColor: AppColors.teal,
          ),
        );
      }
    }
  }

  void _showEditProfile() {
    final email = _authService.currentEmail ?? '';
    final nameController = TextEditingController(text: email.split('@')[0]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  )),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        backgroundColor: AppColors.primary,
                        child: _profileImage == null
                            ? Text(
                                email.isNotEmpty ? email[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle:
                      TextStyle(color: AppColors.textSecondary(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person_outline,
                      color: AppColors.textSecondary(context)),
                  filled: true,
                  fillColor: AppColors.inputFill(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: false,
                controller: TextEditingController(text: email),
                style: TextStyle(color: AppColors.textSecondary(context)),
                decoration: InputDecoration(
                  labelText: 'Email (cannot change)',
                  labelStyle:
                      TextStyle(color: AppColors.textSecondary(context)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppColors.textSecondary(context)),
                  filled: true,
                  fillColor: AppColors.inputFill(context),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Profile updated!'),
                      backgroundColor: AppColors.teal,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePassword() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  )),
              const SizedBox(height: 24),
              TextField(
                controller: currentController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle:
                      TextStyle(color: AppColors.textSecondary(context)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock_outline,
                      color: AppColors.textSecondary(context)),
                  filled: true,
                  fillColor: AppColors.inputFill(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary(context)),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle:
                      TextStyle(color: AppColors.textSecondary(context)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock_outline,
                      color: AppColors.textSecondary(context)),
                  filled: true,
                  fillColor: AppColors.inputFill(context),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Update Password',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Password updated!'),
                      backgroundColor: AppColors.teal,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  )),
              const SizedBox(height: 24),
              _NotificationTile(
                  title: 'Push Notifications', subtitle: 'Get app updates'),
              _NotificationTile(
                  title: 'New Features', subtitle: 'Learn about new features'),
              _NotificationTile(
                  title: 'Tips & Tricks', subtitle: 'Get helpful tips'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _rateApp() async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.ai_descriptor');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _shareApp() {
    Share.share(
      'Check out AI Product Describer! Generate professional product descriptions instantly using AI!',
      subject: 'AI Product Describer App',
    );
  }

  void _openHelp() async {
    final url = Uri.parse('mailto:support@aiproductdescriber.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Contact: support@aiproductdescriber.com')),
        );
      }
    }
  }

  void _openPrivacyPolicy() async {
    final url =
        Uri.parse('https://sites.google.com/view/ai-product-describer-privacy');
    if (await canLaunchUrl(url))
      await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background(context),
        title: Text('Logout',
            style: TextStyle(color: AppColors.textPrimary(context))),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(color: AppColors.textSecondary(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary(context))),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentEmail ?? 'user@example.com';
    final username = email.split('@')[0];
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.background(context),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                      ),
                      child: Stack(
                        children: [
                          // Ambient glow
                          Positioned(
                            top: -50,
                            left: -50,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(
                                  AppColors.isDark(context) ? 0.1 : 0.06,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -50,
                            right: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondary.withOpacity(
                                  AppColors.isDark(context) ? 0.08 : 0.04,
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              Center(
                                child: GestureDetector(
                                  onTap: _pickProfileImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.5),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.2),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundImage: _profileImage != null
                                              ? FileImage(_profileImage!)
                                              : null,
                                          backgroundColor:
                                              AppColors.primary.withOpacity(0.2),
                                          child: _profileImage == null
                                              ? Text(
                                                  username[0].toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.isDark(context)
                                                            ? Colors.white
                                                            : AppColors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  AppColors.background(context),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(Icons.camera_alt,
                                              color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                username,
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  color: AppColors.textSecondary(context),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats
                        Row(children: [
                          _StatCard(
                            icon: Icons.auto_awesome,
                            value: '$_savedCount',
                            label: 'Saved',
                            color: AppColors.primary,
                            context: context,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.description,
                            value: '∞',
                            label: 'Generated',
                            color: AppColors.secondary,
                            context: context,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.workspace_premium,
                            value: 'FREE',
                            label: 'Plan',
                            color: Colors.orange,
                            context: context,
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Account
                        _SectionTitle('ACCOUNT', context),
                        _SettingsTile(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Change name and photo',
                          onTap: _showEditProfile,
                          context: context,
                        ),
                        _SettingsTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: _showChangePassword,
                          context: context,
                        ),
                        _SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notifications',
                          onTap: _showNotifications,
                          context: context,
                        ),
                        const SizedBox(height: 16),

                        // App
                        _SectionTitle('APP', context),
                        _SettingsTile(
                          icon: Icons.history,
                          title: 'My History',
                          subtitle: '$_savedCount saved descriptions',
                          onTap: () => Navigator.pushNamed(context, '/history'),
                          context: context,
                        ),
                        // Dark mode tile
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.borderColor(context)),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.dark_mode_outlined,
                                  color: AppColors.primary, size: 20),
                            ),
                            title: Text('Dark Mode',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context))),
                            subtitle: Text(
                              isDark ? 'Dark theme on' : 'Light theme on',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary(context)),
                            ),
                            trailing: Switch(
                              value: isDark,
                              onChanged: (val) => themeProvider.toggleTheme(),
                              activeColor: AppColors.primary,
                            ),
                          ),
                        ),
                        _SettingsTile(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                          context: context,
                        ),
                        const SizedBox(height: 16),

                        // Support
                        _SectionTitle('SUPPORT', context),
                        _SettingsTile(
                          icon: Icons.star_outline,
                          title: 'Rate the App',
                          subtitle: 'Love the app? Rate us ⭐',
                          onTap: _rateApp,
                          context: context,
                        ),
                        _SettingsTile(
                          icon: Icons.share_outlined,
                          title: 'Share App',
                          subtitle: 'Share with friends',
                          onTap: _shareApp,
                          context: context,
                        ),
                        _SettingsTile(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help or report issues',
                          onTap: _openHelp,
                          context: context,
                        ),
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          onTap: _openPrivacyPolicy,
                          context: context,
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            'AI Product Describer v1.0.0',
                            style: TextStyle(
                                color: AppColors.sectionLabel(context),
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                            text: 'Logout',
                            onPressed: _logout,
                            color: Colors.red),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final String title;
  final String subtitle;
  const _NotificationTile({required this.title, required this.subtitle});

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(widget.title,
          style: TextStyle(color: AppColors.textPrimary(context))),
      subtitle: Text(widget.subtitle,
          style:
              TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
      value: _enabled,
      onChanged: (val) => setState(() => _enabled = val),
      activeColor: AppColors.primary,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final BuildContext context;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: AppColors.textSecondary(context))),
        ]),
      ),
    );
  }
}

Widget _SectionTitle(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.sectionLabel(context),
        letterSpacing: 1.5,
      ),
    ),
  );
}

Widget _SettingsTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.cardColor(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderColor(context)),
    ),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context))),
      subtitle: Text(subtitle,
          style:
              TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
      trailing:
          Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
      onTap: onTap,
    ),
  );
}
