import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/audio_model.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';

class FullAudioPlayerScreen extends StatelessWidget {
  final AudioModel audio;

  const FullAudioPlayerScreen({
    super.key,
    required this.audio,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _showSpeedPicker(BuildContext context, AudioPlayerService playerService) {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ValueListenableBuilder<double>(
          valueListenable: playerService.speedNotifier,
          builder: (context, currentSpeed, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'رفتار کا انتخاب (Playback Speed)',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: speeds.map((speed) {
                        final isSelected = (currentSpeed - speed).abs() < 0.05;
                        return ChoiceChip(
                          label: Text('${speed}x'),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryEmerald,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            playerService.setSpeed(speed);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerService = AudioPlayerService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'صوت و بیان (Audio Player)',
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryEmerald,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed_rounded, color: AppTheme.accentGoldLight),
            tooltip: 'رفتار (Speed)',
            onPressed: () => _showSpeedPicker(context, playerService),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Sacred Disc Art
              Center(
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primaryEmerald],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryEmerald.withOpacity(0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.accentGold.withOpacity(0.8),
                      width: 3.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.graphic_eq_rounded,
                        size: 80,
                        color: AppTheme.accentGoldLight,
                      ),
                    ],
                  ),
                ),
              ),

              // Title & Topic Info
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      audio.topic,
                      style: GoogleFonts.amiri(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGoldDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    audio.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ],
              ),

              // Progress Bar & Duration Stream
              StreamBuilder<Duration>(
                stream: playerService.positionStream,
                builder: (context, posSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration?>(
                    stream: playerService.durationStream,
                    builder: (context, durSnapshot) {
                      final duration = durSnapshot.data ?? Duration.zero;
                      final maxSec = duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1.0;
                      final currentSec = position.inMilliseconds
                          .toDouble()
                          .clamp(0.0, maxSec);

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primaryEmerald,
                              inactiveTrackColor: AppTheme.primaryEmerald.withOpacity(0.15),
                              thumbColor: AppTheme.accentGold,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            ),
                            child: Slider(
                              value: currentSec,
                              max: maxSec,
                              onChanged: (val) {
                                playerService.seek(Duration(milliseconds: val.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              // Controls: Replay 10s, Play/Pause, Forward 10s
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -10s
                  IconButton(
                    iconSize: 42,
                    icon: const Icon(Icons.replay_10_rounded, color: AppTheme.primaryEmerald),
                    tooltip: '10 سیکنڈ پیچھے',
                    onPressed: () => playerService.seekBackward(seconds: 10),
                  ),
                  const SizedBox(width: 24),

                  // Play/Pause Main Button
                  ValueListenableBuilder<bool>(
                    valueListenable: playerService.isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: playerService.isLoadingNotifier,
                        builder: (context, isLoading, _) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryEmerald, AppTheme.primaryLight],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryEmerald.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 52,
                              color: Colors.white,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                              onPressed: () => playerService.togglePlayPause(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 24),

                  // +10s
                  IconButton(
                    iconSize: 42,
                    icon: const Icon(Icons.forward_10_rounded, color: AppTheme.primaryEmerald),
                    tooltip: '10 سیکنڈ آگے',
                    onPressed: () => playerService.seekForward(seconds: 10),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
