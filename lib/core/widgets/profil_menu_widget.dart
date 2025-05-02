import 'package:flutter/material.dart';


class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor
  });
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Color(0xFFE6F0FA)
        ),
        child: Icon(icon, color: Color(0xFF2196F3),),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold).apply(color: textColor),),
      trailing: endIcon? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withValues(alpha: 0.1)
        ),
        child: const Icon(Icons.chevron_right, size: 18, color: Colors.grey,),
      ) : null,
    );
  }
}