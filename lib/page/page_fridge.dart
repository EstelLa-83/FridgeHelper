import 'package:flutter/material.dart';
import 'package:fridge/model/food.dart';
import 'package:fridge/widget/fridge/fridge_food_card.dart';
import 'package:fridge/widget/fridge/fridge_appbar.dart';
import 'package:fridge/widget/fridge/fridge_divider.dart';
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:fridge/controller/foodImages.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FridgePage extends StatefulWidget {
  final int fridgeId;
  final String fridgeName;

  const FridgePage({
    super.key,
    required this.fridgeId,
    required this.fridgeName,
    });

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  List<Food> foodList = [];
  List<Food> filteredFoodList = [];
  String selectedStorageType = "ALL";

  Future<void> _loadFoodsFromServer() async {
    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse("$BASE_URL/foods?fridgeId=${widget.fridgeId}"),
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      final List<Food> fetchedFoods = data.map((item) {
        return Food(
          foodId: item['id'],
          foodImage: item['icon'],
          name: item['name'],
          count: item['count'],
          expiryDate: DateTime.parse(item['expiryDate']),
          storageType: item['storageType'],
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        foodList = fetchedFoods;
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
        .where((item) => item.storageType == selectedStorageType) 
        .toList();
    }
  }

  void sortByExpiryDate(List<Food> list) {
    list.sort((a, b) {
      return a.expiryDate.compareTo(b.expiryDate);
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
            FridgeAppBar(
              fridgeName: widget.fridgeName,
              onAddPressed: () => showAddFoodDialog(context),
            ),
            const SizedBox(height: 5),
            FridgeDivider(
              onTypeChanged: (type) {
                if (!mounted) return;
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
                        name: item.name,
                        foodImage: item.foodImage,
                        count: item.count,
                        expiryDate: item.expiryDate,
                        onDelete: () {
                          showDeleteDialog(context, item.foodId);
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

  Future<int?> _showFoodImagePicker(BuildContext context) async {
    return showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: foodImages.length,
            itemBuilder: (context, index) {
              final imagePath = foodImages[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context, index);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showAddFoodDialog(BuildContext context) {
    int foodImg = 0;
    int count = 1;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedStorageType = "COLD";
    
    final storageTypeOptions = ["COLD", "FROZEN"];
    final nameController = TextEditingController();
    final countController = TextEditingController(text: count.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Food'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final result = await _showFoodImagePicker(context);
                                if (result != null) {
                                  if (!mounted) return;
                                  setState(() {
                                    foodImg = result;
                                  });
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8), // 둥근 정도 설정
                                child: Image.asset(
                                  foodImages[foodImg],
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: 'Food Name'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Count: "),
                          IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () {
                                  if (count > 1) {
                                    if (!mounted) return;
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
                                      if (!mounted) return;
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
                                  if (!mounted) return;
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
                            value: selectedStorageType,
                            items: storageTypeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (!mounted) return;
                              setState(() {
                                selectedStorageType = newValue!;
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
                                if (!mounted) return;
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
                          const Text("Expiry Time: "),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Not Selected",
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
                                if (!mounted) return;
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
                ),
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
                          "icon": foodImg,
                          "count": count,
                          "expiryDate": DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(expiryDateTime),
                          "memo": "",
                          "storageType": selectedStorageType == "FROZEN" ? "FROZEN" : "COLD",
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Food"),
        content: const Text("Are you sure about deleting this?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await authenticatedRequest(
                context: context,
                url: Uri.parse("$BASE_URL/foods/$foodId"),
                method: "DELETE",
              );
              
              if (response.statusCode == 204) {
                _loadFoodsFromServer();
                Navigator.pop(context);
              } 
              else {
                print("Failed to delete food: ${response.statusCode}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to delete food")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showEditDialog(BuildContext context, int idx) {
    final Food targetFood = filteredFoodList[idx];
    int foodImg = targetFood.foodImage;
    int count = targetFood.count;
    DateTime selectedDate = targetFood.expiryDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    final countController = TextEditingController(text: count.toString());
    String selectedStorageType = targetFood.storageType == "FROZEN" ? "FROZEN" : "COLD";
    final storageTypeOptions = ["COLD", "FROZEN"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await _showFoodImagePicker(context);
                      if (result != null) {
                        if (!mounted) return;
                        setState(() {
                          foodImg = result;
                        });
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // 둥근 정도 설정
                      child: Image.asset(
                        foodImages[foodImg],
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    targetFood.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 280,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 보관 상태
                      Row(
                        children: [
                          const Text("Status: "),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedStorageType,
                            items: storageTypeOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (!mounted) return;
                              setState(() {
                                selectedStorageType = newValue!;
                              });
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
                                if (!mounted) return;
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
                                  if (!mounted) return;
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
                              if (!mounted) return;
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
                          const Text("New date: "),
                          Text(
                            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(selectedDate),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                if (!mounted) return;
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
                            selectedTime.format(context),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                if (!mounted) return;
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
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    final parsedCount = int.tryParse(countController.text) ?? 1;

                    final selectedDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    final response = await authenticatedRequest(
                      context: context,
                      url: Uri.parse("$BASE_URL/foods/${targetFood.foodId}"),
                      method: "PUT",
                      body: {
                        "name": targetFood.name,
                        "icon": foodImg,
                        "count": parsedCount,
                        "expiryDate":DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(selectedDateTime),
                        "memo": "",
                        "storageType": selectedStorageType == "FROZEN" ? "FROZEN" : "COLD",
                        "fridgeId": widget.fridgeId,
                      },
                    );

                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      _loadFoodsFromServer(); // 다시 가져오기
                    } else {
                      print("Failed to update food: ${response.statusCode}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to edit food")),
                      );
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
