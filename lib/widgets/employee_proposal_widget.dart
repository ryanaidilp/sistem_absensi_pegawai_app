import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:spo_balaesang/screen/image_detail_screen.dart';
import 'package:spo_balaesang/utils/app_const.dart';
import 'package:spo_balaesang/utils/view_util.dart';
import 'package:spo_balaesang/widgets/image_placeholder_widget.dart';

class EmployeeProposalWidget extends StatelessWidget {
  const EmployeeProposalWidget(
      {this.title,
      this.isApproved,
      this.employeeName,
      this.approvalStatus,
      this.isApprovalCard = false,
      this.isPaidLeave = false,
      this.startDate,
      this.dueDate,
      this.description,
      this.category,
      this.photo,
      this.updateWidget,
      this.heroTag,
      this.button});

  final String title;
  final bool isApproved;
  final String employeeName;
  final String approvalStatus;
  final bool isApprovalCard;
  final bool isPaidLeave;
  final DateTime startDate;
  final DateTime dueDate;
  final String description;
  final String category;
  final String photo;
  final String heroTag;
  final Widget button;
  final Widget updateWidget;

  Color _checkStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green;
      case 'Menunggu Persetujuan':
        return Colors.deepOrange;
      default:
        return Colors.red[800];
    }
  }

  Widget _buildEmployeeNameSection() {
    if (isApprovalCard) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          sizedBoxH4,
          Row(
            children: <Widget>[
              Text(
                'Diajukan oleh : ',
                style: labelTextStyle.copyWith(fontSize: 12.0),
              ),
              Text(
                employeeName,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          sizedBoxH5,
        ],
      );
    }
    return sizedBoxH5;
  }

  Widget _buildCategorySection() {
    if (isPaidLeave) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          sizedBoxH4,
          Row(
            children: <Widget>[
              Text(
                'Kategori          : ',
                style: labelTextStyle.copyWith(fontSize: 12.0),
              ),
              Text(
                category,
                style: const TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        ],
      );
    }
    return sizedBox;
  }

  Widget _buildButtonSection() {
    if (isApprovalCard) {
      return Column(
        children: [
          dividerT1,
          button,
        ],
      );
    }
    return sizedBox;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4.0,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16.0),
                ),
                sizedBoxH5,
                dividerT1,
                sizedBoxH5,
                Row(
                  children: <Widget>[
                    Text(
                      'Status              : ',
                      style: labelTextStyle.copyWith(fontSize: 12.0),
                    ),
                    Text(
                      approvalStatus,
                      style: TextStyle(
                          fontSize: 12.0,
                          color: _checkStatusColor(approvalStatus)),
                    ),
                  ],
                ),
                _buildCategorySection(),
                _buildEmployeeNameSection(),
                dividerT1,
                sizedBoxH5,
                const Text(
                  'Masa Berlaku : ',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                sizedBoxH5,
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16.0,
                    ),
                    sizedBoxW5,
                    Text(
                      '${startDate.day}/${startDate.month}/${startDate.year} - ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
                sizedBoxH10,
                const Text(
                  'Deskripsi : ',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                AutoSizeText(
                  description,
                  maxFontSize: 12.0,
                  minFontSize: 10.0,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                sizedBoxH10,
                const Text(
                  'Lampiran : ',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                const Text(
                  '*tekan untuk memperbesar',
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic),
                ),
                sizedBoxH5,
                InkWell(
                  onLongPress: () {
                    if (updateWidget != null) {
                      Get.to(() => updateWidget);
                    }
                  },
                  onTap: () {
                    Get.to(() => ImageDetailScreen(
                          imageUrl: photo,
                          tag: heroTag,
                        ));
                  },
                  child: Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        placeholder: (_, __) => const ImagePlaceholderWidget(
                          label: 'Memuat Foto',
                          child: SpinKitFadingCircle(
                            size: 25.0,
                            color: Colors.blueAccent,
                          ),
                        ),
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const ImagePlaceholderWidget(
                          label: 'Gagal memuat foto!',
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey,
                          ),
                        ),
                        width: Get.width,
                        height: 250.0,
                      ),
                    ),
                  ),
                ),
                _buildButtonSection()
              ],
            )),
      ),
    );
  }
}
