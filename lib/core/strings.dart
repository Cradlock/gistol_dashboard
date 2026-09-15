class AppStrings {
  static const common = CommonStrings();
  static const auth = AuthStrings();
  static const groups = GroupStrings();
  static const students = StudentsStrings();
  static const tasks = TaskStrings();
  static const exams = ExamStrings();
  static const settings = SettingsStrings();
  static const navigation = NavigationStrings();
  static const errors = ErrorsStrings();
}

class CommonStrings {
  const CommonStrings();

  static const String _ns = "common.";

  // Вспомогательный метод для склейки
  static String _k(String key) => "$_ns$key";

  // Теперь писать одно удовольствие:
  String get cancel => _k("cancel");
  String get yes => _k("yes");
  String get ok => _k("ok");
  String get exit => _k("exit");
  String get save => _k("save");
  String get create => _k("create");
  String get retry => _k("retry");
  String get errorBlankInput => _k("error_blank_input");

  String get from => _k("from");
  String get to => _k("to");

  String get error_no_internet => _k("error_no_internet");
  String get error_server_error => _k("error_server_error");
  String get error_timeout => _k("error_timeout");
}

class SettingsStrings {
  const SettingsStrings();

  static const String _ns = "settings.";

  // Вспомогательный метод для склейки
  static String _k(String key) => "$_ns$key";

  String get darkmode => _k("darkmode");
  String get langmode => _k("langmode");
  String get title => _k("title");
}

class AuthStrings {
  const AuthStrings();

  static const String _ns = "auth.";

  // Вспомогательный метод для склейки
  static String _k(String key) => "$_ns$key";

  String get error_incorrect_password_or_code =>
      _k("error_incorrect_password_or_code");
  String get usernameLabel => _k("username_label");
  String get usernameHint => _k("username_hint_text");
  String get passwordLabel => _k("password_label");
  String get passwordHint => _k("password_hint_text");
  String get loginBtn => _k("login_btn");
}

class NavigationStrings {
  const NavigationStrings();

  static const String _ns = "navigation.";
  static String _k(String key) => "$_ns$key";

  String get menu => _k("menu");
  String get home => _k("home");
}

class ErrorsStrings {
  const ErrorsStrings();

  static const String _ns = "errors.network.";
  static String _k(String key) => "$_ns$key";

  String get noInternet => _k("no_internet_label");
  String get noConnection => _k("no_connection_label");
}

class GroupStrings {
  const GroupStrings();

  static const String _ns = "groups.";

  // Вспомогательный метод для склейки

  static String _k(String key) => "$_ns$key";
  String get error_duplicate => _k("error_duplicate");
  String get title => _k("title");
  String get filters => _k("filters");
  String get sort => _k("sort");
  String get resetSort => _k("reset_sort");
  String get resetFilters => _k("reset_filters");

  String get minToMax => _k("min_to_max");
  String get maxToMin => _k("max_to_min");

  String get sortOrder => _k("sort_order");
  String get sortField => _k("sort_field");

  // Поля для сортировки
  String get sortFieldDate => _k("sort_field_date");
  String get sortFieldStudents => _k("sort_field_students");
  String get sortFieldTitle => _k("sort_field_title");

  String get addPlaceholderTitle => _k("add_placeholder_title");
  String get addPlaceholderCourse => _k("add_placeholder_course");
  String get searchPlaceholder => _k("search_placeholder");
  String get selectGroup => _k("select_group");
  String get empty => _k("empty");
  String get course => _k("course");
  String get created => _k("created");
  String get notSelected => _k("not_selected");
  String get deleteQuestion => _k("delete_question");

  String get filterCourseRangeLabel => _k("filterCourseRangeLabel");
  String get filterDateRangeLabel => _k("filterDateRangeLabel");
  String get filterStudentsCountRangeLabel =>
      _k("filterStudentsCountRangeLabel");
}

class StudentsStrings {
  const StudentsStrings();

  static const String _ns = "students.";

  static String _k(String key) => "$_ns$key";

  String get title => _k("title");

  String get year_sort_label => _k("year_sort_label");
  String get scores_sort_label => _k("scores_sort_label");
  String get error_student_not_found => _k("error_student_not_found");
  String get errorInvalidUpdate => _k("error_invalid_update");

  String get editPlaceholderName => _k("edit_placeholder_name");
  String get editPlaceholderSurname => _k("edit_placeholder_surname");
  String get editPlaceholderYear => _k("edit_placeholder_year");
  String get editPlaceholderGroup => _k("edit_placeholder_group");
  String get editPlaceholderScores => _k("edit_placeholder_scores");

  String get fioPlaceholder => _k("fio_placeholder");
  String get sort => _k("sort");
  String get filters => _k("filters");
  String get resetSort => _k("reset_sort");
  String get resetFilters => _k("reset_filters");
  String get sortOrder => _k("sort_order");
  String get sortField => _k("sort_field");
  String get filterCourseRangeLabel => _k("filter_course_range");
  String get filterGroupLabel => _k("filter_group");
  String get newStudents => _k("new_students");
  String get deletedStudents => _k("deleted_students");
  String get notSelected => _k("not_selected");
  String get deleteQuestion => _k("delete_question");
  String get confirmQuestion => _k("confirm_question");
  String get unconfirmQuestion => _k("unconfirm_question");
  String get recoveryQuestion => _k("recovery_question");
}

class TaskStrings {
  const TaskStrings();

  static const String _ns = "tasks.";
  static String _k(String key) => "$_ns$key";

  String get title => _k("title");
  String get searchPlaceholder => _k("search_placeholder");
  String get filterGroup => _k("filter_group");
  String get allGroups => _k("all_groups");
  String get notSelected => _k("not_selected");
  String get deleteQuestion => _k("delete_question");
  String get addPlaceholderTitle => _k("add_placeholder_title");
  String get addPlaceholderContent => _k("add_placeholder_content");
  String get addPlaceholderGroup => _k("add_placeholder_group");
  String get addPlaceholderPoints => _k("add_placeholder_points");
  String get startAt => _k("start_at");
  String get endAt => _k("end_at");
  String get points => _k("points");
  String get group => _k("group");
  String get details => _k("details");
  String get answers => _k("answers");
  String get answersEmpty => _k("answers_empty");
  String get student => _k("student");
  String get statusPending => _k("status_pending");
  String get statusPositive => _k("status_positive");
  String get statusNegative => _k("status_negative");
  String get gradePositive => _k("grade_positive");
  String get gradeNegative => _k("grade_negative");
  String get gradePending => _k("grade_pending");
  String get errorNotFound => _k("error_not_found");
  String get errorInvalid => _k("error_invalid");
  String get dateRangeInvalid => _k("date_range_invalid");
}

class ExamStrings {
  const ExamStrings();

  static const String _ns = 'exams.';
  static String _k(String key) => '$_ns$key';

  String get title => _k('title');
  String get searchPlaceholder => _k('search_placeholder');
  String get filterGroup => _k('filter_group');
  String get notSelected => _k('not_selected');
  String get create => _k('create');
  String get edit => _k('edit');
  String get empty => _k('empty');
  String get total => _k('total');
  String get titleField => _k('title_field');
  String get theme => _k('theme');
  String get startAt => _k('start_at');
  String get duration => _k('duration');
  String get minutes => _k('minutes');
  String get positiveNumber => _k('positive_number');
  String get deleteQuestion => _k('delete_question');
  String get deleteSelected => _k('delete_selected');
  String get targets => _k('targets');
  String get addTarget => _k('add_target');
  String get editTarget => _k('edit_target');
  String get year => _k('year');
  String get entireYear => _k('entire_year');
  String get group => _k('group');
  String get useEntireYear => _k('use_entire_year');
  String get groupOptional => _k('group_optional');
  String get questions => _k('questions');
  String get addQuestion => _k('add_question');
  String get editQuestion => _k('edit_question');
  String get questionText => _k('question_text');
  String get choice => _k('choice');
  String get input => _k('input');
  String get points => _k('points');
  String get position => _k('position');
  String get expectedAnswer => _k('expected_answer');
  String get addChoice => _k('add_choice');
  String get correctChoice => _k('correct_choice');
  String get questionInvalid => _k('question_invalid');
  String get errorNotFound => _k('error_not_found');
  String get errorInvalid => _k('error_invalid');
  String get errorConflict => _k('error_conflict');
}
