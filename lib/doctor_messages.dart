import 'package:flutter/material.dart';

class DoctorMessagesScreenView extends StatefulWidget {
  const DoctorMessagesScreenView({super.key});

  @override
  State<DoctorMessagesScreenView> createState() =>
      _DoctorMessagesScreenViewState();
}

class _DoctorMessagesScreenViewState extends State<DoctorMessagesScreenView> {
  final TextEditingController _msgController = TextEditingController();
  int _selectedChatIndex = 0;

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Elena Vance',
      'pet': 'Luna (Golden Retriever)',
      'time': '10:42 AM',
      'lastMsg': 'How is Luna\'s recovery going today?',
      'isOnline': true,
      'unread': false,
    },
    {
      'name': 'Arthur Miller',
      'pet': 'Max (Beagle)',
      'time': 'Yesterday',
      'lastMsg': 'Thank you for the update on Max.',
      'isOnline': false,
      'unread': false,
    },
    {
      'name': 'Staff: Night Shift',
      'pet': 'Ward C Updates',
      'time': '9:15 AM',
      'lastMsg': 'All patients in Ward C are stable.',
      'isOnline': true,
      'isStaff': true,
    },
    {
      'name': 'Marcus Wright',
      'pet': 'Rocky (Bulldog)',
      'time': 'Monday',
      'lastMsg': 'Attached is the lab report.',
      'isOnline': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeChat = _chats[_selectedChatIndex];

    return Row(
      children: [
        // 1. RECENT CHATS PANEL
        Container(
          width: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: [
              // Chat Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Chats',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A))),
                    IconButton(
                      icon: const Icon(Icons.edit_square,
                          size: 20, color: Color(0xFF475569)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Chat List
              Expanded(
                child: ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    final isSelected = index == _selectedChatIndex;

                    return Container(
                      color: isSelected
                          ? const Color(0xFFF1F5F9)
                          : Colors.transparent,
                      child: ListTile(
                        onTap: () => setState(() => _selectedChatIndex = index),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: chat['isStaff'] == true
                                  ? const Color(0xFFE0E7FF)
                                  : const Color(0xFFCBD5E1),
                              child: Icon(
                                chat['isStaff'] == true
                                    ? Icons.groups
                                    : Icons.person,
                                color: chat['isStaff'] == true
                                    ? const Color(0xFF3730A3)
                                    : const Color(0xFF475569),
                              ),
                            ),
                            if (chat['isOnline'] == true)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(chat['name'],
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            Text(chat['time'],
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        subtitle: Text(
                          chat['lastMsg'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF64748B)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 2. MAIN CONVERSATION PANEL
        Expanded(
          child: Column(
            children: [
              // Active Conversation Header
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFCBD5E1),
                          child: Icon(Icons.person,
                              color: Color(0xFF475569), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeChat['name'],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.circle,
                                    color: Color(0xFF22C55E), size: 8),
                                const SizedBox(width: 4),
                                Text("Online • ${activeChat['pet']}",
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Search in chat
                        Container(
                          width: 260,
                          height: 36,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(18)),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search conversations...',
                              hintStyle: TextStyle(
                                  fontSize: 11, color: Color(0xFF94A3B8)),
                              prefixIcon: Icon(Icons.search,
                                  size: 16, color: Color(0xFF94A3B8)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                            icon: const Icon(Icons.notifications_none,
                                size: 20, color: Color(0xFF64748B)),
                            onPressed: () {}),
                        const SizedBox(width: 12),

                        // Pet Profile Action Button
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.pets,
                              size: 14, color: Color(0xFF0F172A)),
                          label: const Text('Pet Profile',
                              style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                            icon: const Icon(Icons.more_vert,
                                size: 20, color: Color(0xFF64748B)),
                            onPressed: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // Conversation Thread
              Expanded(
                child: Container(
                  color: const Color(0xFFFAFAFA),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 20),
                    children: [
                      // Date Divider
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('TODAY',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B))),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Incoming Message
                      _buildIncomingBubble(
                        'Hi Dr. Thorne, I\'m just checking in on Luna\'s progress after her surgery yesterday. She seems a bit lethargic this morning, is that normal?',
                        '10:40 AM',
                      ),
                      const SizedBox(height: 16),

                      // Outgoing Doctor Message
                      _buildOutgoingBubble(
                        'Hello Elena! Yes, some lethargy is perfectly normal within the first 24-48 hours post-op. She\'s still metabolizing the anesthesia.',
                        '10:42 AM',
                      ),
                      const SizedBox(height: 12),

                      // Outgoing Doctor Follow-up
                      _buildOutgoingBubble(
                        'Is she drinking water and attempting to eat at all?',
                        '10:42 AM',
                      ),
                      const SizedBox(height: 16),

                      // Incoming Message with Attachment
                      _buildIncomingBubbleWithImage(
                        'She drank a little bit. Here\'s a photo of how she looks right now. She\'s just resting on her favorite blanket.',
                        '10:45 AM',
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Input Bar Area
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF64748B), size: 20),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.image_outlined,
                                      color: Color(0xFF64748B), size: 20),
                                  onPressed: () {},
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _msgController,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: 'Type your message here...',
                                      hintStyle: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.sentiment_satisfied_alt,
                                      color: Color(0xFF64748B),
                                      size: 20),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Send Button
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                                color: Color(0xFF0F172A),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.send,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Actions Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.science_outlined,
                              size: 14, color: Color(0xFF64748B)),
                          label: const Text('SEND LAB RESULTS',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B))),
                        ),
                        const SizedBox(width: 24),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_month_outlined,
                              size: 14, color: Color(0xFF64748B)),
                          label: const Text('SCHEDULE FOLLOW-UP',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildIncomingBubble(String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFCBD5E1),
          child: Icon(Icons.person, size: 16, color: Color(0xFF475569)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF0F172A), height: 1.4)),
            ),
            const SizedBox(height: 4),
            Text(time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomingBubbleWithImage(String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFCBD5E1),
          child: Icon(Icons.person, size: 16, color: Color(0xFF475569)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF0F172A), height: 1.4)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: const Color(0xFFFEF3C7),
                      child: const Center(
                        child: Icon(Icons.pets,
                            size: 60, color: Color(0xFFD97706)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  Widget _buildOutgoingBubble(String text, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white, height: 1.4)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(time,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF94A3B8))),
                const SizedBox(width: 4),
                const Icon(Icons.done_all, size: 14, color: Color(0xFF22C55E)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFF1E293B),
          child: Icon(Icons.medical_services, size: 14, color: Colors.white),
        ),
      ],
    );
  }
}
