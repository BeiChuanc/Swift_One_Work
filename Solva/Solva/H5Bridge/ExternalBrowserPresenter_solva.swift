//
//  ExternalBrowserPresenter_solva.swift
//  Solva
//
//  外跳浏览器 / 外部 scheme 打开器。
//  设计思路：对应文档第 3 章「openByBrowser 实现」。http/https 用 SFSafariViewController
//  独立模态展示（不占用主 WKWebView，可点 Done 返回 App）；钱包、银行 App、电话、
//  短信等其它 scheme 交给 UIApplication.shared.open 处理。
//  App 整体通过 Info.plist 强制横屏，但外跳网页与 H5BrowserScreen_solva 一样需要竖屏
//  体验：展示前调用 H5OrientationLock_solva.lockPortrait_solva 切到纯竖屏，并用
//  PortraitSafariViewController_solva 重写 supportedInterfaceOrientations 让系统真正
//  转向竖屏；用户点击 Done 关闭后再调用 restoreDefault_solva 恢复 App 默认横屏。
//

import Foundation
import SafariServices
import UIKit

/// 强制竖屏展示的 SFSafariViewController，仅用于承载外跳 http/https 网页
private final class PortraitSafariViewController_solva: SFSafariViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var shouldAutorotate: Bool { true }
}

/// 外跳浏览器展示器
final class ExternalBrowserPresenter_solva: NSObject, SFSafariViewControllerDelegate {

    static let shared_solva = ExternalBrowserPresenter_solva()

    private weak var presentedSafari_solva: SFSafariViewController?

    private override init() {}

    /// 打开外跳地址，自动区分 http/https 与其它外部 scheme
    /// - Parameters:
    ///   - urlString_solva: H5 传入的完整业务 URL，需保留 # 之后的 hash
    ///   - presenter_solva: 用于承载 SFSafariViewController 的宿主视图控制器；
    ///     传 nil 时自动使用当前可见层级最顶层的视图控制器
    func present_solva(urlString: String, from presenter_solva: UIViewController?) {
        guard let url_solva = URL(string: urlString) else {
            print("外跳地址无法解析为 URL：\(urlString)")
            return
        }

        let scheme_solva = url_solva.scheme?.lowercased()
        if scheme_solva == "http" || scheme_solva == "https" {
            presentInSafari_solva(url_solva: url_solva, from: presenter_solva)
        } else {
            openExternalScheme_solva(url_solva: url_solva)
        }
    }

    /// 用 SFSafariViewController 以独立模态展示 http/https 地址；展示前锁定竖屏
    private func presentInSafari_solva(url_solva: URL, from presenter_solva: UIViewController?) {
        guard let hostController_solva = presenter_solva ?? UIApplication.shared.topMostViewController_solva else {
            print("未找到可用于展示外跳浏览器的宿主视图控制器，本次外跳已取消")
            return
        }

        H5OrientationLock_solva.lockPortrait_solva()

        let safari_solva = PortraitSafariViewController_solva(url: url_solva)
        safari_solva.modalPresentationStyle = .fullScreen
        safari_solva.delegate = self
        presentedSafari_solva = safari_solva
        hostController_solva.present(safari_solva, animated: true)
    }

    /// 钱包、银行 App、电话、短信等外部 scheme 交给系统处理
    /// 注意：自定义 scheme 若要让 canOpenURL 生效，需要在 Info.plist 的
    /// LSApplicationQueriesSchemes 中声明该 scheme
    private func openExternalScheme_solva(url_solva: URL) {
        guard UIApplication.shared.canOpenURL(url_solva) else {
            print("系统未安装可处理该 scheme 的 App，或未在 LSApplicationQueriesSchemes 中声明：\(url_solva)")
            return
        }
        UIApplication.shared.open(url_solva, options: [:]) { success_solva in
            print(success_solva ? "已跳转外部 scheme：\(url_solva)" : "跳转外部 scheme 失败：\(url_solva)")
        }
    }

    /// 用户点击 SFSafariViewController 左上角 Done，回到主 App，并恢复 App 默认横屏
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
            H5OrientationLock_solva.restoreDefault_solva()
        }
    }
}

extension UIApplication {
    /// 当前可见层级中最顶层的视图控制器，用于承载外跳浏览器等模态展示
    var topMostViewController_solva: UIViewController? {
        let keyWindow_solva = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        var top_solva = keyWindow_solva?.rootViewController
        while let presented_solva = top_solva?.presentedViewController {
            top_solva = presented_solva
        }
        return top_solva
    }
}
