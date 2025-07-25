import UIKit
import Flutter
import NaverThirdPartyLogin  // 추가

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 네이버 로그인을 위한 URL 스키마 처리 추가
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    var applicationResult = false
    if (!applicationResult) {
       applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
    
    if (!applicationResult) {
       applicationResult = super.application(app, open: url, options: options)
    }
    return applicationResult
  }
}
