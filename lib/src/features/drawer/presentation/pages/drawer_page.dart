import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:liquid_art_ai/src/features/apikey_repository/presentation/apikey_repository_page.dart';
import 'package:liquid_art_ai/src/features/drawer/infrastructure/api_services.dart';
import 'package:liquid_art_ai/src/features/gallery/presentation/pages/galley_page.dart';
import 'package:liquid_art_ai/src/features/home/presentation/page/home_page.dart';
import 'package:liquid_art_ai/src/features/connection/presentation/page/connection_page.dart';
import 'package:liquid_art_ai/src/utils/user_configurations.dart';
import 'package:liquid_art_ai/src/widgets/liquid_art_button.dart';
import 'package:liquid_art_ai/src/widgets/liquid_art_dropdown.dart';
import 'package:liquid_art_ai/src/widgets/liquid_art_text_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  List<String> modes = ["Dall-E", "Stable-Diffusion"];
  List<String> modelValues = ["dall_e", "stable_diffusion"];
  String? modelValue;

  List<String> sizes = ["Small", "Medium", "Large"];
  List<String> sizeValues = ["256x256", "512x512", "1024x1024"];
  String? sizeValue;

  List<String> batchCount = ["0"];
  List<String> batchCountValues = ["0"];
  String? batchCountValue;

  List<String> batchSize = ["0"];
  List<String> batchSizeValues = ["0"];
  String? batchSizeValue;

  List<String> scale = ["0"];
  List<String> scaleValues = ["0"];
  String? scaleValue;

  String image = "";
  String imageBytes = "";
  bool isLoaded = false;
  bool isSaving = false;
  bool placeHolder = true;

  var textController = TextEditingController();

  ScreenshotController screenshotController = ScreenshotController();

  bool isListening = false;
  SpeechToText speechToText = SpeechToText();

  shareImage() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 100), pixelRatio: 1.0)
        .then((Uint8List? img) async {
      if (img != null) {
        final directory = (await getApplicationDocumentsDirectory()).path;
        final filename = "share.png";
        final imgPath = await File("${directory}/$filename").create();
        await imgPath.writeAsBytes(img);

        Share.shareFiles([imgPath.path], text: "Generated by AI - LiquidArtAI");
      }
    });
  }

  downloadImg() async {
    setState(() {
      isSaving = true;
    });
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    var res = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;
    if (res.isGranted) {
      const folder = "LiquidArtAI";
      final path = await getApplicationDocumentsDirectory();
      final imgPath = Directory('${path.path}/$folder');

      final fileName = "${_imagePromptController?.text}.jpg";

      if (await path.exists()) {
        await screenshotController.captureAndSave(imgPath.path,
            delay: const Duration(milliseconds: 100),
            fileName: fileName,
            pixelRatio: 1.0);
      } else {
        await imgPath.create();
        await screenshotController.captureAndSave(imgPath.path,
            delay: const Duration(milliseconds: 100),
            fileName: fileName,
            pixelRatio: 1.0);
      }

      setState(() {
        isSaving = false;
      });
    }
  }

  TextEditingController? _imagePromptController;

  String drawer = "Drawer";

  @override
  void initState() {
    _imagePromptController = TextEditingController(text: '');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          drawer,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Container(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 4,
                              child: LiquidArtDropDown(
                                label: "AI Model",
                                dropValue: modelValue,
                                hintText: "AI Model",
                                values: modelValues,
                                items: modes,
                                onChanged: (value) {
                                  setState(() {
                                    modelValue = value;
                                  });
                                  if (value == 'stable_diffusion') {
                                    sizes.add('LG 3 screens');
                                    sizeValues.add('500x1500');
                                    sizes.add('LG 5 screens');
                                    sizeValues.add('500x2500');
                                  } else {
                                    sizeValue = '1024x1024';
                                    sizes.remove('LG 3 screens');
                                    sizeValues.remove('500x1500');
                                    sizes.remove('LG 5 screens');
                                    sizeValues.remove('500x2500');
                                  }
                                },
                              ),
                            ),
                            const Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Flexible(
                              flex: 3,
                              child: LiquidArtDropDown(
                                label: "Size",
                                dropValue: sizeValue,
                                hintText: "Size",
                                values: sizeValues,
                                items: sizes,
                                onChanged: (value) {
                                  setState(() {
                                    sizeValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: LiquidArtTextField(
                                enabled: modelValue != null,
                                label: 'Image Prompt',
                                hintText: 'Image Prompt',
                                textController: _imagePromptController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                                onTapDown: (details) async {
                                  if (!isListening) {
                                    var available =
                                        await speechToText.initialize();
                                    if (available) {
                                      setState(() {
                                        isListening = true;
                                        speechToText.listen(onResult: (result) {
                                          setState(() {
                                            _imagePromptController =
                                                TextEditingController(
                                                    text:
                                                        result.recognizedWords);
                                          });
                                        });
                                      });
                                    }
                                  }
                                },
                                onTapUp: (details) {
                                  setState(() {
                                    isListening = false;
                                  });
                                  speechToText.stop();
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: isListening
                                      ? Colors.white
                                      : const Color(0xFF4C7BBF),
                                  child: Icon(
                                    Icons.mic,
                                    color: isListening
                                        ? const Color(0xFF4C7BBF)
                                        : Colors.white,
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        LiquidArtTextField(
                          enabled: modelValue == 'stable_diffusion',
                          label: 'Negative Prompt',
                          hintText: 'Negative Prompt',
                          textController: textController,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: LiquidArtTextField(
                                enabled: modelValue == 'stable_diffusion',
                                label: 'Batch Count',
                                hintText: 'Batch Count',
                                textController: textController,
                              ),
                            ),
                            const Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Flexible(
                              flex: 2,
                              child: LiquidArtTextField(
                                enabled: modelValue == 'stable_diffusion',
                                label: 'Batch Size',
                                hintText: 'Batch Size',
                                textController: textController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 4,
                              child: LiquidArtTextField(
                                enabled: modelValue == 'stable_diffusion',
                                label: 'Seed',
                                hintText: 'Seed',
                                textController: textController,
                              ),
                            ),
                            const Flexible(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Flexible(
                              flex: 2,
                              child: LiquidArtTextField(
                                enabled: modelValue == 'stable_diffusion',
                                label: 'CFG Scale',
                                hintText: 'CFG Scale',
                                textController: textController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: LiquidArtButton(
                            label: 'Generate Image',
                            onTap: modelValue != null &&
                                    sizeValue != null &&
                                    _imagePromptController!.text.isNotEmpty
                                ? () async {
                                    setState(() {
                                      isLoaded = false;
                                      placeHolder = false;
                                      image = '';
                                      imageBytes = '';
                                    });
                                    if (modelValue == "dall_e") {
                                      image = await DallE.generateImage(
                                          context,
                                          _imagePromptController!.text,
                                          sizeValue!);
                                    } else {
                                      imageBytes =
                                          await StableDiffusion.generateImage(
                                              context,
                                              _imagePromptController!.text,
                                              sizeValue!);
                                    }
                                    setState(() {
                                      isLoaded = true;
                                    });
                                  }
                                : null,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoaded) ...[
                        if (imageBytes != '')...[
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Screenshot(
                              controller: screenshotController,
                              child: Image.memory(base64Decode(imageBytes)),
                            ),
                          )
                        ]else...[
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Screenshot(
                              controller: screenshotController,
                              child: Image.network(image),
                            ),
                          )
                        ]
                      ] else ...[
                        if (placeHolder) ...[
                          Image.asset('assets/logo/Logo.png')
                        ] else ...[
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ]
                      ],
                      const SizedBox(height: 20),
                      if (isSaving) ...[
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ] else ...[
                        LiquidArtButton(
                          label: 'Save Image',
                          onTap: image != "" || imageBytes != ""
                              ? () async {
                                  await downloadImg();
                                }
                              : null,
                        ),
                      ],
                      const SizedBox(
                        height: 15,
                      ),
                      LiquidArtButton(
                        label: 'Share the Image',
                        onTap: image != ""
                            ? () async {
                                await shareImage();
                              }
                            : null,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: const Color(0xFF4C7BBF),
        children: [
          _buildSpeedDial(
              context,
              'Home Page',
              const Icon(
                Icons.home,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }),
          _buildSpeedDial(
              context,
              'Connection Page',
              const Icon(
                Icons.cast_connected,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ConnectionPage()),
            );
          }),
          _buildSpeedDial(
              context,
              'Gallery Page',
              const Icon(
                Icons.image,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const GalleryPage()),
            );
          }),
          _buildSpeedDial(
              context,
              'API Key',
              const Icon(
                Icons.key,
                color: Colors.white,
              ),
              const Color(0xFF4C7BBF), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const ApiKeyRepositoryPage()),
            );
          }),
        ],
      ),
    );
  }
}

_buildSpeedDial(context, String label, Icon icon, Color backgroundColor,
    Function function) {
  return SpeedDialChild(
    label: label,
    child: icon,
    backgroundColor: backgroundColor,
    onTap: () {
      function();
    },
  );
}
