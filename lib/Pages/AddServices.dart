import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dr_tech/Components/Alert.dart';
import 'package:dr_tech/Components/CustomBehavior.dart';
import 'package:dr_tech/Components/CustomLoading.dart';
import 'package:dr_tech/Components/TitleBar.dart';
import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:dr_tech/Network/NetworkManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';

class AddServices extends StatefulWidget {
  final id;
  AddServices({this.id});

  @override
  _AddServicesState createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices>
    with TickerProviderStateMixin {
  Map<String, String> body = {}, selectedTexts = {}, errors = {};
  Map selectOptions = {}, config, data;
  List images = [], removedImagesUpdate = [], removedOffers = [];
  Map<String, TextEditingController> controllers = {};
  Map<String, TabController> tabControllers = {};
  bool isLoading = false;
  List<Map> selectedFiles = [], offers = [];
  @override
  void initState() {
    loadConfig();
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "services/configuration", context, (r) {
      if (r['state'] == true) {
        setState(() {
          config = r['data'];
          if (widget.id != null) {
            load();
          } else {
            isLoading = false;
          }
        });
      }
    }, cashable: true);
  }

  void load() {
    setState(() {
      isLoading = true;
    });
    NetworkManager.httpGet(Globals.baseUrl + "user/service?id=${widget.id}", context, (r) {
      if (r['state'] == true) {
        setState(() {
          data = r['data'];
          initBodyData();
          isLoading = false;
        });
      }
    }, cashable: true);
  }

  void initBodyData() {
    offers = [];
    selectedFiles = [];
    selectedTexts["service"] = data['service'];
    selectedTexts["service_catigory"] = data['name'];
    selectedTexts["about"] = data["about"];

    body["service"] = data['service_id'];
    body["service_catigory"] = data['service_catigory_id'];
    body['about'] = data["about"];
    for (var item in data['offers']) {
      offers.add({"details": item['description'], "price": item['price']});
    }
    for (var item in data['images']) {
      selectedFiles.add({"id": item['id'], "url": item['name']});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, widget.id == null ? 253 : 254),
          isLoading
              ? Expanded(child: Center(child: CustomLoading()))
              : Expanded(
                  child: ScrollConfiguration(
                  behavior: CustomBehavior(),
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    children: getFormInputs(),
                  ),
                ))
        ]));
  }

  List<Widget> getFormInputs() {
    List<Widget> items = [];
    items.add(
        createSelectInput("service", 255, config['service'], onSelected: (v) {
      setState(() {
        selectOptions["service_catigories"] = v['children'];
        selectedTexts["service"] = v['name'];
        body["service"] = v['id'];
      });
    }));
    items.add(createSelectInput(
        "service_catigory", 256, selectOptions["service_catigories"],
        onEmptyMessage: LanguageManager.getText(257), onSelected: (v) {
      setState(() {
        selectedTexts['service_catigory'] = v['name'];
        body["service_catigory"] = v['id'];
      });
    }));

    items.add(createInput("about", 258, maxInput: 500, maxLines: 4));

    items.add(Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Text(
        LanguageManager.getText(259),
        textDirection: LanguageManager.getTextDirection(),
        style: TextStyle(
            color: Converter.hexToColor("#2094CD"),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
    ));
    items.add(createImagesPicker());

    items.add(InkWell(
      onTap: () {
        Alert.show(context, getAddOfferForm(), type: AlertType.WIDGET);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: Converter.hexToColor("#344F64"),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            child: Text(
              LanguageManager.getText(260),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  color: Converter.hexToColor("#2094CD"),
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ));
    items.add(offers.length == 0
        ? Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withAlpha(50), width: 1),
                borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(25),
            child: Text(
              LanguageManager.getText(263),
              textAlign: TextAlign.center,
            ),
          )
        : Container(
            child: Column(
              textDirection: LanguageManager.getTextDirection(),
              mainAxisSize: MainAxisSize.min,
              children: offers.map((e) {
                return Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 2,
                            spreadRadius: 2)
                      ],
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    textDirection: LanguageManager.getTextDirection(),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        textDirection: LanguageManager.getTextDirection(),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e["price"].toString() + " " + Globals.getUnit(),
                            textDirection: LanguageManager.getTextDirection(),
                            style: TextStyle(
                                color: Converter.hexToColor("#2094CD"),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                offers.remove(e);
                              });
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                      Text(
                        e["details"].toString(),
                        textDirection: LanguageManager.getTextDirection(),
                        style: TextStyle(
                            color: Converter.hexToColor("#727272"),
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ));
    items.add(InkWell(
      onTap: send,
      child: Container(
        margin: EdgeInsets.all(10),
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(widget.id == null ? 262 : 254),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ],
            borderRadius: BorderRadius.circular(8),
            color: Converter.hexToColor("#344f64")),
      ),
    ));
    return items;
  }

  Widget getAddOfferForm() {
    List<Widget> items = [];
    items.add(Container(
      padding: EdgeInsets.all(10),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          Text(
            LanguageManager.getText(260),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () {
              Alert.publicClose();
            },
            child: Container(
              child: Icon(Icons.close),
            ),
          ),
        ],
      ),
    ));
    items.add(createInput("offer_price", 95, textType: TextInputType.number));
    items.add(createInput("offer_details", 261, maxLines: 4, maxInput: 200));
    items.add(InkWell(
      onTap: () {
        if (body['offer_price'] == null ||
            body['offer_details'] == null ||
            body['offer_price'].isEmpty ||
            body['offer_details'].isEmpty) {
          Alert.show(context, LanguageManager.getText(264));
          return;
        }
        setState(() {
          offers.add({
            "price": body["offer_price"],
            "details": body["offer_details"],
          });
        });
        body['offer_price'] = "";
        body['offer_details'] = "";
        controllers["offer_price"].text = "";
        controllers["offer_details"].text = "";
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        height: 45,
        alignment: Alignment.center,
        child: Text(
          LanguageManager.getText(260),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(15),
                  spreadRadius: 2,
                  blurRadius: 2)
            ],
            borderRadius: BorderRadius.circular(8),
            color: Converter.hexToColor("#344f64")),
      ),
    ));
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items,
      ),
    );
  }

  Widget createImagesPicker() {
    if (tabControllers["images"] == null ||
        tabControllers["images"].length != selectedFiles.length) {
      tabControllers["images"] =
          TabController(length: selectedFiles.length, vsync: this);
      tabControllers["images"].addListener(() {
        setState(() {});
      });
      if (selectedFiles.length > 0)
        tabControllers["images"].index = selectedFiles.length - 1;
    }
    double size = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: size,
              height: size * 0.5,
              child: TabBarView(
                controller: tabControllers["images"],
                children: selectedFiles.map((e) {
                  if (e["id"] != null) {
                    return CachedNetworkImage(imageUrl: e["url"]);
                  } else
                    return Image.memory(e["data"]);
                }).toList(),
              ),
              decoration: BoxDecoration(
                color: Converter.hexToColor(
                    errors["images"] != null ? "#E9B3B3" : "#F2F2F2"),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: LanguageManager.getTextDirection(),
                children: [
                  Container(
                    width: 50,
                  ),
                  Row(
                    children: selectedFiles.map((e) {
                      bool selected = tabControllers["images"].index ==
                          selectedFiles.indexOf(e);
                      return Container(
                        margin: EdgeInsets.only(left: 2, right: 2),
                        width: selected ? 10 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Converter.hexToColor("#344F64"),
                            borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  Row(
                    textDirection: LanguageManager.getTextDirection(),
                    children: [
                      InkWell(
                        onTap: () async {
                          await pickImage(ImageSource.gallery);
                        },
                        child: Container(
                            width: 24,
                            height: 24,
                            child: Icon(
                              Icons.upload_sharp,
                              size: 24,
                            )),
                      ),
                      Container(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            int index = tabControllers['images'].index;
                            if (selectedFiles.isNotEmpty) {
                              if (selectedFiles[index]['id'] != null)
                                removedImagesUpdate
                                    .add(selectedFiles[index]['id']);
                              selectedFiles.removeAt(index);
                            }
                          });
                        },
                        child: Container(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.delete, size: 22)),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget createImagesUploaded() {
    double size = (MediaQuery.of(context).size.width - 20) * 0.25;
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Converter.hexToColor("#ffffff")),
      child: Wrap(
          textDirection: LanguageManager.getTextDirection(),
          children: images.map((e) {
            return Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(10),
                child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(25),
                              spreadRadius: 2,
                              blurRadius: 2)
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white),
                    child: Stack(
                      children: [
                        CachedNetworkImage(imageUrl: e['name']),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                images.remove(e);
                                removedImagesUpdate.add(e["id"]);
                                body["removed_images"] =
                                    jsonEncode(removedImagesUpdate);
                              });
                            },
                            child: Container(
                                width: 24,
                                height: 24,
                                color: Colors.white,
                                child: Icon(
                                  Icons.delete,
                                  size: 22,
                                )),
                          ),
                        )
                      ],
                    )));
          }).toList()),
    );
  }

  Widget createSelectInput(key, titel, options, {onEmptyMessage, onSelected}) {
    return GestureDetector(
      onTap: () {
        hideKeyBoard();
        if (options == null) {
          Alert.show(context, onEmptyMessage);
          return;
        }
        Alert.show(context, options,
            type: AlertType.SELECT, onSelected: onSelected);
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        padding: EdgeInsets.only(left: 7, right: 7),
        decoration: BoxDecoration(
            color: Converter.hexToColor(
                errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Expanded(
                child: Text(
              selectedTexts[key] != null
                  ? selectedTexts[key]
                  : LanguageManager.getText(titel),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 16,
                  color:
                      selectedTexts[key] != null ? Colors.black : Colors.grey),
            )),
            Icon(
              FlutterIcons.chevron_down_fea,
              color: Converter.hexToColor("#727272"),
              size: 22,
            )
          ],
        ),
      ),
    );
  }

  Widget createInput(key, titel,
      {maxInput, TextInputType textType: TextInputType.text, maxLines}) {
    if (controllers[key] == null) {
      controllers[key] = TextEditingController(
          text: selectedTexts[key] != null ? selectedTexts[key] : "");
    }
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      padding: EdgeInsets.only(left: 7, right: 7),
      decoration: BoxDecoration(
          color:
              Converter.hexToColor(errors[key] != null ? "#E9B3B3" : "#F2F2F2"),
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        onChanged: (t) {
          body[key] = t;
        },
        keyboardType: textType,
        maxLength: maxInput,
        maxLines: maxLines,
        controller: controllers[key],
        textDirection: LanguageManager.getTextDirection(),
        decoration: InputDecoration(
            hintText: LanguageManager.getText(titel),
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            hintTextDirection: LanguageManager.getTextDirection(),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0)),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      ImagePicker _picker = ImagePicker();

      PickedFile pickedFile = await _picker.getImage(
          source: source, maxWidth: 1024, imageQuality: 50);
      if (pickedFile == null) return;
      var extantion = pickedFile.path.split(".").last;
      Uint8List data = await pickedFile.readAsBytes();
      setState(() {
        selectedFiles.add({"type": extantion, "data": data});
      });
    } catch (e) {
      Alert.show(context, LanguageManager.getText(27));
      // error
    }
  }

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }

  void send() {
    setState(() {
      errors = {};
    });
    List validateKeys = ["service", "service_catigory", "about"];
    for (var key in validateKeys) {
      if (body[key] == null || body[key].isEmpty)
        setState(() {
          errors[key] = "_";
        });
    }
    if (selectedFiles.length == 0 && images.length == 0) {
      errors["images"] = "_";
    }
    if (errors.keys.length > 0) return;

    List files = [];

    var i = 0;
    for (var item in selectedFiles) {
      if (item['id'] == null) {
        files.add({
          "name": "image_$i",
          "file": item['data'],
          "type_name": "image",
          "file_type": item['type'],
          "file_name": "image"
        });
        i++;
      }
    }
    body["images_length"] = files.length.toString();

    body['offers'] = jsonEncode(offers);
    body['removed_images'] = jsonEncode(removedImagesUpdate);
    if (widget.id != null) {
      body['id'] = widget.id.toString();
    }
    Alert.startLoading(context);
    NetworkManager().fileUpload(Globals.baseUrl + "services/add", files, (p) {},
        (r) {
      Alert.endLoading();
      if (r["status"] == true) {
        Navigator.of(context).pop(true);
      }
    }, body: body);
  }
}
