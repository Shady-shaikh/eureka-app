//1) outletEdit.dart
//1.1)
// AddItemList(
// outletId: widget.outletId,
// orderId: order[0]['order_booking_id'])
//
//1.2)
// AddItemList(
//     itemData:
//         itemData, // Pass the list directly
//     isEditing: true,
//     outletId:
//         widget.outletId,
//     orderId: order[0][
//         'order_booking_id']
// )
//2)viewOrder.dart
// 2.1)
// AddItemList(
//     itemData:
//         itemData, // Pass the list directly
//     isEditing: true,
//     isOg: true,
//     outletId: widget.outletId,
//     orderId: order[0]
//         ['order_booking_id'],
//
// )
// 2.2)
// AddItemList(
//   outletId: widget.outletId,
//   isOg: true,
//   orderId: order[0]['order_booking_id']
// )
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eureka/fragments/daysplan/outletEdit.dart';
import '../../global_helper.dart';
import 'package:eureka/util/constants.dart' as constants;

//       "${inputDependentList[index]['name'].toString()}"
late Map mapData;
List listData = [];
List newList = [];
List inputDependentList = [];

// ignore: must_be_immutable
class AddItemList extends StatefulWidget {
  final bool isEditing;
  final bool isOg;
  final int orderId;
  final int outletId;
  Map<String, dynamic>? itemData;
  AddItemList({
    Key? key,
    this.isEditing = false,
    this.isOg = false,
    required this.orderId,
    required this.outletId,
    this.itemData,
  }) : super(key: key);

  @override
  State<AddItemList> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AddItemList> {
  List<TextEditingController> quantityControllers = [];
  List<String> itemCardTotals = [];

  @override
  void initState() {
    getApiData();
    super.initState();

    quantityControllers =
        List.generate(newList.length, (index) => TextEditingController());
    itemCardTotals = List.generate(newList.length, (index) => '0');
  }

  final globalHelper = GlobalHelper();

  Future getApiData() async {
    http.Response response;
    response = await http.get(
      Uri.parse(
          '${constants.apiBaseURL}/get_products?customer_id=${widget.outletId}'),
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          mapData = json.decode(response.body);
          listData = mapData['products'];
        });
      }
    }

    for (var i = 0; i < listData.length; i++) {
      newList.add({
        "name": listData[i]["name"],
        "product_item_id": listData[i]["product_item_id"],
        "hsncode_id": listData[i]["hsncode_id"],
        "sku": listData[i]["sku"],
        "unit_price": listData[i]["unit_price"],
        "mrp": listData[i]["mrp"],
        "brand_id": listData[i]["brand_id"],
        "sub_category_id": listData[i]["sub_category_id"],
        "gst_id": listData[i]["gst_id"],
        "item_code": listData[i]["item_code"],
        "margin": listData[i]['margin'],
        "scheme": listData[i]['scheme'],
      });
    }
    if (mounted) {
      setState(() {
        inputDependentList = newList;
        quantityControllers =
            List.generate(newList.length, (index) => TextEditingController());
        itemCardTotals = List.generate(newList.length, (index) => '0');
      });
    }
  }

// Method to handle quantity increment
  void incrementQuantity(int index) {
    if (mounted) {
      int currentQty = int.parse(quantityControllers[index].text);
      setState(() {
        quantityControllers[index].text = (currentQty + 1).toString();
        handleQuantityChange(index, quantityControllers[index].text);
      });
    }
  }

// Method to handle quantity decrement
  void decrementQuantity(int index) {
    if (mounted) {
      int currentQty = int.parse(quantityControllers[index].text);
      if (currentQty > 0) {
        setState(() {
          quantityControllers[index].text = (currentQty - 1).toString();
          handleQuantityChange(index, quantityControllers[index].text);
        });
      }
    }
  }

  void updatedList(String val) {
    if (mounted) {
      setState(() {
        if (val.isEmpty) {
          inputDependentList = newList;
        } else {
          inputDependentList = newList
              .where((element) => element['name']
                  .toString()
                  .toLowerCase()
                  .startsWith(val.toString().toLowerCase()))
              .toList();
        }
      });
    }
  }

  // Function to handle quantity changes
  void handleQuantityChange(int index, String value) {
    if (mounted) {
      setState(() {
        if (value.isNotEmpty) {
          double mrpDoubleVal = double.parse(listData[index]['unit_price']);
          int qty = int.parse(value);

          double totalPrice = mrpDoubleVal * qty;
          itemCardTotals[index] = totalPrice.toStringAsFixed(2);
        } else {
          itemCardTotals[index] = '0';
        }
      });
    }
  }

  TextEditingController productValue = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.isEditing ? 'Edit Item' : 'Add Item';
    final cartButtonText = widget.isOg ? 'Add' : 'Add To Cart';
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            if (!widget.isOg)
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // settings: RouteSettings(arguments: response),
                        builder: (context) => OrderBookingEditPage(
                            outletId: widget.outletId, orderId: widget.orderId),
                      ),
                    );
                  },
                  icon: Icon(Icons.shopping_cart))
          ],
          toolbarHeight: 70,

          // toolbarHeight: 70,
          bottom: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            toolbarHeight: 70,
            primary: false,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border:
                          Border.all(color: Colors.brown.shade200, width: 1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  height: 44,
                  // child:Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      onChanged: (value) => updatedList(value),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        hintText: " Search...",
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.grey,
                        ),

                        // ),
                      ),
                    ),
                  )),
            ),
          ),
          title: Text(
            appBarTitle,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: inputDependentList.length,
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, index) {
              return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1, color: Colors.brown.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 15, left: 10, right: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inputDependentList[index]['name'].toString(),
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      const Text("MRP",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          "${inputDependentList[index]['mrp']}",
                                          style: TextStyle(color: Colors.brown))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Unit Price",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          "${inputDependentList[index]['unit_price']}",
                                          style: TextStyle(
                                              color: Colors.brown.shade300))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Margin",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          "${inputDependentList[index]['margin']} %",
                                          style: TextStyle(
                                              color: Colors.brown.shade300))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Scheme",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700)),
                                      Text(
                                          "${inputDependentList[index]['scheme']} %",
                                          style: TextStyle(
                                              color: Colors.brown.shade300))
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total : ${itemCardTotals[index]}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  Container(
                                    // height: 20,
                                    width: 140,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5)),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors
                                                          .brown.shade200)),
                                              child: Center(
                                                child: IconButton(
                                                  onPressed: () =>
                                                      decrementQuantity(index),
                                                  icon: Icon(Icons.remove,
                                                      size: 20,
                                                      color: Colors
                                                          .brown.shade400),
                                                ),
                                              )),
                                          Container(
                                              width: 50,
                                              child: TextField(
                                                controller:
                                                    quantityControllers[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                onChanged: (value) =>
                                                    handleQuantityChange(
                                                        index, value),
                                              )),
                                          Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5)),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors
                                                          .brown.shade400)),
                                              child: Center(
                                                child: IconButton(
                                                  onPressed: () =>
                                                      incrementQuantity(index),
                                                  icon: Icon(Icons.add,
                                                      size: 20,
                                                      color: Colors
                                                          .brown.shade400),
                                                ),
                                              )),
                                        ]),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 40,
                                width: double.infinity,
                                child: TextButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.brown.shade200),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))))),
                                  onPressed: () {
                                    _handleSaveAction(index);
                                    Future.delayed(
                                        const Duration(milliseconds: 1000), () {
                                      if (mounted) {
                                        setState(() {
                                          quantityControllers[index].clear();
                                          itemCardTotals[index] = '0';
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    cartButtonText,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              )
                            ]),
                      )));
            },
          ),
        ));
  }

  void _handleSaveAction(int index) async {
    var sharedPref = await SharedPreferences.getInstance();
    var company_id = sharedPref.getInt('company_id');
    if (quantityControllers[index] != '0' &&
        itemCardTotals[index] != '0' &&
        itemCardTotals[index] != '0.00') {
      var postedData = {
        'company_id': company_id,
        'order_booking_id': widget.orderId,
        'outlet_id': widget.outletId,
        'item_code': inputDependentList[index]['item_code'],
        'item_name': inputDependentList[index]['name'],
        'hsn_sac': inputDependentList[index]['hsncode_id'],
        'qty': quantityControllers[index].text,
        'unit_price': inputDependentList[index]['unit_price'],
        'gst_rate': inputDependentList[index]['gst_id'],
        'total': itemCardTotals[index],
        'mrp': inputDependentList[index]['mrp'],
        'margin': inputDependentList[index]['margin'],
        'scheme': inputDependentList[index]['scheme'],
      };

      if (widget.isEditing && widget.itemData != null) {
        final item = widget.itemData!['order_items'][0];
        if (item != null) {
          postedData['order_booking_item_id'] = item['order_booking_item_id'];
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) =>
            Center(child: CircularProgressIndicator()),
      );

      var response;
      if (widget.isOg) {
        response = await globalHelper.updateSoItems(postedData);
      } else {
        response = await globalHelper.update_so_items(postedData);
      }

      if (response['success'] != null) {
        print(response['success']);
        constants.Notification(response['success']);
        Navigator.pop(context);
        // Navigator.pop(context);
      } else if (response['error'] != null) {
        constants.Notification(response['error']);
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}




// Text buildText(int ind, int ttl) {
//   final indec;
//   return Text(
//
//     if(indec= ind){
//
//   }
//   );
// }
