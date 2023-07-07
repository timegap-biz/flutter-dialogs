import 'dart:async';
import 'dart:ui';

import 'package:ars_dialog/src/transition.dart';
import 'package:ars_dialog/src/utils.dart';
import 'package:ars_dialog/src/zoom_widget/zoom_widget.dart';
import 'package:flutter/material.dart';

/// ArsDialogs widget
class ArsDialog extends StatelessWidget {
  ///Dialog style
  final DialogStyle? dialogStyle;

  ///The (optional) title of the dialog is displayed in a large font at the top of the dialog.
  final Widget? title;

  ///The (optional) content of the dialog is displayed in the center of the dialog in a lighter font.
  final Widget? content;

  ///The (optional) set of actions that are displayed at the bottom of the dialog.
  final List<Widget>? actions;

  const ArsDialog(
      {Key? key, this.dialogStyle, this.title, this.content, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DialogTheme dialogTheme = DialogTheme.of(context);
    final DialogStyle style = dialogStyle ?? DialogStyle();

    String? label = style.semanticsLabel;
    Widget dialogChild = IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          title != null
              ? Padding(
                  padding: style.titlePadding ??
                      EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                  child: DefaultTextStyle(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Semantics(
                          child: title,
                          namesRoute: true,
                          label: label,
                        ),
                        style.titleDivider ?? false
                            ? Divider()
                            : Container(
                                height: 10.0,
                              )
                      ],
                    ),
                    style: style.titleTextStyle ??
                        dialogTheme.titleTextStyle ??
                        theme.textTheme.titleLarge!,
                  ),
                )
              : Container(),
          content != null
              ? Flexible(
                  child: Padding(
                    padding: style.contentPadding ??
                        EdgeInsets.only(
                            right: 15.0, left: 15.0, top: 0.0, bottom: 15.0),
                    child: DefaultTextStyle(
                      child: Semantics(child: content),
                      style: style.contentTextStyle ??
                          dialogTheme.contentTextStyle ??
                          theme.textTheme.titleMedium!,
                    ),
                  ),
                )
              : Container(),
          actions != null
              ? Theme(
                  data: ThemeData(
                    buttonTheme: ButtonThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  child: actions!.length <= 3
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(
                              actions!.length,
                              (index) {
                                return Expanded(child: actions![index]);
                              },
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            actions!.length,
                            (index) {
                              return SizedBox(
                                height: 50.0,
                                child: actions![index],
                              );
                            },
                          ),
                        ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );

    return Padding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280.0),
          child: Card(
            child: dialogChild,
            clipBehavior: Clip.antiAlias,
            elevation: style.elevation ?? 24,
            color: style.backgroundColor,
            shape: style.borderRadius != null
                ? RoundedRectangleBorder(borderRadius: style.borderRadius!)
                : style.shape ??
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      ),
    );
  }

  Future<T?> show<T>(BuildContext context,
          {DialogTransitionType? transitionType,
          bool? dismissable,
          Duration? transitionDuration}) =>
      DialogUtils(
        child: this,
        dialogTransitionType: transitionType,
        dismissable: dismissable,
        barrierColor: Colors.black.withOpacity(.5),
        transitionDuration: transitionDuration,
      ).show(context) as Future<T?>;
}

///Simple dialog with blur background and popup animations, use DialogStyle to custom it
class ArsAlertDialog extends DialogBackground {
  ///Dialog style
  final DialogStyle? dialogStyle;

  ///The (optional) title of the dialog is displayed in a large font at the top of the dialog.
  final Widget? title;

  ///The (optional) content of the dialog is displayed in the center of the dialog in a lighter font.
  final Widget? content;

  ///The (optional) set of actions that are displayed at the bottom of the dialog.
  final List<Widget>? actions;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double? blur;

  ///Is your dialog dismissable?, because its warp by BlurDialogBackground,
  ///you have to declare here instead on showDialog
  final bool? dismissable;

  ///Its Barrier Color
  final Color? backgroundColor;

  ///Action before dialog dismissed
  final Function? onDismiss;

  const ArsAlertDialog({
    Key? key,
    this.backgroundColor,
    this.dialogStyle,
    this.title,
    this.content,
    this.actions,
    this.blur,
    this.dismissable,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      dialog: ArsDialog(
        dialogStyle: dialogStyle,
        actions: actions,
        content: content,
        title: title,
      ),
      dismissable: dismissable,
      blur: blur ?? 0,
      onDismiss: onDismiss,
      barrierColor: backgroundColor,
      key: key,
    );
  }
}

@deprecated
class BlurDialogBackground extends DialogBackground {
  ///Widget of dialog, you can use ars_dialog, Dialog, AlertDialog or Custom your own Dialog
  final Widget? dialog;

  ///Because blur dialog cover the barrier, you have to declare here
  final bool? dismissable;

  ///Action before dialog dismissed
  final Function? onDismiss;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double? blur;

  /// Background color
  final Color? color;

  const BlurDialogBackground(
      {Key? key,
      this.color,
      this.dialog,
      this.dismissable,
      this.blur,
      this.onDismiss})
      : super(key: key);
}

//A Dialog, but you can zoom on it
class ZoomDialog extends DialogBackground {
  ///The (optional) content of the dialog is displayed in the center of the dialog in a lighter font.
  final Widget child;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double? blur;

  /// Background color
  final Color? backgroundColor;

  ///Maximum zoom scale
  final double zoomScale;

  ///Initialize zoom scale on dialog show
  final double initZoomScale;

  ///Action before dialog dismissed
  final Function? onDismiss;

  const ZoomDialog(
      {Key? key,
      this.backgroundColor,
      required this.child,
      this.initZoomScale = 0,
      this.blur,
      this.zoomScale = 3,
      this.onDismiss})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogBackground(
      key: key,
      dialog: Zoom(
        onTap: () {
          Navigator.pop(context);
          if (onDismiss != null) onDismiss!();
        },
        canvasColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        initZoom: initZoomScale,
        centerOnScale: true,
        maxZoomWidth: MediaQuery.of(context).size.width * zoomScale,
        maxZoomHeight: MediaQuery.of(context).size.height * zoomScale,
        child: Transform.scale(
          scale: zoomScale,
          child: Center(
            child: Container(
              child: child,
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
        ),
      ),
      dismissable: true,
      blur: blur ?? 0,
      onDismiss: onDismiss,
      barrierColor: backgroundColor,
    );
  }
}

///Blur background of dialog, you can use this class to make your custom dialog background blur
class DialogBackground extends StatelessWidget {
  ///Widget of dialog, you can use ars_dialog, Dialog, AlertDialog or Custom your own Dialog
  final Widget? dialog;

  ///Because blur dialog cover the barrier, you have to declare here
  final bool? dismissable;

  ///Action before dialog dismissed
  final Function? onDismiss;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double? blur;

  final Color? barrierColor;

  @Deprecated("Use barrierColor instead")
  final Color? color;

  const DialogBackground(
      {Key? key,
      this.dialog,
      this.color,
      this.dismissable,
      this.blur,
      this.onDismiss,
      this.barrierColor})
      : super(key: key);

  ///Show dialog directly
  // Future show<T>(BuildContext context) => showDialog<T>(context: context, builder: (context) => this, barrierColor: barrierColor, barrierDismissible: dismissable ?? true);

  Future<T?> show<T>(BuildContext context,
          {DialogTransitionType? transitionType,
          bool? dismissable,
          Duration? transitionDuration}) =>
      DialogUtils(
        child: this,
        dialogTransitionType: transitionType,
        dismissable: dismissable,
        barrierColor: barrierColor ?? Colors.black.withOpacity(.5),
        transitionDuration: transitionDuration,
      ).show(context) as Future<T?>;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Colors.transparent,
      child: WillPopScope(
        onWillPop: () async {
          if (dismissable ?? true) {
            if (onDismiss != null) onDismiss!();
            Navigator.pop(context);
          }
          return false;
        },
        child: Stack(
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: dismissable ?? true
                  ? () {
                      if (onDismiss != null) {
                        onDismiss!();
                      }
                      Navigator.pop(context);
                    }
                  : () {},
              child: (blur ?? 0) < 1
                  ? Container()
                  : TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.1, end: blur ?? 0),
                      duration: Duration(milliseconds: 300),
                      builder: (context, double? val, Widget? child) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: val ?? 0,
                            sigmaY: val ?? 0,
                          ),
                          child: Container(color: Colors.transparent),
                        );
                      },
                    ),
            ),
            dialog!
          ],
        ),
      ),
    );
  }
}

///Dialog style to custom your dialog
class DialogStyle {
  /// Divider on title
  final bool? titleDivider;

  ///Set circular border radius for your dialog
  final BorderRadius? borderRadius;

  ///Set semanticslabel for Title
  final String? semanticsLabel;

  ///Set padding for your Title
  final EdgeInsets? titlePadding;

  ///Set padding for your  Content
  final EdgeInsets? contentPadding;

  ///Set TextStyle for your Title
  final TextStyle? titleTextStyle;

  ///Set TextStyle for your Content
  final TextStyle? contentTextStyle;

  ///Elevation for dialog
  final double? elevation;

  ///Background color of dialog
  final Color? backgroundColor;

  ///Shape for dialog, ignored if you set BorderRadius
  final ShapeBorder? shape;

  ///Bubble animation when your dialog will popup
  @Deprecated("Use animatePopup on .show() instead")
  final bool? animatePopup;

  ///Dialog Transition Type
  // final DialogTransitionType dialogTransitionType;

  DialogStyle({
    this.titleDivider,
    // this.dialogTransitionType,
    this.borderRadius,
    this.semanticsLabel,
    this.titlePadding,
    this.contentPadding,
    this.titleTextStyle,
    this.contentTextStyle,
    this.elevation,
    this.backgroundColor,
    this.animatePopup,
    this.shape,
  });
}
