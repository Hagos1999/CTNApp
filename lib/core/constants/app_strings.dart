/// Static string constants for CTNApp
class AppStrings {
  AppStrings._();

  static const String appName = 'CTNApp';
  static const String appTagline = 'Solar Energy Monitoring';
  static const String poweredBy = 'Powered by CTNApp';
  static const String welcomeMessage = 'Monitor your energy usage in real-time.';

  // Auth
  static const String signIn = 'Sign In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String loginSubtitle = 'Monitor your solar energy in real time';
  static const String invalidCredentials = 'Invalid email or password';
  static const String loginError = 'An error occurred. Please try again.';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String voltage = 'Voltage';
  static const String current = 'Current';
  static const String power = 'Power';
  static const String energy = 'Energy';
  static const String frequency = 'Frequency';
  static const String powerFactor = 'Power Factor';
  static const String deviceOnline = 'Device Online';
  static const String deviceOffline = 'Device Offline';
  static const String lastUpdated = 'Last updated';
  static const String noData = 'No data yet';
  static const String noDataSubtitle = 'Waiting for sensor readings...';

  // History
  static const String history = 'Energy History';
  static const String today = 'Today';
  static const String last7Days = '7 Days';
  static const String last30Days = '30 Days';
  static const String totalEnergy = 'Total Energy';
  static const String avgPower = 'Avg Power';
  static const String peakPower = 'Peak Power';
  static const String noReadings = 'No readings for this period';

  // Settings
  static const String settings = 'Settings';
  static const String deviceConfig = 'Device Configuration';
  static const String deviceId = 'Device ID';
  static const String dataSource = 'Data Source';
  static const String account = 'Account';
  static const String logout = 'Logout';
  static const String about = 'About';
  static const String version = 'Version';
  static const String defaultDeviceId = 'esp32_001';

  // Units
  static const String unitVoltage = 'V';
  static const String unitCurrent = 'A';
  static const String unitPower = 'W';
  static const String unitEnergy = 'kWh';
  static const String unitFrequency = 'Hz';
  static const String unitPowerFactor = '';

  // Errors
  static const String connectionError = 'Connection error';
  static const String retry = 'Retry';
}
