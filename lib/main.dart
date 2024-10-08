import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:mom_recipe/confirmation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'recipe.dart';
import 'recipe_database.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CardSliderScreen(),
    );
  }
}

class CardSliderScreen extends StatefulWidget {
  @override
  _CardSliderScreenState createState() => _CardSliderScreenState();
}

class _CardSliderScreenState extends State<CardSliderScreen> {
  final List<Color> cardColors = [
    Colors.red.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
  ];

  List<Map<String,dynamic>> dataValue = [];
   List<Map<String,dynamic>> filteredDataValue = [];
   List<Map<String,dynamic>> beefs = [];
   List<Map<String,dynamic>> pooks = [];
   List<Map<String,dynamic>> chickens = [];
  List<Map<String,dynamic>> fishse = [];
   List<Map<String,dynamic>> yasais = [];
  List<Map<String,dynamic>> sweetses = [];
   List<Map<String,dynamic>> others = [];
   List<bool> _isChecked = [false, false, false,false, false, false, false];
   List<bool> beefB = [true,false,false,false,false,false,false];
   String beef =    "true,false,false,false,false,false,false"; 
   String pook =    "false,true,false,false,false,false,false";
   String chicken = "false,false,true,false,false,false,false";
   String fish =    "false,false,false,true,false,false,false";
   String yasai =   "false,false,false,false,true,false,false";
   String sweets =  "false,false,false,false,false,true,false";
   String other =   "false,false,false,false,false,false,true";
  String? title,recipe,imagePath;
  List<List<bool>> check = [];
 
 
  List<bool> stringToBoolList(String str) {
  return str.split(',').map((value) => value.trim() == 'true').toList();
}

 String boolListToJson(List<bool> list) {
  return jsonEncode(list);
}
  void _loadRecipes2() async {
  final db = RecipeDatabase.instance;
  List<Map<String, dynamic>> result = [];
  
  // 各カテゴリーに基づいてデータを取得
  if (_isChecked[0]) {
    result = await db.getRowsWithSameCategory(beef);
    print("ビーフは$result");
  } else if (_isChecked[1]) {
    result = await db.getRowsWithSameCategory(pook);
  } else if (_isChecked[2]) {
    result = await db.getRowsWithSameCategory(chicken);
  }else if(_isChecked[3]){
    result = await db.getRowsWithSameCategory(fish);
  }else if(_isChecked[4]){
    result = await db.getRowsWithSameCategory(yasai);

  }else if(_isChecked[5]){
    result = await db.getRowsWithSameCategory(sweets);
  }else if(_isChecked[6]){
    result = await db.getRowsWithSameCategory(other);
  }
  // ここで他のカテゴリーも追加

  // 全てのチェックが外れている場合は全データを取得
  if (_isChecked.every((element) => element == false)) {
    result = await db.getData();
  }

  setState(() {
    dataValue = result;
  });
}

  


  
  
   //List<bool> selectedValues = List.filled(7, false); // チェックボックスの選択状態
  List<String> checkValue = ["牛", "豚","鶏", "魚", "野菜", "スイーツ", "その他"];
 
  bool _isRequestingPermissions = false;

Future<void> _requestPermissions() async {
  if (_isRequestingPermissions) {
    return; // すでにリクエスト中の場合は何もしない
  }

  _isRequestingPermissions = true;

  try {
    final status = await Permission.photos.request(); // 例として写真パーミッション
    if (status.isGranted) {
      // パーミッションが許可された場合の処理
    } else if (status.isDenied) {
      _requestPermissions();// パーミッションが拒否された場合の処理
    } else if (status.isPermanentlyDenied) {
      // パーミッションが恒久的に拒否された場合の処理
      // ユーザーに設定画面を開くように促す
    }
  } catch (e) {
    print("Error requesting permissions: $e");
  } finally {
    _isRequestingPermissions = false; // リクエストが完了したらフラグをリセット
  }
}

  @override
  void initState() {
    super.initState();
    //_loadRecipes(_isChecked.toString());
    _requestPermissions();
    _loadRecipes2();

   // loadData();
  }



String assets = "assets/images/not_image.jpeg"; // デフォルト画像のパス
  Uint8List? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ...checkValue.map((item){
               int index = checkValue.indexOf(item);
              return ListTile(
                
               leading: Icon(Icons.restaurant),
               title: Text(item),
               trailing: Checkbox(
                  value: _isChecked[index], // チェックボックスの初期状態
                  onChanged: (bool? value) {
                   
                   setState(() {
                      //_handleCheck(index);
                      _isChecked[index] = value ?? false;
                      print(_isChecked);
                      
                      _loadRecipes2();
                      print(dataValue);
                   });
                  },
                ),
              );
            })
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Recipe()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Slideable Cards'),
        backgroundColor: Colors.deepPurpleAccent,

      ),
body: dataValue.isNotEmpty && _isChecked.every((isChecked) => !isChecked) == true
          ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                print(dataValue);// ローカル変数で画像を管理
                print(item["title"]);
                print(item["checks"]);
                print(item["image"]);
                String localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

                

                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ):_isChecked[0] && dataValue.isNotEmpty
             ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

               

                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          

          :_isChecked[1] == true && dataValue.isNotEmpty
           ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

                
                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"] // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :_isChecked[2] == true && dataValue.isNotEmpty 
            ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

                

                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :_isChecked[3] == true && dataValue.isNotEmpty
            ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

                

                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :_isChecked[4] == true && dataValue.isNotEmpty
               ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

               

                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :_isChecked[5] == true && dataValue.isNotEmpty
               ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

               
                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :_isChecked[6] == true && dataValue.isNotEmpty
               ? PageView.builder(
              itemCount: dataValue.length,
              itemBuilder: (context, index) {
                final item = dataValue[index];
                // ローカル変数で画像を管理
                Uint8List? localImage;
                String localAssets = "assets/images/not_image.jpeg"; // デフォルトのアセット画像
                String encodedImage = item["image"] ?? ""; // Hivedのプロパティ名に変更

                
                return Padding(
                  padding: const EdgeInsets.all(12.0), // 全体のパディングを調整
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: [
                        // 画像部分
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: encodedImage.isNotEmpty && encodedImage != "assets/images/not_image.jpeg" // ローカル変数を使用
                                ? Image.file(
                                  File(encodedImage)
                                    ,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    localAssets, // デフォルト画像を表示
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        // テキスト部分
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0), // 内側の余白
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "タイトル：" + item["title"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "レシピ：" + item["recipe"], // Hivedのプロパティ名に変更
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Confirmation(
                                            id: item["id"], // Hivedのプロパティ名に変更
                                            title: item["title"], // Hivedのプロパティ名に変更
                                            recipe: item["recipe"], // Hivedのプロパティ名に変更
                                            image: item["image"], // Hivedのプロパティ名に変更
                                            check: item["checks"], // Hivedのプロパティ名に変更
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text(
                                        '詳細を見る',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          :Center(child: Text("Not Data"),)
    );
  }
}

void main() async{
  runApp(MyApp());

}
