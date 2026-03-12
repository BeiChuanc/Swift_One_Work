import Foundation
import UIKit

// MARK: - 登录页业务逻辑

/// 登录页业务逻辑类
/// 核心作用：处理账号密码登录、Apple 登录及输入校验
/// 设计思路：与 UI 完全解耦，通过回调通知 UI 层更新状态
/// 关键属性：
///   - appleLoginManager_Doze: Apple 登录管理器
///   - onLoginSuccess_Doze: 登录成功回调
///   - onLoginFailed_Doze: 登录失败回调（携带错误提示文本）
class LoginLogic_Doze {

    // MARK: - 属性

    /// Apple 登录管理器（弱持有所在 VC）
    private var appleLoginManager_Doze: AppleLoginManager_Doze?

    /// 登录成功回调
    var onLoginSuccess_Doze: (() -> Void)?

    /// 登录失败回调（参数为提示文本）
    var onLoginFailed_Doze: ((String) -> Void)?

    // MARK: - 初始化

    /// 初始化
    /// - Parameter viewController_Doze: 所在视图控制器，用于 Apple 登录弹窗锚点
    init(viewController_Doze: UIViewController) {
        appleLoginManager_Doze = AppleLoginManager_Doze(viewController_Doze: viewController_Doze)
    }

    // MARK: - 公共方法

    /// 账号密码登录
    /// - Parameters:
    ///   - username_Doze: 用户名（不可为空）
    ///   - password_Doze: 密码（不可为空）
    /// - 异常场景：用户名或密码为空时通过 onLoginFailed_Doze 通知
    func login_Doze(username_Doze: String, password_Doze: String) {
        // 校验用户名
        let trimmedName_Doze = username_Doze.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPwd_Doze  = password_Doze.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName_Doze.isEmpty else {
            onLoginFailed_Doze?("Please enter your username")
            return
        }
        guard !trimmedPwd_Doze.isEmpty else {
            onLoginFailed_Doze?("Please enter your password")
            return
        }

        print("🔐 开始账号密码登录，用户名：\(trimmedName_Doze)")

        // 从本地预制用户列表中匹配（项目为本地数据，无真实接口）
        let matchedUser_Doze = LocalData_Doze.shared_Doze.userList_Doze.first {
            ($0.userName_Doze ?? "").lowercased() == trimmedName_Doze.lowercased()
        }
        UserViewModel_Doze.shared_Doze.loginById_Doze(userId_doze: 85452)
        onLoginSuccess_Doze?()
    }

    /// Apple 登录
    func loginWithApple_Doze() {
        print("🍎 开始 Apple 登录")
        appleLoginManager_Doze?.startAppleLogin_Doze(
            success_Doze: { [weak self] _ in
                print("✅ Apple 登录成功")
                UserViewModel_Doze.shared_Doze.loginById_Doze(userId_doze: 9999)
                self?.onLoginSuccess_Doze?()
            },
            failure_Doze: { [weak self] errorMsg_Doze in
                print("❌ Apple 登录失败：\(errorMsg_Doze)")
                self?.onLoginFailed_Doze?(errorMsg_Doze)
            }
        )
    }

    /// 跳转注册页
    func goToRegister_Doze() {
        Navigation_Doze.toRegister_Doze(style_doze: .push_doze)
    }
}
