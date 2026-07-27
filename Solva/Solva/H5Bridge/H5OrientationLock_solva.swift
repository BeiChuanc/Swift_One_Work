//
//  H5OrientationLock_solva.swift
//  Solva
//
//  H5 浏览页面 / 外跳浏览器共用的临时竖屏锁定。
//  设计思路：整个 App 通过 Info.plist 强制横屏，但 H5BrowserScreen_solva 与
//  ExternalBrowserPresenter_solva 展示的都是网页，通常按竖屏体验设计。系统查询
//  「当前允许的界面方向」只有
//  UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:) 这一个
//  全局入口，SwiftUI App 默认没有 AppDelegate，这里用 AppDelegate_solva 补上；
//  H5BrowserPresenter_solva、ExternalBrowserPresenter_solva 展示/关闭页面时分别调用
//  lockPortrait_solva / restoreDefault_solva 切换方向掩码。两者可能叠加展示（H5 页面
//  内点击外跳链接会在其上再弹出一层 Safari），因此用嵌套计数而非布尔值记录锁定状态，
//  避免内层页面先关闭时错误地提前恢复横屏。
//

import UIKit

/// 系统界面方向掩码的集中存储点
enum H5OrientationLock_solva {
    /// App 默认方向：与 Info.plist 里配置的强制横屏保持一致
    static let defaultMask_solva: UIInterfaceOrientationMask = [.landscapeLeft, .landscapeRight]

    /// 当前允许的界面方向，AppDelegate_solva 会读取本值回答系统查询
    private(set) static var currentMask_solva: UIInterfaceOrientationMask = defaultMask_solva

    /// 竖屏锁定的嵌套计数：H5 浏览页面与外跳浏览器可能同时叠加展示，
    /// 用计数而非布尔值记录，避免内层页面先关闭时错误提前恢复横屏
    private static var portraitLockCount_solva = 0

    /// 切到纯竖屏，并尝试立即触发一次系统重新计算方向；支持嵌套调用
    static func lockPortrait_solva() {
        portraitLockCount_solva += 1
        currentMask_solva = .portrait
        requestRotationUpdate_solva()
    }

    /// 与一次 lockPortrait_solva 配对调用；仅当所有嵌套锁定都已释放时才真正恢复 App 默认横屏
    static func restoreDefault_solva() {
        portraitLockCount_solva = max(0, portraitLockCount_solva - 1)
        guard portraitLockCount_solva == 0 else { return }
        currentMask_solva = defaultMask_solva
        requestRotationUpdate_solva()
    }

    /// 方向掩码变化后系统不会自动重新询问，需要主动触发一次
    private static func requestRotationUpdate_solva() {
        guard let windowScene_solva = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            windowScene_solva.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

/// SwiftUI App 默认没有 AppDelegate，这里补一个最小实现专门响应系统方向查询
final class AppDelegate_solva: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        H5OrientationLock_solva.currentMask_solva
    }
}
