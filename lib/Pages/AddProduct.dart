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

class AddProduct extends StatefulWidget {
  final id;
  const AddProduct({this.id});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Map<String, String> body = {}, selectedTexts = {}, errors = {};
  Map selectOptions = {};
  List images = [], removedImagesUpdate = [];
  Map<String, TextEditingController> controllers = {};
  bool isLoading = false, showExtraOptions = true;
  List<Map> selectedFiles = [];
  var config;
  @override
  void initState() {
    body["garanteed"] = "0";
    body["used"] = "0";
    Future.delayed(Duration.zero, () {
      loadConfig();
    });
    super.initState();
  }

  void loadConfig() {
    setState(() {
      isLoading = true;
    });
    var r = {
      "state": true,
      "catigories": [
        {
          "id": "1",
          "name": "قسم الجوالات",
          "name_en": "",
          "parent_id": "0",
          "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
          "created_at": "2021-07-12 08:09:42",
          "children": [
            {
              "id": "3",
              "name": "ايفون",
              "name_en": "",
              "parent_id": "1",
              "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
              "created_at": "2021-07-12 08:09:42",
              "children": [
                {
                  "id": "6",
                  "name": "iphone 5S",
                  "name_en": "",
                  "parent_id": "3",
                  "icon": "https:\/\/server.drtechapp.com\/storage\/images\/",
                  "created_at": "2021-07-12 08:09:42",
                  "children": []
                }
              ]
            },
            {
              "id": "4",
              "name": "سامسونج",
              "name_en": "",
              "parent_id": "1",
              "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
              "created_at": "2021-07-12 08:09:42",
              "children": []
            },
            {
              "id": "5",
              "name": "هواوي",
              "name_en": "",
              "parent_id": "1",
              "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
              "created_at": "2021-07-12 08:09:42",
              "children": []
            }
          ],
          "extra_options": true
        },
        {
          "id": "2",
          "name": "قسم الاكسسوارات ",
          "name_en": "",
          "parent_id": "0",
          "icon": "https:\/\/server.drtechapp.com\/storage\/images\/camera.svg",
          "created_at": "2021-07-12 08:09:42",
          "children": []
        }
      ],
      "cities": [
        {
          "id": "8363",
          "name": "مكة",
          "name_en": "",
          "country_id": "191",
          "text": "مكة",
          "children": [
            {
              "id": "633",
              "name": "الرياض",
              "name_en": "",
              "city_id": "8363",
              "text": "الرياض"
            }
          ]
        },
        {
          "id": "8364",
          "name": "جدة",
          "name_en": "",
          "country_id": "191",
          "text": "جدة",
          "children": [
            {
              "id": "634",
              "name": "المدينة المنورة",
              "name_en": "",
              "city_id": "8364",
              "text": "المدينة المنورة"
            }
          ]
        }
      ],
      "colors": [
        {
          "id": "1",
          "name": "احمر",
          "name_en": "",
          "created_at": "2021-07-12 13:55:45"
        },
        {
          "id": "2",
          "name": "اسود",
          "name_en": "",
          "created_at": "2021-07-12 13:55:45"
        }
      ],
      "store_product_duration": [
        {
          "id": "1",
          "name": "3 ايام",
          "name_en": "",
          "days": "3",
          "created_at": "2022-06-12 00:00:00"
        },
        {
          "id": "2",
          "name": "شهر",
          "name_en": "",
          "days": "30",
          "created_at": "2022-06-12 00:00:00"
        }
      ]
    };
    // NetworkManager.httpGet(Globals.baseUrl + "product/configuration", context, (r) {
      if (r['state'] == true) {
        setState(() {
          config = r;
          if (widget.id != null) {
            // load();
          } else {
            isLoading = false;
          }
        });
      }
    // }, cashable: true);
  }

  void load() {
    NetworkManager.httpGet(Globals.baseUrl + "product/get?id=${widget.id}", context, (r) {
      if (r["status"] == true) {
        setState(() {
          isLoading = false;

          fillData(r['data']);
        });
      }
    }, cashable: true);
  }

  void fillData(data) {
    body["id"] = widget.id.toString();
    body["titel"] = data['titel'];
    body["catigory"] = data['catigory_id'];
    body["city"] = data['city_id'];
    body["brand"] = data['product_type_id'];
    body["model"] = data['product_model_id'];
    body["color"] = data['color_id'];
    body["used_time"] = data['used_period'];
    body["memory"] = data['memory'];
    body["garanteed"] = data['is_guaranteed'].toString();
    body["used"] = data['product_status'] == "USED" ? "1" : "0";
    body["isOffer"] = data['show_in_promotion'].toString();
    body["offer_price"] = data['promotion_price'];
    body["price"] = data['price'];
    body["note"] = data['description'];
    images = data['images'];
    selectedTexts["titel"] = data['titel'];
    selectedTexts["catigory"] = data['catigory'];
    selectedTexts["city"] = data['city'];
    selectedTexts["brand"] = data['brand'];
    selectedTexts["model"] = data['model'];
    selectedTexts["color"] = data['color'];
    selectedTexts["used_time"] = data['used_period'];
    selectedTexts["memory"] = data['memory'];
    selectedTexts["offer_price"] = data['promotion_price'];
    selectedTexts["price"] = data['price'];
    selectedTexts["note"] = data['description'];
  }

  void deleteProduct() {
    Alert.show(
        context,
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: LanguageManager.getTextDirection(),
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      FlutterIcons.x_fea,
                      size: 24,
                    ),
                  )
                ],
              ),
              Container(
                child: Icon(
                  FlutterIcons.trash_faw,
                  size: 50,
                  color: Converter.hexToColor("#707070"),
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                LanguageManager.getText(171),
                style: TextStyle(
                    color: Converter.hexToColor("#707070"),
                    fontWeight: FontWeight.bold),
              ),
              Container(
                height: 30,
              ),
              Row(
                textDirection: LanguageManager.getTextDirection(),
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      deleteProductConferm();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(169),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withAlpha(15),
                                spreadRadius: 2,
                                blurRadius: 2)
                          ],
                          borderRadius: BorderRadius.circular(8),
                          color: Converter.hexToColor("#FF0000")),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Alert.publicClose();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 45,
                      alignment: Alignment.center,
                      child: Text(
                        LanguageManager.getText(172),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                  )
                ],
              )
            ],
          ),
        ),
        type: AlertType.WIDGET);
  }

  void deleteProductConferm() {
    Alert.startLoading(context);
    Map<String, String> body = {"id": widget.id.toString()};
    NetworkManager.httpPost(Globals.baseUrl + "product/delete",context , (r) {
      if (r['state'] == true) {
        Alert.endLoading();
        Navigator.pop(context);
      }
    }, body: body);
  }

  void send() {
    setState(() {
      errors = {};
    });
    List validateKeys = [
      "titel",
      "catigory",
      "city",
      "brand",
      "model",
      "color",
      "price"
    ];
    if (widget.id == null) validateKeys.add("store_product_duration");
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
    body["images_length"] = selectedFiles.length.toString();

    for (var i = 0; i < selectedFiles.length; i++) {
      var item = selectedFiles[i];
      files.add({
        "name": "image_$i",
        "file": item['data'],
        "type_name": "image",
        "file_type": item['type'],
        "file_name": "image"
      });
    }
    Alert.startLoading(context);
    NetworkManager().fileUpload(Globals.baseUrl + "product/add", files, (p) {},
        (r) {
      Alert.endLoading();
      if (r["status"] == true) {
        Navigator.pop(context);
      }
    }, body: body);
  }

  void pickImage(ImageSource source) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(children: [
          TitleBar(() {Navigator.pop(context);}, widget.id == null ? 144 : 176),
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

    items.add(createInput("titel", 145));
    items.add(createSelectInput("catigory", 146, config['catigories'],
        onSelected: (v) {
      setState(() {
        selectedTexts["catigory"] = v['name'];
        body["catigory"] = v['id'];
        selectOptions["brand"] = v['children'];
        showExtraOptions = v['extra_options'] == true;

        // clear
        selectedTexts.remove("brand");
        body.remove("brand");
        selectOptions.remove("model");
        body.remove("model");
        selectedTexts.remove("model");

        body.remove("used_time");
        body.remove("memory");
      });
    }));
    items.add(createSelectInput("city", 107, config['cities'], onSelected: (v) {
      setState(() {
        selectedTexts["city"] = v['name'];
        body["city"] = v['id'];
      });
    }));
    items.add(createSelectInput("brand", 147, selectOptions["brand"],
        onEmptyMessage: LanguageManager.getText(160), onSelected: (v) {
      setState(() {
        selectedTexts["brand"] = v['name'];
        body["brand"] = v['id'];
        selectOptions["model"] = v['children'];
      });
    }));
    items.add(createSelectInput("model", 148, selectOptions["model"],
        onEmptyMessage: LanguageManager.getText(160), onSelected: (v) {
      setState(() {
        selectedTexts["model"] = v['name'];
        body["model"] = v['id'];
      });
    }));
    items.add(createSelectInput("color", 149, config["colors"], onSelected: (v) {
      setState(() {
        selectedTexts["color"] = v['name'];
        body["color"] = v['id'];
      });
    }));

    if (showExtraOptions) items.add(createInput("used_time", 150));
    if (showExtraOptions) items.add(createInput("memory", 151));

    items.add(createSelectInput(
        "store_product_duration", 152, config["store_product_duration"],
        onSelected: (v) {
      setState(() {
        selectedTexts["store_product_duration"] = v['name'];
        body["store_product_duration"] = v['id'];
      });
    }));

    items.add(createDuleOptions(
        "garanteed", 153, 155, 156, body["garanteed"] == "1"));
    items.add(createDuleOptions("used", 154, 142, 143, body["used"] == "1"));

    items.add(Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          textDirection: LanguageManager.getTextDirection(),
          children: [
            Expanded(
                child: Text(LanguageManager.getText(157),
                    textDirection: LanguageManager.getTextDirection(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Converter.hexToColor("#2094CD"),
                    ))),
            Switch(
                value: body["isOffer"] == "1",
                onChanged: (v) {
                  setState(() {
                    body["isOffer"] = v ? "1" : "0";
                  });
                })
          ],
        )));

    items.add(createInput("price", 95, textType: TextInputType.number));
    items.add(createInput("offer_price", 158, textType: TextInputType.number));
    items.add(
        createInput("note", 159, textType: TextInputType.text, maxLines: 4));
    items.add(Container(
      height: 5,
    ));
    items.add(createImagesUploaded());
    items.add(createImagesPicker());
    items.add(Container(
      height: 5,
    ));

    items.add(Row(
      textDirection: LanguageManager.getTextDirection(),
      children: [
        Expanded(
          child: InkWell(
            onTap: send,
            child: Container(
              margin: EdgeInsets.all(10),
              height: 45,
              alignment: Alignment.center,
              child: Text(
                LanguageManager.getText(widget.id == null ? 161 : 177),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          ),
        ),
        widget.id == null
            ? Container()
            : Expanded(
                child: InkWell(
                  onTap: deleteProduct,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    height: 45,
                    alignment: Alignment.center,
                    child: Text(
                      LanguageManager.getText(169),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(15),
                              spreadRadius: 2,
                              blurRadius: 2)
                        ],
                        borderRadius: BorderRadius.circular(8),
                        color: Converter.hexToColor("#f00000")),
                  ),
                ),
              ),
      ],
    ));
    return items;
  }

  Widget createImagesPicker() {
    double size = (MediaQuery.of(context).size.width - 20) * 0.25;
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Converter.hexToColor(
              errors["images"] != null ? "#E9B3B3" : "#ffffff")),
      child: Wrap(
        textDirection: LanguageManager.getTextDirection(),
        children: selectedFiles.map((e) {
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
                      Image.memory(e["data"]),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedFiles.remove(e);
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
        }).toList()
          ..add(Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                pickImage(ImageSource.gallery);
              },
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(25),
                      spreadRadius: 2,
                      blurRadius: 2)
                ], borderRadius: BorderRadius.circular(5), color: Colors.white),
                alignment: Alignment.center,
                child: Icon(
                  FlutterIcons.upload_faw,
                  size: 25,
                ),
              ),
            ),
          )),
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

  Widget createDuleOptions(key, titel, yesOption, noOption, bool isActive) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        textDirection: LanguageManager.getTextDirection(),
        children: [
          Container(
            width: 100,
            child: Text(
              LanguageManager.getText(titel),
              textDirection: LanguageManager.getTextDirection(),
              style: TextStyle(
                  fontSize: 16,
                  color: Converter.hexToColor("#2094CD"),
                  fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                body[key] = "1";
              });
            },
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(width: 2, color: Colors.grey)),
                    child: isActive
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey),
                          )
                        : null,
                  ),
                ),
                Container(
                  width: 10,
                ),
                Text(
                  LanguageManager.getText(yesOption),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
          ),
          InkWell(
            onTap: () {
              setState(() {
                body[key] = "0";
              });
            },
            child: Row(
              textDirection: LanguageManager.getTextDirection(),
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(width: 2, color: Colors.grey)),
                    child: !isActive
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey),
                          )
                        : null,
                  ),
                ),
                Container(
                  width: 10,
                ),
                Text(
                  LanguageManager.getText(noOption),
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            ),
          )
        ],
      ),
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

  void hideKeyBoard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild.unfocus();
    }
  }
}
