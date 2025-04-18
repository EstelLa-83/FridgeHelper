import 'package:flutter/material.dart';
import 'package:fridge/widget/fridge/food_card.dart';
import 'package:fridge/widget/fridge/fridge_appbar.dart';
import 'package:fridge/widget/fridge/fridge_divider.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FridgePage extends StatefulWidget {
  final int fridgeId;

  const FridgePage({
    super.key,
    required this.fridgeId,
    });

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  List foodList = [];
  List filteredFoodList = [];
  String selectedStorageType = "ALL";

  Future<void> _loadFoodsFromServer() async {
    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/foods?fridgeId=${widget.fridgeId}"),
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        foodList = data;
        sortByExpiryDate(foodList);
        getFilteredFoodList();
      });
    } else {
      print("Failed to load foods: ${response.statusCode}");
    }
  }

  void getFilteredFoodList() {
    if (selectedStorageType == "ALL") {
      filteredFoodList = foodList;
    }
    else { 
      filteredFoodList = foodList
        .where((item) => item["storageType"] == selectedStorageType) 
        .toList();
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

  @override
  void initState() {
    super.initState();
    _loadFoodsFromServer();
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
      body: SafeArea(
        child: Column(
          children: [
            FridgeAppBar(),
            Row(
              children: [
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showAddFoodDialog(context);
                  },
                ),
                const SizedBox(width: 8.0),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(color: Colors.black26, height: 2),
            const SizedBox(height: 5),
            FridgeDivider(
              onTypeChanged: (type) {
                setState(() {
                  selectedStorageType = type;
                  getFilteredFoodList();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: filteredFoodList.length,
                itemBuilder: (BuildContext context, int idx) {
                  final item = filteredFoodList[idx];
                  return Column(
                    children: <Widget>[
                      FridgeFoodCard(
                        name: item["name"],
                        count: item["count"],
                        expiryDate: item["expiryDate"],
                        onDelete: () {
                          showDeleteDialog(context, item["id"]);
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
    int count = 1;
    final countController = TextEditingController(text: count.toString());
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedIsFrozen = "COLD";
    final isFrozenOptions = ["COLD", "FROZEN"];

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
                      const Text("Count: "),
                      IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              if (count > 1) {
                                setState(() {
                                  count--;
                                  countController.text = count.toString();
                                });
                              }
                            },
                          ),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              controller: countController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed > 0) {
                                  setState(() {
                                    count = parsed;
                                  });
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                count++;
                                countController.text = count.toString();
                              });
                            },
                          ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Status: "),
                      DropdownButton<String>(
                        value: selectedIsFrozen,
                        items: isFrozenOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedIsFrozen = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Expiry Date: "),
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
                  Row(
                    children: [
                      const Text("Time: "),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : "Not Selected (00:00)",
                        style: TextStyle(
                          color:
                              selectedTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 0, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
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
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        selectedDate != null) {
                      final expiryDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime?.hour ?? 0, // 시간 선택 없으면 00:00
                        selectedTime?.minute ?? 0,
                      );

                      final response = await authenticatedRequest(
                        context: context,
                        url: Uri.parse("$BASE_URL/foods"),
                        method: "POST",
                        body: {
                          "name": nameController.text,
                          "count": count,
                          "expiryDate": DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(expiryDateTime),
                          "memo": "",
                          "storageType": selectedIsFrozen == "FROZEN" ? "FROZEN" : "COLD",
                          "fridgeId": widget.fridgeId,
                        },
                      );

                      if (response.statusCode == 201) {
                        Navigator.pop(context);
                        _loadFoodsFromServer();
                      } 
                      else {
                        print("Failed to add food: ${response.statusCode}");
                      }
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

  void showDeleteDialog(BuildContext context, int foodId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Food"),
        content: const Text("Are you sure about deleting this?"),
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

    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/foods/$foodId"),
      method: "DELETE",
    );

    if (response.statusCode == 204) {
      _loadFoodsFromServer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete food")),
      );
    }
  }

  void showEditDialog(BuildContext context, int idx) {
    DateTime? selectedDate = DateTime.tryParse(foodList[idx]["expiryDate"]);
    TimeOfDay? selectedTime;
    int count = foodList[idx]["count"] ?? 1;
    final countController = TextEditingController(text: count.toString());
    String selectedIsFrozen = foodList[idx]["storageType"] == "FROZEN" ? "FROZEN" : "COLD";
    final isFrozenOptions = ["Cold", "Frozen"];

    if (selectedDate != null) {
      selectedTime = TimeOfDay.fromDateTime(selectedDate);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('"${foodList[idx]["name"]}"'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text("New date: "),
                      Text(
                        selectedDate != null
                            ? "${selectedDate!.toLocal()}".split(' ')[0]
                            : "Invalid",
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
                  Row(
                    children: [
                      const Text("New time: "),
                      Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : "Not selected (00:00)",
                        style: TextStyle(
                          color:
                              selectedTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime:
                                selectedTime ?? TimeOfDay(hour: 0, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Count: "),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (count > 1) {
                            setState(() {
                              count--;
                              countController.text = count.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          controller: countController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                count = parsed;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            count++;
                            countController.text = count.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 보관 상태
                  Row(
                    children: [
                      const Text("Status: "),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedIsFrozen,
                        items: isFrozenOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedIsFrozen = newValue!;
                          });
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
                  child: const Text('Save'),
                  onPressed: () async {
                    if (selectedDate != null) {
                      final updatedDateTime = DateTime(
                        selectedDate!.year,
                        selectedDate!.month,
                        selectedDate!.day,
                        selectedTime?.hour ?? 0,
                        selectedTime?.minute ?? 0,
                      );

                      final parsedCount = int.tryParse(countController.text) ?? 1;

                      final response = await authenticatedRequest(
                        context: context,
                        url: Uri.parse("$BASE_URL/foods/${foodList[idx]['id']}"),
                        method: "PUT",
                        body: {
                          "name": foodList[idx]['name'],
                          "count": parsedCount,
                          "expiryDate":DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(updatedDateTime),
                          "memo": "",
                          "storageType": selectedIsFrozen == "FROZEN" ? "FROZEN" : "COLD",
                          "fridgeId": widget.fridgeId,
                        },
                      );

                      if (response.statusCode == 200) {
                        Navigator.pop(context);
                        _loadFoodsFromServer(); // 다시 가져오기
                      } else {
                        print("Failed to update food: ${response.statusCode}");
                      }
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
