import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'recipe_database.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Recipe extends StatefulWidget {
  @override
  _Recipe createState() => _Recipe();
}

class _Recipe extends State<Recipe> {
  TextEditingController title = TextEditingController();
  TextEditingController recipe = TextEditingController();

  List<String> checkValue = ["牛", "豚", "鶏", "魚", "野菜", "スイーツ", "その他"];
  List<bool> _isChecked = [false, false, false, false, false, false, false];

  File? _image; // 選択された画像ファイルを保持する変数
  Uint8List? decodedBytes;
  final picker = ImagePicker();

  // チェックボックスが選ばれたときに他を解除するロジック
  void _handleCheck(int index) {
    setState(() {
      for (int i = 0; i < _isChecked.length; i++) {
        _isChecked[i] = false;
      }
      _isChecked[index] = true; // 選択されたチェックボックスのみオンにする
    });
  }

  String? savedImagePath;

  // 画像をローカルストレージに保存するメソッド
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 選択した画像をファイルに保存
      File imageFile = File(pickedFile.path);
      String savedPath = await _saveImageToLocal(imageFile);

      setState(() {
        _image = File(savedPath); // 保存した画像ファイルを設定
        savedImagePath = savedPath; // 保存したパスを保持
      });
    }
  }

  // ローカルストレージに画像を保存
  Future<String> _saveImageToLocal(File imageFile) async {
    try {
      // アプリのドキュメントディレクトリを取得
      final directory = await getApplicationDocumentsDirectory();
      // 保存するファイルパスを設定（元のファイル名を保持）
      final String fileName = basename(imageFile.path);
      final String path = '${directory.path}/$fileName';

      // 画像をコピーして保存
      await imageFile.copy(path);
      return path;
    } catch (e) {
      print("画像の保存に失敗しました: $e");
      return "";
    }
  }

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
    margin: const EdgeInsetsDirectional.all(16),
    content: Row(
      children: const [
        Icon(
          Icons.close,
          color: Colors.red,
        ),
        SizedBox(width: 8),
        Text(
          '入力が足りません！',
          style: TextStyle(color: Colors.green),
        ),
      ],
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    showCloseIcon: true,
    elevation: 4.0,
    backgroundColor: Colors.white,
    dismissDirection: DismissDirection.horizontal,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.photo),
      ),
      appBar: AppBar(
        title: Text("Recipe Text"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: title,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "ここにタイトル！",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: recipe,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: "ここにレシピ！",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: _image != null
                  ? Image.file(
                      _image!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/not_image.jpeg",
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 20),
            Column(
              children: checkValue.map((value) {
                int index = checkValue.indexOf(value);
                return CheckboxListTile(
                  title: Text(value),
                  value: _isChecked[index],
                  onChanged: (bool? value) {
                    _handleCheck(index);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final db = await RecipeDatabase.instance;

                  String recipeText = title.text;
                  String recipeValue = recipe.text;
                  String imagePath = savedImagePath ?? "assets/images/not_image.jpeg";

                  if (_isChecked.contains(true) && recipeText.isNotEmpty && recipeValue.isNotEmpty) {
                    
                    Map<String,dynamic> data = {"title":recipeText,"recipe":recipeValue,"image":imagePath,"checks":_isChecked};

                    await db.insertData(data);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    );
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
    );
  }
}
