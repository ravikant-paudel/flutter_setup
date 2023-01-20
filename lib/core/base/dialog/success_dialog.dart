part of '../base_page.dart';

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({
    required this.title,
    required this.message,
    required this.onOk,
  });

  final String message;
  final String title;
  final VoidCallback onOk;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: d_margin2),
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(d_margin1, d_margin3, d_margin1, d_margin1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // const SizedBox(
              //   height: d_margin9,
              //   width: d_margin20,
              //   child: KhaltiSvgImage(
              //     Svgs.successDialog,
              //   ),
              // ),
              // const Gap.vertical(),
              // Text(
              //   title,
              //   style: KhaltiApplyTheme.textTheme.headline6!.copyWith(
              //     color: KhaltiApplyTheme.color.surface,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              // const Gap.vertical(),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: d_margin1),
              //   child: Text(
              //     message,
              //     style: KhaltiApplyTheme.textTheme.bodyText2!.copyWith(
              //       color: KhaltiApplyTheme.color.surface.shade400,
              //     ),
              //     textAlign: TextAlign.left,
              //   ),
              // ),
              // const Gap.vertical(d_margin4),
              // Align(
              //   alignment: Alignment.topRight,
              //   child: KhaltiAction.ok(
              //     onPressed: () {
              //       Navigator.pop(context);
              //       onOk();
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
