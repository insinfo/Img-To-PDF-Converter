import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pdfWrite;

import 'export.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String fileName="pdfFile.pdf";
  final picker = ImagePicker();
  final pdf = pdfWrite.Document();
  List<File> image = [];
  final fileNameController = TextEditingController();

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: GestureDetector(
        onTap: ()=>FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            image.isEmpty
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
                        setState(() {
                          fileName = DateTime.now().toString()+".pdf";
                        });

                        getImageFromGallery();
                      },
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        height: 200,
                        width: MediaQuery.of(context).size.width - 20,
                        child: image != null
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: image.length,
                                itemBuilder: (context, index) => Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(8),
                                      height: 200,
                                      width: 200,
                                      decoration: widgetBoxDecoration,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.file(
                                          image[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 15,
                                      right: 15,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        child: Center(
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
            image.isEmpty
                ? SizedBox()
                : Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 15),
                      width: MediaQuery.of(context).size.width - 20,
                      decoration: widgetBoxDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "File Name: ",
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 16,
                                    letterSpacing: 0.5),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 6),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 50,
                                alignment: Alignment.centerRight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.black12, width: 1),
                                ),
                                child: TextField(
                                  controller: fileNameController,
                                  decoration: InputDecoration.collapsed(
                                      hintText:fileName,
                                      hintStyle:
                                          TextStyle(color: Colors.deepPurple)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            image.isEmpty
                ? SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15, left: 20),
                        child: RaisedButton(
                          color: Colors.deepPurple,
                          padding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          onPressed: () {
                            getImageFromGallery();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 66,
                            child: Text(
                              "Import",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 15, right: 20),
                        child: RaisedButton(
                          color: Colors.deepPurple,
                          padding:
                              EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              fileName=fileNameController.text;
                            });
                            createPDF();
                            savePDF();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 66,
                            child: Text(
                              "Convert",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        image.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  createPDF() async {
    for (var img in image) {
      final image = pdfWrite.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pdfWrite.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pdfWrite.Context contex) {
            return pdfWrite.Center(child: pdfWrite.Image(image));
          }));
    }
  }

  savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir.path}/'+fileName);
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage('success', 'saved to documents');
    } catch (e) {
      showPrintedMessage('error', e.toString());
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
