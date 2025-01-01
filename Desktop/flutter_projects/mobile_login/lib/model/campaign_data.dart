import 'advertising_structure.dart';

class CampaignData {
  static final CampaignData _instance = CampaignData._internal();
  factory CampaignData() => _instance;

  CampaignData._internal();

  List<AdvertisingStructure> selectedStructures = [];
  List<AdvertisingStructure> historyStructures = [];
}
