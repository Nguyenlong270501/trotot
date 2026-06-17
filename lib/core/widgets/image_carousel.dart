import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'full_screen_image_viewer.dart';

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.images,
    this.enableFullScreenOnTap = true,
  });

  final List<String> images;
  final bool enableFullScreenOnTap;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          allowImplicitScrolling: true,
          itemCount: widget.images.length,
          onPageChanged: (index) => _currentIndex.value = index,
          itemBuilder: (context, index) {
            final imagePath = widget.images[index];

            final Widget image;
            if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
              image = CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.cover,
                memCacheWidth: 600,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              );
            } else {
              image = Image.file(File(imagePath), fit: BoxFit.cover);
            }

            if (!widget.enableFullScreenOnTap) {
              return image;
            }
            return GestureDetector(
              onTap: () => FullScreenImageViewer.show(
                context,
                imageUrls: widget.images,
                initialIndex: index,
              ),
              child: image,
            );
          },
        ),

        Positioned(
          bottom: 12,
          child: ValueListenableBuilder<int>(
            valueListenable: _currentIndex,
            builder: (context, currentIndex, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (index) {
                  final isActive = index == currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
