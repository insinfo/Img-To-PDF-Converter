import 'package:flutter/material.dart';

Widget raisedButton({
  Color? color,
  Widget? child,
  RoundedRectangleBorder? shape,
  required void Function()? onPressed,
  Key? key,
  Color? disabledColor,
  Color? disabledTextColor,
  Color? textColor,
  EdgeInsetsGeometry? padding,
}) {
  if (disabledTextColor == null && textColor == null) {
    disabledTextColor = color;
  }
  if (textColor == null) {
    textColor = color;
  }
  return ElevatedButton(
      key: key,
      style: ButtonStyle(
        padding: padding != null
            ? MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                ((states) => padding))
            : null,
        foregroundColor: textColor != null || disabledTextColor != null
            ? MaterialStateProperty.resolveWith<Color?>(
                // text color
                (Set<MaterialState> states) =>
                    states.contains(MaterialState.disabled)
                        ? disabledTextColor
                        : textColor,
              )
            : null,
        backgroundColor: color != null || disabledColor != null
            ? MaterialStateProperty.resolveWith<Color?>(
                // background color    this is color:
                (Set<MaterialState> states) =>
                    states.contains(MaterialState.disabled)
                        ? disabledColor
                        : color,
              )
            : null,
        shape: MaterialStateProperty.all(shape),
      ),
      onPressed: onPressed,
      child: child);
}
