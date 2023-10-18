import 'package:flutter/material.dart';
import 'package:lectary/utils/colors.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:provider/provider.dart';

class AudioIndicator extends StatelessWidget {
  final String audio;

  const AudioIndicator({required this.audio, super.key});

  @override
  Widget build(BuildContext context) {
    final isAudioOn = context.read<SettingViewModel>().settingPlayMediaWithSound;
    return GestureDetector(
      onTap: () {
        final settings = Provider.of<SettingViewModel>(context, listen: false);
        settings.toggleSettingPlayMediaWithSound();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, bottom: 10),
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 10, top: 3, bottom: 3),
          decoration: BoxDecoration(
            color: ColorsLectary.darkBlue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAudioOn ? Icons.volume_up : Icons.volume_off,
                color: ColorsLectary.lightBlue,
              ),
              const Text(
                " - ",
                style: TextStyle(color: ColorsLectary.lightBlue),
              ),
              Text(
                audio,
                style: const TextStyle(color: ColorsLectary.lightBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
