import 'dart:async';


import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taqam/modules/ta2m_Chats_screen/cubit/cubit.dart';

import 'DetailsChat_screen.dart';


class Audio_player extends StatefulWidget {
  final String url;
  final String urlImage;
  final AudioPlayer audioPlayer;
  final bool isme;

  final String time;
  final bool read;
  static String? currentAudioUrl;

  Audio_player(
      {super.key, required this.audioPlayer, required this.urlImage, required this.url, required this.isme, required this.time, required this.read,});

  @override
  State<Audio_player> createState() => _Audio_playerState();
}

class _Audio_playerState extends State<Audio_player> {
  late AudioPlayer audioplayer;
  late StreamSubscription<PlayerState> playerStateChangedListener;
  late StreamSubscription<Duration> durationChangedListener;
  late StreamSubscription<Duration> positionChangedListener;
  late StreamSubscription<void> playerCompleteListener;
  late Future<dynamic>setaudio;

  @override
  void initState() {
    super.initState();
    var cubit = ChatCubit.get(context);
    audioplayer = widget.audioPlayer;

    setAudio().then((value) {
      setState(() {});
    });


    playerStateChangedListener =
        audioplayer.onPlayerStateChanged.listen((state) {
          setState(() {
            isplaying = state == PlayerState.playing;
          });
        });

    durationChangedListener = audioplayer.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });

    positionChangedListener = audioplayer.onPositionChanged.listen((event) {
      setState(() {
        postion = event;
      });
    });

    playerCompleteListener = audioplayer.onPlayerComplete.listen((event) {
      audioplayer.seek(Duration.zero);
      setState(() {
        isplaying = false;
        postion = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    playerStateChangedListener.cancel();
    durationChangedListener.cancel();
    positionChangedListener.cancel();
    playerCompleteListener.cancel();
    duration = Duration.zero;
    postion = Duration.zero;
    audioplayer.dispose();
    super.dispose();
  }

  Future setAudio() async {
    await audioplayer.setSourceUrl(widget.url).then((value) {

    });
  }

  Future<void> playAudio(String audioUrl) async {
    if (Audio_player.currentAudioUrl != null) {
      await DetailsChatScreen.audios[Audio_player.currentAudioUrl]!
          .pause();
    }
    //await setAudio();
    await audioplayer.play(UrlSource(audioUrl));

    setState(() {
      Audio_player.currentAudioUrl = audioUrl;
    });
  }

  Future<void> pauseAudio() async {
    await audioplayer.pause();
  }

  bool isplaying = false;

  Duration duration = Duration.zero;
  Duration postion = Duration.zero;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery
        .of(context)
        .size;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: mq.width * 0.67, maxHeight: 60),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
                color: widget.isme ? Colors.blue.withOpacity(0.2) : Colors
                    .grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: widget.isme
                      ? const Radius.circular(0)
                      : const Radius.circular(14),
                  bottomRight: !widget.isme
                      ? const Radius.circular(0)
                      : const Radius.circular(14),
                ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(

                  padding: const EdgeInsets.only(bottom: 4),
                  child: Slider(
                      inactiveColor: widget.isme ? Colors.grey : Colors.blue
                          .shade100,
                      value: postion.inSeconds.toDouble(),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await audioplayer.seek(position);
                        if (isplaying) {
                          await audioplayer.resume();
                        }
                      }),
                ),

              ),
              IconButton(
                onPressed: () async {
                  if (isplaying) {
                    await pauseAudio();
                  } else {
                    await playAudio(widget.url);
                  }
                },
                icon: Icon(
                  isplaying ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    width: mq.height * .06,
                    height: mq.height * .06,
                    imageUrl: widget.urlImage,
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                          'asets/image/profileman2.png'),
                    ),
                  ),
                ),
              ),

            ],
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Icon(Icons.done_all_outlined,
                    color: widget.read == true ? Colors.greenAccent : Colors
                        .black54, size: 15),
                const SizedBox(width: 3,),
                SizedBox(
                  width: mq.width * 0.25, // Set the desired width
                  child: Text(
                    widget.time,
                    style: const TextStyle(
                        overflow: TextOverflow.clip, fontSize: 10),
                    maxLines: 1,
                  ),
                ),
                if (!isplaying)
                  Text(formatTime(duration - postion)),
                if (isplaying)
                  Text(formatTime(postion)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String towDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  String formatTime(Duration duration) {
    final hours = towDigits(duration.inHours);
    final minutess = towDigits(duration.inMinutes.remainder(60));
    final seconds = towDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutess, seconds].join(':');
  }
}
