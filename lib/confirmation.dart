import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mom_recipe/main.dart';  // MyAppをインポート
import 'package:mom_recipe/recipe_database.dart';  // RecipeDatabaseをインポート
import 'package:path_provider/path_provider.dart';  // ローカルディレクトリにアクセスするためのパッケージ

class Confirmation extends StatefulWidget {
  String title = "";
  String recipe = "";
  String image = "";
  String check = "";
  int id = 0;

  Confirmation({required this.id, required this.title, required this.recipe, required this.image, required this.check});

  @override
  _Confirmation createState() => _Confirmation();
}

class _Confirmation extends State<Confirmation> {
  late TextEditingController titleController;
  late TextEditingController recipeController;
  Uint8List? decodedBytes;
  String input = "";
  List<String> checkValue = ["牛", "豚", "鶏", "魚", "野菜", "スイーツ", "その他"];
  late List<bool> checkList;
  String? base64Image ;





  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    recipeController = TextEditingController(text: widget.recipe);
   
    input = widget.check;
    print(input);
    checkList = widget.check.split(',').map((str) => str.toLowerCase() == 'true').toList();
    print(checkList);
  }

  void _handleCheck(int index) {
    setState(() {
      for (int i = 0; i < checkList.length; i++) {
        checkList[i] = false;
      }
      checkList[index] = true;
    });
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Row(
      children: const [
        Icon(Icons.close, color: Colors.red),
        SizedBox(width: 8),
        Text('入力が足りません！', style: TextStyle(color: Colors.red)),
      ],
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    backgroundColor: Colors.white,
  );

  File? _storedImage;
  final picker = ImagePicker();

  // ローカルディレクトリに画像を保存する関数
  Future<String> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = image.path.split('/').last;
    final localImage = await image.copy('${directory.path}/$fileName');
    return localImage.path;
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // 画像をローカルディレクトリに保存
      String imagePath = await saveImageLocally(imageFile);
      
      setState(() {
        _storedImage = File(imagePath);
        base64Image = base64Encode(imageFile.readAsBytesSync())?? widget.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CardSliderScreen()));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "ここにタイトル！",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: recipeController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: "ここにレシピ！",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: base64Image != "assets/images/not_image.jpeg"
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.image),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/not_image.jpeg",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Column(
              children: checkValue.map((value) {
                int index = checkValue.indexOf(value);
                return CheckboxListTile(
                  title: Text(value),
                  value: checkList[index],
                  onChanged: (bool? value) {
                    _handleCheck(index);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final db = await RecipeDatabase.instance;
                  String recipeText = titleController.text;
                  String recipeValue = recipeController.text;
                  String imagePath = _storedImage?.path ?? widget.image;

                   if (checkList.contains(true) && recipeText.isNotEmpty && recipeValue.isNotEmpty) {
                   // RecipeDatabaseのメソッドを呼び出す
                    await db.updateData(widget.id, recipeText, recipeValue, imagePath, checkList);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text("保存", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.photo),
      ),
    );
  }
}
