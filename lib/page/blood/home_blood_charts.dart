import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application/Api/api_provider.dart';
import 'package:flutter_application/model/YearModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../API/api_provider_authen.dart';
import '../knowledge/BloodGlucose/Low/adviceHomeLow.dart';
import 'blood_charts.dart';

class HomeBlood extends StatefulWidget {
  const HomeBlood({super.key});

  @override
  State<HomeBlood> createState() => _HomeBloodState();
}

class _HomeBloodState extends State<HomeBlood> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getYear();
  }

  ApiproviderAuth apiprovider = ApiproviderAuth();

  late List<YearModel?> _yearModel;
  var jsonResponse = [];

  Future<List<YearModel?>?> getYear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? user_id = prefs.getInt('userId');
      var response = await apiprovider.getYear(user_id!);
      if (response.statusCode == 200) {
        print(response.body);
        jsonResponse = jsonDecode(response.body);
        _yearModel = jsonResponse.map((e) => YearModel.fromJson(e)).toList();
      }
      if (response.statusCode == 404) {
        print("object");
      }
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    return _yearModel;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ประวัติระดับน้ำตาลในเลือด "),
        ),
        body: FutureBuilder(
          future: getYear(),
          builder: ((context, snapshot) {
            var data = snapshot.data;
            if (!snapshot.hasData) {
              // ignore: avoid_unnecessary_containers
              return Container(
                child: const LinearProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                    child: ListView.builder(
                  itemCount: data?.length,
                  itemBuilder: ((context, index) {
                    return SingleChildScrollView(
                        child: Center(
                      child: Column(
                        children: [
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                  height: 65,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xcc5286d4))),
                                      child: Text('ปี ${data?[index]?.year}'),
                                      onPressed: () async {
                                        final int? year = data?[index]?.year;
                                        print("${data?[index]?.year}");
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setInt('year', year!);
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BloodChart()));
                                      })),
                            ),
                          ),
                        ],
                      ),
                    ));
                  }),
                ))
              ],
            );
          }),
        ));
  }
}
