import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/support_models.dart';
import '../../../services/support_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  static const Color _brand = primaryColor;

  SupportTicket? _ticket;
  bool _isLoading = true;
  String? _error;

  final _replyCtrl = TextEditingController();
  bool _isSending = false;
  bool _isClosing = false;

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ticket =
          await SupportService.getTicketDetail(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendReply() async {
    final msg = _replyCtrl.text.trim();
    if (msg.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await SupportService.addReply(widget.ticketId, msg);
      _replyCtrl.clear();
      await _loadTicket();
      // Scroll to bottom after reload
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _closeTicket() async {
    setState(() => _isClosing = true);
    try {
      final success = await SupportService.closeTicket(widget.ticketId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket closed'),
            backgroundColor: successColor,
          ),
        );
        await _loadTicket();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to close ticket'),
            backgroundColor: errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(_ticket?.ticketNumber.isNotEmpty == true
            ? _ticket!.ticketNumber
            : 'Ticket #${widget.ticketId}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _brand))
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildRepliesList()),
                    if (_ticket?.status == 'RESOLVED')
                      _buildCloseButton(),
                    _buildReplyInput(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: errorColor),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: blackColor60)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _brand),
            onPressed: _loadTicket,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final t = _ticket!;
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      color: Theme.of(context).cardTheme.color ?? Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.subject,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(t.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip(t.category.replaceAll('_', ' ')),
              const SizedBox(width: 8),
              _buildChip(t.priority),
            ],
          ),
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(t.description,
                style: const TextStyle(fontSize: 13, color: blackColor60)),
          ],
        ],
      ),
    );
  }

  Widget _buildRepliesList() {
    final replies = _ticket?.replies ?? [];
    if (replies.isEmpty) {
      return const Center(
        child: Text('No messages yet.',
            style: TextStyle(color: blackColor60)),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: 12),
      itemCount: replies.length,
      itemBuilder: (context, i) => _buildBubble(replies[i]),
    );
  }

  Widget _buildBubble(TicketReply reply) {
    final isCustomer = reply.userType == 'CUSTOMER';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isCustomer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCustomer) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.support_agent, size: 18, color: blackColor60),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCustomer
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  reply.userName.isNotEmpty ? reply.userName : reply.userType,
                  style: const TextStyle(fontSize: 11, color: blackColor60),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCustomer
                        ? _brand.withOpacity(0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isCustomer ? 16 : 4),
                      bottomRight: Radius.circular(isCustomer ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    reply.message,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(reply.createdAt),
                  style: const TextStyle(fontSize: 10, color: blackColor40),
                ),
              ],
            ),
          ),
          if (isCustomer) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: _brand.withOpacity(0.15),
              child: const Icon(Icons.person, size: 18, color: _brand),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: blackColor40),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _isClosing ? null : _closeTicket,
          child: _isClosing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: _brand),
                )
              : const Text('Close Ticket',
                  style: TextStyle(color: blackColor60)),
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    final isClosed = _ticket?.status == 'CLOSED';
    return Container(
      padding: EdgeInsets.only(
        left: defaultPadding,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isClosed
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'This ticket is closed',
                  style: TextStyle(color: blackColor60, fontSize: 13),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyCtrl,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: _isSending ? null : _sendReply,
                  icon: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _brand),
                        )
                      : const Icon(Icons.send_rounded, color: _brand),
                ),
              ],
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'OPEN':
        color = Colors.blue;
        break;
      case 'IN_PROGRESS':
        color = Colors.orange;
        break;
      case 'RESOLVED':
        color = successColor;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: blackColor60)),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
    } catch (_) {
      return '';
    }
  }
}
