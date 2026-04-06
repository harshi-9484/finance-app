import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

//////////////// LOGIN PAGE //////////////////

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login(BuildContext context) {
    if (emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Welcome Back 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => login(context),
                child: Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//////////////// HOME //////////////////

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Transaction {
  String title;
  double amount;
  bool isIncome;

  Transaction(this.title, this.amount, this.isIncome);
}

class _HomePageState extends State<HomePage> {
  List<Transaction> transactions = [];
  double goal = 10000;

  double get income =>
      transactions.where((t) => t.isIncome).fold(0, (a, b) => a + b.amount);

  double get expense =>
      transactions.where((t) => !t.isIncome).fold(0, (a, b) => a + b.amount);

  double get balance => income - expense;

  void addTransaction(String title, double amount, bool isIncome) {
    setState(() {
      transactions.add(Transaction(title, amount, isIncome));
    });
  }

  void showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Transaction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            DropdownButton<bool>(
              value: isIncome,
              items: [
                DropdownMenuItem(value: true, child: Text("Income")),
                DropdownMenuItem(value: false, child: Text("Expense")),
              ],
              onChanged: (val) {
                isIncome = val!;
              },
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              addTransaction(
                titleController.text,
                double.parse(amountController.text),
                isIncome,
              );
              Navigator.pop(context);
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      dashboard(),
      insights(),
      goals(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Finance Dashboard")),
      body: pages[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Insights"),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: "Goals"),
        ],
      ),
    );
  }

//////////////// DASHBOARD //////////////////

  Widget dashboard() {
    return Column(
      children: [
        SizedBox(height: 20),
        Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text("Balance: ₹$balance", style: TextStyle(fontSize: 20)),
                Text("Income: ₹$income"),
                Text("Expense: ₹$expense"),
              ],
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? Center(child: Text("No Transactions Yet"))
              : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (_, i) {
              final t = transactions[i];
              return ListTile(
                title: Text(t.title),
                trailing: Text(
                  "₹${t.amount}",
                  style: TextStyle(
                      color: t.isIncome ? Colors.green : Colors.red),
                ),
              );
            },
          ),
        )
      ],
    );
  }

//////////////// INSIGHTS //////////////////

  Widget insights() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Insights 📊", style: TextStyle(fontSize: 22)),
          Text("Total Income: ₹$income"),
          Text("Total Expense: ₹$expense"),
          Text(
              "Savings: ₹${balance > 0 ? balance : 0}"),
        ],
      ),
    );
  }

//////////////// GOALS //////////////////

  Widget goals() {
    double progress = balance / goal;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Goal Tracker 🎯", style: TextStyle(fontSize: 22)),
          SizedBox(height: 20),
          Text("Goal: ₹$goal"),
          Padding(
            padding: EdgeInsets.all(20),
            child: LinearProgressIndicator(value: progress),
          ),
          Text("Saved: ₹$balance"),
        ],
      ),
    );
  }
}