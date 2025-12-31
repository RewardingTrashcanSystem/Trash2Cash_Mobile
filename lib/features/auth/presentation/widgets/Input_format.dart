import 'package:flutter/material.dart';

class InputFormat {
  static Widget firstName({
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'First Name ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your first name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          textInputAction: TextInputAction.next,
          validator: validator,
        ),
      ],
    );
  }

  static Widget lastName({
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Last Name ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your last name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          textInputAction: TextInputAction.next,
          validator: validator,
        ),
      ],
    );
  }

  static Widget email({
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Email ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: validator,
        ),
      ],
    );
  }

  static Widget phone({
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Phone Number ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: validator,
        ),
      ],
    );
  }

  static Widget password({
    required TextEditingController controller,
    bool isRequired = false,
    String? Function(String?)? validator,
    bool obscureText = true,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Password ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggleVisibility,
            ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          textInputAction: TextInputAction.next,
          validator: validator,
        ),
      ],
    );
  }

  static Widget confirmPassword({
    required TextEditingController controller,
    required String originalPassword,
    String label = 'Confirm Password',
    bool isRequired = false,
    String? Function(String?)? validator,
    bool obscureText = true,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            '$label ${isRequired ? '*' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggleVisibility,
            ),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          textInputAction: TextInputAction.done,
          validator: validator,
        ),
      ],
    );
  }
}