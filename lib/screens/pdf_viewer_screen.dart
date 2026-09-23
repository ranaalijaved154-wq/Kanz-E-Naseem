import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 1;
  int _pageCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Bookmarked page numbers
  final Set<int> _bookmarks = {};

  bool get _isNetworkPdf =>
      widget.pdfUrl.startsWith('http://') || widget.pdfUrl.startsWith('https://');

  bool get _isAssetPdf => widget.pdfUrl.startsWith('assets/');

  void _toggleBookmark() {
    setState(() {
      if (_bookmarks.contains(_currentPage)) {
        _bookmarks.remove(_currentPage);
        _showToast('صفحہ $_currentPage سے بک مارک ہٹا دیا گیا');
      } else {
        _bookmarks.add(_currentPage);
        _showToast('صفحہ $_currentPage بک مارک کر لیا گیا');
      }
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
    );
  }

  void _showBookmarksSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sortedBookmarks = _bookmarks.toList()..sort();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'محفوظ شدہ صفحات (Bookmarks)',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                if (sortedBookmarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_border_rounded,
                              size: 40, color: AppTheme.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'کوئی صفحہ بک مارک نہیں کیا گیا۔\n(No pages bookmarked yet)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sortedBookmarks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final page = sortedBookmarks[index];
                        return ListTile(
                          leading: const Icon(Icons.bookmark_rounded,
                              color: AppTheme.accentGoldDark),
                          title: Text(
                            'صفحہ $page (Page $page)',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() {
                                _bookmarks.remove(page);
                              });
                              Navigator.pop(ctx);
                              _showBookmarksSheet();
                            },
                          ),
                          onTap: () {
                            _pdfViewerController.jumpToPage(page);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showJumpToPageDialog() {
    final textController = TextEditingController(text: '$_currentPage');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'صفحہ پر جائیں (Go to Page)',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryEmerald,
            ),
          ),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '1 - $_pageCount',
              prefixIcon: const Icon(Icons.find_in_page_rounded, color: AppTheme.accentGold),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('منسوخ (Cancel)'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(textController.text.trim());
                if (page != null && page >= 1 && page <= _pageCount) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
              ),
              child: const Text('جائیں (Go)'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentPageBookmarked = _bookmarks.contains(_currentPage);

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryEmerald,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Bookmark Toggle
          IconButton(
            icon: Icon(
              isCurrentPageBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isCurrentPageBookmarked ? AppTheme.accentGoldLight : Colors.white,
            ),
            tooltip: 'بک مارک (Bookmark page)',
            onPressed: _toggleBookmark,
          ),

          // View All Bookmarks
          IconButton(
            icon: const Icon(Icons.bookmarks_rounded, color: Colors.white),
            tooltip: 'بک مارکس لسٹ (All bookmarks)',
            onPressed: _showBookmarksSheet,
          ),

          // Jump to page
          if (_pageCount > 0)
            IconButton(
              icon: const Icon(Icons.find_in_page_rounded, color: AppTheme.accentGoldLight),
              tooltip: 'صفحہ تلاش کریں (Jump to Page)',
              onPressed: _showJumpToPageDialog,
            ),

          // Zoom In
          IconButton(
            icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
            tooltip: 'بڑا کریں (Zoom In)',
            onPressed: () {
              _pdfViewerController.zoomLevel =
                  (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.5);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Render Asset, Network or Local File PDF
          _isAssetPdf
              ? SfPdfViewer.asset(
                  widget.pdfUrl,
                  controller: _pdfViewerController,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    setState(() {
                      _pageCount = details.document.pages.count;
                      _isLoading = false;
                      _errorMessage = null;
                    });
                  },
                  onPageChanged: (PdfPageChangedDetails details) {
                    setState(() {
                      _currentPage = details.newPageNumber;
                    });
                  },
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = details.description;
                    });
                  },
                )
              : _isNetworkPdf
                  ? SfPdfViewer.network(
                      widget.pdfUrl,
                      controller: _pdfViewerController,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _pageCount = details.document.pages.count;
                          _isLoading = false;
                          _errorMessage = null;
                        });
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = details.description;
                        });
                      },
                    )
                  : SfPdfViewer.file(
                      File(widget.pdfUrl),
                      controller: _pdfViewerController,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _pageCount = details.document.pages.count;
                          _isLoading = false;
                          _errorMessage = null;
                        });
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = details.description;
                        });
                      },
                    ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                ),
              ),
            ),

          // Error view
          if (_errorMessage != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    const Text(
                      'کتاب کھولنے میں دشواری پیش آئی ہے',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryEmerald,
                      ),
                      child: const Text('دوبارہ کوشش کریں (Retry)'),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Floating Page Indicator Badge
          if (_pageCount > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showJumpToPageDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isCurrentPageBookmarked
                            ? AppTheme.accentGoldLight
                            : AppTheme.accentGold.withOpacity(0.5),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrentPageBookmarked) ...[
                          const Icon(Icons.bookmark_rounded,
                              size: 16, color: AppTheme.accentGoldLight),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          'صفحہ $_currentPage از $_pageCount',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
