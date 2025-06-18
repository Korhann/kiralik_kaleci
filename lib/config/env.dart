abstract class Env {
  static String appName = "";
  static String baseUrl = "";
  static bool useFirebase = false;

  static void setEnvironment(EnvironmentType env) {
    switch (env) {
      case EnvironmentType.dev:
        appName = "MyApp Dev";
        baseUrl = "https://dev-api.example.com";
        useFirebase = true;
        break;
      case EnvironmentType.stage:
        appName = "MyApp Staging";
        baseUrl = "https://stage-api.example.com";
        useFirebase = true;
        break;
      case EnvironmentType.prod:
        appName = "MyApp";
        baseUrl = "https://api.example.com";
        useFirebase = true;
        break;
    }
  }
}

enum EnvironmentType { dev, stage, prod }