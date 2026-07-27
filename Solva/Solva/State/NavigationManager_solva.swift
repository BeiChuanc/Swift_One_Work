//
//  NavigationManager_solva.swift
//  Solva
//
//  项目内置导航管理器。
//  设计思路：全 App 统一使用本类进行页面跳转，不直接使用系统 NavigationStack/NavigationLink，
//  以便集中控制转场动画与路由栈，并兼容较低系统版本。内部用一个「路由枚举栈」表达当前导航层级，
//  根路由容器（RootRouterView_solva）依据 currentRoute_solva 渲染对应页面。
//  关键属性：routeStack_solva（导航栈，末尾为当前显示页面）
//  关键方法：push_solva / pop_solva / popToRoot_solva（前进/后退/返回首页）
import SwiftUI
import Combine

final class NavigationManager_solva: ObservableObject {

    /// App 内可导航到的全部路由
    enum Route_solva: Equatable {
        case home
        case playing(GameType_solva)
        case records
        case stats
        case achievements
        case howToPlay
    }

    /// 导航栈，栈底固定为 .home
    @Published private(set) var routeStack_solva: [Route_solva] = [.home]

    /// 当前展示的路由（栈顶）
    var currentRoute_solva: Route_solva {
        routeStack_solva.last ?? .home
    }

    /// 前进到新页面
    func push_solva(_ route_solva: Route_solva) {
        withAnimation(.easeInOut(duration: 0.28)) {
            routeStack_solva.append(route_solva)
        }
    }

    /// 返回上一页；若已在首页则不做任何事
    func pop_solva() {
        guard routeStack_solva.count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.24)) {
            // 显式忽略 removeLast() 的返回值：该语句若作为闭包唯一语句会被推断为隐式返回值，
            // 导致 withAnimation 的结果类型变为非 Void 而触发「结果未使用」警告。
            _ = routeStack_solva.removeLast()
        }
    }

    /// 直接返回首页（清空导航栈）
    func popToRoot_solva() {
        withAnimation(.easeInOut(duration: 0.28)) {
            routeStack_solva = [.home]
        }
    }
}
