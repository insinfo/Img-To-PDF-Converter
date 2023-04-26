import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_to_pdf_converter/constants/widget_container_dec.dart';
import 'package:img_to_pdf_converter/widgets/app_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWrite;
import 'widgets/raised_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final picker = ImagePicker();

  List<File> imagens = [];
  bool _loading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: body()),
          if (_loading)
            Container(
                color: Color.fromARGB(50, 255, 255, 255),
                child: Center(child: LinearProgressIndicator()))
        ],
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            raisedButton(
              color: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              onPressed: () {
                getImageFromGallery();
              },
              child: Text(
                'Import',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            raisedButton(
              color: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              onPressed: () {
                setState(() {
                  imagens.clear();
                });
              },
              child: Text(
                'Clear',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            raisedButton(
              color: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              onPressed: () {
                FocusScope.of(context).unfocus();
                startTask();
              },
              child: Text(
                'Convert',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        imagens.isEmpty
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    height: 200,
                    width: 200,
                    decoration: widgetBoxDecoration,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        Text(
                          "Click to import images",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    getImageFromGallery();
                  },
                ),
              )
            : Expanded(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: gridViw()),
              ),
      ],
    );
  }

  Widget gridViw() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: imagens.length,
      itemBuilder: (context, index) => Container(
        // color: Colors.black,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: widgetBoxDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(imagens[index], fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: IconButton(
                iconSize: 33,
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.purple,
                ),
                onPressed: () {
                  setState(() {
                    imagens.remove(imagens[index]);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getImageFromGallery() async {
    //source: ImageSource.gallery
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          imagens.add(File(file.path));
        }
      } else {
        print('No image selected');
      }
    });
  }

  Future<void> startTask() async {
    if (imagens.isEmpty) {
      showPrintedMessage('Erro', 'Sem imagem');
      return;
    }
    setState(() {
      _loading = true;
    });
    var paths = imagens.map((e) => e.path).toList().join(';');
    var error = await isolateRun(createPDF, paths);
    print('startTask error $error');
    if (error != null) {
      showPrintedMessage('error', error.toString());
    }
    showPrintedMessage('Sucesso', 'concluido');
    setState(() {
      _loading = false;
    });
  }

  static Future<dynamic> isolateRun(
          Future<dynamic> Function(String) func, paths) =>
      Isolate.run(() => func(paths));

  static Future<dynamic> createPDF(String imageFilePaths) async {
    try {
      var files = imageFilePaths.split(';').map((p) => File(p)).toList();
      for (var img in files) {
        final image = pdfWrite.MemoryImage(img.readAsBytesSync());
        final pdf = pdfWrite.Document();
        pdf.addPage(
          pdfWrite.Page(
              margin: pdfWrite.EdgeInsets.all(0),
              pageFormat: PdfPageFormat.letter,
              build: (pdfWrite.Context contex) {
                return pdfWrite.Center(child: pdfWrite.Image(image));
              }),
        );
        //final Directory? downloadsDir = await getDownloadsDirectory();
        final dir = path.dirname(img.path);
        final oldFileName = path.basenameWithoutExtension(img.path);
        final newPath = path.join(dir, oldFileName + '.pdf');
        final file = File(newPath);
        var bytes = await pdf.save();
        await file.writeAsBytes(bytes);
        print('createPDF $newPath');
      }
      return null;
    } catch (e, s) {
      print('createPDF error $e $s');
      return e;
    }
  }

  showPrintedMessage(String title, String msg) {
    Flushbar(
      title: title,
      message: msg,
      duration: Duration(seconds: 3),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    )..show(context);
  }
}
