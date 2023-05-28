import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

//Input Widget
Widget inputText(
    {label,
      obscureText = false,
      required TextEditingController controller,
      TextInputType? keyboardType,
      FormFieldValidator? validator,
      required BuildContext context
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,

    children: <Widget>[

      Container(
        width: MediaQuery.of(context).size.width*0.9,
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        color: AppColors.secondaryBackgroundColor,
        child: TextFormField(

          obscureText: obscureText,
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          cursorColor: AppColors.primaryColor,
          style: GoogleFonts.comfortaa(
            color: AppColors.secondaryColor,

          ),
          enableInteractiveSelection: false,

          decoration: InputDecoration(
              filled: true,

              fillColor: AppColors.secondaryBackgroundColor,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              labelText: label,

              labelStyle: GoogleFonts.comfortaa(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(15),

              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(15),

              ),
              border:
              OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryColor))),

        ),
      ),
      SizedBox(
        height: 10,
      ),


    ],
  );
}

Widget button({ required BuildContext context ,required label, required onPressed}) {
  return SizedBox(
    height: 50,
    width: MediaQuery.of(context).size.width*0.9,
    child: ElevatedButton(
      style: ButtonStyle(

        backgroundColor: MaterialStateProperty.all<Color>(AppColors.secondaryBackgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: AppColors.primaryColor),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(label,
        style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800
        ),
      ),
    ),
  );
}

