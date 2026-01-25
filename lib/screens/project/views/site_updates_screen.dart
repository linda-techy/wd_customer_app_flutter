import 'package:flutter/material.dart';
import '../../../components/organisms/site_update_card.dart';
import '../../../constants.dart';

class SiteUpdatesScreen extends StatelessWidget {
  const SiteUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text("Daily Site Updates", style: TextStyle(color: blackColor)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          // Dummy data for now
          final dates = ["Today, 24 Jan", "Yesterday, 23 Jan", "21 Jan 2024"];
          final descriptions = [
             "Completed the foundation laying for the north wing. The concrete mix was tested and approved by the site engineer. Tomorrow we start the pillar reinforcements.",
             "Material delivery arrived at 10 AM. Unloaded 500 bags of cement and 2 truckloads of sand. Site inspection scheduled for tomorrow.",
             "Excavation work completed. Removed debris from the site. Weather was a bit rainy so work was halted for 2 hours.",
          ];
          final weather = ["28°C Sunny", "26°C Cloudy", "24°C Rainy"];
          
          return SiteUpdateCard(
            date: dates[index],
            description: descriptions[index],
            imageUrls: [
              "https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800",
            ],
            weather: weather[index],
            onComment: () {},
            onShare: () {},
          );
        },
      ),
    );
  }
}
