import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:projekt_webshop/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class HeartButtonWidget extends StatefulWidget {
  const HeartButtonWidget({
    super.key,
    this.bkgColor = Colors.transparent,
    this.size = 20,
    required this.productId,
    // this.IsInWishlist = false,
  });
  final Color bkgColor;
  final double size;
  final String productId;
  // final bool? IsInWishlist;

  @override
  State<HeartButtonWidget> createState() => _HeartButtonWidgetState();
}

class _HeartButtonWidgetState extends State<HeartButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.bkgColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        style: IconButton.styleFrom(elevation: 10),
        onPressed: () async{
          // wishlistProvider.addOrRemoveFromWishlist(
          //   productId: widget.productId
          //   );
            if (wishlistProvider.getWishlis.containsKey(widget.productId)) {
              await wishlistProvider.removeWishlistItemFromFirestore(
                wishlistId: wishlistProvider.getWishlis[widget.productId]!.wishlistId,
                productId: widget.productId,
              );
            } else {
              await wishlistProvider.addToWishlistFirebase(
                productId: widget.productId,
                context: context,
              );
            }
            await wishlistProvider.fetchWishlist();
          },// prouči widget.productId
        icon: Icon(
          wishlistProvider.isProdinWishlist(
            productId: widget.productId,
          )
          ? IconlyBold.heart
          : IconlyLight.heart,
          size: widget.size,
          color:  wishlistProvider.isProdinWishlist(
            productId: widget.productId,
          )
          ? Colors.red
          : Colors.grey,
        ),
      ),
    );
  }
}
