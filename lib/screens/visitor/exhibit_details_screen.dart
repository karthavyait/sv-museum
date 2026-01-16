import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/exhibit.dart';
import '../../widgets/audio_player_widget.dart';

class ExhibitDetailsScreen extends StatefulWidget {
  const ExhibitDetailsScreen({super.key, required this.exhibit});

  final Exhibit exhibit;

  @override
  State<ExhibitDetailsScreen> createState() => _ExhibitDetailsScreenState();
}

class _ExhibitDetailsScreenState extends State<ExhibitDetailsScreen> {
  late final FlutterTts _tts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();

    _tts = FlutterTts();

    // Basic settings (works offline using device voices)
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS error: $message')),
      );
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleTts() async {
    final text =
        '${widget.exhibit.title}. ${widget.exhibit.description}'.trim();

    if (text.isEmpty) return;

    if (_isSpeaking) {
      await _tts.stop();
      return;
    }

    // (Optional) Try English voice. If device doesn't support, it will fallback.
    // You can later switch to "en-IN" or "kn-IN" based on content.
    await _tts.setLanguage('en-IN');

    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final exhibit = widget.exhibit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exhibit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              await Share.share('${exhibit.title}\n\n${exhibit.description}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row + TTS button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exhibit.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  tooltip: _isSpeaking ? 'Stop voice' : 'Listen (TTS)',
                  icon: Icon(
                    _isSpeaking
                        ? Icons.stop_circle_outlined
                        : Icons.record_voice_over_outlined,
                  ),
                  onPressed: _toggleTts,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Image
            if (exhibit.imagePath != null &&
                File(exhibit.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(exhibit.imagePath!)),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.image_outlined, size: 64),
              ),

            const SizedBox(height: 16),

            // Description
            Text(
              exhibit.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                  ),
            ),

            const SizedBox(height: 24),

            // Audio Guide heading + play
            Text(
              'Audio Guide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            AudioPlayerWidget(audioPath: exhibit.audioPath),

            const SizedBox(height: 16),

            // Small help line
            Text(
              'Tip: Use the voice button near the title to listen instantly (works offline).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
