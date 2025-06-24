import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NetworkMedia extends StatefulWidget {
  final String url;
  const NetworkMedia(this.url, {Key? key}) : super(key: key);

  @override
  _NetworkMediaState createState() => _NetworkMediaState();
}

class _NetworkMediaState extends State<NetworkMedia> {
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideo;

  bool get isVideo => widget.url.toLowerCase().contains('.webm');

  @override
  void initState() {
    super.initState();
    if (isVideo) {
      _videoController = VideoPlayerController.network(widget.url);
      _initializeVideo = _videoController!.initialize().then((_) {
        _videoController!
          ..setLooping(true)
          ..play();
        setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(NetworkMedia old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _videoController?.dispose();
      _videoController = null;
      _initializeVideo = null;
      if (isVideo) initState(); // re-init
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return FutureBuilder<void>(
        future: _initializeVideo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _videoController!.value.isInitialized) {
            return AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            );
          }
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    // Image fallback
    return Image.network(
      widget.url,
      width: double.infinity,
      fit: BoxFit.fitWidth, // <-- scale to width, no cropping
      errorBuilder: (_, __, ___) => AspectRatio(
        aspectRatio: 16 / 9, // or whatever your cards usually are
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      ),
    );
  }
}
