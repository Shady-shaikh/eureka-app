import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eureka/global_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eureka/util/constants.dart' as constants;

// ignore: must_be_immutable
class AddItemPage extends StatefulWidget {
  final bool isEditing;
  final bool isOg;
  final int orderId;
  final int outletId;
  Map<String, dynamic>? itemData;
  AddItemPage({
    Key? key,
    this.isEditing = false,
    this.isOg = false,
    required this.orderId,
    required this.outletId,
    this.itemData,
  }) : super(key: key);

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController hsnSacController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController marginController = TextEditingController();
  final TextEditingController schemeController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController gstAmountController = TextEditingController();
  final TextEditingController totalInrController = TextEditingController();

  final FocusNode itemNameFocus = FocusNode();
  final FocusNode itemDescriptionFocus = FocusNode();

  String selectedGstOption = '1';
  String previousItemCode = '';
  String previousItemDesc = '';

  final globalHelper = GlobalHelper();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    quantityController.addListener(_calculateTotalAmount);
    unitPriceController.addListener(_calculateTotalAmount);

    _initializeEditingData();
    // _initializeFocusListeners();
  }

  void _initializeEditingData() {
    if (widget.isEditing && widget.itemData != null) {
      final item = widget.itemData!['order_items'][0];
      itemNameController.text = item['item_code'].toString();
      itemDescriptionController.text = item['item_name'];
      hsnSacController.text = item['hsn_sac'];
      quantityController.text = item['qty'].toString();
      mrpController.text = item['mrp'] ?? '';
      marginController.text = item['margin'] ?? '';
      schemeController.text = item['scheme'] ?? '';
      unitPriceController.text = item['taxable_amount'];
      selectedGstOption = item['gst_rate'].toString();
      double total = double.tryParse(item['total']) ?? 0.0;
      totalInrController.text = total.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    quantityController.removeListener(_calculateTotalAmount);
    unitPriceController.removeListener(_calculateTotalAmount);
    super.dispose();
  }

  void _calculateTotalAmount() {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;
    double unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;
    totalInrController.text = (quantity * unitPrice).toString();
  }

  bool isRequestInProgress = false;
  Timer? suggestionTimer;

  void _onItemCodeChanged(String value) async {
    if (value.isNotEmpty && value.length >= 3) {
      if (value == itemNameController.text) {
        final response =
            await globalHelper.get_item_auto(value, widget.outletId);
        // print(response);
        _showSuggestions(response, (item) async {
          final marginId = response['margin'] == null
              ? ''
              : response['margin']['pricing_master_id'];
          final schemeId = response['scheme'] == null
              ? ''
              : response['scheme']['pricing_master_id'];
          final marginScheme =
              await globalHelper.get_margin_scheme(marginId, schemeId);

          // print(marginScheme);
          if (marginScheme['margin'] != null) {
            marginScheme['margin'].forEach((row) {
              if (row['brand_id'] == item['brand_id'] &&
                  row['sub_category_id'] == item['sub_category_id']) {
                marginController.text = row['margin'];
              }
            });
          }

          if (marginScheme['scheme'] != null) {
            marginScheme['scheme'].forEach((row) {
              if (row['brand_id'] == item['brand_id'] &&
                  row['sub_category_id'] == item['sub_category_id']) {
                schemeController.text = row['scheme'];
              }
            });
          }

          itemNameController.text = item['name'];
          itemDescriptionController.text = item['consumer_desc'];
          hsnSacController.text = item['hsncode_id'];
          mrpController.text = item['mrp'].toString();
          unitPriceController.text = response['pricing_price'].toString();
        });
      }
    }
  }

  void _onDescriptionChanged(String value) async {
    if (value.isNotEmpty && value.length >= 3) {
      if (value == itemDescriptionController.text) {
        final response =
            await globalHelper.get_item_auto(value, widget.outletId);

        // print(response);
        _showSuggestions(response, (item) async {
          final marginId = response['margin'] == null
              ? ''
              : response['margin']['pricing_master_id'];
          final schemeId = response['scheme'] == null
              ? ''
              : response['scheme']['pricing_master_id'];
          final marginScheme =
              await globalHelper.get_margin_scheme(marginId, schemeId);

          // print(marginScheme);
          // print(item);
          if (marginScheme['margin'] != null) {
            marginScheme['margin'].forEach((row) {
              if (row['brand_id'] == item['brand_id'] &&
                  row['sub_category_id'] == item['sub_category_id'] &&
                  row['variant'].toString() == item['variant'].toString() &&
                  row['buom_pack_size'].toString() ==
                      item['buom_pack_size'].toString()) {
                marginController.text = row['margin'];
              }
            });
          }

          if (marginScheme['scheme'] != null) {
            marginScheme['scheme'].forEach((row) {
              if (row['brand_id'] == item['brand_id'] &&
                  row['sub_category_id'] == item['sub_category_id'] &&
                  row['variant'].toString() == item['variant'].toString() &&
                  row['buom_pack_size'].toString() ==
                      item['buom_pack_size'].toString()) {
                schemeController.text = row['scheme'];
              }
            });
          }

          itemNameController.text = item['item_code'];
          itemDescriptionController.text = item['name'];
          hsnSacController.text = item['hsncode_id'];
          mrpController.text = item['mrp'].toString();
          unitPriceController.text = response['pricing_price'].toString();

          if (response['pricing_price'] == 0) {
            constants.Notification('Pricing for this item does not exist !');
          }
        });
      }
    }
  }

  void _showSuggestions(
      Map<String, dynamic> response, Function updateControllers) {
    List<Map<String, dynamic>> itemList =
        List<Map<String, dynamic>>.from(response['item']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Suggestions'),
          content: Container(
            height: 250.0,
            child: SingleChildScrollView(
              child: Column(
                children: itemList.map((item) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          item['name'],
                          style: TextStyle(fontSize: 13),
                        ),
                        onTap: () {
                          updateControllers(item);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(), // Divider after each ListTile
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> gstOptions =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> gst =
        List<Map<String, dynamic>>.from(gstOptions['gst']);

    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing ? Text('Edit Item') : Text('Add Item'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Fields
                // _buildTextFormField(itemNameController, 'Item Code',
                //     _onItemCodeChanged, TextInputType.number),
                _buildTextFormField(itemDescriptionController,
                    'Item Description', _onDescriptionChanged),
                _buildTextFormField(hsnSacController, 'HSN/SAC', () => {},
                    TextInputType.number, true, false),
                _buildTextFormField(quantityController, 'Quantity', () {
                  _calculateTotalAmount();
                }, TextInputType.number),
                _buildTextFormField(
                    mrpController, 'MRP', null, TextInputType.number, true),
                _buildTextFormField(marginController, 'Margin', null,
                    TextInputType.text, true, false),
                _buildTextFormField(schemeController, 'Scheme', null,
                    TextInputType.text, true, false),
                _buildTextFormField(unitPriceController, 'Unit Price (INR)',
                    null, TextInputType.number, true),
                _buildDropdownFormField(selectedGstOption, gst, 'GST'),
                _buildTextFormField(totalInrController, 'Total INR', null,
                    TextInputType.number, true),
                SizedBox(height: 16.0),
                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      if (quantityController.text != '0' &&
                          totalInrController.text != '0' &&
                          totalInrController.text != '0.00') {
                        _handleSaveAction();
                      }
                    }
                  },
                  child: Text(widget.isEditing ? 'Save Changes' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText, Function? onChanged,
      [TextInputType? keyboardType,
      bool readOnly = false,
      bool validate = true]) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted:
          onChanged != null ? (_) => onChanged(controller.text) : null,
      keyboardType: keyboardType,
      enabled: !readOnly,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: validate
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDropdownFormField(
      String value, List<Map<String, dynamic>> items, String labelText) {
    return DropdownButtonFormField(
      value: value,
      items: items.map<DropdownMenuItem<String>>(
        (Map<String, dynamic> option) {
          return DropdownMenuItem(
            value: option['gst_id'].toString(),
            child: Text(option['gst_name']),
          );
        },
      ).toList(),
      onChanged: null,
      decoration: InputDecoration(labelText: labelText),
      disabledHint: Text(value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $labelText';
        }
        return null;
      },
    );
  }

  void _handleSaveAction() async {
    if (unitPriceController.text.isEmpty || unitPriceController.text == '0') {
      constants.Notification('Pricing for this item does not exist !');
      return; // Prevent form submission
    }

    var sharedPref = await SharedPreferences.getInstance();
    var company_id = sharedPref.getInt('company_id');

    var postedData = {
      'company_id': company_id,
      'order_booking_id': widget.orderId,
      'outlet_id': widget.outletId,
      'item_code': itemNameController.text,
      'item_name': itemDescriptionController.text,
      'hsn_sac': hsnSacController.text,
      'qty': quantityController.text,
      'unit_price': unitPriceController.text,
      'gst_rate': selectedGstOption,
      'total': totalInrController.text,
      'mrp': mrpController.text,
      'margin': marginController.text,
      'scheme': schemeController.text,
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
      constants.Notification(response['success']);
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (response['error'] != null) {
      constants.Notification(response['error']);
      Navigator.pop(context);
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: AddItemPage(outletId: 0, orderId: 0),
  ));
}
