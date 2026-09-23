import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/memory_model.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../image_viewer_screen.dart';

class YadainTab extends StatefulWidget {
  final bool isAdmin;

  const YadainTab({super.key, this.isAdmin = false});

  @override
  State<YadainTab> createState() => _YadainTabState();
}

class _YadainTabState extends State<YadainTab> {
  final ContentService _contentService = ContentService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true; // Clean grid view is default!

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(MemoryModel memory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('یادگار حذف کریں (Delete Memory)'),
        content: Text('کیا آپ واقعی "${memory.title}" کو حذف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('منسوخ (Cancel)'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _contentService.deleteMemory(memory.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('حذف کریں (Delete)'),
          ),
        ],
      ),
    );
  }

  void _openImageViewer(List<MemoryModel> memories, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          memories: memories,
          initialIndex: index,
        ),
      ),
    );
  }

  Widget _buildImageWidget(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 40, color: AppTheme.textMuted),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) => Container(
        color: AppTheme.primaryEmerald.withOpacity(0.06),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image_rounded, size: 40, color: AppTheme.textMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & View Toggle Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Search Input
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'سوانح، تاریخ یا تصویر تلاش کریں...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryEmerald),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Grid / List View Toggle Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                child: IconButton(
                  icon: Icon(
                    _isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                    color: AppTheme.primaryEmerald,
                  ),
                  tooltip: _isGridView ? 'لسٹ ویو (List View)' : 'گریڈ ویو (Grid View)',
                  onPressed: () {
                    setState(() => _isGridView = !_isGridView);
                  },
                ),
              ),
            ],
          ),
        ),

        // Memories Stream List / Grid
        Expanded(
          child: StreamBuilder<List<MemoryModel>>(
            initialData: _contentService.localMemories,
            stream: _contentService.streamMemories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                  ),
                );
              }

              final allMemories = snapshot.data ?? [];
              final filtered = allMemories.where((m) {
                if (_searchQuery.isEmpty) return true;
                return m.title.toLowerCase().contains(_searchQuery) ||
                    m.description.toLowerCase().contains(_searchQuery) ||
                    m.date.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 64, color: AppTheme.accentGold.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'جلد ہی حضور سرکار جی کی مبارک یادگار تصاویر شامل کی جائیں گی۔'
                              : 'کوئی سوانح دستیاب نہیں ملی۔',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Blessed historical photographs of Sarkar G will be published soon.'
                            : 'No matching records found.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return _isGridView
                  ? _buildGalleryGridView(filtered)
                  : _buildGalleryListView(filtered);
            },
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // CLEAN GRID VIEW FOR YAD E SARKAR G GALLERY
  // -------------------------------------------------------------
  Widget _buildGalleryGridView(List<MemoryModel> memories) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openImageViewer(memories, index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo
                    _buildImageWidget(memory.imageUrl, fit: BoxFit.cover),

                    // Top Gradient & Date Badge
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.isAdmin)
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red.shade700.withOpacity(0.85),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline, size: 14, color: Colors.white),
                                  onPressed: () => _confirmDelete(memory),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGoldDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                memory.date,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Gradient & Title Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.75),
                              Colors.black.withOpacity(0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              memory.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.zoom_in_rounded, size: 13, color: AppTheme.accentGoldLight),
                                    SizedBox(width: 3),
                                    Text(
                                      'بڑا کریں',
                                      style: TextStyle(color: AppTheme.accentGoldLight, fontSize: 10),
                                    ),
                                  ],
                                ),
                                if (memory.description.isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      memory.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // DETAILED LIST VIEW (OPTIONAL ALTERNATIVE)
  // -------------------------------------------------------------
  Widget _buildGalleryListView(List<MemoryModel> memories) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: memories.length,
      itemBuilder: (context, index) {
        final memory = memories[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Date Badge & Delete Option
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(memory),
                      )
                    else
                      const SizedBox.shrink(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: AppTheme.accentGoldDark),
                          const SizedBox(width: 6),
                          Text(
                            memory.date,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGoldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Image Thumbnail
              GestureDetector(
                onTap: () => _openImageViewer(memories, index),
                child: Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.primaryEmerald.withOpacity(0.06),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageWidget(memory.imageUrl, fit: BoxFit.cover),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Zoom',
                                  style: TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Title & Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      memory.title,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    if (memory.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        memory.description,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.amiri(
                          fontSize: 15,
                          color: AppTheme.textDark.withOpacity(0.85),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
