import 'package:flutter/material.dart';

class BiddingScreen extends StatefulWidget {
  const BiddingScreen({super.key});

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  int _currentBid = 16; // starting bid value

  void _increaseBid() {
    setState(() {
      if (_currentBid < 28) _currentBid++;
    });
  }

  void _decreaseBid() {
    setState(() {
      if (_currentBid > 16) _currentBid--;
    });
  }

  void _confirmBid() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Bid confirmed: $_currentBid")));
    Navigator.pop(context); // go back to Game Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bidding")),
      body: Container(
        color: Colors.orange[50],
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select Your Bid",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decreaseBid,
                  icon: const Icon(Icons.remove_circle, size: 40),
                ),
                Text(
                  "$_currentBid",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _increaseBid,
                  icon: const Icon(Icons.add_circle, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _confirmBid,
              icon: const Icon(Icons.check),
              label: const Text("Confirm Bid"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
