// lib/providers/profile_provider.dart
import 'dart:io';
import '../utils/friendly_error.dart';
import 'package:flutter/material.dart';
import 'package:fitness_tracker_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  /// Fetch profile data from the API.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final data = await _apiService.getProfile();
      
      // Get custom profile picture path from local storage if it exists
      final prefs = await SharedPreferences.getInstance();
      final customProfilePic = prefs.getString('profile_picture_path');
      
      if (customProfilePic != null && customProfilePic.isNotEmpty) {
        data['custom_profile_pic'] = customProfilePic;
      }
      
      _profileData = data;
    } catch (e) {
      _errorMessage = "We couldn't load your profile. ${friendlyError(e)}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update profile picture.
  Future<void> updateProfilePicture(String imagePath) async {
    try {
      // Check if file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Selected image does not exist');
      }
      
      // In a real app, you might upload this to a server
      // await _apiService.uploadProfilePicture(file);
      
      // Store the path in local storage for now
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_picture_path', imagePath);
      
      // Update the profile data
      if (_profileData != null) {
        _profileData!['custom_profile_pic'] = imagePath;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Couldn't update your photo. ${friendlyError(e)}";
      notifyListeners();
    }
  }
  
  /// Update profile information.
  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // In a real app, you would update the profile on the server
      final updatedProfile = await _apiService.updateProfile(updatedData);
      
      // Preserve custom profile picture if it exists
      if (_profileData != null && _profileData!.containsKey('custom_profile_pic')) {
        updatedProfile['custom_profile_pic'] = _profileData!['custom_profile_pic'];
      }
      
      _profileData = updatedProfile;
    } catch (e) {
      _errorMessage = "Couldn't update your profile. ${friendlyError(e)}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Reset profile data (for testing or logout).
  void resetProfile() {
    _profileData = null;
    notifyListeners();
  }
}