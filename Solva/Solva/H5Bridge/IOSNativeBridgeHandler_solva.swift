//
//  IOSNativeBridgeHandler_solva.swift
//  Solva
//
//  iOS Native Bridge 消息模型与处理器。
//  设计思路：H5 通过 window.webkit.messageHandlers.iosNative 发消息，message.body
//  可能是 Dictionary 也可能是 JSON 字符串，这里统一解析后按 item 分发；openByBrowser
//  转交 delegate_solva 处理真正的外跳动作，其余 item 只做兼容识别、不回传业务数据。
//

import Foundation
import WebKit

/// H5 -> iOS 的桥接消息，对应 { item, id, param.url } 结构
struct H5NativeMessage_solva {
    let item_solva: String
    let id_solva: String
    /// param.url 原始字符串，保留 # 之后的 hash，不做任何 URL 重组
    let paramURLString_solva: String?

    /// 从 WKScriptMessage.body 解析；body 既非 Dictionary 也非合法 JSON 字符串，
    /// 或缺少 item 字段时返回 nil
    init?(body_solva: Any) {
        let dict_solva: [String: Any]?
        if let dictionary_solva = body_solva as? [String: Any] {
            dict_solva = dictionary_solva
        } else if let jsonString_solva = body_solva as? String, let data_solva = jsonString_solva.data(using: .utf8) {
            dict_solva = (try? JSONSerialization.jsonObject(with: data_solva, options: [])) as? [String: Any]
        } else {
            dict_solva = nil
        }

        guard let resolvedDict_solva = dict_solva, let item_solva = resolvedDict_solva["item"] as? String else {
            return nil
        }
        self.item_solva = item_solva
        self.id_solva = (resolvedDict_solva["id"] as? String) ?? ""
        self.paramURLString_solva = (resolvedDict_solva["param"] as? [String: Any])?["url"] as? String
    }
}

/// H5 桥接消息的业务动作回调协议
protocol H5BridgeDelegate_solva: AnyObject {
    /// H5 调用 openByBrowser 时触发，urlString_solva 为完整业务 URL（含 hash）
    func h5Bridge_solva(_ handler_solva: IOSNativeBridgeHandler_solva, didRequestOpenByBrowser urlString_solva: String)
}

/// iosNative bridge 的 WKScriptMessageHandler 实现
final class IOSNativeBridgeHandler_solva: NSObject, WKScriptMessageHandler {

    weak var delegate_solva: H5BridgeDelegate_solva?

    /// 接收并按 item 分发 H5 发来的桥接消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == H5BridgeConfig_solva.nativeBridgeHandlerName_solva,
              let nativeMessage_solva = H5NativeMessage_solva(body_solva: message.body) else {
            print("iOS Native Bridge 收到无法解析的消息")
            return
        }

        switch nativeMessage_solva.item_solva {
        case "openByBrowser":
            guard let urlString_solva = nativeMessage_solva.paramURLString_solva, !urlString_solva.isEmpty else {
                print("openByBrowser 缺少 param.url，忽略本次外跳请求")
                return
            }
            print("iosNative openByBrowser called url=\(urlString_solva)")
            delegate_solva?.h5Bridge_solva(self, didRequestOpenByBrowser: urlString_solva)
        case "getNativeAppInfo", "getAppVersion", "setRefresh":
            // 仅用于避免 H5 侦测基础 bridge 能力时抛异常，无需回传业务数据
            break
        default:
            print("iOS Native Bridge 收到未识别的 item：\(nativeMessage_solva.item_solva)")
        }
    }
}
