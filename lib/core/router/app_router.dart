import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/auth/landing_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/profile_details_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/community/community_screen.dart';
import '../../models/news_share_article.dart';
import '../../models/tea_item.dart';
import '../../screens/community/tea_feed_screen.dart';
import '../../screens/community/watchlist_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/misc/help_improve_screen.dart';
import '../../screens/pod/pod_ai_tech_screen.dart';
import '../../screens/pod/pod_current_affairs_screen.dart';
import '../../screens/pod/pod_entrepreneurship_screen.dart';
import '../../screens/pod/pod_explore_topic_screen.dart';
import '../../screens/pod/pod_group_chat_screen.dart';
import '../../screens/pod/pod_reflections_screen.dart';
import '../../screens/pod/pod_screen.dart';
import '../../screens/pod/pod_sports_screen.dart';
import '../../screens/pod/pod_sports_topic_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/user_profile_screen.dart';
import '../../screens/reflections/all_day_reflections_screen.dart';
import '../../screens/reflections/share_reflection_screen.dart';
import '../../screens/reflections/share_suggestions_screen.dart';
import '../../screens/wellbeing/emotional_wellbeing_screen.dart';
import '../../widgets/deite_bottom_navigation.dart';
import '../../widgets/deite_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/landing', builder: (_, __) => const LandingScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/signup/profile-details',
        builder: (_, __) => const ProfileDetailsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => DeiteScaffold(
          showNav: showBottomNav(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(path: '/pod', builder: (_, __) => const PodScreen()),
          GoRoute(
            path: '/community',
            builder: (_, __) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/wellbeing',
            builder: (_, __) => const EmotionalWellbeingScreen(),
          ),
        ],
      ),
      GoRoute(path: '/pod/sports', builder: (_, __) => const PodSportsScreen()),
      GoRoute(
        path: '/pod/sports/topic/:topicId',
        builder: (_, state) =>
            PodSportsTopicScreen(topicId: state.pathParameters['topicId']!),
      ),
      GoRoute(
        path: '/pod/explore/:section/:topicId',
        builder: (_, state) => PodExploreTopicScreen(
          section: state.pathParameters['section']!,
          topicId: state.pathParameters['topicId']!,
        ),
      ),
      GoRoute(path: '/pod/ai-tech', builder: (_, __) => const PodAiTechScreen()),
      GoRoute(
        path: '/pod/entrepreneurship',
        builder: (_, __) => const PodEntrepreneurshipScreen(),
      ),
      GoRoute(
        path: '/pod/current-affairs',
        builder: (_, __) => const PodCurrentAffairsScreen(),
      ),
      GoRoute(path: '/pod/chat', builder: (_, __) => const PodGroupChatScreen()),
      GoRoute(
        path: '/pod/reflections',
        builder: (_, __) => const PodReflectionsScreen(),
      ),
      GoRoute(
        path: '/reflections',
        builder: (_, __) => const AllDayReflectionsScreen(),
      ),
      GoRoute(
        path: '/share-reflection',
        builder: (_, __) => const ShareReflectionScreen(),
      ),
      GoRoute(
        path: '/share-suggestions',
        builder: (context, state) {
          String? reflection;
          NewsShareArticle? news;
          final extra = state.extra;
          if (extra is Map) {
            if (extra['reflection'] is String) {
              reflection = extra['reflection'] as String;
            }
            if (extra['newsArticle'] is Map) {
              news = NewsShareArticle.fromMap(
                Map<String, dynamic>.from(extra['newsArticle'] as Map),
              );
            }
          }
          return ShareSuggestionsScreen(
            initialReflection: reflection,
            newsArticle: news,
          );
        },
      ),
      GoRoute(
        path: '/tea-feed',
        builder: (context, state) {
          List<TeaItem>? items;
          var returnTo = '/dashboard';
          final extra = state.extra;
          if (extra is Map) {
            final raw = extra['teaItems'];
            if (raw is List<TeaItem>) {
              items = raw;
            } else if (raw is List) {
              items = raw.whereType<TeaItem>().toList();
            }
            final rt = extra['returnTo'];
            if (rt is String && rt.startsWith('/')) returnTo = rt;
          }
          return TeaFeedScreen(initialItems: items, returnTo: returnTo);
        },
      ),
      GoRoute(
        path: '/help-improve-deite',
        builder: (_, __) => const HelpImproveScreen(),
      ),
      GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistScreen()),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final q = state.uri.queryParameters;
          return ChatScreen(
            dateId: q['dateId'],
            isWhisperMode: q['whisper'] == '1' || q['whisper'] == 'true',
            isFreshSession: q['fresh'] == '1' || q['fresh'] == 'true',
          );
        },
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/user/:userId',
        builder: (_, state) =>
            UserProfileScreen(userId: state.pathParameters['userId']!),
      ),
    ],
  );
}
