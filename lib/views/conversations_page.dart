import 'package:flutter/material.dart';
import 'package:healthmate/pages/chat_page.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversations = chatProvider.conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          if (conversations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClearAll(context),
              tooltip: 'Clear all conversations',
            ),
        ],
      ),
      body: conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  title: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Last updated ${timeago.format(conversation.lastUpdatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.chat_outlined),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, conversation.id),
                  ),
                  onTap: () {
                    chatProvider.loadConversation(conversation.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatPage()),
                    );
                  },
                  onLongPress: () => _showRenameDialog(
                    context, 
                    conversation.id, 
                    conversation.title,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          chatProvider.startNewConversation();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'New conversation',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Start a new conversation with HealthMate',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.deleteConversation(id);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all conversations'),
        content: const Text('Are you sure you want to delete all conversations? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.clearAllConversations();
    }
  }

  Future<void> _showRenameDialog(BuildContext context, String id, String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename conversation'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('RENAME'),
          ),
        ],
      ),
    );
    
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.updateConversationTitle(id, newTitle.trim());
    }
  }
}