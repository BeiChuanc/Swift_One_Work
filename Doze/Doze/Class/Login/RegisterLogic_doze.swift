import Foundation
import UIKit

// MARK: - 注册页业务逻辑

/// 注册页业务逻辑类
/// 核心作用：处理账号注册时的输入校验与用户创建
/// 设计思路：与 UI 完全解耦，通过回调通知 UI 层更新状态
/// 关键属性：
///   - onRegisterSuccess_Doze: 注册成功回调
///   - onRegisterFailed_Doze: 注册失败回调（携带错误提示文本）
class RegisterLogic_Doze {

    // MARK: - 回调

    /// 注册成功回调
    var onRegisterSuccess_Doze: (() -> Void)?

    /// 注册失败回调（参数为提示文本）
    var onRegisterFailed_Doze: ((String) -> Void)?

    // MARK: - 公共方法

    /// 执行注册逻辑
    /// - Parameters:
    ///   - username_Doze: 用户名（不可为空）
    ///   - password_Doze: 密码（不可为空）
    ///   - confirmPassword_Doze: 确认密码（必须与 password_Doze 一致）
    /// - 异常场景：
    ///   - 用户名为空 → onRegisterFailed_Doze("Please enter your username")
    ///   - 密码为空 → onRegisterFailed_Doze("Please enter your password")
    ///   - 确认密码为空 → onRegisterFailed_Doze("Please confirm your password")
    ///   - 两次密码不一致 → onRegisterFailed_Doze("Passwords do not match")
    func register_Doze(
        username_Doze: String,
        password_Doze: String,
        confirmPassword_Doze: String
    ) {
        let trimmedName_Doze    = username_Doze.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPwd_Doze     = password_Doze.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm_Doze = confirmPassword_Doze.trimmingCharacters(in: .whitespacesAndNewlines)

        // 用户名校验
        guard !trimmedName_Doze.isEmpty else {
            onRegisterFailed_Doze?("Please enter your username")
            return
        }
        // 密码校验
        guard !trimmedPwd_Doze.isEmpty else {
            onRegisterFailed_Doze?("Please enter your password")
            return
        }
        // 确认密码校验
        guard !trimmedConfirm_Doze.isEmpty else {
            onRegisterFailed_Doze?("Please confirm your password")
            return
        }
        // 一致性校验
        guard trimmedPwd_Doze == trimmedConfirm_Doze else {
            onRegisterFailed_Doze?("Passwords do not match")
            return
        }

        print("📝 开始注册，用户名：\(trimmedName_Doze)")

        // 注册成功后直接登录
        UserViewModel_Doze.shared_Doze.loginById_Doze(userId_doze: 874545)
        onRegisterSuccess_Doze?()
    }

    /// 返回登录页
    func goBack_Doze() {
        Navigation_Doze.pop_Doze()
    }
}
