import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fridge/widget/fridge/food_card.dart';

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  List info = [];

  void saveFoodInfo(List foodList) async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(foodList); // List<Map> → JSON 문자열
    await prefs.setString('cached_food_list', encoded);
  }

  Future<List> loadFoodInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('cached_food_list');

    if (jsonString != null) {
      return jsonDecode(jsonString); // JSON 문자열 → List
    } else {
      return []; // 없으면 빈 리스트 반환
    }
  }

  void sortByExpiryDate(List list) {
    list.sort((a, b) {
      final dateA = DateTime.tryParse(a["expiryDate"]);
      final dateB = DateTime.tryParse(b["expiryDate"]);
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });
  }

  void addFood(Map<String, dynamic> food) {
    setState(() {
      info.add(food);
      sortByExpiryDate(info);
    });
    saveFoodInfo(info);
  }

  @override
  void initState() {
    super.initState();
    loadFoodInfo().then((loaded) {
      sortByExpiryDate(loaded);
      setState(() {
        info = loaded;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Fridge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showAddFoodDialog(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Divider(color: Colors.black26, height: 2),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: info.length,
                itemBuilder: (BuildContext context, int idx) {
                  print(info[idx]["name"]);
                  return Column(
                    children: <Widget>[
                      FridgeFoodCard(
                        name: info[idx]["name"],
                        expiryDate: info[idx]["expiryDate"],
                        onDelete: () {
                          setState(() {
                            info.removeAt(idx);
                          });
                          saveFoodInfo(info);
                        },
                        onEdit: () {
                          showEditDialog(context, idx);
                        },
                      ),
                    ],
                  );
                },
                separatorBuilder:
                    (BuildContext context, int index) => const ColoredBox(
                      color: Color(0xffFDFCFF),
                      child: SizedBox(height: 5),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddFoodDialog(BuildContext context) {
    final nameController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Food'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Food Name'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("expiryDate: "),
                      Text(
                        selectedDate != null
                            ? "${selectedDate!.toLocal()}".split(' ')[0]
                            : "Not Selected",
                        style: TextStyle(
                          color:
                              selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        selectedDate != null) {
                      addFood({
                        "name": nameController.text,
                        "expiryDate": selectedDate!.toIso8601String(),
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showEditDialog(BuildContext context, int idx) {
    DateTime? selectedDate = DateTime.tryParse(info[idx]["expiryDate"]);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('"${info[idx]["name"]}"'),
              content: Row(
                children: [
                  const Text("New expiry: "),
                  Text(
                    selectedDate != null
                        ? "${selectedDate!.toLocal()}".split(' ')[0]
                        : "Invalid",
                    style: TextStyle(
                      color: selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (selectedDate != null) {
                      setState(() {
                        info[idx]["expiryDate"] =
                            selectedDate!.toIso8601String();
                        sortByExpiryDate(info);
                      });
                      saveFoodInfo(info);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
