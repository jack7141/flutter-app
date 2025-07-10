import 'package:celeb_voice/common/widgets/common_app_%20bar.dart';
import 'package:celeb_voice/common/widgets/form_button.dart';
import 'package:celeb_voice/constants/gaps.dart';
import 'package:celeb_voice/constants/sizes.dart';
import 'package:celeb_voice/features/main/models/celeb_models.dart';
import 'package:celeb_voice/features/user_info/repos/job_repo.dart';
import 'package:celeb_voice/features/user_info/view_models/user_info_view_model.dart';
import 'package:celeb_voice/features/user_info/views/attitude_screen.dart';
import 'package:celeb_voice/features/user_info/widgets/celeb_avatar.dart';
import 'package:celeb_voice/features/user_info/widgets/interest_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JobScreen extends ConsumerStatefulWidget {
  static const String routeName = "job";
  final CelebModel? celeb;

  const JobScreen({super.key, this.celeb});

  @override
  ConsumerState<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends ConsumerState<JobScreen> {
  final JobRepo _jobRepo = JobRepo();
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("🏠 JobScreen initState 호출됨");
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    print("🔄 직업 목록 로딩 시작");
    final jobList = await _jobRepo.getJobs();
    setState(() {
      if (jobList != null) {
        jobs = jobList;
        print("✅ 직업 목록 로딩 완료: ${jobs.length}개");
        for (var job in jobs) {
          print("   - ${job['name']} (ID: ${job['id']})");
        }
      } else {
        print("❌ 직업 목록 로딩 실패");
      }
      isLoading = false;
    });
  }

  void _onJobSelected(String job, int id) {
    print("🎯 JobScreen - 직업 선택됨: $job (ID: $id)");
    print("🔍 Provider 업데이트 전 상태: ${ref.read(userInfoProvider).selectedJob}");

    ref.read(userInfoProvider.notifier).updateJob(job, id);

    // 업데이트 후 상태 확인
    final updatedState = ref.read(userInfoProvider);
    print("🔍 Provider 업데이트 후 상태:");
    print("   selectedJob: ${updatedState.selectedJob}");
    print("   selectedJobId: ${updatedState.selectedJobId}");
  }

  void _onNextTap(BuildContext context) {
    final userInfo = ref.read(userInfoProvider);

    print("🔍 JobScreen - 다음 버튼 클릭");
    print("🔍 현재 선택된 직업: ${userInfo.selectedJob}");

    if (userInfo.selectedJob != null) {
      print("✅ 직업 선택됨 - Attitude 화면으로 이동");

      if (widget.celeb != null) {
        print("🎭 셀럽 정보와 함께 이동: ${widget.celeb!.name}");
        context.push('/attitude', extra: widget.celeb);
      } else {
        print("🎭 셀럽 정보 없이 이동");
        context.pushNamed(AttitudeScreen.routeName);
      }
    } else {
      print("❌ 직업 미선택 - 스낵바 표시");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('직업을 선택해주세요')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider);

    print("🏗️ JobScreen build 호출됨");
    print("🔍 현재 상태 - 선택된 직업: ${userInfo.selectedJob}");

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: const CommonAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CelebAvatar(currentCeleb: widget.celeb),
              Gaps.v20,
              Text(
                "어떤 일을 하고 있어요?",
                style: TextStyle(
                  fontSize: Sizes.size16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v20,
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      runSpacing: Sizes.size8,
                      spacing: Sizes.size8,
                      children: [
                        for (var job in jobs)
                          GestureDetector(
                            onTap: () {
                              print("👆 직업 버튼 탭됨: ${job['name']}");
                              _onJobSelected(job['name'], job['id']);
                            },
                            child: InterestButton(
                              interest: job['name'],
                              id: job['id'],
                              isSelected: userInfo.selectedJob == job['name'],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Gaps.v24,
              GestureDetector(
                onTap: isLoading ? null : () => _onNextTap(context),
                child: FormButton(text: '이런 걸 해요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
