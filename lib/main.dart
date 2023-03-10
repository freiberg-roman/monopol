import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AccountState(),
      child: MaterialApp(
        title: 'Monopoly Banking',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class Transaction {
  int amount = 0;
  int state_before_transaction = 0;

  Transaction(amount, state_before_transaction) {
    this.amount = amount;
    this.state_before_transaction = state_before_transaction;
  }
}

class AccountState extends ChangeNotifier {
  int _current_money = 0;
  List<Transaction> _transaction_history = [];

  void receive(int amount) {
    Transaction trans = Transaction(amount, _current_money);
    _transaction_history.add(trans);
    _current_money += amount;
    notifyListeners();
  }

  void send(int amount) {
    Transaction trans = Transaction(-amount, _current_money);
    _transaction_history.add(trans);
    _current_money -= amount;
    notifyListeners();
  }

  void restore_state(int index) {
    _current_money = _transaction_history[index].state_before_transaction;
    _transaction_history.removeRange(index, _transaction_history.length);
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var accState = context.watch<AccountState>();
    var msgController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Transactions '
                        '${accState._transaction_history.length}:'),
                  ),
                  for (var i = accState._transaction_history.length - 1;
                      i >= 0;
                      i--)
                    ListTile(
                      leading: IconButton(
                          icon: Icon(Icons.sync, semanticLabel: 'Delete'),
                          onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Rewind action"),
                                    content: const Text(
                                        "Do you really want to rewind your transaction history? Action cannot be undone."),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Cancel'),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          accState.restore_state(i);
                                          Navigator.pop(context, 'Cancel');
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ]),
                              )),
                      title: Text(
                          accState._transaction_history[i].amount.toString()),
                    ),
                ],
              ),
            )),
            Consumer<AccountState>(builder: (context, acc, child) {
              return Card(
                child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Row(children: [
                      Icon(
                        Icons.account_balance,
                        size: 32.0,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32.0),
                          child: Center(
                              child:
                                  Text(acc._current_money.toString() + " BTC")),
                        ),
                      ),
                    ])),
              );
            }),
            SizedBox(
              height: 10.0,
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                    controller: msgController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onFieldSubmitted: (String? input) {
                      msgController.clear();
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.attach_money),
                      hintText: 'Enter amount to be sent or received',
                      labelText: 'Transaction',
                    ))),
            SizedBox(
              height: 30.0,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.vertical_align_bottom,
                      size: 50.0,
                    ),
                    onPressed: () {
                      accState.receive(int.parse(msgController.text ?? '0'));
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                  SizedBox(width: 50.0),
                  IconButton(
                    icon: Icon(
                      Icons.vertical_align_top,
                      size: 50.0,
                    ),
                    onPressed: () {
                      accState.send(int.parse(msgController.text ?? '0'));
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            )
          ],
        ),
      ),
    );
  }
}
