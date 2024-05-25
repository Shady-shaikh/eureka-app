// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, non_constant_identifier_names

import 'dart:convert';

import 'package:eureka/util/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GlobalHelper {
  var api = constants.apiBaseURL;

  Future<dynamic> login(String username, String password) async {
    var response = await http.post(
      Uri.parse('${api}/login'),
      body: {
        'email': username,
        'password': password,
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      // print(responseData);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> updatePassword(
      String email, String new_password) async {
    var response = await http.post(
      Uri.parse('${api}/updatePassword'),
      body: {
        'email': email,
        'new_password': new_password,
      },
    );
    // print(response.body);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      // print(responseData);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_companies() async {
    final response = await http.get(Uri.parse('${api}/get_companies'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_dashboard_data() async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');

    final response = await http
        .get(Uri.parse('${api}/get_dashboard_data?user_id=${user_id}'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_user_data() async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var response = await http.get(
      Uri.parse('${api}/get_user_data?user_id=${user_id}'),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_daily_beats() async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var response = await http.get(
      Uri.parse('${api}/get_daily_beats?user_id=${user_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_outlets(beat_id) async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var response = await http.get(
      Uri.parse('${api}/get_outlets?user_id=${user_id}&beat_id=${beat_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> update_days_plan(postedData) async {
    var response = await http.post(
      Uri.parse('${api}/update_days_plan'),
      body: {
        'posted_data': jsonEncode(postedData),
      },
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> update_outlet_Selection(postedData) async {
    var response = await http.post(
      Uri.parse('${api}/update_outlet_Selection'),
      body: {
        'posted_data': jsonEncode(postedData),
      },
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> update_order(outlet_id) async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var company_id = sharedPref.getInt('company_id');
    var fy_year = sharedPref.getString('fy_year');

    var response = await http.get(
      Uri.parse(
          '${api}/update_order_temp?outlet_id=${outlet_id}&user_id=${user_id}&company_id=${company_id}&fy_year=${fy_year}'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_orders(outlet_id) async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');

    var response = await http.get(
      Uri.parse('${api}/get_orders?outlet_id=${outlet_id}&user_id=${user_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> view_order(order_id, outlet_id) async {
    var response = await http.get(
      Uri.parse(
          '${api}/view_order_temp?order_id=${order_id}&outlet_id=${outlet_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> viewOrder(order_id) async {
    var response = await http.get(
      Uri.parse('${api}/view_order?order_id=${order_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_item_auto(query, customer_id) async {
    var response = await http.get(
      Uri.parse(
          '${api}/get_item_auto?query=${query}&customer_id=${customer_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_margin_scheme(margin, scheme) async {
    var response = await http.get(
      Uri.parse('${api}/get_margin_scheme?margin=${margin}&scheme=${scheme}'),
    );
    // print(response.body);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_gst() async {
    final response = await http.get(Uri.parse('${api}/get_gst'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> update_so_items(postedData) async {
    var response = await http.post(
      Uri.parse('${api}/update_so_items_temp'),
      body: {
        'posted_data': jsonEncode(postedData),
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> updateSoItems(postedData) async {
    var response = await http.post(
      Uri.parse('${api}/update_so_items'),
      body: {
        'posted_data': jsonEncode(postedData),
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> view_order_item(order_item_id) async {
    var response = await http.get(
      Uri.parse('${api}/view_order_item_temp?order_item_id=${order_item_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> viewOrderItem(order_item_id) async {
    var response = await http.get(
      Uri.parse('${api}/view_order_item?order_item_id=${order_item_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> delete_order(order_id) async {
    final response = await http
        .get(Uri.parse('${api}/delete_order_temp?order_id=${order_id}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> deleteOrder(order_id) async {
    final response =
        await http.get(Uri.parse('${api}/delete_order?order_id=${order_id}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> delete_order_item(order_item_id) async {
    final response = await http.get(Uri.parse(
        '${api}/delete_order_item_temp?order_item_id=${order_item_id}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> deleteOrderItem(order_item_id) async {
    final response = await http.get(
        Uri.parse('${api}/delete_order_item?order_item_id=${order_item_id}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> save_order(order_id) async {
    final response =
        await http.get(Uri.parse('${api}/save_order?order_id=${order_id}'));

    //  print(response.body);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_previous_comments(outlet_id) async {
    var response = await http.get(
      Uri.parse('${api}/get_previous_comments?outlet_id=${outlet_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_previous_soh(outlet_id) async {
    var response = await http.get(
      Uri.parse('${api}/get_previous_soh?outlet_id=${outlet_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> outlets() async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var response = await http.get(
      Uri.parse('${api}/outlets?user_id=${user_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_area_route_beat(area_id, route_id) async {
    var response = await http.get(
      Uri.parse(
          '${api}/get_area_route_beat?area_id=${area_id}&route_id=${route_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get_country_state_district(
      country_id, state_id) async {
    var response = await http.get(
      Uri.parse(
          '${api}/get_country_state_district?country_id=${country_id}&state_id=${state_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<dynamic> update_outlet(postedData) async {
    var response = await http.post(
      Uri.parse('${api}/update_outlet'),
      body: {
        'posted_data': jsonEncode(postedData),
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> view_outlet(outlet_id) async {
    var response = await http.get(
      Uri.parse('${api}/view_outlet?outlet_id=${outlet_id}'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> delete_outlet(outlet_id) async {
    final response = await http
        .get(Uri.parse('${api}/delete_outlet?outlet_id=${outlet_id}'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to Fetch Data: ${response.statusCode}');
    }
  }
}
