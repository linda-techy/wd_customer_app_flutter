import 'package:flutter/material.dart';

class DividerListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final double? minLeadingWidth;

  const DividerListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.minLeadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          leading: leading,
          trailing: trailing,
          onTap: onTap,
          minLeadingWidth: minLeadingWidth,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class DividerListTileWithTrilingText extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? leading;
  final String? svgSrc;
  final VoidCallback? onTap;
  final bool showDivider;

  const DividerListTileWithTrilingText({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.leading,
    this.svgSrc,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle!) : null,
          leading: leading,
          trailing: trailingText != null
              ? Text(
                  trailingText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                )
              : null,
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
