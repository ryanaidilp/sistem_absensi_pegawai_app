// Shared Preferences Keys

import 'package:flutter/material.dart';

const String prefsTokenKey = 'token';
const String prefsUserKey = 'user';
const String prefsEmployeeKey = 'employee';
const String prefsAlarmKey = 'alarm';
const String prefsSeenKey = 'seen';

// General
const String jsonDataField = 'data';
const String approvalStatusField = 'approval_status';

// User/Employee
const String userIdField = 'id';
const String userNipField = 'nip';
const String userNameField = 'name';
const String userPhoneField = 'phone';
const String userGenderField = 'gender';
const String userDepartmentField = 'department';
const String userStatusField = 'status';
const String userPositionField = 'position';
const String userUnreadNotificationsCountField = 'unread_notifications';
const String userIsHolidayField = 'holiday';
const String userIsWeekendField = 'is_weekend';
const String userTokenField = 'token';
const String userNextPresenceField = 'next_presence';
const String userPresencesField = 'presence';
const String userRankField = 'rank';
const String userGroupField = 'group';

// Presence
const String presenceDateField = 'date';
const String presenceCodeTypeField = 'code_type';
const String presenceStatusField = 'status';
const String presenceAttendTimeField = 'attend_time';
const String presenceLocationField = 'location';
const String presencePhotoField = 'photo';
const String presenceStartTimeField = 'start_time';
const String presenceEndTimeField = 'end_time';

// Outstation/Permission
const String outstationIdField = 'id';
const String outstationTitleField = 'title';
const String outstationDescriptionField = 'description';
const String outstationIsApprovedField = 'is_approved';
const String outstationPhotoField = 'photo';
const String outstationDueDateField = 'due_date';
const String outstationStartDateField = 'start_date';
const String outstationUserField = 'user';

// Paid Leave
const String paidLeaveIdField = 'id';
const String paidLeaveTitleField = 'title';
const String paidLeaveCategoryField = 'category';
const String paidLeaveDescriptionField = 'description';
const String paidLeaveIsApprovedField = 'is_approved';
const String paidLeavePhotoField = 'photo';
const String paidLeaveDueDateField = 'due_date';
const String paidLeaveStartDateField = 'start_date';
const String paidLeaveUserField = 'user';

// Absent Permission
const String absentPermissionIdField = 'id';
const String absentPermissionTitleField = 'title';
const String absentPermissionDescriptionField = 'description';
const String absentPermissionIsApprovedField = 'is_approved';
const String absentPermissionPhotoField = 'photo';
const String absentPermissionDueDateField = 'due_date';
const String absentPermissionStartDateField = 'start_date';
const String absentPermissionUserField = 'user';

// Notification
const String notificationIdField = 'id';
const String notificationNotifiableIdField = 'notifiable_id';
const String notificationNotifiableTypeField = 'notifiable_type';
const String notificationIsReadField = 'is_read';

// Location
const String locationLatitudeField = 'latitude';
const String locationLongitudeField = 'longitude';
const String locationAddressField = 'address';

// Absent Report
const String reportAttendancePercentageFieldField = 'attendance_percentage';
const String reportDayField = 'day';
const String reportLimitField = 'limit';
const String reportLateCountField = 'late_count';
const String reportLeaveEarlyFieldCountField = 'leave_early_count';
const String reportNotMorningParadeCountField = 'not_morning_parade_count';
const String reportEarlyLunchBreakCountField = 'early_lunch_break_count';
const String reportNotComeAfterLunchBreakCountField =
    'not_come_after_lunch_break_count';
const String reportTotalWorkDayField = 'total_work_day';
const String reportAnnualLeaveField = 'annual_leave';
const String reportImportantReasonLeaveField = 'important_reason_leave';
const String reportSickLeaveField = 'sick_leave';
const String reportMaternityLeaveField = 'maternity_leave';
const String reportOutOfLiabilityLeaveField = 'out_of_liability_leave';
const String absentReportPercentageField = 'percentage';
const String absentReportYearlyField = 'yearly';
const String absentReportMonthlyField = 'monthly';
const String absentReportDailyField = 'daily';
const String absentReportHolidaysField = 'holidays';

// DailyData (Report)
const String dailyDateField = 'date';
const String dailyPresencesField = 'attendances';
const String dailyDataAttendTimeField = 'attend_time';
const String dailyDataAttendTypeField = 'absent_type';
const String dailyDataAttendStatusField = 'attend_status';

// Yearly
const String yearlyAbsentField = 'absent';
const String yearlyAbsentPermissionField = 'absent_permission';
const String yearlyOutstationField = 'outstation';

// Holiday
const String holidayDateField = 'date';
const String holidayNameField = 'name';
const String holidayDescriptionField = 'description';

const Map<String, dynamic> paidLeaveCategories = {
  'Cuti Tahunan (97.5%)': 1,
  'Cuti Alasan Penting (97.5%)': 2,
  'Cuti Bersalin (97.5%)': 3,
  'Cuti Sakit (97.5%)': 4,
  'Cuti Diluar Tanggungan (0%)': 5
};

const sizedBox = SizedBox();
const sizedBoxW2 = SizedBox(width: 2);
const sizedBoxW4 = SizedBox(width: 4);
const sizedBoxW5 = SizedBox(width: 5);
const sizedBoxW6 = SizedBox(width: 6);
const sizedBoxW8 = SizedBox(width: 8);
const sizedBoxW10 = SizedBox(width: 10);
const sizedBoxW12 = SizedBox(width: 12);
const sizedBoxW16 = SizedBox(width: 16);
const sizedBoxW20 = SizedBox(width: 20);
const sizedBoxW30 = SizedBox(width: 30);
const sizedBoxH2 = SizedBox(height: 2);
const sizedBoxH4 = SizedBox(height: 4);
const sizedBoxH5 = SizedBox(height: 5);
const sizedBoxH6 = SizedBox(height: 6);
const sizedBoxH8 = SizedBox(height: 8);
const sizedBoxH10 = SizedBox(height: 10);
const sizedBoxH12 = SizedBox(height: 12);
const sizedBoxH16 = SizedBox(height: 16);
const sizedBoxH20 = SizedBox(height: 20);
const sizedBoxH30 = SizedBox(height: 30);

const dividerT1 = Divider(thickness: 1);
const dividerT2 = Divider(thickness: 2);
const verticalDiv = VerticalDivider(
  thickness: 1,
  color: Colors.black,
);
