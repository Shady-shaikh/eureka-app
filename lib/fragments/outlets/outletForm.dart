import 'dart:async';

// import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class OutletForm extends StatefulWidget {
  final bool isEditing;
  Map<String, dynamic>? itemData;
  OutletForm({
    Key? key,
    this.isEditing = false,
    this.itemData,
  }) : super(key: key);

  @override
  _OutletFormState createState() => _OutletFormState();
}

class _OutletFormState extends State<OutletForm> {
  final TextEditingController outletName = TextEditingController();
  final TextEditingController building = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController landmark = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController distrcit = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController latitude = TextEditingController();
  final TextEditingController longitude = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController route = TextEditingController();
  final TextEditingController beat = TextEditingController();

  String selectedArea = '0';
  String selectedRoute = '0';
  String selectedBeat = '0';

  String selectedCountry = '0';
  String selectedState = '0';
  String selectedDistrict = '0';

  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> areaList = [];
  List<Map<String, dynamic>> routeList = [];
  List<Map<String, dynamic>> beatList = [];

  List<Map<String, dynamic>> countryList = [];
  List<Map<String, dynamic>> stateList = [];
  List<Map<String, dynamic>> distrcitList = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeEditingData();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final response =
          await globalHelper.get_area_route_beat(selectedArea, selectedRoute);

      final response1 = await globalHelper.get_country_state_district(
          selectedCountry, selectedState);
      if (mounted) {
        setState(() {
          areaList = List<Map<String, dynamic>>.from(response['area']);
          routeList = List<Map<String, dynamic>>.from(response['routes']);
          beatList = List<Map<String, dynamic>>.from(response['beats']);

          countryList = List<Map<String, dynamic>>.from(response1['countries']);
          stateList = List<Map<String, dynamic>>.from(response1['states']);
          distrcitList =
              List<Map<String, dynamic>>.from(response1['districts']);

          areaList.insert(0, {
            'area_id': 0,
            'area_name': 'Please select',
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });
          routeList.insert(0, {
            'route_id': 0,
            'route_name': 'Please select',
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });
          beatList.insert(0, {
            'beat_id': 0,
            'beat_name': 'Please select',
            'beat_number': null,
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });

          countryList.insert(0, {
            'country_id': 0,
            'name': 'Please select',
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });

          stateList.insert(0, {
            'id': 0,
            'name': 'Please select',
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });
          distrcitList.insert(0, {
            'city_id': 0,
            'city_name': 'Please select',
            'created_at': null,
            'updated_at': null,
            'deleted_at': null,
          });
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await Future.delayed(Duration(seconds: constants.delayedTime));
    }
  }

  void _initializeEditingData() {
    if (widget.isEditing && widget.itemData != null) {
      final item = widget.itemData!['outlet'][0];
      final itemAddress = widget.itemData!['outlet_address'][0];

      outletName.text = item['bp_name'].toString();
      building.text = itemAddress['building_no_name'];
      street.text = itemAddress['street_name'];
      landmark.text = itemAddress['landmark'];
      selectedCountry = itemAddress['country'];
      selectedState = itemAddress['state'];
      selectedDistrict = itemAddress['district'];
      city.text = itemAddress['city'];
      pincode.text = itemAddress['pin_code'].toString();
      latitude.text = item['latitude'].toString();
      longitude.text = item['longitude'].toString();
      selectedArea = item['area_id'];
      selectedRoute = item['route_id'];
      selectedBeat = item['beat_id'];
      selectedCountry = itemAddress['country'];
      selectedState = itemAddress['state'];
      selectedDistrict = itemAddress['district'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditing ? Text('Edit Outlet') : Text('Add Outlet'),
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
                _buildTextFormField(outletName, 'Outlet', () => {}, null),
                _buildTextFormField(
                    building, 'Building No and Name', () => {}, null),
                _buildTextFormField(street, 'Street Name', () => {}, null),
                _buildTextFormField(landmark, 'Landmark', () => {}, null),

                //Country dropdown
                DropdownButtonFormField(
                  value: selectedCountry,
                  items: countryList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['country_id'].toString(),
                        child: Text(option['name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCountry = newValue!;
                      selectedState = '0';
                      selectedDistrict = '0';
                      initializeData();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Country',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select Country';
                    }
                    return null;
                  },
                ),
                //route dropdown
                DropdownButtonFormField(
                  value: selectedState,
                  items: stateList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['id'].toString(),
                        child: Text(option['name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedState = newValue!;
                      selectedDistrict = '0';
                      initializeData();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'State',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select State';
                    }
                    return null;
                  },
                ),
                //beat dropdown
                DropdownButtonFormField(
                  value: selectedDistrict,
                  items: distrcitList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['city_id'].toString(),
                        child: Text(option['city_name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDistrict = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'District',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select District';
                    }
                    return null;
                  },
                ),

                _buildTextFormField(city, 'Name of City', () => {}, null),
                _buildTextFormField(
                    pincode, 'Pin Code', () => {}, TextInputType.number),
                _buildTextFormField(
                    latitude, 'Latitude', () => {}, TextInputType.number),
                _buildTextFormField(
                    longitude, 'Longitude', () => {}, TextInputType.number),

                //area dropdown
                DropdownButtonFormField(
                  value: selectedArea,
                  items: areaList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['area_id'].toString(),
                        child: Text(option['area_name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedArea = newValue!;
                      selectedRoute = '0';
                      selectedBeat = '0';
                      initializeData();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Area',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select Area';
                    }
                    return null;
                  },
                ),
                //route dropdown
                DropdownButtonFormField(
                  value: selectedRoute,
                  items: routeList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['route_id'].toString(),
                        child: Text(option['route_name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRoute = newValue!;
                      selectedBeat = '0';
                      initializeData();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Route',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select Route';
                    }
                    return null;
                  },
                ),
                //beat dropdown
                DropdownButtonFormField(
                  value: selectedBeat,
                  items: beatList.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> option) {
                      return DropdownMenuItem(
                        value: option['beat_id'].toString(),
                        child: Text(option['beat_name']),
                      );
                    },
                  ).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedBeat = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Beat',
                  ),
                  style: TextStyle(color: Colors.black), // Set text color
                  icon: Icon(Icons.arrow_drop_down), // Add dropdown icon
                  isExpanded: true,
                  validator: (value) {
                    if (value == null || value == '0') {
                      return 'Please select Beat';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.0),
                // Save Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      _handleSaveAction();
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
      [TextInputType? keyboardType, bool readOnly = false]) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged != null ? (_) => onChanged(controller.text) : null,
      keyboardType: keyboardType,
      enabled: !readOnly,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: (value) {
        return null;
      },
    );
  }

  void _handleSaveAction() async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var company_id = sharedPref.getInt('company_id');

    // Implement the save action
    var postedData = {
      'company_id':company_id.toString(),
      'salesman': user_id.toString(),
      'outlet_name': outletName.text.toString(),
      'area_id': selectedArea.toString(),
      'route_id': selectedRoute.toString(),
      'beat_id': selectedBeat.toString(),
      'building_no_name': building.text.toString(),
      'street_name': street.text.toString(),
      'landmark': landmark.text.toString(),
      'country': selectedCountry.toString(),
      'state': selectedState.toString(),
      'district': selectedDistrict.toString(),
      'city': city.text.toString(),
      'pin_code': int.parse(pincode.text),
      'latitude': latitude.text.isEmpty ? 0.0 : double.parse(latitude.text),
      'longitude': longitude.text.isEmpty ? 0.0 : double.parse(longitude.text),
    };

    if (widget.isEditing && widget.itemData != null) {
      final item = widget.itemData!['outlet'][0];
      final itemAddress = widget.itemData!['outlet_address'][0];
      if (item != null && itemAddress != null) {
        postedData['business_partner_id'] = item['business_partner_id'];
        postedData['bussiness_partner_id'] =
            itemAddress['bussiness_partner_id'];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          Center(child: CircularProgressIndicator()),
    );

    var response = await globalHelper.update_outlet(postedData);

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
    home: OutletForm(),
  ));
}
