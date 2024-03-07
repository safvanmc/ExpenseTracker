import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<RadioBtn>(context, listen: false);
    num totalinc = 0;
    num totalexp = 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: CustomFloatingBtn(context),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 30, 29, 29),
        centerTitle: true,
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('money')
            .orderBy('date', descending: true)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          var data = snapshot.data?.docs ?? [];
          if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          if (snapshot.hasData) {
            totalinc = 0;
            totalexp = 0;
            for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
              var amount = doc['amount'] ?? 0;
              String type = doc['mode'];
              if (type == 'Income') {
                totalinc += int.parse(amount);
              } else if (type == 'Expense') {
                totalexp += int.parse(amount);
              }
            }
            print(totalinc);
          }
          return ListOfEntries(totalinc, totalexp, data, snapshot);
        },
      ),
    );
  }

  FloatingActionButton CustomFloatingBtn(BuildContext context) {
    return FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: Color.fromARGB(255, 30, 29, 29),
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        add(context);
      },
    );
  }

  Column ListOfEntries(
      num totalinc,
      num totalexp,
      List<QueryDocumentSnapshot<Object?>> data,
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10).w,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          height: 50.h,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                    offset: Offset(1, 0),
                    blurRadius: 3,
                    color: Colors.grey,
                    spreadRadius: 2)
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income:${totalinc}',
                style: TextStyle(color: Colors.green, fontSize: 15.sp),
              ),
              Text('Expense:${totalexp}',
                  style: TextStyle(color: Colors.red, fontSize: 15.sp)),
            ],
          ),
        ),
        data.isNotEmpty
            ? Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  padding: EdgeInsets.all(20.w),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Dismissible(
                          key: UniqueKey(),
                          onDismissed: (direction) {
                            // data[index]['mode'] == 'Income'
                            //     ? prov.removeInc(
                            //         int.parse(data[index]['amount']))
                            //     : prov.removeExp(
                            //         int.parse(data[index]['amount']));
                            FirebaseFirestore.instance
                                .collection('money')
                                .doc(data[index].id)
                                .delete()
                                .then((value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('removed'),
                                    )));
                          },
                          child: ListTile(
                            leading: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  snapshot.data?.docs[index]['Source'],
                                  style: TextStyle(fontSize: 20.sp),
                                ),
                                Text(data[index]['date'],
                                    style: TextStyle(fontSize: 10.sp))
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    data[index]['mode'] == 'Income'
                                        ? '+${data[index]['amount']}'
                                        : '-${data[index]['amount']}',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        color: data[index]['mode'] == 'Income'
                                            ? Colors.green
                                            : Colors.red)),
                                Text(data[index]['time'],
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                    ))
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.w)),
                            // tileColor: Colors.yellow,
                          ),
                        ),
                        Divider(
                          height: 5.h,
                        )
                      ],
                    );
                  },
                ),
              )
            : Center(
                child: Text('Add Income and Expense'),
              ),
      ],
    );
  }

  add(
    BuildContext context,
  ) {
    TextEditingController source = TextEditingController();
    TextEditingController amount = TextEditingController();
    final formkey = GlobalKey<FormState>();

    DateTime dateTime = DateTime.now();
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);
    String fortime = DateFormat("HH:mm").format(dateTime);
    var selecteditem;
    final _provider = Provider.of<RadioBtn>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            'Add income and expenses',
            style: TextStyle(fontSize: 20.sp),
          ),
        ),
        content: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextfeild(source, 'source', (value) {
                  if (value == null || value.isEmpty) {
                    return 'empty field';
                  }
                }, TextInputType.text),
                CustomTextfeild(amount, 'amount', (value) {
                  if (value == null || value.isEmpty) {
                    print('saf');
                    return 'empty field';
                  }
                }, TextInputType.number),
                SizedBox(height: 10.h),
                Consumer<RadioBtn>(
                  builder: (context, pro, child) => Column(
                    children: [
                      RadioListTile(
                        // selected: true,
                        title: const Text(
                          "Income",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        value: "Income",
                        groupValue: pro.selectvalue,
                        onChanged: (selectvalue) {
                          pro.valuechanged(selectvalue.toString());
                        },
                      ),
                      RadioListTile(
                        title: const Text(
                          "Expense",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        value: "Expense",
                        groupValue: pro.selectvalue,
                        onChanged: (selectvalue) {
                          pro.valuechanged(selectvalue.toString());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          MaterialButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 2.w),
                borderRadius: BorderRadius.circular(10.w)),
            onPressed: () async {
              if (formkey.currentState!.validate())
                await FirebaseFirestore.instance.collection('money').add({
                  'Source': source.text,
                  'amount': amount.text,
                  'date': formattedDate,
                  'time': fortime,
                  'mode': _provider.selectvalue.toString()
                }).then((value) => Navigator.pop(context));
              print(amount.text);
              // _provider.selectvalue == 'Income'
              //     ? _provider.addInc(int.parse(amount.text))
              //     : _provider.addExp(int.parse(amount.text));
            },
            child: Text('Save'),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 2.w),
                borderRadius: BorderRadius.circular(10.w)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('cancel'),
          )
        ],
      ),
    );
  }

  TextFormField CustomTextfeild(TextEditingController controller, String text,
      String? Function(String?)? validator, TextInputType? keyboardType) {
    return TextFormField(
      keyboardType: keyboardType,
      validator: validator,
      controller: controller,
      decoration: InputDecoration(hintText: text),
    );
  }
}
