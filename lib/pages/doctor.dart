import 'dart:convert';
import 'dart:io';
import 'package:data_collection/helperClass/testFacilityField.dart';
import 'package:data_collection/model/doctorModel.dart';
import 'package:data_collection/postData/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../model/doctorModel.dart';

class Doctor extends StatefulWidget {
  @override
  _DoctorState createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  List<String> departmentItems = [];
  List<String> visitedHoursItems = [];
  List<String> testFacilitiesItems = [];

  var locationmsg = " ";
  var latmsg = '';
  var longmsg = '';
  double currentlat;
  double currentlong;
  File imageFile;

  bool loading = true;

  final hospitalNameEng = TextEditingController();
  final hospitalNameBang = TextEditingController();
  //dropdown
  var _mySelection; //division
  var _citySelection; //city
  final addressInEng = TextEditingController();
  final addressInBng = TextEditingController();
  final branchName = TextEditingController();
  final mobileNo = TextEditingController();

  final _notesController = TextEditingController();
  // var locationLatitude;
  //var locationLongitude;

  // final _formKeytest = GlobalKey<FormState>();
  //final _formKeyservices = GlobalKey<FormState>();

  final _formKeySurgeries = GlobalKey<FormState>();

  String servicejson;
  String surgeryjson;
  String testfacilityjson;
  int cityId;
  int divId;
  int latitudemessage;
  int longitudemessage;

  int surveyquestionnum = 1;
  int surveyquestiontotal = 1;

  int linktestdevices = 1;
  String dropdownvalue = "SELECT FROM DROPDOWN";
  String divisiondropdown = "Select Division";
  String citydropdown = "Select Area";
  String testgorir = "Select testgorir";
  List serviceList = [];

  // for map
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    // var position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    //currentlat = lastPosition.latitude;
    //currentlong = lastPosition.longitude;
    print(lastPosition);

    setState(() {
      // locationmsg = "$position.latitude";
      latmsg = lastPosition.latitude.toString();
      longmsg = lastPosition.longitude.toString();
      //locationmsg = lastPosition as String;
    });
  }

  var departmantItem;
  var designationItems;
  var expertiseItems;
  //for camera dialogBox
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Make a Choice"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text("Gallery"),
                    onTap: () {
                      _openGallery(context);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(5.0)),
                  GestureDetector(
                    child: Text("Camera"),
                    onTap: () {
                      _openCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

//  final String url = "http://139.59.112.145/api/registration/helper/hospital";

  List data = []; //edited line
  List cityData = [];
  var city;
  var resBody;

  var url = Uri(
      scheme: "http",
      host: "139.59.112.145",
      path: "/api/registration/helper/doctor/");

  Future<String> getSWData() async {
    var res = await http.get(url, headers: {"Accept": "application/json"});
    resBody = json.decode(res.body);
    // print(resBody);
    var user = resBody['data']['divisions'];
    setState(() {
      data = user;
    });
    return "Sucess";
  }

  Future<String> getCity() async {
    var res = await http.get(url, headers: {"Accept": "application/json"});
    var rresBody = json.decode(res.body);

    var city = rresBody['data']['divisions'];

    // for (int k = 0; k < div.toString().length; k++) {
    //   city = div['cities'][k];
    // }

    //city = diva['cities'];
    // print('city: $city.');
    setState(() {
      cityData = city;
    });

    return "Sucess";
  }

  @override
  void initState() {
    super.initState();
    this.getSWData();
    this.getCity();
  }

  //autoCompleteTextView test
  // var _divisionController = new TextEditingController();
  // var _cityController = new TextEditingController();
  var uses;
  // for image
  Widget _decideImageView() {
    if (imageFile == null) {
      return Text("No Image Selected");
    } else {
      Image.file(
        imageFile,
        width: 200,
        height: 200,
      );
    }
    return Image.file(
      imageFile,
      width: 200,
      height: 200,
    );
  }

  // List<String> data = [];
  //var user, user2, user1;

  List department = [];
  List visitHour = [];
  List expertises = [];
  List desginations = [];

  fetchDivisons() async {
    final response = await http.get(
      Uri(
          scheme: "http",
          host: "139.59.112.145",
          path: "/api/registration/helper/doctor/"),
    );
    final jsonResponse = json.decode(response.body);
    //Doctor helper = Doctor.fromJson(jsonResponse);
    DoctorHelper doctor = new DoctorHelper.fromJson(jsonResponse);

    // for (var i = 0; i < helper.data.surguries.length; i++) {
    //   //  data.add(helper.data.surguries[i].name);
    // }
    // print(data);
    return doctor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //Name
            Container(
              //margin: const EdgeInsets.only(bottom:5.0),
              child: TextField(
                controller: hospitalNameEng,
                decoration:
                    InputDecoration(hintText: 'Hospital Name In English'),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            //Name bn
            Container(
              child: TextField(
                controller: hospitalNameBang,
                decoration:
                    InputDecoration(hintText: 'Hospital Name In Bangla'),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            //division
            Container(
                width: 300.0,
                margin: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    new DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down),
                      hint: Text("  $divisiondropdown"),
                      items: data.asMap().entries.map((item) {
                        return new DropdownMenuItem(
                          child: new Text(item.value['name']),
                          value: item.key,
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        var item = data.asMap().values.elementAt(newVal);
                        // var selectedCities = data.map((item) {
                        //   print(item['cities']);

                        //   if (newVal == item['id']) {
                        //     return item['cities'];
                        //   }
                        // });
                        // print(selectedCities);
                        setState(() {
                          cityData = item['cities'];
                          _mySelection = item['id'];
                          // print(_mySelection);
                        });
                      },
                      value: _mySelection,
                    ),
                  ],
                )),
            //city
            Container(
                width: 300.0,
                margin: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    new DropdownButton(
                      underline: SizedBox(),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down),
                      hint: Text("  $citydropdown"),
                      items: cityData.map((item) {
                        return new DropdownMenuItem(
                          child: new Text(item['name']),
                          value: item['id'].toString(),
                        );
                      }).toList(),
                      onChanged: (cityVal) {
                        // setState(() {
                        _citySelection = cityVal;
                        // });
                        // print(_citySelection);
                      },
                      value: _citySelection,
                    ),
                  ],
                )),
            //address
            Container(
              child: TextField(
                controller: addressInEng,
                decoration: InputDecoration(hintText: 'Address In English'),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            //address
            Container(
              child: TextField(
                controller: addressInBng,
                decoration: InputDecoration(hintText: 'Address In Bangla'),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            //Location
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      getCurrentLocation();
                    },
                    // color: Colors.blue[800],
                    child: Icon(
                      Icons.location_on,
                      size: 20.0,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text("Latitude:" + latmsg),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 8.0,
                  ),
                  Text("Longitude:" + longmsg),
                ],
              ),
            ),
            //branch name
            Container(
              child: TextField(
                controller: branchName,
                decoration: InputDecoration(hintText: 'Branch Name'),
              ),
              padding: EdgeInsets.all(10.0),
            ),
            //reciption no
            Container(
              child: TextField(
                controller: mobileNo,
                decoration: InputDecoration(hintText: 'Phone Number'),
              ),
              padding: EdgeInsets.all(10.0),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FutureBuilder(
                    future: fetchDivisons(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return CupertinoActivityIndicator();
                      } else {
                        expertises = [];
                        department = [];
                        desginations = [];
                        for (var i = 0;
                            i < snapshot.data.data.departments.length;
                            i++) {
                          // user = snapshot.data.data.services[i];
                          department.add(snapshot.data.data.departments[i]);
                          // print(department);
                        }
                        for (var i = 0;
                            i < snapshot.data.data.expertises.length;
                            i++) {
                          expertises.add(snapshot.data.data.expertises[i]);
                        }
                        for (var i = 0;
                            i < snapshot.data.data.designations.length;
                            i++) {
                          desginations.add(snapshot.data.data.designations[i]);
                        }

                        // for (var i = 0;
                        //     i < snapshot.data.data.testFacilities.length;
                        //     i++) {
                        //   user2 = snapshot.data.data.testFacilities[i];
                        // }
                        // print(department);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //  crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            //department
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text("Department")),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.6,
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        children: [
                                          new DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            icon: Icon(Icons.arrow_drop_down),
                                            hint: Text(
                                              "  Select department",
                                              textAlign: TextAlign.center,
                                            ),
                                            items: [
                                              for (var i in department)
                                                DropdownMenuItem(
                                                  child:
                                                      Text(i.name.toString()),
                                                  value: i.id.toString(),
                                                )
                                            ],

                                            // department.map((item) {
                                            //   return new DropdownMenuItem(
                                            //     child: new Text(item['name']),
                                            //     value: item['id'].toString(),
                                            //   );
                                            // }).toList(),

                                            onChanged: (cityVal) {
                                              // setState(() {
                                              departmantItem = cityVal;
                                              //   });
                                              // print(departmantItem);
                                            },
                                            value: departmantItem,
                                          ),
                                        ],
                                      )),

                                  //   Container(
                                  //     child: Form(
                                  //       key: _formKeyservices,
                                  //       child: MultiSelectFormFieldForDepartment(
                                  //         context: context,
                                  //         buttonText: 'Department',
                                  //         itemList: [
                                  //           for (var i in department)
                                  //             i.id.toString() +
                                  //                 ") " +
                                  //                 i.name.toString()
                                  //         ],

                                  //         // itemList: department.map((item) {
                                  //         //   item.name;
                                  //         // }).toList(),

                                  //         questionText: 'Select Your Department',
                                  //         validator: (flavours1) => flavours1
                                  //                     .length ==
                                  //                 0
                                  //             ? 'Please select at least one Department!'
                                  //             : null,
                                  //         onSaved: (flavours1) {
                                  //           //print(flavours1);
                                  //           //var items = flavours1.map((e) => e.replaceAll(')', ' '));
                                  //           departmentItems = flavours1
                                  //               .map((e) => e.split(")")[0])
                                  //               .toList();
                                  //           // print(items.toString());
                                  //           //  departmentItems = items.toList();
                                  //           // departmentItems = items.toList();
                                  //           print(departmentItems);

                                  //           // Logic to save selected flavours in the database
                                  //         },
                                  //       ),
                                  //       onChanged: () {
                                  //         if (_formKeyservices.currentState
                                  //             .validate()) {
                                  //           // Invokes the OnSaved Method
                                  //           // departmentItems.cast();

                                  //           _formKeyservices.currentState.save();
                                  //         }
                                  //       },
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
//desination
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Designations"),
                                  SizedBox(width: 10),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.6,
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        children: [
                                          new DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            icon: Icon(Icons.arrow_drop_down),
                                            hint: Text(
                                              "  Select designations",
                                              textAlign: TextAlign.center,
                                            ),
                                            items: [
                                              for (var i in desginations)
                                                DropdownMenuItem(
                                                  child:
                                                      Text(i.name.toString()),
                                                  value: i.id.toString(),
                                                )
                                            ],
                                            onChanged: (cityVal) {
                                              // setState(() {
                                              designationItems = cityVal;
                                              //   });
                                              // print(departmantItem);
                                            },
                                            value: designationItems,
                                          ),
                                        ],
                                      )),

                                  //   Container(
                                  //     child: Form(
                                  //       key: _formKeyservices,
                                  //       child: MultiSelectFormFieldForDepartment(
                                  //         context: context,
                                  //         buttonText: 'Department',
                                  //         itemList: [
                                  //           for (var i in department)
                                  //             i.id.toString() +
                                  //                 ") " +
                                  //                 i.name.toString()
                                  //         ],
                                  // itemList: department.map((item) {
                                  //   item.name;
                                  // }).toList(),
                                  //         questionText: 'Select Your Department',
                                  //         validator: (flavours1) => flavours1
                                  //                     .length ==
                                  //                 0
                                  //             ? 'Please select at least one Department!'
                                  //             : null,
                                  //         onSaved: (flavours1) {
                                  //print(flavours1);
                                  //var items = flavours1.map((e) => e.replaceAll(')', ' '));
                                  //           departmentItems = flavours1
                                  //               .map((e) => e.split(")")[0])
                                  //               .toList();
                                  // print(items.toString());
                                  //  departmentItems = items.toList();
                                  // departmentItems = items.toList();
                                  //           print(departmentItems);
                                  // Logic to save selected flavours in the database
                                  //         },
                                  //       ),
                                  //       onChanged: () {
                                  //         if (_formKeyservices.currentState
                                  //             .validate()) {
                                  // Invokes the OnSaved Method
                                  // departmentItems.cast();
                                  //           _formKeyservices.currentState.save();
                                  //         }
                                  //       },
                                  //     ),
                                  //   ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Expertises"),
                                  SizedBox(width: 10),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.6,
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        children: [
                                          new DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            icon: Icon(Icons.arrow_drop_down),
                                            hint: Text(
                                              "  Select expertises",
                                              textAlign: TextAlign.center,
                                            ),
                                            items: [
                                              for (var i in expertises)
                                                DropdownMenuItem(
                                                  child:
                                                      Text(i.name.toString()),
                                                  value: i.id.toString(),
                                                )
                                            ],
                                            onChanged: (cityVal) {
                                              // setState(() {
                                              expertiseItems = cityVal;
                                              //   });
                                              // print(departmantItem);
                                            },
                                            value: expertiseItems,
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("visitHours"),
                            //     Container(
                            //       child: Form(
                            //         key: _formKeySurgeries,
                            //         child: MultiSelectFormFieldForSurgeries(
                            //           context: context,
                            //           buttonText: 'visitHours',
                            //           itemList: [
                            //             for (var i in visitHour)
                            //               i.id.toString() +
                            //                   ") " +
                            //                   i.days.toString()
                            //           ],
                            //           questionText: 'Select Your surguries',
                            //           validator: (flavours2) => flavours2
                            //                       .length ==
                            //                   0
                            //               ? 'Please select at least one flavor!'
                            //               : null,
                            //           onSaved: (flavours2) {
                            //             visitedHoursItems = flavours2
                            //                 .map((e) => e.split(")")[0])
                            //                 .toList();
                            // print(visitedHoursItems);
                            // Logic to save selected flavours in the database
                            //           },
                            //         ),
                            //         onChanged: () {
                            //           if (_formKeySurgeries.currentState
                            //               .validate()) {
                            //             // Invokes the OnSaved Method
                            //             _formKeySurgeries.currentState.save();
                            //           }
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text("testFacilities"),
                            //     Container(
                            //       child: Form(
                            //         key: _formKeytest,
                            //         child:
                            //             MultiSelectFormFieldForTestFacilities(
                            //           context: context,
                            //           buttonText: 'testFacilities',
                            //           itemList: [
                            //             user2.id.toString() +
                            //                 ")  " +
                            //                 user2.name.toString(),
                            //           ],
                            //           questionText:
                            //               'Select Your testFacilities',
                            //           validator: (flavours3) => flavours3
                            //                       .length ==
                            //                   0
                            // //               ? 'Please select at least one testFacilities!'
                            //               : null,
                            //           onSaved: (flavours3) {
                            //             testFacilitiesItems = flavours3
                            //                 .map((e) => e.split(")")[0])
                            //                 .toList();

                            //             // Logic to save selected flavours in the database
                            //           },
                            //         ),
                            //         onChanged: () {
                            //           if (_formKeytest.currentState
                            //               .validate()) {
                            //             // Invokes the OnSaved Method
                            //             _formKeytest.currentState.save();
                            //           }
                            //         },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        );
                      }
                    }),
              ],
            ),

            // //image
            Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        _showChoiceDialog(context);
                      },
                      child: Text("Select Image"),
                    ),
                    _decideImageView(),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            //notes

            Container(
              height: 100,
              margin: EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                    labelText: "Notes",
                    hintText: 'Give us your feeling of thought',
                    border: OutlineInputBorder()),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),

            //send to server
            Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    // ignore: deprecated_member_use
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green)),
                      onPressed: () {
                        //String imageFileName = imageFile.path.split('/').last;

                        // print(testFacilitiesItems);
                        // print(visitedHoursItems);
                        // print(departmentItems);

                        List<int> imageBytes = imageFile.readAsBytesSync();
                        String baseimage = base64Encode(imageBytes);
                        NetWork().sendDoctorStore(
                            context: context,
                            name: hospitalNameEng.text,
                            nameBangla: hospitalNameBang.text,
                            cityId: _citySelection,
                            divisionId: _mySelection,
                            departmentId: departmentItems,
                            //  surgeries: visitedHoursItems,
                            expertiseId: expertiseItems,
                            //testFacilities: testFacilitiesItems,
                            addressLine1: addressInEng.text,
                            addressLine2: addressInBng.text,
                            image: baseimage,
                            locationLat: (latmsg),
                            locationLng: (longmsg),
                            branchName: branchName.text,
                            notes: _notesController.text,
                            designationId: designationItems,
                            receptionPhone: (mobileNo.text));
                      },
                      child: Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //gallery
  _openGallery(BuildContext context) async {
    final _picker = ImagePicker();
    final pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    final File file = File(pickedFile.path);
    // var picture = await ImagePicker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      imageFile = file;
    });
    Navigator.of(context).pop();
  }

  //Camera
  _openCamera(BuildContext context) async {
    final _picker = ImagePicker();
    final pickedFile =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    final File file = File(pickedFile.path);

    setState(() {
      imageFile = file;
    });
    Navigator.of(context).pop();
  }
}
