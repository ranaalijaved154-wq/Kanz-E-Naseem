import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/memory_model.dart';
import '../theme/app_theme.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<MemoryModel> memories;
  final int initialIndex;

  // Backwards compatibility constructor for single memory
  ImageViewerScreen({
    super.key,
    MemoryModel? memory,
    List<MemoryModel>? memories,
    this.initialIndex = 0,
  }) : memories = memories ?? (memory != null ? [memory] : []);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showCaptions = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.memories.isEmpty ? 0 : widget.memories.length - 1,
    );
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white38),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
        ),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.memories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'کوئی تصویر دستیاب نہیں ہے',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentMemory = widget.memories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.55),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentMemory.title,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.memories.length > 1)
              Text(
                'تصویر ${_currentIndex + 1} از ${widget.memories.length}',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppTheme.accentGoldLight,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showCaptions ? Icons.info_rounded : Icons.info_outline_rounded,
              color: _showCaptions ? AppTheme.accentGoldLight : Colors.white70,
            ),
            tooltip: _showCaptions ? 'معلومات چھپائیں' : 'معلومات دکھائیں',
            onPressed: () {
              setState(() {
                _showCaptions = !_showCaptions;
              });
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Swipeable Gallery PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.memories.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              final memory = widget.memories[index];
              return Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5.0,
                  clipBehavior: Clip.none,
                  child: _buildImage(memory.imageUrl),
                ),
              );
            },
          ),

          // Horizontal Navigation Indicators for Gallery
          if (widget.memories.length > 1) ...[
            // Previous button
            if (_currentIndex > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Next button
            if (_currentIndex < widget.memories.length - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],

          // Expandable / Dismissible Caption Card at Bottom
          if (_showCaptions)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGoldDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentMemory.date,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              currentMemory.title,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentMemory.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentMemory.description,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
