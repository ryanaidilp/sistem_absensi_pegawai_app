// Shared Preferences Keys

const String PREFS_TOKEN_KEY = 'token';
const String PREFS_USER_KEY = 'user';
const String PREFS_EMPLOYEE_KEY = 'employee';
const String PREFS_ALARM_KEY = 'alarm';
const String PREFS_SEEN_KEY = 'seen';

// General
const String JSON_DATA_FIELD = 'data';

// User/Employee
const String USER_ID_FIELD = 'id';
const String USER_NIP_FIELD = 'nip';
const String USER_NAME_FIELD = 'name';
const String USER_PHONE_FIELD = 'phone';
const String USER_GENDER_FIELD = 'gender';
const String USER_DEPARTMENT_FIELD = 'department';
const String USER_STATUS_FIELD = 'status';
const String USER_POSITION_FIELD = 'position';
const String USER_UNREAD_NOTIFICATION_COUNT_FIELD = 'unread_notifications';
const String USER_HOLIDAY_FIELD = 'holiday';
const String USER_IS_WEEKEND_FIELD = 'is_weekend';
const String USER_TOKEN_FIELD = 'token';
const String USER_NEXT_PRESENCE_FIELD = 'next_presence';
const String USER_PRESENCES_FIELD = 'presence';
const String USER_RANK_FIELD = 'rank';
const String USER_GROUP_FIELD = 'group';

// Presence
const String PRESENCE_DATE_FIELD = 'date';
const String PRESENCE_CODE_TYPE_FIELD = 'code_type';
const String PRESENCE_STATUS_FIELD = 'status';
const String PRESENCE_ATTEND_TIME_FIELD = 'attend_time';
const String PRESENCE_LOCATION_FIELD = 'location';
const String PRESENCE_PHOTO_FIELD = 'photo';
const String PRESENCE_START_TIME_FIELD = 'start_time';
const String PRESENCE_END_TIME_FIELD = 'end_time';

// Outstation/Permission
const String OUTSTATION_ID_FIELD = 'id';
const String OUTSTATION_TITLE_FIELD = 'title';
const String OUTSTATION_DESCRIPTION_FIELD = 'description';
const String OUTSTATION_IS_APPROVED_FIELD = 'is_approved';
const String OUTSTATION_PHOTO_FIELD = 'photo';
const String OUTSTATION_DUE_DATE_FIELD = 'due_date';
const String OUTSTATION_START_DATE_FIELD = 'start_date';
const String OUTSTATION_USER_FIELD = 'user';

// Paid Leave
const String PAID_LEAVE_ID_FIELD = 'id';
const String PAID_LEAVE_TITLE_FIELD = 'title';
const String PAID_LEAVE_CATEGORY_FIELD = 'category';
const String PAID_LEAVE_DESCRIPTION_FIELD = 'description';
const String PAID_LEAVE_IS_APPROVED_FIELD = 'is_approved';
const String PAID_LEAVE_PHOTO_FIELD = 'photo';
const String PAID_LEAVE_DUE_DATE_FIELD = 'due_date';
const String PAID_LEAVE_START_DATE_FIELD = 'start_date';
const String PAID_LEAVE_USER_FIELD = 'user';

// Absent Permission
const String ABSENT_PERMISSION_ID_FIELD = 'id';
const String ABSENT_PERMISSION_TITLE_FIELD = 'title';
const String ABSENT_PERMISSION_DESCRIPTION_FIELD = 'description';
const String ABSENT_PERMISSION_IS_APPROVED_FIELD = 'is_approved';
const String ABSENT_PERMISSION_PHOTO_FIELD = 'photo';
const String ABSENT_PERMISSION_DUE_DATE_FIELD = 'due_date';
const String ABSENT_PERMISSION_START_DATE_FIELD = 'start_date';
const String ABSENT_PERMISSION_USER_FIELD = 'user';

// Notification
const String NOTIFICATION_ID_FIELD = 'id';
const String NOTIFICATION_NOTIFIABLE_ID_FIELD = 'notifiable_id';
const String NOTIFICATION_NOTIFIABLE_TYPE_FIELD = 'notifiable_type';
const String NOTIFICATION_IS_READ_FIELD = 'is_read';

// Location
const String LOCATION_LATITUDE_FIELD = 'latitude';
const String LOCATION_LONGITUDE_FIELD = 'longitude';
const String LOCATION_ADDRESS_FIELD = 'address';

// Absent Report
const String REPORT_ATTENDANCE_PERCENTAGE_FIELD = 'attendance_percentage';
const String REPORT_DAY_FIELD = 'day';
const String REPORT_LIMIT_FIELD = 'limit';
const String REPORT_LATE_COUNT_FIELD = 'late_count';
const String REPORT_LEAVE_EARLY_COUNT_FIELD = 'leave_early_count';
const String REPORT_NOT_MORNING_PARADE_COUNT_FIELD = 'not_morning_parade_count';
const String REPORT_EARLY_LUNCH_BREAK_COUNT_FIELD = 'early_lunch_break_count';
const String REPORT_NOT_COME_AFTER_LUNCH_BREAK_COUNT_FIELD =
    'not_come_after_lunch_break_count';
const String REPORT_TOTAL_WORK_DAY_FIELD = 'total_work_day';
const String REPORT_ANNUAL_LEAVE_FIELD = 'annual_leave';
const String REPORT_IMPORTANT_REASON_LEAVE_FIELD = 'important_reason_leave';
const String REPORT_SICK_LEAVE_FIELD = 'sick_leave';
const String REPORT_MATERNITY_LEAVE_FIELD = 'maternity_leave';
const String REPORT_OUT_OF_LIABILITY_LEAVE_FIELD = 'out_of_liability_leave';
const String REPORT_PERCENTAGE_FIELD = 'percentage';
const String ABSENT_REPORT_YEARLY_FIELD = 'yearly';
const String ABSENT_REPORT_MONTHLY_FIELD = 'monthly';
const String ABSENT_REPORT_DAILY_FIELD = 'daily';
const String ABSENT_REPORT_HOLIDAYS_FIELD = 'holidays';

// DailyData (Report)
const String DAILY_DATE_FIELD = 'date';
const String DAILY_PRESENCES_FIELD = 'attendances';
const String DAILY_DATA_ATTEND_TIME_FIELD = 'attend_time';
const String DAILY_DATA_ATTEND_TYPE_FIELD = 'absent_type';
const String DAILY_DATA_ATTEND_STATUS_FIELD = 'attend_status';

// Yearly
const String YEARLY_ABSENT_FIELD = 'absent';
const String YEARLY_ABSENT_PERMISSION_FIELD = 'absent_permission';
const String YEARLY_OUTSTATION_FIELD = 'outstation';

// Holiday
const String HOLIDAY_DATE_FIELD = 'date';
const String HOLIDAY_NAME_FIELD = 'name';
const String HOLIDAY_DESCRIPTION_FIELD = 'description';

const Map<String, dynamic> paidLeaveCategories = {
  'Cuti Tahunan (97.5%)': 1,
  'Cuti Alasan Penting (97.5%)': 2,
  'Cuti Bersalin (97.5%)': 3,
  'Cuti Sakit (97.5%)': 4,
  'Cuti Diluar Tanggungan (0%)': 5
};
