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
import 'route_transitions.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/landing',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const LandingScreen(),
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup/profile-details',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const ProfileDetailsScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => DeiteScaffold(
          showNav: showBottomNav(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => noTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/pod',
            pageBuilder: (context, state) => noTransitionPage(
              key: state.pageKey,
              child: const PodScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => noTransitionPage(
              key: state.pageKey,
              child: const CommunityScreen(),
            ),
          ),
          GoRoute(
            path: '/wellbeing',
            pageBuilder: (context, state) => noTransitionPage(
              key: state.pageKey,
              child: const EmotionalWellbeingScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/pod/sports',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodSportsScreen(),
        ),
      ),
      GoRoute(
        path: '/pod/sports/topic/:topicId',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: PodSportsTopicScreen(
            topicId: state.pathParameters['topicId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/pod/explore/:section/:topicId',
        pageBuilder: (context, state) {
          final section = state.pathParameters['section']!;
          final topicId = state.pathParameters['topicId']!;
          return fadeTransitionPage(
            key: state.pageKey,
            child: PodExploreTopicScreen(
              key: ValueKey('$section-$topicId'),
              section: section,
              topicId: topicId,
            ),
          );
        },
      ),
      GoRoute(
        path: '/pod/ai-tech',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodAiTechScreen(),
        ),
      ),
      GoRoute(
        path: '/pod/entrepreneurship',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodEntrepreneurshipScreen(),
        ),
      ),
      GoRoute(
        path: '/pod/current-affairs',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodCurrentAffairsScreen(),
        ),
      ),
      GoRoute(
        path: '/pod/chat',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodGroupChatScreen(),
        ),
      ),
      GoRoute(
        path: '/pod/reflections',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const PodReflectionsScreen(),
        ),
      ),
      GoRoute(
        path: '/reflections',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const AllDayReflectionsScreen(),
        ),
      ),
      GoRoute(
        path: '/share-reflection',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const ShareReflectionScreen(),
        ),
      ),
      GoRoute(
        path: '/share-suggestions',
        pageBuilder: (context, state) {
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
          return fadeTransitionPage(
            key: state.pageKey,
            child: ShareSuggestionsScreen(
              initialReflection: reflection,
              newsArticle: news,
            ),
          );
        },
      ),
      GoRoute(
        path: '/tea-feed',
        pageBuilder: (context, state) {
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
          return fadeTransitionPage(
            key: state.pageKey,
            child: TeaFeedScreen(initialItems: items, returnTo: returnTo),
          );
        },
      ),
      GoRoute(
        path: '/help-improve-deite',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const HelpImproveScreen(),
        ),
      ),
      GoRoute(
        path: '/watchlist',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const WatchlistScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          return fadeTransitionPage(
            key: state.pageKey,
            child: ChatScreen(
              dateId: q['dateId'],
              isWhisperMode: q['whisper'] == '1' || q['whisper'] == 'true',
              isFreshSession: q['fresh'] == '1' || q['fresh'] == 'true',
            ),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/user/:userId',
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: UserProfileScreen(
            userId: state.pathParameters['userId']!,
          ),
        ),
      ),
    ],
  );
}
