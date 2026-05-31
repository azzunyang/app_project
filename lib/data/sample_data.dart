import 'package:flutter/foundation.dart';
import '../models/notice.dart';
import '../services/favorites_service.dart';

final List<Notice> sampleNotices = [
  Notice(
    id: '1',
    title: '국가장학금 신청하기!',
    department: '학생장학팀',
    date: '2026-03-18',
    category: '장학',
    isFeatured: true,
    dday: 'D-1',
    content: '2026학년도 국가장학금 2차 신청이 마감됩니다.\n\n신청 기간: 2026.03.17 ~ 2026.03.19\n신청 방법: 한국장학재단 홈페이지(www.kosaf.go.kr) 접속 후 신청\n\n소득분위 확인 및 서류 제출 기한을 반드시 지켜주시기 바랍니다.',
  ),
  Notice(
    id: '2',
    title: '2026학년도 수강신청 안내',
    department: '학사팀',
    date: '2026-02-06',
    category: '학사',
    content: '2026학년도 1학기 수강신청 일정을 안내드립니다.\n\n수강신청 기간: 2026.02.10 ~ 2026.02.12\n수강신청 시스템: 포털 → 학사 → 수강신청\n\n수강 정정 기간: 2026.02.20 ~ 2026.02.21',
  ),
  Notice(
    id: '3',
    title: '2026-1학기 국가장학금 1차 지급일정 안내',
    department: '학생장학팀',
    date: '2026-03-18',
    category: '장학',
    content: '2026학년도 1학기 국가장학금 1차 지급 일정을 안내드립니다.\n\n지급일: 2026.03.25\n지급 대상: 국가장학금 1유형, 2유형 수혜자\n\n장학금은 등록금 계좌로 직접 지급됩니다.',
  ),
  Notice(
    id: '4',
    title: '호서대학교 교내취업 취망자 신청 안내',
    department: '취업팀',
    date: '2026-02-06',
    category: '취업',
    content: '호서대학교 교내 취업 희망자를 모집합니다.\n\n모집 분야: 행정 보조, 연구 보조 등\n신청 기간: 2026.02.10 ~ 2026.02.28\n신청 방법: 포털 → 취업 → 교내취업 신청',
  ),
  Notice(
    id: '5',
    title: '2026학년도 1학기 성적 이의신청 안내',
    department: '학사팀',
    date: '2026-04-10',
    category: '학사',
    content: '2026학년도 1학기 성적 이의신청 기간을 안내드립니다.\n\n이의신청 기간: 2026.04.15 ~ 2026.04.19\n신청 방법: 해당 교수님께 직접 문의\n\n성적 정정은 교수님 확인 후 처리됩니다.',
  ),
  Notice(
    id: '6',
    title: '2026년 교내 창업경진대회 참가자 모집',
    department: '창업지원팀',
    date: '2026-04-15',
    category: '외부',
    content: '2026년 호서대학교 교내 창업경진대회 참가자를 모집합니다.\n\n대회 일정: 2026.05.20\n참가 자격: 재학생 2인 이상 팀\n신청 기간: 2026.04.15 ~ 2026.05.01\n\n우수팀에게 창업 지원금 및 멘토링을 제공합니다.',
  ),
  Notice(
    id: '7',
    title: '국가장학금 2차 신청 마감 안내',
    department: '학생장학팀',
    date: '2026-03-19',
    category: '장학',
    content: '국가장학금 2차 신청이 오늘 마감됩니다.\n\n마감 시간: 2026.03.19 18:00\n\n신청을 완료하지 않은 학생은 반드시 오늘까지 신청 완료하시기 바랍니다.',
  ),
  Notice(
    id: '8',
    title: '2026학년도 사회봉사 신청 안내',
    department: '사회봉사센터',
    date: '2026-03-05',
    category: '사회봉사',
    content: '2026학년도 사회봉사 교과목 수강 신청 안내입니다.\n\n신청 기간: 2026.03.05 ~ 2026.03.15\n활동 기간: 2026.03.20 ~ 2026.06.30\n\n사회봉사 시간 인정: 30시간 이상 활동 시 1학점 인정',
  ),
  Notice(
    id: '9',
    title: '2026학년도 1학기 교양 강의 수강 신청 안내',
    department: '교양교육센터',
    date: '2026-02-20',
    category: '교양',
    content: '2026학년도 1학기 교양 강의 수강 신청 안내입니다.\n\n인문, 사회, 자연, 예술 등 다양한 영역의 교양 강의를 개설하였습니다.\n\n포털 수강신청 시스템에서 교양 탭을 선택하여 신청하세요.',
  ),
  Notice(
    id: '10',
    title: '하계 인턴십 프로그램 참가자 모집',
    department: '취업팀',
    date: '2026-04-20',
    category: '취업',
    content: '2026년 하계 인턴십 프로그램 참가자를 모집합니다.\n\n참가 기간: 2026.07.01 ~ 2026.08.31\n모집 인원: 50명\n신청 기간: 2026.04.20 ~ 2026.05.15\n\n참가자에게 소정의 인턴십 수당이 지급됩니다.',
  ),
  Notice(
    id: '11',
    title: '글로벌 교류 프로그램 참가자 모집',
    department: '국제교류팀',
    date: '2026-04-01',
    category: '외부',
    content: '2026학년도 글로벌 교류 프로그램 참가자를 모집합니다.\n\n교류 국가: 일본, 중국, 미국, 유럽 등\n참가 기간: 2026.09 ~ 2027.02\n신청 기간: 2026.04.01 ~ 2026.04.30\n\n어학 요건 및 학점 기준을 반드시 확인하세요.',
  ),
  Notice(
    id: '12',
    title: '지역사회 봉사활동 참가자 모집',
    department: '사회봉사센터',
    date: '2026-04-05',
    category: '사회봉사',
    content: '지역사회 봉사활동에 참가할 학생을 모집합니다.\n\n봉사 내용: 노인복지관, 장애인시설 등 봉사\n활동 기간: 2026.04.15 ~ 2026.06.20\n\n봉사 시간은 사회봉사 교과목 시간으로 인정됩니다.',
  ),
];

final List<Notice> featuredNotices = sampleNotices.where((n) => n.isFeatured).toList();

// Global notice list shared across screens — updated when API data loads
List<Notice> allNotices = List.of(sampleNotices);

final favoritesNotifier = ValueNotifier<int>(0);

void toggleFavorite(Notice notice) {
  notice.isFavorite = !notice.isFavorite;
  favoritesNotifier.value++;
  if (notice.isFavorite) {
    FavoritesService.add(notice.id);
  } else {
    FavoritesService.remove(notice.id);
  }
}
