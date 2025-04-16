import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class BookingFormPage extends StatefulWidget {
  final String lecturerId;
  final String lecturerName;
  final String slotId;
  final String date;
  final String time;

  const BookingFormPage({
    super.key,
    required this.lecturerId,
    required this.lecturerName,
    required this.slotId,
    required this.date,
    required this.time,
  });

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;

  // File attachment variables
  File? _selectedFile;
  String? _selectedFileName;
  String? _fileDownloadUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    // Parse the time string to separate start and end times
    if (widget.time.contains('-')) {
      final timeParts = widget.time.split('-');
      if (timeParts.length == 2) {
        _fromController.text = timeParts[0].trim();
        _toController.text = timeParts[1].trim();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select file: $e')),
        );
      }
    }
  }

  Future<String?> _uploadFile() async {
    if (_selectedFile == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create unique file name using timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName';

      // Create reference to the file location in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('booking_attachments')
          .child(widget.lecturerId)
          .child(fileName);

      // Upload the file
      final uploadTask = storageRef.putFile(_selectedFile!);

      // Wait for upload to complete
      await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload file if selected
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile();
      }

      // Update the booking status in the slot document
      await FirebaseFirestore.instance
          .collection('lecturers')
          .doc(widget.lecturerId)
          .collection('slots')
          .doc(widget.slotId)
          .update({
        'booked': true,
      });

      // Create a record in bookings collection
      await FirebaseFirestore.instance.collection('bookings').add({
        'lecturerId': widget.lecturerId,
        'lecturerName': widget.lecturerName,
        'slotId': widget.slotId,
        'date': widget.date,
        'time': widget.time,
        'studentName': _nameController.text,
        'fromTime': _fromController.text,
        'toTime': _toController.text,
        'message': _messageController.text,
        'hasAttachment': fileUrl != null,
        'attachmentUrl': fileUrl,
        'attachmentName': _selectedFileName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return success to previous page
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error submitting booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit booking: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request to book'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Name field
              const Text('Your First Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // From field
              const Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fromController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // User can't edit this field
              ),

              const SizedBox(height: 16),

              // To field
              const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _toController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true, // User can't edit this field
              ),

              const SizedBox(height: 16),

              // Message field
              const Text('Write a message to the host',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 5, // Reduced max lines
              ),

              const SizedBox(height: 20),

              // Attachment section with Browse File button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_file),
                        const SizedBox(width: 8),
                        const Text(
                          'Attachment',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Icon(Icons.info_outline, size: 16),
                      ],
                    ),
                    Text(
                      'Select and upload the files of your choice',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(minHeight: 90),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedFile != null
                          ? _buildSelectedFilePreview()
                          : _buildFilePicker(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (_isSubmitting || _isUploading) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isSubmitting || _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(_isUploading
                                ? 'Uploading...'
                                : 'Submitting...'),
                          ],
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickFile,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload, color: Colors.grey),
              const SizedBox(height: 4),
              const Text(
                'Choose a file or drag & drop it here',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'JPEG, PNG, PDF, and MP4 formats, up to 50MB',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: OutlinedButton(
                  onPressed: _pickFile,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Browse File',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFilePreview() {
    // Get file extension
    final extension = _selectedFileName?.split('.').last.toLowerCase();
    final isImage =
        extension == 'jpg' || extension == 'jpeg' || extension == 'png';

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show preview if it's an image
          if (isImage && _selectedFile != null)
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Image.file(
                _selectedFile!,
                fit: BoxFit.contain,
                height: 120,
              ),
            ),

          // Show file icon for non-images
          if (!isImage)
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Icon(
                extension == 'pdf'
                    ? Icons.picture_as_pdf
                    : extension == 'mp4'
                        ? Icons.video_file
                        : Icons.insert_drive_file,
                size: 48,
                color: Colors.grey[700],
              ),
            ),

          const SizedBox(height: 8),

          // File name
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedFileName ?? 'Selected file',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _selectedFileName = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          // Change file button
          TextButton(
            onPressed: _pickFile,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[800],
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change file',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
