import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import '../../theme/app_colors.dart';

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      backgroundColor: AppColors.obsidianBlack,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(
              icon: Icons.history_edu,
              title: 'Backstory',
              description:
              'This application\'s development is based on the results of a university research project, where we analyzed the correlation between sedentary behavior in university students and the evidently resulting decline in physical health and mental wellness. The aim of this application is to incentivize users, mainly university students or young adults, to participate in daily physical activity whilst remaining flexible and compatible with ever-changing academic and extracurricular schedules.'
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.directions_walk,
              title: 'Your Fitness Journey',
              description:
              'You are assigned a loyal slayer who will grow stronger alongside you as you complete workouts and maintain your streak. As you complete workout sessions you will be rewarded experience points (XP), slowly increasing your level. You will set your own fitness goals, and based on your goals you will receive an opportunity to slay a powerful enemy - a BOSS! But beware, do not charge into battle under-leveled and unprepared, lest you risk DEFEAT! However, should you slay the BOSS and achieve VICTORY!, you will be rewarded with Coins, which you can save up and exchange for new equipment for your slayer, providing stat increases and snazzy new looks, which will help you grow stronger and slay even more powerful BOSSES! Rinse and repeat!'
            ),

            const SizedBox(height: 16),

            _buildInfoCard(
              icon: Icons.local_fire_department,
              title: 'The Unending Quest',
              description:
              'Fitness is a lifelong pursuit, and your loyal slayer will be there with you every step of the way as you both become stronger and face increasingly difficult challenges! Incremental rewards and streaks will help encourage you to continue working on yourself and pursue your goals. Remember to enjoy moments of respite and make the most of your workout sessions. You are not alone! Venture forth, and become the ultimate FITNESS SLAYER!'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkTavernGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.flameOrange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.flameOrange,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.parchmentWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.parchmentWhite,
              fontSize: 17,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
