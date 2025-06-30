import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/user_info/repos/job_repo.dart';
import 'package:celeb_voice/features/user_info/views/attitude_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const jobs = [
  "사무직",
  "전문직",
  "공무원/공공기간",
  "서비스직",
  "연구/교육",
  "생산/기술직",
  "프리랜서",
  "예술/문화/엔터테인먼트",
  "자영업/소상공인",
  "영업/마케팅",
  "IT/개발",
  "금융/보험",
  "의료/간호/보건",
  "학생/취준생",
  "기사/육아",
  "쉬고 있어요",
  "이중엔 없어요",
];

class JobScreen extends StatefulWidget {
  static const String routeName = "job";

  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final JobRepo _jobRepo = JobRepo();
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    print("🔄 직업 목록 로딩 시작");

    final jobList = await _jobRepo.getJobs();

    setState(() {
      if (jobList != null) {
        jobs = jobList;
        print("✅ 직업 목록 로딩 완료: ${jobs.length}개");
      } else {
        print("❌ 직업 목록 로딩 실패");
      }
      isLoading = false;
    });
  }

  void _onNextTap(BuildContext context) {
    context.pushNamed(AttitudeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CelebAvatar(),
              Gaps.v20,
              Text(
                "어떤 일을 하고 있어요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              Wrap(
                runSpacing: Sizes.size8,
                spacing: Sizes.size8,
                children: [
                  for (var job in jobs)
                    InterestButton(interest: job['name'], id: job['id']),
                ],
              ),
              Gaps.v24,
              GestureDetector(
                onTap: () => _onNextTap(context),
                child: FormButton(text: '이런 걸 해요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
