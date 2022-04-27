import 'package:dr_tech/Config/Converter.dart';
import 'package:dr_tech/Models/LanguageManager.dart';
import 'package:share/share.dart';

class ShareManager {
  static void shearEngineer(id, name, service) {
    print('here_shearEngineer: $name ,$service ,');
    String paylaod = [
      Converter.replaceValue(LanguageManager.getText(173), name) + service,
      LanguageManager.getText(321),//Globals.shareUrl + "?eng_id=$id",
      LanguageManager.getText(174)
    ].join("\n");

    Share.share(paylaod, subject: service);
  }

  static void shearService(id, name, {service = ''}) {
    String paylaod = [
      Converter.replaceValue(LanguageManager.getText(266), service) + name,
      LanguageManager.getText(321),//Globals.shareUrl + "?service_id=$id",
      LanguageManager.getText(174)
    ].join("\n");

    Share.share(paylaod, subject: name);
  }
}
