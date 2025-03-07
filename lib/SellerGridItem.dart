import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class SellerGridItem extends StatelessWidget {
  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final Function(String) onTap;

  const SellerGridItem({
    super.key,
    required this.sellerDetails,
    required this.sellerUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var fullName = sellerDetails['sellerFullName'] ?? "Bilinmeyen";
    var imageUrl = sellerDetails['imageUrls'][0] ?? "";
    var city = sellerDetails['city'] ?? "";
    var district = sellerDetails['district'] ?? "";

    return GestureDetector(
      onTap: () => onTap(sellerUid),
      child: Card(
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "$city, $district",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
