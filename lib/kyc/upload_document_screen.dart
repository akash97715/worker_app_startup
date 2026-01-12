import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../core/api_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  List<String> roles = [];
  List<String> uploadedDocuments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPartnerInfo();
    });
  }

  Future<void> _loadPartnerInfo() async {
    // Ensure we always stop loading, even if something goes wrong
    try {
      if (!mounted) return;
      
      final route = ModalRoute.of(context);
      if (route == null || route.settings.arguments == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Mobile number not found. Please go back and try again.';
          });
        }
        return;
      }
      
      final mobile = route.settings.arguments as String?;
      if (mobile == null || mobile.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Mobile number is required. Please go back and try again.';
          });
        }
        return;
      }
      
      print('Loading partner info for mobile: $mobile');
      
      print('Making API call to /partner/info');
      final response = await ApiClient.dio.get(
        '/partner/info',
        queryParameters: {'mobile_number': mobile},
        options: Options(
          validateStatus: (status) => status! < 500, // Accept all status codes < 500
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('Request timeout');
          throw DioException(
            requestOptions: RequestOptions(path: '/partner/info'),
            type: DioExceptionType.connectionTimeout,
            message: 'Request timeout. Please check your connection and try again.',
          );
        },
      );
      
      print('API response received: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (!mounted) return;
      
      if (response.statusCode != null && response.statusCode! >= 400) {
        // Handle error response
        final errorDetail = response.data is Map 
            ? response.data['detail'] ?? response.data['message'] ?? 'Server error'
            : 'Server error occurred';
        setState(() {
          isLoading = false;
          errorMessage = errorDetail.toString();
        });
        return;
      }
      
      final rolesList = List<String>.from(response.data['roles'] ?? []);
      final docsList = List<String>.from(response.data['uploaded_documents'] ?? []);
      
      print('Partner info loaded successfully.');
      print('Roles: $rolesList');
      print('Uploaded documents: $docsList');
      print('Is Aadhaar uploaded: ${docsList.contains('aadhaar')}');
      print('Is DL uploaded: ${docsList.contains('dl')}');
      print('Is driver selected: ${rolesList.contains('driver')}');
      print('Can submit: ${docsList.contains('aadhaar') && (!rolesList.contains('driver') || docsList.contains('dl'))}');
      
      setState(() {
        roles = rolesList;
        uploadedDocuments = docsList;
        isLoading = false;
        errorMessage = null;
      });
    } on DioException catch (e) {
      print('DioException caught: ${e.type}, ${e.message}');
      print('Response: ${e.response?.data}');
      if (!mounted) return;
      
      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMsg = 'Request timeout. Please check your connection and ensure the backend server is running.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Cannot connect to server. Please check if the backend is running on http://127.0.0.1:8000';
      } else if (e.response != null) {
        errorMsg = e.response?.data is Map
            ? (e.response?.data['detail'] ?? e.response?.data['message'] ?? 'Server error occurred')
            : (e.response?.statusMessage ?? 'Server error occurred');
      } else {
        errorMsg = e.message ?? 'Failed to load partner information. Please try again.';
      }
      
      setState(() {
        isLoading = false;
        errorMessage = errorMsg;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'An unexpected error occurred. Please check the console for details.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always ensure loading is stopped
      if (mounted && isLoading) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> upload(String mobile, String type) async {
    try {
      Uint8List? bytes;
      String fileName;
      
      // Show dialog to choose file type
      final fileType = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Document Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Image (JPEG, PNG)'),
                subtitle: const Text('Camera or Gallery'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF Document'),
                subtitle: const Text('Select from files'),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
            ],
          ),
        ),
      );
      
      if (fileType == null) return;
      
      if (fileType == 'image') {
        // Use ImagePicker for images
        final picker = ImagePicker();
        
        // Show dialog to choose source
        final source = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
        
        if (source == null) return;
        
        final picked = await picker.pickImage(
          source: source,
          imageQuality: 85,
        );
        
        if (picked == null) return;
        
        bytes = await picked.readAsBytes();
        fileName = picked.name;
      } else {
        // Use FilePicker for PDFs
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        
        if (result == null || result.files.isEmpty) return;
        
        final file = result.files.single;
        
        // file_picker returns bytes on web and most platforms
        // On some platforms it might return path, but bytes should be preferred
        if (file.bytes != null) {
          bytes = file.bytes;
          fileName = file.name;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not read file. Please try selecting the PDF again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      
      if (bytes == null) return;

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Uploading document...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final formData = FormData.fromMap({
        'mobile_number': mobile,
        'document_type': type,
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await ApiClient.dio.post(
        '/partner/upload-document',
        data: formData,
      );
      
      print('Upload response: ${response.data}');
      
      // Reload partner info to update uploaded documents
      await _loadPartnerInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      print('Upload error: ${e.response?.data}');
      if (mounted) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['detail'] ?? 'Failed to upload document')
            : 'Failed to upload document. Please try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get isDriverRoleSelected => roles.contains('driver');
  bool get isAadhaarUploaded => uploadedDocuments.contains('aadhaar');
  bool get isDLUploaded => uploadedDocuments.contains('dl');
  
  // Aadhaar/Voter ID is mandatory for all
  // DL is mandatory only if driver role is selected
  bool get canSubmit => isAadhaarUploaded && (!isDriverRoleSelected || isDLUploaded);

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final mobile = route?.settings.arguments as String? ?? '';
    
    if (mobile.isEmpty && !isLoading && errorMessage == null) {
      // If mobile is not available and we haven't loaded yet, try to load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadPartnerInfo();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            _loadPartnerInfo();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
              children: [
                // Debug info (remove in production)
                if (roles.isNotEmpty || uploadedDocuments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Debug: Roles=$roles, Docs=$uploadedDocuments, CanSubmit=$canSubmit',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ListTile(
                  title: const Text('Upload Aadhaar / Voter ID *'),
                  subtitle: isAadhaarUploaded 
                      ? const Text('Uploaded', style: TextStyle(color: Colors.green))
                      : const Text('Required', style: TextStyle(color: Colors.red)),
                  trailing: isAadhaarUploaded 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.upload_file),
                  onTap: () => upload(mobile, 'aadhaar'),
                ),
                ListTile(
                  title: Text('Upload Driving License${isDriverRoleSelected ? ' *' : ''}'),
                  subtitle: isDriverRoleSelected
                      ? (isDLUploaded 
                          ? const Text('Uploaded', style: TextStyle(color: Colors.green))
                          : const Text('Required for Driver', style: TextStyle(color: Colors.red)))
                      : const Text('Optional'),
                  trailing: isDLUploaded 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.upload_file),
                  onTap: () => upload(mobile, 'dl'),
                ),
                if (!isAadhaarUploaded)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aadhaar / Voter ID is mandatory',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isDriverRoleSelected && !isDLUploaded)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Driving License is mandatory for Driver role',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canSubmit
                          ? () async {
                              try {
                                await ApiClient.dio.post(
                                  '/partner/submit-application',
                                  queryParameters: {"mobile_number": mobile},
                                );
                                if (mounted) {
                                  Navigator.pushNamed(context, '/pending');
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to submit application'),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSubmit ? Colors.orange : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: 18, 
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
