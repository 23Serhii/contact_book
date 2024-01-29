import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageSourceSheet extends StatelessWidget {

  final Function(Future<File?>) onImageSelected;

  const ImageSourceSheet({Key? key, required this.onImageSelected}) : super(key: key);

  void imageSelected(PickedFile? image) async {
    if(image!= null) {
      Future<CroppedFile?> croppedImage = ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      );
      onImageSelected(croppedImage as Future<File?>);
    }
  }


  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              child: const Text('Камера'),
              onPressed: () async {
                // ignore: invalid_use_of_visible_for_testing_member
                PickedFile? image = await ImagePicker.platform.pickImage(source: ImageSource.camera)
                    .then((file) {
                  if(file==null) {
                    return null;
                  } else {
                    return file;
                  }

                });
                imageSelected(image);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextButton(
              child: const Text('Галерея'),
              onPressed: () async {
                // ignore: invalid_use_of_visible_for_testing_member
                PickedFile? image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                imageSelected(image);
              },
            ),
          ),
        ],

      ),
    );
  }


}