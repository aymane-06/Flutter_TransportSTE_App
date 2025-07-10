import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/api_config_model.dart';
import '../../repository/api_config_repo.dart';
import '../../view_model/api_config_cubit/api_config_cubit.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  late TextEditingController _baseUrlController;
  late TextEditingController _portController;
  late TextEditingController _dbNameController;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    final apiConfig = getIt<ApiConfigRepo>().getApiCongig();
    _baseUrlController = TextEditingController(text: apiConfig.baseUrl);
    _portController = TextEditingController(text: apiConfig.port);
    _dbNameController = TextEditingController(text: apiConfig.dbName);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _portController.dispose();
    _dbNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ApiConfigCubit>()..getApiConfig(),
      child: _ServerConfigBody(
        baseUrlController: _baseUrlController,
        portController: _portController,
        dbNameController: _dbNameController,
        formKey: _formKey,
      ),
    );
  }
}

class _ServerConfigBody extends StatelessWidget {
  final TextEditingController baseUrlController;
  final TextEditingController portController;
  final TextEditingController dbNameController;
  final GlobalKey<FormState> formKey;

  const _ServerConfigBody({
    required this.baseUrlController,
    required this.portController,
    required this.dbNameController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: AppColors.grey200,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuration Serveur',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
      ),
      body: BlocListener<ApiConfigCubit, ApiConfigState>(
        listener: (context, state) {
          if (state is SuccessToChangeApiConfigState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Configuration sauvegardée avec succès"),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
          if (state is FailedToConnectState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is SuccessToTestApiConnectionState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }

        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey200.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.settings_applications,
                        size: 48.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Configuration du Serveur',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Configurez les paramètres de connexion au serveur',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Form Fields
                _buildInputField(
                  controller: baseUrlController,
                  label: "URL de base",
                  hint: "Ex : www.example.com",
                  icon: Icons.language,
                ),

                SizedBox(height: 20.h),

                _buildInputField(
                  controller: portController,
                  label: "Port",
                  hint: "Ex : 8080",
                  icon: Icons.settings_ethernet,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20.h),

                _buildInputField(
                  controller: dbNameController,
                  label: "Nom de la base de données",
                  hint: "Ex : example_db_1",
                  icon: Icons.storage,
                ),

                SizedBox(height: 40.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => _handleSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      "Enregistrer",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                ),
              SizedBox(height: 20.h),

                 // Test Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => _handleTestConnection(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.grey50,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: AppColors.primary, width: 1),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_find,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Tester la connexion",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  } 

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value?.isEmpty == true) {
              return "$label est requis";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.grey500),
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.grey500),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleSave(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      final model = ApiConfigModel(
        port: portController.text.trim(),
        baseUrl: baseUrlController.text.trim(),
        dbName: dbNameController.text.trim(),
      );
      context.read<ApiConfigCubit>().setApiConfig(model);
    }
  }
  void _handleTestConnection(BuildContext context) {

    if (formKey.currentState?.validate() ?? false) {
      final model = ApiConfigModel(
        port: portController.text.trim(),
        baseUrl: baseUrlController.text.trim(),
        dbName: dbNameController.text.trim(),
      );
      context.read<ApiConfigCubit>().testApiConnection(model);
    }
  }
}
