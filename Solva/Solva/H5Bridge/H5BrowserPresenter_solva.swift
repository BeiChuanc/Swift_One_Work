//
//  H5BrowserPresenter_solva.swift
//  Solva
//
//  以竖屏模态展示 H5BrowserScreen_solva 的统一入口。
//  设计思路：App 整体横屏锁定，H5 页面需要竖屏体验，这里用一个重写了
//  supportedInterfaceOrientations 的 UIHostingController 子类做全屏模态展示；
//  展示前调用 H5OrientationLock_solva.lockPortrait_solva 切到纯竖屏，
//  用户关闭页面后再恢复默认横屏，两者配合才能让系统真正切换界面方向。
//

import SwiftUI
import UIKit

/// 强制竖屏展示的 UIHostingController，仅用于承载 H5BrowserScreen_solva
private final class PortraitHostingController_solva: UIHostingController<H5BrowserScreen_solva> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var shouldAutorotate: Bool { true }
}

/// H5 浏览页面的展示器
enum H5BrowserPresenter_solva {

    /// 以竖屏全屏模态展示 H5 浏览页面；调用方无需关心方向锁定与恢复
    /// - Parameters:
    ///   - urlString_solva: 目标 H5 地址，缺省加载 H5BridgeConfig_solva.entryURLString_solva
    ///   - presenter_solva: 承载模态的宿主视图控制器；传 nil 时自动使用当前最顶层视图控制器
    static func present_solva(urlString_solva: String = H5BridgeConfig_solva.entryURLString_solva, from presenter_solva: UIViewController? = nil) {
        guard let hostController_solva = presenter_solva ?? UIApplication.shared.topMostViewController_solva else {
            print("未找到可用于展示 H5 浏览页面的宿主视图控制器")
            return
        }

        H5OrientationLock_solva.lockPortrait_solva()

        var portraitController_solva: UIHostingController<H5BrowserScreen_solva>?
        let content_solva = H5BrowserScreen_solva(urlString_solva: urlString_solva) {
            portraitController_solva?.dismiss(animated: true) {
                H5OrientationLock_solva.restoreDefault_solva()
            }
        }
        let controller_solva = PortraitHostingController_solva(rootView: content_solva)
        portraitController_solva = controller_solva
        controller_solva.modalPresentationStyle = .fullScreen
        hostController_solva.present(controller_solva, animated: true)
    }
}
