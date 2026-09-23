import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/audio_model.dart';
import '../../screens/full_audio_player_screen.dart';
import '../../services/audio_player_service.dart';
import '../../theme/app_theme.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = AudioPlayerService();

    return ValueListenableBuilder<AudioModel?>(
      valueListenable: playerService.currentAudioNotifier,
      builder: (context, currentAudio, _) {
        if (currentAudio == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullAudioPlayerScreen(audio: currentAudio),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentGold.withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryDark.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress line
                  StreamBuilder<Duration>(
                    stream: playerService.positionStream,
                    builder: (context, posSnapshot) {
                      final pos = posSnapshot.data?.inMilliseconds ?? 0;
                      return StreamBuilder<Duration?>(
                        stream: playerService.durationStream,
                        builder: (context, durSnapshot) {
                          final dur = durSnapshot.data?.inMilliseconds ?? 1;
                          final progress = (dur > 0 ? pos / dur : 0.0).clamp(0.0, 1.0);

                          return LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.borderGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.accentGoldDark,
                            ),
                            minHeight: 2.5,
                          );
                        },
                      );
                    },
                  ),

                  // Content Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Disc Art
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryDark, AppTheme.primaryEmerald],
                            ),
                            border: Border.all(color: AppTheme.accentGold, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.graphic_eq_rounded,
                            color: AppTheme.accentGoldLight,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Topic
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentAudio.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.amiri(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              Text(
                                currentAudio.topic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Play/Pause
                        ValueListenableBuilder<bool>(
                          valueListenable: playerService.isPlayingNotifier,
                          builder: (context, isPlaying, _) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: playerService.isLoadingNotifier,
                              builder: (context, isLoading, _) {
                                if (isLoading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                }

                                return IconButton(
                                  icon: Icon(
                                    isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: AppTheme.primaryEmerald,
                                    size: 34,
                                  ),
                                  onPressed: () => playerService.togglePlayPause(),
                                );
                              },
                            );
                          },
                        ),

                        // Close Button
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textMuted),
                          onPressed: () => playerService.stop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
