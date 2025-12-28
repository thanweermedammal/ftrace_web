import 'package:flutter/material.dart';
class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || isHover;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active ? Colors.blue.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // ICON MOVE
              AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: isHover ? const Offset(0.15, 0) : Offset.zero,
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: active ? Colors.blue : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                  widget.selected ? FontWeight.w600 : FontWeight.w400,
                  color: active ? Colors.blue : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
