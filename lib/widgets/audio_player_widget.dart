import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key, required this.audioPath});

  final String? audioPath;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _player.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
    _player.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.audioPath == null) {
      return;
    }

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioPath!));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioPath == null) {
      return const Text('Audio not added yet');
    }

    final fileExists = File(widget.audioPath!).existsSync();
    if (!fileExists) {
      return const Text('Audio file not found.');
    }

    final sliderMax = _duration.inMilliseconds.toDouble().clamp(1, double.infinity);
    final sliderValue = _position.inMilliseconds.toDouble().clamp(0, sliderMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
              iconSize: 42,
              onPressed: _togglePlay,
            ),
            Expanded(
              child: Slider(
                value: sliderValue,
                max: sliderMax,
                onChanged: (value) async {
                  final position = Duration(milliseconds: value.toInt());
                  await _player.seek(position);
                  setState(() {
                    _position = position;
                  });
                },
              ),
            ),
          ],
        ),
        Text(
          '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
