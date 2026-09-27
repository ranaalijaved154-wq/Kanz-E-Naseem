import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../models/audio_model.dart';
import '../../services/audio_player_service.dart';
import '../../services/content_service.dart';
import '../../services/url_service.dart';
import '../../theme/app_theme.dart';
import '../full_audio_player_screen.dart';

class SoutTab extends StatefulWidget {
  final bool isAdmin;

  const SoutTab({super.key, this.isAdmin = false});

  @override
  State<SoutTab> createState() => _SoutTabState();
}

class _SoutTabState extends State<SoutTab> {
  final ContentService _contentService = ContentService();
  final AudioPlayerService _playerService = AudioPlayerService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedTopic = 'تمام';
  String _searchQuery = '';

  final List<String> _topics = [
    'تمام',
    'ویڈیو بیانات (YouTube)',
    'ملفوظات شریف',
    'خطبات و بیانات',
    'روحانی محافل',
    'دعائیہ کلمات',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(AudioModel audio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('آڈیو حذف کریں (Delete Audio)'),
        content: Text('کیا آپ واقعی "${audio.title}" کو حذف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('منسوخ (Cancel)'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _contentService.deleteAudio(audio.id);
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
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'بیان یا عنوان تلاش کریں... (Search audio)',
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

        // YouTube Official Channel Banner
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => UrlService.openYouTubeChannel(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E1B1B), // Elegant Islamic Dark Crimson
                      Color(0xFFC4302B), // YouTube Red
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'یوٹیوب آفیشل چینل',
                                style: GoogleFonts.amiri(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  AppConstants.youtubeChannelHandle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'حضور قبلہ سرکار صوفی نسیم احمد قدس سرہ کے تمام ویڈیو بیانات دیکھنے کے لیے کلک کریں',
                            style: GoogleFonts.amiri(
                              color: Colors.white.withOpacity(0.92),
                              fontSize: 11,
                              height: 1.25,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'چینل دیکھیں',
                            style: GoogleFonts.amiri(
                              color: const Color(0xFFC4302B),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 11,
                            color: Color(0xFFC4302B),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Topic Filter Chips
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = _selectedTopic == topic;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ChoiceChip(
                  label: Text(topic),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryEmerald,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedTopic = topic);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Audio Playlist Stream
        Expanded(
          child: StreamBuilder<List<AudioModel>>(
            initialData: _contentService.localAudios,
            stream: _contentService.streamAudios(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                  ),
                );
              }

              final allAudios = snapshot.data ?? [];
              final filteredAudios = allAudios.where((a) {
                final matchesTopic =
                    _selectedTopic == 'تمام' || a.topic.trim() == _selectedTopic.trim();
                final matchesQuery = _searchQuery.isEmpty ||
                    a.title.toLowerCase().contains(_searchQuery) ||
                    a.topic.toLowerCase().contains(_searchQuery);
                return matchesTopic && matchesQuery;
              }).toList();

              if (filteredAudios.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.graphic_eq_rounded,
                          size: 64, color: AppTheme.accentGold.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'جلد ہی مبارک بیانات اور آڈیو ریکارڈنگز شامل کی جائیں گی۔'
                              : 'کوئی بیان دستیاب نہیں ملا۔',
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
                            ? 'Blessed lectures and audio recordings will be uploaded soon.'
                            : 'No matching audio tracks found.',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                itemCount: filteredAudios.length,
                itemBuilder: (context, index) {
                  final audio = filteredAudios[index];
                  return _buildAudioCard(audio);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioCard(AudioModel audio) {
    final isYouTube = audio.fileUrl.contains('youtube.com') ||
        audio.fileUrl.contains('youtu.be');

    if (isYouTube) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade300,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade600,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          title: Text(
            audio.title,
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_display_rounded, size: 12, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'ویڈیو بیان (یوٹیوب)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                audio.topic,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.accentGoldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          trailing: widget.isAdmin
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(audio),
                )
              : IconButton(
                  icon: const Icon(Icons.open_in_new_rounded, color: Colors.redAccent),
                  onPressed: () => UrlService.launchWebUrl(context, audio.fileUrl),
                ),
          onTap: () => UrlService.launchWebUrl(context, audio.fileUrl),
        ),
      );
    }

    return ValueListenableBuilder<AudioModel?>(
      valueListenable: _playerService.currentAudioNotifier,
      builder: (context, currentAudio, _) {
        final isThisTrackActive = currentAudio?.id == audio.id;

        return ValueListenableBuilder<bool>(
          valueListenable: _playerService.isPlayingNotifier,
          builder: (context, isPlaying, _) {
            final isCurrentPlaying = isThisTrackActive && isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isThisTrackActive
                    ? AppTheme.primaryEmerald.withOpacity(0.04)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isThisTrackActive
                      ? AppTheme.accentGold
                      : AppTheme.borderGrey.withOpacity(0.7),
                  width: isThisTrackActive ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isThisTrackActive
                        ? AppTheme.primaryEmerald
                        : AppTheme.primaryEmerald.withOpacity(0.1),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isCurrentPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isThisTrackActive ? Colors.white : AppTheme.primaryEmerald,
                      size: 26,
                    ),
                    onPressed: () {
                      if (isThisTrackActive) {
                        _playerService.togglePlayPause();
                      } else {
                        _playerService.playAudio(audio);
                      }
                    },
                  ),
                ),
                title: Text(
                  audio.title,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isThisTrackActive
                        ? AppTheme.primaryDark
                        : AppTheme.textDark,
                  ),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.borderGrey.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        audio.duration,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ),
                    // Topic
                    Text(
                      audio.topic,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentGoldDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                trailing: widget.isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(audio),
                      )
                    : IconButton(
                        icon: const Icon(Icons.chevron_left_rounded,
                            color: AppTheme.textMuted),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullAudioPlayerScreen(audio: audio),
                            ),
                          );
                        },
                      ),
                onTap: () {
                  if (!isThisTrackActive) {
                    _playerService.playAudio(audio);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullAudioPlayerScreen(audio: audio),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
