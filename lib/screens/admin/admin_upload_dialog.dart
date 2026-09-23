import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/audio_model.dart';
import '../../models/book_model.dart';
import '../../models/memory_model.dart';
import '../../services/content_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

class AdminUploadDialog extends StatefulWidget {
  const AdminUploadDialog({super.key});

  @override
  State<AdminUploadDialog> createState() => _AdminUploadDialogState();
}

class _AdminUploadDialogState extends State<AdminUploadDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StorageService _storageService = StorageService();
  final ContentService _contentService = ContentService();

  // Book State
  final _bookTitleController = TextEditingController();
  final _bookDescController = TextEditingController();
  final _bookPagesController = TextEditingController();
  File? _bookCoverFile;
  File? _bookPdfFile;

  // Audio State
  final _audioTitleController = TextEditingController();
  final _audioTopicController = TextEditingController(text: 'ملفوظات شریف');
  final _audioDurationController = TextEditingController();
  File? _audioFile;

  // Memory State
  final _memoryTitleController = TextEditingController();
  final _memoryDescController = TextEditingController();
  final _memoryDateController = TextEditingController();
  File? _memoryImageFile;

  // Upload Progress
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  // Local directory detection (D:\Sarkar G Books)
  static const String localFolderPath = 'D:\\Sarkar G Books';
  bool _hasLocalFolder = false;
  List<FileSystemEntity> _localPdfs = [];
  List<FileSystemEntity> _localImages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkLocalFolder();
  }

  void _checkLocalFolder() {
    try {
      final dir = Directory(localFolderPath);
      if (dir.existsSync()) {
        final list = dir.listSync();
        final pdfs = list.where((e) => e.path.toLowerCase().endsWith('.pdf')).toList();
        final imgs = list
            .where((e) =>
                e.path.toLowerCase().endsWith('.jpg') ||
                e.path.toLowerCase().endsWith('.jpeg') ||
                e.path.toLowerCase().endsWith('.png'))
            .toList();

        setState(() {
          _hasLocalFolder = true;
          _localPdfs = pdfs;
          _localImages = imgs;
        });
      }
    } catch (_) {
      _hasLocalFolder = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookTitleController.dispose();
    _bookDescController.dispose();
    _bookPagesController.dispose();
    _audioTitleController.dispose();
    _audioTopicController.dispose();
    _audioDurationController.dispose();
    _memoryTitleController.dispose();
    _memoryDescController.dispose();
    _memoryDateController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------
  // LOCAL QUICK PICKERS (D:\Sarkar G Books)
  // -------------------------------------------------------------

  void _showLocalBookPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                      'D:\\Sarkar G Books سے کتاب منتخب کریں',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
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
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _localPdfs.length,
                    itemBuilder: (context, index) {
                      final file = _localPdfs[index];
                      final name = file.path.split(Platform.pathSeparator).last;
                      final titleWithoutExt = name.replaceAll('.pdf', '');

                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent),
                        title: Text(
                          titleWithoutExt,
                          style: GoogleFonts.amiri(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${(File(file.path).lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () {
                          setState(() {
                            _bookPdfFile = File(file.path);
                            if (_bookTitleController.text.trim().isEmpty) {
                              _bookTitleController.text = titleWithoutExt;
                            }
                          });
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

  void _showLocalImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                      'D:\\Sarkar G Books سے تصویر منتخب کریں',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
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
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _localImages.length,
                    itemBuilder: (context, index) {
                      final file = _localImages[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _memoryImageFile = File(file.path);
                            if (_memoryTitleController.text.trim().isEmpty) {
                              _memoryTitleController.text =
                                  'حضور سرکار جی کی مبارک یادگار';
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                          ),
                        ),
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

  // -------------------------------------------------------------
  // UPLOAD HANDLERS
  // -------------------------------------------------------------

  Future<void> _uploadBook() async {
    final title = _bookTitleController.text.trim();
    if (title.isEmpty) {
      _showMessage('کتاب کا عنوان درج کریں');
      return;
    }
    if (_bookPdfFile == null) {
      _showMessage('براہ کرم پی ڈی ایف فائل منتخب کریں');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'پی ڈی ایف اپلوڈ ہو رہی ہے...';
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Upload Cover if selected
      String coverUrl = '';
      if (_bookCoverFile != null) {
        setState(() => _uploadStatus = 'سرورق (Cover) اپلوڈ ہو رہا ہے...');
        coverUrl = await _storageService.uploadFile(
          folder: 'books/covers',
          fileName: 'cover_$timestamp.jpg',
          file: _bookCoverFile!,
        );
      }

      // 2. Upload PDF
      setState(() => _uploadStatus = 'پی ڈی ایف فائل اپلوڈ ہو رہی ہے...');
      final pdfUrl = await _storageService.uploadFile(
        folder: 'books',
        fileName: 'book_$timestamp.pdf',
        file: _bookPdfFile!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      // 3. Save to Firestore
      final totalPages = int.tryParse(_bookPagesController.text.trim()) ?? 0;
      final book = BookModel(
        id: '',
        title: title,
        description: _bookDescController.text.trim(),
        coverUrl: coverUrl,
        fileUrl: pdfUrl,
        totalPages: totalPages,
        createdAt: DateTime.now(),
      );

      await _contentService.addBook(book);

      if (mounted) {
        Navigator.pop(context);
        _showMessage('کتاب کامیابی سے شامل کر دی گئی ہے۔', isError: false);
      }
    } catch (e) {
      if (mounted) _showMessage('خرابی: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadAudio() async {
    final title = _audioTitleController.text.trim();
    if (title.isEmpty) {
      _showMessage('بیان کا عنوان درج کریں');
      return;
    }
    if (_audioFile == null) {
      _showMessage('براہ کرم آڈیو فائل منتخب کریں');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'آڈیو فائل اپلوڈ ہو رہی ہے...';
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = _audioFile!.path.split('.').last;

      final audioUrl = await _storageService.uploadFile(
        folder: 'audios',
        fileName: 'audio_$timestamp.$ext',
        file: _audioFile!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      final audio = AudioModel(
        id: '',
        title: title,
        topic: _audioTopicController.text.trim().isEmpty
            ? 'ملفوظات شریف'
            : _audioTopicController.text.trim(),
        duration: _audioDurationController.text.trim().isEmpty
            ? '00:00'
            : _audioDurationController.text.trim(),
        fileUrl: audioUrl,
        createdAt: DateTime.now(),
      );

      await _contentService.addAudio(audio);

      if (mounted) {
        Navigator.pop(context);
        _showMessage('بیان کامیابی سے شامل کر دیا گیا ہے۔', isError: false);
      }
    } catch (e) {
      if (mounted) _showMessage('خرابی: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _uploadMemory() async {
    final title = _memoryTitleController.text.trim();
    if (title.isEmpty) {
      _showMessage('عنوان درج کریں');
      return;
    }
    if (_memoryImageFile == null) {
      _showMessage('براہ کرم یادگار تصویر منتخب کریں');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'تصویر اپلوڈ ہو رہی ہے...';
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final imageUrl = await _storageService.uploadFile(
        folder: 'memories',
        fileName: 'memory_$timestamp.jpg',
        file: _memoryImageFile!,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      final memory = MemoryModel(
        id: '',
        title: title,
        description: _memoryDescController.text.trim(),
        imageUrl: imageUrl,
        date: _memoryDateController.text.trim().isEmpty
            ? 'تاریخ نامعلوم'
            : _memoryDateController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _contentService.addMemory(memory);

      if (mounted) {
        Navigator.pop(context);
        _showMessage('یادگار کامیابی سے شامل کر دی گئی ہے۔', isError: false);
      }
    } catch (e) {
      if (mounted) _showMessage('خرابی: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMessage(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : AppTheme.primaryEmerald,
      ),
    );
  }

  // -------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              decoration: const BoxDecoration(
                color: AppTheme.primaryEmerald,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: AppTheme.accentGoldLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ایڈمن مواد اپلوڈ (Upload Content)',
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryEmerald,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.menu_book_rounded), text: 'کتاب (Book)'),
                Tab(icon: Icon(Icons.photo_library_rounded), text: 'یادگار (Memory)'),
                Tab(icon: Icon(Icons.audiotrack_rounded), text: 'بیان (Audio)'),
              ],
            ),

            // Upload Progress Bar
            if (_isUploading)
              Container(
                padding: const EdgeInsets.all(12),
                color: AppTheme.accentGold.withOpacity(0.12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _uploadStatus,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGoldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGoldDark),
                    ),
                  ],
                ),
              ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookUploadTab(),
                  _buildMemoryUploadTab(),
                  _buildAudioUploadTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Book Tab
  Widget _buildBookUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Button if D:\Sarkar G Books exists
          if (_hasLocalFolder && _localPdfs.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: OutlinedButton.icon(
                onPressed: _showLocalBookPicker,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentGoldDark, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                icon: const Icon(Icons.folder_special_rounded, color: AppTheme.accentGoldDark),
                label: Text(
                  'D:\\Sarkar G Books سے کتاب منتخب کریں (${_localPdfs.length} کتب)',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGoldDark,
                  ),
                ),
              ),
            ),
          ],

          TextField(
            controller: _bookTitleController,
            decoration: const InputDecoration(
              labelText: 'کتاب کا عنوان (Book Title)',
              prefixIcon: Icon(Icons.title, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bookDescController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'مختصر تعارف / وضاحت (Description)',
              prefixIcon: Icon(Icons.description, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bookPagesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'کل صفحات (Total Pages)',
              prefixIcon: Icon(Icons.numbers, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 16),

          // Cover Image Picker
          _buildFilePickerTile(
            title: _bookCoverFile != null
                ? 'سرورق منتخب ہو گیا: ${_bookCoverFile!.path.split(Platform.pathSeparator).last}'
                : 'سرورق تصویر منتخب کریں (Pick Cover Image)',
            icon: Icons.image_outlined,
            isPicked: _bookCoverFile != null,
            onTap: () async {
              final file = await _storageService.pickImage();
              if (file != null) setState(() => _bookCoverFile = file);
            },
          ),
          const SizedBox(height: 10),

          // PDF File Picker
          _buildFilePickerTile(
            title: _bookPdfFile != null
                ? 'پی ڈی ایف منتخب: ${_bookPdfFile!.path.split(Platform.pathSeparator).last}'
                : 'پی ڈی ایف فائل منتخب کریں (Pick PDF Document)',
            icon: Icons.picture_as_pdf_outlined,
            isPicked: _bookPdfFile != null,
            onTap: () async {
              final result = await _storageService.pickPdf();
              if (result != null && result.files.single.path != null) {
                setState(() => _bookPdfFile = File(result.files.single.path!));
              }
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadBook,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('کتاب اپلوڈ کریں (Upload Book to /books/)'),
          ),
        ],
      ),
    );
  }

  // 2. Memory Tab
  Widget _buildMemoryUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Button if D:\Sarkar G Books exists
          if (_hasLocalFolder && _localImages.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: OutlinedButton.icon(
                onPressed: _showLocalImagePicker,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentGoldDark, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                icon: const Icon(Icons.photo_library_rounded, color: AppTheme.accentGoldDark),
                label: Text(
                  'D:\\Sarkar G Books سے تصویر منتخب کریں (${_localImages.length} تصاویر)',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGoldDark,
                  ),
                ),
              ),
            ),
          ],

          TextField(
            controller: _memoryTitleController,
            decoration: const InputDecoration(
              labelText: 'عنوان (Title)',
              prefixIcon: Icon(Icons.title, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memoryDateController,
            decoration: const InputDecoration(
              labelText: 'تاریخ یا سن (Date / Era e.g. 1995ء / 1416ھ)',
              prefixIcon: Icon(Icons.calendar_month, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memoryDescController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'سوانحی تفصیل / واقعہ (Description)',
              prefixIcon: Icon(Icons.description, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 16),

          // Image Picker
          _buildFilePickerTile(
            title: _memoryImageFile != null
                ? 'تصویر منتخب ہو گئی: ${_memoryImageFile!.path.split(Platform.pathSeparator).last}'
                : 'یادگار تصویر منتخب کریں (Pick Photograph)',
            icon: Icons.add_photo_alternate_outlined,
            isPicked: _memoryImageFile != null,
            onTap: () async {
              final file = await _storageService.pickImage();
              if (file != null) setState(() => _memoryImageFile = file);
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadMemory,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('یادگار اپلوڈ کریں (Upload Memory to /memories/)'),
          ),
        ],
      ),
    );
  }

  // 3. Audio Tab
  Widget _buildAudioUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _audioTitleController,
            decoration: const InputDecoration(
              labelText: 'بیان کا عنوان (Audio Title)',
              prefixIcon: Icon(Icons.title, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _audioTopicController,
            decoration: const InputDecoration(
              labelText: 'موضوع / کیٹیگری (Topic / Category)',
              hintText: 'ملفوظات شریف / خطبات / محافل',
              prefixIcon: Icon(Icons.category, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _audioDurationController,
            decoration: const InputDecoration(
              labelText: 'دورانیہ (Duration e.g. 45:30)',
              prefixIcon: Icon(Icons.timer_outlined, color: AppTheme.primaryEmerald),
            ),
          ),
          const SizedBox(height: 16),

          // Audio Picker
          _buildFilePickerTile(
            title: _audioFile != null
                ? 'آڈیو فائل منتخب: ${_audioFile!.path.split(Platform.pathSeparator).last}'
                : 'آڈیو فائل منتخب کریں (Pick MP3/Audio File)',
            icon: Icons.audio_file_outlined,
            isPicked: _audioFile != null,
            onTap: () async {
              final result = await _storageService.pickAudio();
              if (result != null && result.files.single.path != null) {
                setState(() => _audioFile = File(result.files.single.path!));
              }
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadAudio,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryEmerald),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('بیان اپلوڈ کریں (Upload Audio to /audios/)'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerTile({
    required String title,
    required IconData icon,
    required bool isPicked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isPicked
              ? AppTheme.primaryEmerald.withOpacity(0.08)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPicked ? AppTheme.primaryEmerald : AppTheme.borderGrey,
            width: isPicked ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPicked ? Icons.check_circle_rounded : icon,
              color: isPicked ? AppTheme.primaryEmerald : AppTheme.accentGoldDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isPicked ? FontWeight.bold : FontWeight.normal,
                  color: isPicked ? AppTheme.primaryEmerald : AppTheme.textDark,
                ),
              ),
            ),
            const Icon(Icons.attachment_rounded, size: 20, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
