enum NoticeCategory { all, academic, scholarship, job, external }

class Notice {
  final String id;
  final String title;
  final String department;
  final String date;
  final NoticeCategory category;
  final bool isImportant;
  final String? dDay;

  Notice({
    required this.id,
    required this.title,
    required this.department,
    required this.date,
    required this.category,
    this.isImportant = false,
    this.dDay,
  });
}

final List<Notice> noticeData = [
  Notice(
    id: '1',
    title: '2026학년도 수강신청 안내',
    department: '학사팀',
    date: '2025-02-06',
    category: NoticeCategory.academic,
    isImportant: true,
  ),
  Notice(
    id: '2',
    title: '2026-1학기 국가장학금 1차 지급일정 안내',
    department: '학생장학팀',
    date: '2026-03-18',
    category: NoticeCategory.scholarship,
  ),
  Notice(
    id: '3',
    title: '호서대학교 교내취업 취망자 신청 안내',
    department: '취업팀',
    date: '2026-02-06',
    category: NoticeCategory.job,
  ),
  Notice(
    id: '4',
    title: '2026학년도 1학기 성적 이의신청 안내',
    department: '학사팀',
    date: '2026-04-10',
    category: NoticeCategory.academic,
    isImportant: true,
  ),
  Notice(
    id: '5',
    title: '2026년 교내 창업경진대회 참가자 모집',
    department: '창업지원팀',
    date: '2026-04-15',
    category: NoticeCategory.external,
  ),
  Notice(
    id: '6',
    title: '국가장학금 2차 신청 마감 안내',
    department: '학생장학팀',
    date: '2026-04-20',
    category: NoticeCategory.scholarship,
    isImportant: true,
    dDay: 'D-1',
  ),
  Notice(
    id: '7',
    title: '2026-1학기 학점인정 신청 안내',
    department: '학사팀',
    date: '2026-04-22',
    category: NoticeCategory.academic,
  ),
  Notice(
    id: '8',
    title: '하계 현장실습 참여 기업 모집 공고',
    department: '취업팀',
    date: '2026-04-25',
    category: NoticeCategory.job,
  ),
  Notice(
    id: '9',
    title: '교외 장학금 신청 안내 (삼성꿈장학재단)',
    department: '학생장학팀',
    date: '2026-04-28',
    category: NoticeCategory.scholarship,
  ),
  Notice(
    id: '10',
    title: '2026년 하반기 교환학생 선발 공고',
    department: '국제교류팀',
    date: '2026-05-01',
    category: NoticeCategory.external,
  ),
];

final List<Notice> bannerNotices = [
  Notice(
    id: 'b1',
    title: '국가장학금 신청하기!',
    department: '학생장학팀',
    date: '2026-04-20',
    category: NoticeCategory.scholarship,
    dDay: '2차 신청 마감까지 D-1',
  ),
  Notice(
    id: 'b2',
    title: '2026학년도 수강신청 안내',
    department: '학사팀',
    date: '2025-02-06',
    category: NoticeCategory.academic,
    dDay: '수강신청 기간: 2.10 ~ 2.14',
  ),
  Notice(
    id: 'b3',
    title: '교내취업 취망자 신청 안내',
    department: '취업팀',
    date: '2026-02-06',
    category: NoticeCategory.job,
    dDay: '신청 마감: 2026-02-28',
  ),
];

Map<NoticeCategory, Map<String, String>> categoryColors = {
  NoticeCategory.academic: {
    'bg': '#DBEAFE',
    'text': '#1D4ED8',
    'label': '학사',
  },
  NoticeCategory.scholarship: {
    'bg': '#EDE9FE',
    'text': '#6D28D9',
    'label': '장학',
  },
  NoticeCategory.job: {
    'bg': '#D1FAE5',
    'text': '#065F46',
    'label': '취업',
  },
  NoticeCategory.external: {
    'bg': '#FEF3C7',
    'text': '#92400E',
    'label': '외부',
  },
};
