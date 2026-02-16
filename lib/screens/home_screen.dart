import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/chat_provider.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSidebar = true;

  @override
  void initState() {
    super.initState();
    // Load last conversation or create new one
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = context.read<ChatProvider>();
      final conversations = context.read<StorageService>().getConversations();
      if (conversations.isNotEmpty) {
        // Load most recent
        await chatProvider.loadConversation(conversations.first.id);
      } else {
        await chatProvider.startNewConversation();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final showDesktopSidebar = isDesktop && _showSidebar;
    
    return Scaffold(
      appBar: isDesktop ? null : AppBar( // Hide app bar on desktop if custom
        title: const Text('TheChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const SettingsScreen())
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? const Drawer(child: Sidebar()) : null,
      body: Row(
        children: [
          if (showDesktopSidebar)
            const SizedBox(
              width: 280,
              child: Sidebar(),
            ),
            
          Expanded(
            child: Column(
              children: [
                // Top header for desktop
                if (isDesktop) 
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        if (isDesktop)
                          IconButton(
                            icon: Icon(_showSidebar ? Icons.menu_open : Icons.menu),
                            onPressed: () => setState(() => _showSidebar = !_showSidebar),
                          ),
                        const SizedBox(width: 16),
                        Text('TheChat', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const SettingsScreen())
                          ),
                        ),
                      ],
                    ),
                  ),

                // Chat Area
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chat, _) {
                      if (chat.messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('Start a conversation', style: Theme.of(context).textTheme.headlineSmall),
                            ],
                          ),
                        );
                      }

                      // Auto scroll on new message
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(24),
                        itemCount: chat.messages.length + (chat.isStreaming ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == chat.messages.length) {
                            // Streaming placeholder
                            return const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final msg = chat.messages[index];
                          final isUser = msg.role == 'user';
                          
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 700),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MarkdownBody(
                                    data: msg.content,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(msg.createdAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                ),

                // Input Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onSubmitted: (val) => _sendMessage(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () => _sendMessage(context),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch ChatProvider for conversation updates
    final chatProvider = context.watch<ChatProvider>();
    final allConversations = chatProvider.conversations;
    
    final conversations = _searchQuery.isEmpty 
      ? allConversations 
      : allConversations.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ChatProvider>().startNewConversation();
                if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
                  Navigator.pop(context); // Close drawer on mobile
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: conversations.isEmpty 
              ? const Center(child: Text('No conversations yet'))
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final isActive = chatProvider.activeConversationId == conv.id;
                    
                    return ListTile(
                      title: Text(
                        conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text(
                        _formatDate(conv.updatedAt),
                        style: const TextStyle(fontSize: 10),
                      ),
                      selected: isActive,
                      selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      onTap: () {
                        context.read<ChatProvider>().loadConversation(conv.id);
                        if (Scaffold.of(context).hasDrawer && Scaffold.of(context).isDrawerOpen) {
                           Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime dt) {
    if (dt.year == 1970) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
