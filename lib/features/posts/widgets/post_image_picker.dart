import 'dart:typed_data';
import 'package:flutter/material.dart';

class PostImagePicker extends StatelessWidget {
  const PostImagePicker(
      {super.key,
      required this.images,
      required this.onPick,
      required this.onRemove});
  final List<Uint8List?> images;
  final ValueChanged<int> onPick, onRemove;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth >= 460 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
          itemBuilder: (context, index) => Material(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant)),
            clipBehavior: Clip.antiAlias,
            child: images[index] == null
                ? InkWell(
                    onTap: () => onPick(index),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              color: Color(0xFF087F88), size: 30),
                          const SizedBox(height: 8),
                          Text('Photo ${index + 1}',
                              style: const TextStyle(fontSize: 12)),
                        ]))
                : Stack(fit: StackFit.expand, children: [
                    Image.memory(images[index]!, fit: BoxFit.cover),
                    Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filled(
                            tooltip: 'Remove photo ${index + 1}',
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white),
                            onPressed: () => onRemove(index),
                            icon: const Icon(Icons.close, size: 18))),
                  ]),
          ),
        );
      });
}
