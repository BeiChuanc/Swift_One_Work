//
//  H5BridgeConfig_solva.swift
//  Solva
//
//  H5Bridge 模块的集中配置文件。
//  设计思路：把「H5 环境标识、可信域名白名单、Airbridge 密钥、设备/版本信息取值」等
//  与具体上线账号绑定、且大概率因马甲包不同而不同的可变项集中到一处，
//  其余桥接/归因逻辑代码保持不变，不同马甲包上线时只需替换本文件里的常量即可。
//

import Foundation
import WebKit
import UIKit

/// H5Bridge 模块全局配置
enum H5BridgeConfig_solva {

    // MARK: 桥接协议

    /// iOS Native Bridge 在 WKUserContentController 中注册的 messageHandler 名称，
    /// 必须与 H5 侧探测的 window.webkit.messageHandlers.iosNative 保持一致，不能随意改名
    static let nativeBridgeHandlerName_solva = "iosNative"

    // MARK: App 环境标识

    /// App 展示名，用于 UA 追加标识与 __MEGASBASE_NATIVE_INFO__.appName
    static let appName_solva = "MegasBase"

    /// H5 约定的固定客户端类型，文档中明确写死为 w2a，不随环境变化
    static let clientType_solva = "w2a"

    // MARK: 域名与入口

    /// 允许直接在主 WKWebView 内加载的可信 H5 域名（host 完全匹配）
    // 配置1：上线前替换为真实 H5 域名
    static let trustedHosts_solva: Set<String> = ["https://www.megasbase.com"]

    /// H5 主入口地址
    // 配置2：上线前替换为真实 H5 地址
    static let entryURLString_solva = "https://www.megasbase.com"

    // MARK: Airbridge 密钥

    /// Airbridge 后台配置的 App 名称，App 原生 SDK 与 H5 Web SDK 必须使用同一个 Airbridge 后台应用
    // 配置3：上线前替换为真实 Airbridge App Name
    static let airbridgeAppName_solva = "mb002"

    /// Airbridge App SDK Token，仅用于原生 SDK 初始化，不能和 Web SDK Token 混用
    // 配置4：上线前替换为真实 Airbridge App SDK Token
    static let airbridgeAppSDKToken_solva = "49c9677d6e0f4780a74793eb4e0ec740"

    /// Airbridge Web SDK Token，仅用于 Airbridge.setWebInterface，不能和 App SDK Token 混用
    // 配置5：上线前替换为真实 Airbridge Web SDK Token - 不需要
//    static let airbridgeWebSDKToken_solva = "YOUR_WEB_SDK_TOKEN"

    // MARK: App / 设备信息取值

    /// App 版本号，取自 Bundle 的 CFBundleShortVersionString，取不到时兜底 1.0.0
    static var appVersion_solva: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    /// 构建号，取自 Bundle 的 CFBundleVersion
    static var buildNumber_solva: String {
        (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }

    /// iOS Bundle ID
    static var bundleId_solva: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    /// 手机系统版本号（注意：这是设备系统版本，不是 App 版本）
    static var deviceOsVersion_solva: String {
        UIDevice.current.systemVersion
    }

    /// 机型标识
    static var deviceModel_solva: String {
        UIDevice.current.model
    }

    /// IDFV（Vendor 标识），在用户未授权 ATT 时作为 deviceId 的兜底取值
    static var deviceIdentifierForVendor_solva: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }

    // MARK: UA / 环境注入脚本

    /// 追加到 UA 末尾的 App 标识；赋值给 WKWebViewConfiguration.applicationNameForUserAgent 后，
    /// WKWebView 会自动把它拼接在系统默认 UA 之后，不影响系统默认 UA 前半部分
    static var userAgentSuffix_solva: String {
        "\(appName_solva)/\(appVersion_solva)"
    }

    /// 注入到 window.__MEGASBASE_NATIVE_INFO__ 的原生环境信息脚本
    /// 必须在文档加载最早阶段（.atDocumentStart）注入，保证 H5 首次读取时就能拿到数据
    static var nativeInfoUserScript_solva: WKUserScript {
        let info_solva: [String: Any] = [
            "platform": "ios",
            "os": "ios",
            "appName": appName_solva,
            "appVersion": appVersion_solva,
            "version": appVersion_solva,
            "clientVersion": appVersion_solva,
            "clientType": clientType_solva,
            "nativeClientType": "app",
            "containerType": "app",
            "deviceType": "ios",
            "deviceOsVersion": deviceOsVersion_solva,
            "osVersion": deviceOsVersion_solva,
            "bundleId": bundleId_solva,
            "packageName": bundleId_solva,
            "buildNumber": buildNumber_solva,
            "versionCode": buildNumber_solva,
            "model": deviceModel_solva,
            "nativeChannel": "",
            "appChannel": "",
            "isNativeApp": true,
            "safeAreaTop": 0,
            "safeAreaBottom": 0
        ]
        let jsonData_solva = (try? JSONSerialization.data(withJSONObject: info_solva, options: [])) ?? Data()
        let jsonString_solva = String(data: jsonData_solva, encoding: .utf8) ?? "{}"
        let source_solva = "window.__MEGASBASE_NATIVE_INFO__ = \(jsonString_solva);"
        return WKUserScript(source: source_solva, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    }
}
