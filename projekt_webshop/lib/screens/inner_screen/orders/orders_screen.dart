import 'package:flutter/material.dart';
import 'package:projekt_webshop/providers/order_provider.dart';
import 'package:projekt_webshop/screens/inner_screen/orders/orders_widget.dart';
import 'package:projekt_webshop/services/assets_manager.dart';
import 'package:projekt_webshop/widgets/empty_bag.dart';
import 'package:projekt_webshop/widgets/title_text.dart';
import 'package:provider/provider.dart';

class OrdersScreenFree extends StatefulWidget {
  static const routName = '/OrderScreen';

  const OrdersScreenFree({Key? key}) : super(key: key);

  @override
  State<OrdersScreenFree> createState() => _OrdersScreenFreeState();
}

class _OrdersScreenFreeState extends State<OrdersScreenFree> {
  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(
          label: 'Placed orders',
          ),
      ),
      body: FutureBuilder(
        future: ordersProvider.fetchOrder(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
                child: CircularProgressIndicator(),
            );
        } else if (snapshot.hasError) {
          return Center(
                child: SelectableText(snapshot.error.toString()),
          );
        } else if (!snapshot.hasData || ordersProvider.getOrders.isEmpty) {
          return EmptyBagWidget(
            imagePath: AssetsManagers.orderBag,
            title: "No orders has been placed yet",
            subtitle: "",
            buttonText: "Shop now"
          );
        } return ListView.separated(
          itemCount: snapshot.data!.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: OrdersWidgetFree(
                ordersModelAdvanced: ordersProvider.getOrders[index],),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(

            );
          }
        );
        }
      )
    );
    }
  }