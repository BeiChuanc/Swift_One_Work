//
//  AirbridgeAttributionDispatcher_solva.swift
//  Solva
//
//  Airbridge 归因结果的标准字段载体与分发器。
//  设计思路：只依赖「已经拿到的原始归因字典」，不直接引用 Airbridge SDK 类型；
//  字段映射依据官方回调字段 attributedChannel/attributedCampaign/.../attributedSubPublisher，
//  取不到的字段统一传空字符串，raw_solva 原样保留完整原始字典兜底，不裁剪。
//

import Foundation
import WebKit

/// airbridgeAttribution CustomEvent 的 detail 载体
struct AirbridgeAttributionPayload_solva {
    let channel_solva: String
    let campaign_solva: String
    let adGroup_solva: String
    let adCreative_solva: String
    let term_solva: String
    let content_solva: String
    let clickId_solva: String
    let deviceId_solva: String
    /// Airbridge 原生 SDK 回调的完整原始归因字典，必须原样保留
    let raw_solva: [String: Any]

    /// 生成可直接传入 evaluateJavaScript 的 dispatchEvent 脚本；序列化失败时返回 nil
    func javaScriptDispatchSnippet_solva() -> String? {
        let detail_solva: [String: Any] = [
            "channel": channel_solva, "campaign": campaign_solva, "adGroup": adGroup_solva,
            "adCreative": adCreative_solva, "term": term_solva, "content": content_solva,
            "clickId": clickId_solva, "deviceId": deviceId_solva, "raw": raw_solva
        ]
        guard JSONSerialization.isValidJSONObject(detail_solva),
              let jsonData_solva = try? JSONSerialization.data(withJSONObject: detail_solva, options: []),
              let jsonString_solva = String(data: jsonData_solva, encoding: .utf8) else {
            return nil
        }
        return "window.dispatchEvent(new CustomEvent('airbridgeAttribution', { detail: \(jsonString_solva) }));"
    }
}

/// 归因结果分发器
final class AirbridgeAttributionDispatcher_solva {

    /// 把 Airbridge 回调的原始归因字典映射成 H5 约定的标准字段
    static func buildPayload_solva(rawAttribution_solva: [String: String]) -> AirbridgeAttributionPayload_solva {
        AirbridgeAttributionPayload_solva(
            channel_solva: rawAttribution_solva["attributedChannel"] ?? "",
            campaign_solva: rawAttribution_solva["attributedCampaign"] ?? "",
            adGroup_solva: rawAttribution_solva["attributedAdGroup"] ?? "",
            adCreative_solva: rawAttribution_solva["attributedAdCreative"] ?? "",
            term_solva: rawAttribution_solva["attributedTerm"] ?? "",
            content_solva: rawAttribution_solva["attributedContent"] ?? "",
            clickId_solva: rawAttribution_solva["attributedSubPublisher"] ?? "",
            deviceId_solva: H5BridgeConfig_solva.deviceIdentifierForVendor_solva,
            raw_solva: rawAttribution_solva.mapValues { $0 as Any }
        )
    }

    /// 通过 airbridgeAttribution CustomEvent 分发给 H5；需在页面加载完成、归因异步返回、
    /// WebView 重建等场景下（重复）调用
    static func dispatch_solva(payload_solva: AirbridgeAttributionPayload_solva, to webView_solva: WKWebView) {
        guard let script_solva = payload_solva.javaScriptDispatchSnippet_solva() else {
            print("归因 Payload 序列化失败，放弃本次分发")
            return
        }
        webView_solva.evaluateJavaScript(script_solva) { _, error_solva in
            if let error_solva {
                print("向 H5 分发 airbridgeAttribution 事件失败：\(error_solva)")
            }
        }
    }
}
