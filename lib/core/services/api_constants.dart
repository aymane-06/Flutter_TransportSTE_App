class ApiConstants {
  static const String pallet = "/object/stock.picking/read_bar_code";
  static const String scanPallet = "/object/mrp.production/scan_pallet_export";
  static const String scanPallet2 =
      "/object/mrp.production/scan_pallet_exportt";
  static const String scanPalletWithClient =
      "/object/optipack.chargement/scan_pallet_with_clientt";

  static const String move = "/object/stock.picking/move_packages_call";
  static const String createPacking = "/object/mrp.production/post_pallet";
  static const String createAutoPacking =
      "/object/mrp.production/post_pallete_auto";
  static const String versements = "/object/mrp.production/get_versements";

  static const String chargement =
      "/object/optipack.chargement/post_pallet_info";
  static const String groupWork = "/object/mrp.task/create_tasks_from_group";
  static const String personalWork =
      "/object/mrp.task/create_tasks_from_employee";
  static const String groupRequest =
      "/object/mrp.task/get_groups_from_work_center";
  static const String fetchPeopleByGroupId =
      "/object/mrp.task/get_employee_from_groups";
  static const String printing = "/colis/codes";
  static const String printingConfig = "/object/optipack.printer/get_ip";
  static const String removeColis = "/object/colis.barcode/descanner";
}
// /object/mrp.task/get_groups_from_work_center