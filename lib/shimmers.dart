import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

class SellerGridShimmer extends StatelessWidget {
  const SellerGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: 6, // showing 6 shimmer cards
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 15,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 15,
                      width: 60,
                      color: Colors.grey[400],
                    ),
                    const Spacer(),
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MessagesShimmer extends StatelessWidget {
  const MessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          height: 24,
          width: 120,
          color: userorseller ? sellerbackground : Colors.grey.shade300,
        ),
        backgroundColor: userorseller ? sellerbackground :Colors.white,
        centerTitle: true,
      ),
      backgroundColor: userorseller ? sellerbackground :Colors.white,
      body: ListView.builder(
        itemCount: 8, // number of shimmer items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: userorseller ? sellerbackground : Colors.grey.shade300,
            highlightColor: userorseller ? Colors.grey.shade700 : Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: userorseller ? sellerbackground : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 14,
                width: double.infinity,
                color: userorseller ? sellerbackground : Colors.grey.shade300,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                height: 10,
                width: double.infinity,
                color: userorseller ? sellerbackground : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppointmentsShimmer extends StatelessWidget {
  const AppointmentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: 4, // show 4 shimmer items
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Shimmer.fromColors(
                baseColor: userorseller ? sellergrey : Colors.grey.shade300,
                highlightColor: userorseller ? Colors.grey.shade700 : Colors.grey.shade100,
                child: Container(
                  color: userorseller ? sellerbackground :Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Surname Placeholder
                        Container(
                          height: 16,
                          width: 150,
                          color: userorseller ? sellergrey : Colors.white,
                          margin: const EdgeInsets.only(bottom: 10),
                        ),
                        // Day + Hour Placeholder
                        Container(
                          height: 14,
                          width: 100,
                          color: userorseller ? sellergrey : Colors.white,
                          margin: const EdgeInsets.only(bottom: 10),
                        ),
                        // Location row
                        Row(
                          children: [
                            Container(
                              height: 14,
                              width: 14,
                              color: userorseller ? sellergrey : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Container(
                              height: 14,
                              width: 80,
                              color: userorseller ? sellergrey :  Colors.white,
                            ),
                            const Spacer(),
                            Container(
                              height: 30,
                              width: 60,
                              color: userorseller ? sellergrey : Colors.white,
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Approve/Reject buttons shimmer if needed
                        Container(
                          height: 35,
                          width: double.infinity,
                          color: userorseller ? sellergrey : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class FavouritesShimmer extends StatelessWidget {
  const FavouritesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: 5, // Show shimmer for 5 items
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(
                height: 16,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                height: 14,
                width: 80,
                color: Colors.white,
              ),
              trailing: Container(
                width: 15,
                height: 15,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
class ApprovedFieldsShimmer extends StatelessWidget {
  const ApprovedFieldsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6, // You can adjust the placeholder count
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,  // Keep it clean on a white background
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 16,
                width: 150,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        );
      },
    );
  }
}

