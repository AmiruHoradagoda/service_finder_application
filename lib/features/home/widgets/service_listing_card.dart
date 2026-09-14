import 'package:flutter/material.dart';
import 'package:service_finder_application/features/posts/models/service_post.dart';

class ServiceListingCard extends StatelessWidget {
  const ServiceListingCard(
      {super.key, required this.post, required this.onTap});
  final ServicePost post;
  final VoidCallback onTap;
  static const accent = Color(0xFF087F88);

  ImageProvider _image(String path) => path.startsWith('assets/')
      ? AssetImage(path)
      : NetworkImage(path) as ImageProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45))),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Stack(children: [
            AspectRatio(
                aspectRatio: 2.15,
                child: post.imageUrls.isEmpty
                    ? _placeholder()
                    : Image(
                        image: _image(post.imageUrls.first),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())),
            Positioned(
                left: 14,
                top: 14,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        child: Text(
                            post.isAsk == true
                                ? 'Service request'
                                : 'Local service',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent))))),
          ]),
          Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      SizedBox(
                          width: 32,
                          height: 32,
                          child: ClipOval(
                              child: post.avatarUrl == null
                                  ? const ColoredBox(
                                      color: Color(0xFFE2F5F5),
                                      child: Icon(Icons.person_outline,
                                          size: 20, color: accent))
                                  : Image(
                                      image: _image(post.avatarUrl!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person_outline)))),
                      const SizedBox(width: 9),
                      Expanded(
                          child: Text(post.username ?? 'Community member',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant))),
                    ]),
                    const SizedBox(height: 12),
                    Text(post.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 19,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4)),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: accent),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(
                              post.location.isEmpty
                                  ? 'Location not provided'
                                  : post.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12))),
                      const Text('View details',
                          style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 5),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 17, color: accent),
                    ]),
                  ])),
        ]),
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
      color: Color(0xFFE2F5F5),
      child: Center(
          child: Icon(Icons.home_repair_service_outlined,
              size: 48, color: accent)));
}
