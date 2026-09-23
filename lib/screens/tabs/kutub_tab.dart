import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/book_model.dart';
import '../../services/content_service.dart';
import '../../theme/app_theme.dart';
import '../pdf_viewer_screen.dart';

class KutubTab extends StatefulWidget {
  final bool isAdmin;

  const KutubTab({super.key, this.isAdmin = false});

  @override
  State<KutubTab> createState() => _KutubTabState();
}

class _KutubTabState extends State<KutubTab> {
  final ContentService _contentService = ContentService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('کتاب حذف کریں (Delete Book)'),
        content: Text('کیا آپ واقعی "${book.title}" کو حذف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('منسوخ (Cancel)'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _contentService.deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('حذف کریں (Delete)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'کتاب کا نام یا موضوع تلاش کریں... (Search books)',
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

        // Books Stream List
        Expanded(
          child: StreamBuilder<List<BookModel>>(
            stream: _contentService.streamBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                  ),
                );
              }

              final allBooks = snapshot.data ?? [];
              final filteredBooks = allBooks.where((b) {
                if (_searchQuery.isEmpty) return true;
                return b.title.toLowerCase().contains(_searchQuery) ||
                    b.description.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredBooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories_rounded,
                          size: 64, color: AppTheme.accentGold.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'جلد ہی مبارک کتب اور تحریری خزائن شامل کیے جائیں گے۔'
                              : 'کوئی کتاب دستیاب نہیں ملی۔',
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
                            ? 'Blessed books and holy writings will be uploaded soon.'
                            : 'No matching books found.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.64,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookCard(book);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cover Image with Top Badges
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  book.coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.primaryEmerald.withOpacity(0.08),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => _buildPlaceholderCover(book.title),
                        )
                      : _buildPlaceholderCover(book.title),

                  // Page Count Badge
                  if (book.totalPages > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${book.totalPages} صفحات',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Admin Delete Button
                  if (widget.isAdmin)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.red.shade700.withOpacity(0.85),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                          onPressed: () => _confirmDelete(book),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Title & Read Button
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                if (book.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    book.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
                const SizedBox(height: 8),

                // Read Book Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerScreen(
                          title: book.title,
                          pdfUrl: book.fileUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chrome_reader_mode_rounded, size: 16),
                  label: const Text('مطالعہ کریں', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover(String title) {
    return Container(
      color: AppTheme.primaryEmerald.withOpacity(0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_rounded, size: 40, color: AppTheme.accentGoldDark),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiri(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
