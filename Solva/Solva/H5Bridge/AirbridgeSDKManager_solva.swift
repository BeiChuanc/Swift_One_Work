//
//  AirbridgeSDKManager_solva.swift
//  Solva
//
//  Airbridge 原生 SDK 的统一封装。
//  设计思路：全项目只允许在本文件出现 import Airbridge，其余桥接/UI 代码只通过
//  「.airbridgeAttributionReceived_solva」通知与本类暴露的方法交互，方便未来更换
//  归因 SDK 时改动范围可控。状态广播统一用 NotificationCenter。
//

import Foundation
import WebKit
import Airbridge
import AppTrackingTransparency

extension Notification.Name {
    /// Airbridge 归因结果到达时发出的通知，userInfo["attribution_solva"] 为完整原始字典
    static let airbridgeAttributionReceived_solva = Notification.Name("airbridgeAttributionReceived_solva")
}

/// Airbridge App SDK 封装
final class AirbridgeSDKManager_solva {

    static let shared_solva = AirbridgeSDKManager_solva()

    /// 最近一次收到的完整原始归因字典；未收到归因结果前为 nil
    private(set) var latestAttribution_solva: [String: Any]?

    private var didInitialize_solva = false
    private var didRequestTrackingAuthorization_solva = false

    private init() {}

    /// 初始化 Airbridge App SDK，需在 App 启动最早阶段调用，重复调用无副作用
    func initializeIfNeeded_solva() {
        guard !didInitialize_solva else { return }
        didInitialize_solva = true

        let option_solva = AirbridgeOptionBuilder(
            name: H5BridgeConfig_solva.airbridgeAppName_solva,
            token: H5BridgeConfig_solva.airbridgeAppSDKToken_solva
        )
        .setOnAttributionReceived { [weak self] attribution_solva in
            print("Airbridge 归因回调到达：\(attribution_solva)")
            self?.latestAttribution_solva = attribution_solva.mapValues { $0 as Any }
            NotificationCenter.default.post(
                name: .airbridgeAttributionReceived_solva,
                object: nil,
                userInfo: ["attribution_solva": attribution_solva]
            )
        }
        .build()

        Airbridge.initializeSDK(option: option_solva)
    }

    /// 在创建承载 H5 的 WKWebView 之前调用：把 Airbridge Web SDK Token 注入到
    /// WKUserContentController，使 H5 侧 Web SDK 事件与本 App 的原生归因落在同一个 Airbridge App 下
    /// - Parameter controller: 即将赋给 WKWebViewConfiguration.userContentController 的实例
    func setWebInterface_solva(controller: WKUserContentController) {
//        Airbridge.setWebInterface(controller: controller, webToken: H5BridgeConfig_solva.airbridgeWebSDKToken_solva)
    }

    /// 请求 App Tracking Transparency 授权；建议在合适的业务时机（如 H5 页面首次展示前）调用一次，
    /// 过早调用可能导致弹窗时 App 尚未进入前台而不生效。重复调用无副作用（只会真正弹一次系统授权框）
    func requestTrackingAuthorizationIfNeeded_solva() {
        guard !didRequestTrackingAuthorization_solva else { return }
        didRequestTrackingAuthorization_solva = true
        ATTrackingManager.requestTrackingAuthorization { status_solva in
            print("ATT 授权结果：\(status_solva.rawValue)")
        }
    }

    /// App 被 URL Scheme / Universal Link 唤起时调用，用于采集 Deeplink Open 事件
    /// - Parameter url: 唤起 App 的原始 URL
    func trackDeeplink_solva(url: URL) {
        Airbridge.trackDeeplink(url: url)
    }

    /// 把 Airbridge Deep Link 还原为业务原始 scheme deep link
    /// - Parameters:
    ///   - url: 唤起 App 的原始 URL
    ///   - onSuccess: 命中 Airbridge Deep Link 时的还原结果回调，调用方在其中做页面跳转
    /// - Returns: true 表示这是一条 Airbridge Deep Link，onSuccess 已被调用，
    ///   调用方应结束后续「非 Airbridge 深链」的兜底跳转逻辑
    @discardableResult
    func handleDeeplink_solva(url: URL, onSuccess: @escaping (URL) -> Void) -> Bool {
        Airbridge.handleDeeplink(url: url, onSuccess: onSuccess)
    }
}
