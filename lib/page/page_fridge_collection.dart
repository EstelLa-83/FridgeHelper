import 'package:flutter/material.dart';
import 'package:fridge/model/fridge.dart';
import 'package:fridge/widget/fridge/fridge_card.dart';
import 'package:fridge/page/page_fridge.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

late final FlutterSecureStorage storage;

class FridgeCollectionPage extends StatefulWidget {
  const FridgeCollectionPage({super.key});

  @override
  State<FridgeCollectionPage> createState() => _FridgeCollectionPageState();
}

class _FridgeCollectionPageState extends State<FridgeCollectionPage> {
  final _unfocusNode = FocusNode();
  List<Fridge> fridgeList = [];

  Future<void> _loadFridgesFromServer() async {
    final token = await storage.read(key: 'accessToken');

    if (token == null) {
      print("Access token not found");
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.0.11:8080/users/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List<Fridge> fetchedFridges = (json["fridges"] as List).map((item) {
        return Fridge(
          fridgeId: item["id"],
          fridgeName: item["name"],
        );
      }).toList();

      setState(() {
        fridgeList = fetchedFridges;
      });
    } 
    else {
      print("Failed to load fridges: ${response.statusCode}");
    }
  }

  @override
  void initState() {
    super.initState();
    storage = const FlutterSecureStorage();
    _loadFridgesFromServer();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Fridge List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 44.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = 0; i < fridgeList.length; i++)
                            FridgeCollectionCard(
                              fridge: fridgeList[i],
                              routefunc: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                              FridgePage(fridgeId: fridgeList[i].fridgeId),
                                  ),
                                );
                              },
                              onEdit: () => _showEditFridgeDialog(fridgeList[i]),
                              onDelete: () => _showDeleteFridgeDialog(fridgeList[i].fridgeId),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => _showCreateFridgeDialog(context),
              child: Container(
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 5.0,
                        color: Color(0x411D2429),
                        offset: Offset(0.0, -2.0),
                      )
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 44.0),
                    child: Text(
                      'Make New Fridge',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateFridgeDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Fridge"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Fridge Name: ',
              hintText: 'Enter fridge name',
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Add"),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final token = await storage.read(key: 'accessToken');
                if (token == null)
                {
                  print("Token not found");
                  Navigator.pop(context);
                  return;
                }

                final response = await http.post(
                  Uri.parse("http://192.168.0.11:8080/fridges?name=$name"),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json",
                  },
                );

                if (response.statusCode == 201) {
                  await _loadFridgesFromServer();
                  Navigator.pop(context);
                } 
                else {
                  print("Failed to create fridge: ${response.statusCode}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create fridge')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditFridgeDialog(Fridge fridge) {
    final TextEditingController nameController =
        TextEditingController(text: fridge.fridgeName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Fridge Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'New Name: ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;

                if (newName == fridge.fridgeName) {
                  Navigator.pop(context);
                  return;
                }

                final token = await storage.read(key: 'accessToken');
                if (token == null) {
                  print("Token not found");
                  Navigator.pop(context);
                  return;
                }

                final response = await http.put(
                  Uri.parse("http://192.168.0.11:8080/fridges/${fridge.fridgeId}"),
                  headers: {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json",
                  },
                  body: jsonEncode({
                    "name": newName,
                  }),
                );

                if (response.statusCode == 200) {
                  await _loadFridgesFromServer();
                } else {
                  print("Failed to edit fridge: ${response.statusCode}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to edit fridge')),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteFridgeDialog(int fridgeId) async {
    final token = await storage.read(key: 'accessToken');
    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Fridge"),
        content: const Text("Are you sure you want to delete this fridge?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse("http://192.168.0.11:8080/fridges/$fridgeId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 204) {
      await _loadFridgesFromServer();
    } 
    else {
      print("Failed to delete fridge: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete fridge")),
      );
    }
  }

}