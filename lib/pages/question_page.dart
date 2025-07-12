import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionPage extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> questionData;

  const QuestionPage({
    super.key,
    required this.questionId,
    required this.questionData,
  });

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final TextEditingController _replyController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Stream<QuerySnapshot> _repliesStream;

  @override
  void initState() {
    super.initState();
    _repliesStream = _firestore
        .collection('Questions')
        .doc(widget.questionId)
        .collection('Replies')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _postReply() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to post a reply.')),
      );
      return;
    }

    final String replyText = _replyController.text.trim();
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply cannot be empty.')),
      );
      return;
    }

    try {
      await _firestore
          .collection('Questions')
          .doc(widget.questionId)
          .collection('Replies')
          .add({
        'userID': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'replyText': replyText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _replyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply posted successfully!')),
      );
    } catch (e) {
      print('Error posting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post reply: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.questionData['title'] ?? 'No Title';
    String description = widget.questionData['description'] ?? 'No Description';
    String userId = widget.questionData['userID'] ?? 'Unknown User';

    List<dynamic> tagsDynamic = widget.questionData['tags'] ?? [];
    List<String> tags = tagsDynamic.map((item) => '#${item.toString()}').toList();
    String formattedTags = tags.isNotEmpty ? tags.join(' ') : 'No Tags';

    Timestamp? timestamp = widget.questionData['timestamp'] as Timestamp?;
    String formattedTime = timestamp != null
        ? '${timestamp.toDate().toLocal().day}/${timestamp.toDate().toLocal().month}/${timestamp.toDate().toLocal().year} ${timestamp.toDate().toLocal().hour}:${timestamp.toDate().toLocal().minute}'
        : 'Unknown Time';

    bool isSolved = widget.questionData['solved'] == true;

    return Scaffold(backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... inside your SingleChildScrollView's Column ...

                  Container(
                    padding: const EdgeInsets.all(16.0), // Padding inside the container
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary, // Use your theme's surface color
                      borderRadius: BorderRadius.circular(15.0), // Adjust the radius for more/less curve
                      boxShadow: [ // Optional: Add a subtle shadow
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface, // Use onSurface for text
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface), // Use onSurface
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formattedTags,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Posted by User ID: $userId',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Posted on: $formattedTime',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (isSolved)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'This question is SOLVED! ✅',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
// ... The Divider and Replies section would come after this Container ...
                  const Divider(height: 30, thickness: 1),
                  Text(
                    'Replies:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _repliesStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error loading replies: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Text('No replies yet. Be the first to answer!'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot replyDoc = snapshot.data!.docs[index];
                          Map<String, dynamic> replyData = replyDoc.data() as Map<String, dynamic>;

                          String replyText = replyData['replyText'] ?? 'No Reply Text';
                          String replierId = replyData['userID'] ?? 'Unknown User';
                          String replierName = replyData['userName'] ?? 'Anonymous';
                          Timestamp? replyTimestamp = replyData['timestamp'] as Timestamp?;
                          String formattedReplyTime = replyTimestamp != null
                              ? '${replyTimestamp.toDate().toLocal().day}/${replyTimestamp.toDate().toLocal().month}/${replyTimestamp.toDate().toLocal().year} ${replyTimestamp.toDate().toLocal().hour}:${replyTimestamp.toDate().toLocal().minute}'
                              : 'Unknown Time';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            color: Theme.of(context).colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    replyText,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Replied by $replierName ($replierId) on $formattedReplyTime',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Type your reply...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _postReply,
                  child: const Icon(Icons.send),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}