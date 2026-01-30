import SwiftUI
import AuthenticationServices

// MARK: - Apple 登录按钮组件

/// Apple 登录按钮
struct AppleLoginButton_baseswiftui: View {
    
    /// 成功回调
    let onSuccess_baseswiftui: (String) -> Void
    
    /// 失败回调
    let onFailure_baseswiftui: (String) -> Void
    
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request_baseswiftui in
                // 配置请求
                request_baseswiftui.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result_baseswiftui in
                handleResult_baseswiftui(result_baseswiftui)
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(12)
    }
    
    // MARK: - 处理结果
    
    /// 处理登录结果
    /// - Parameter result_baseswiftui: 授权结果
    private func handleResult_baseswiftui(_ result_baseswiftui: Result<ASAuthorization, Error>) {
        switch result_baseswiftui {
        case .success(let authorization_baseswiftui):
            handleSuccess_baseswiftui(authorization_baseswiftui)
            
        case .failure(let error_baseswiftui):
            handleFailure_baseswiftui(error_baseswiftui)
        }
    }
    
    /// 处理成功结果
    /// - Parameter authorization_baseswiftui: 授权对象
    private func handleSuccess_baseswiftui(_ authorization_baseswiftui: ASAuthorization) {
        switch authorization_baseswiftui.credential {
            
        case let appleIDCredential_baseswiftui as ASAuthorizationAppleIDCredential:
            // 获取邮箱
            let email_baseswiftui = appleIDCredential_baseswiftui.email
            
            // 生成用户账号
            var userAcc_baseswiftui = ""
            if email_baseswiftui == nil || email_baseswiftui == "" {
                userAcc_baseswiftui = "appleId_\(appleIDCredential_baseswiftui.user)"
            } else {
                userAcc_baseswiftui = email_baseswiftui ?? ""
            }
            
            print("✅ Apple登录成功，用户账号：\(userAcc_baseswiftui)")
            
            // 调用成功回调
            onSuccess_baseswiftui(userAcc_baseswiftui)
            
        case let userCredential_baseswiftui as ASPasswordCredential:
            // 密码凭证
            let user_baseswiftui = userCredential_baseswiftui.user
            _ = userCredential_baseswiftui.password
            
            print("✅ 密码凭证登录成功，用户：\(user_baseswiftui)")
            
            // 调用成功回调
            onSuccess_baseswiftui(user_baseswiftui)
            
        default:
            print("❌ 未知授权类型")
            onFailure_baseswiftui("Unknown authorization type")
        }
    }
    
    /// 处理失败结果
    private func handleFailure_baseswiftui(_ error_baseswiftui: Error) {
        if let authError_baseswiftui = error_baseswiftui as? ASAuthorizationError {
            
            var errorMessage_baseswiftui = ""
            
            switch authError_baseswiftui.code {
            case .unknown:
                errorMessage_baseswiftui = "Unknown error"
                print("❌ 授权未知错误")
            case .canceled:
                errorMessage_baseswiftui = "Authorization canceled"
                print("⚠️ 授权取消")
            case .invalidResponse:
                errorMessage_baseswiftui = "Invalid response"
                print("❌ 授权无效请求")
            case .notHandled:
                errorMessage_baseswiftui = "Not handled"
                print("❌ 授权未能处理")
            case .failed:
                errorMessage_baseswiftui = "Authorization failed"
                print("❌ 授权失败")
            case .notInteractive:
                errorMessage_baseswiftui = "Not interactive"
                print("❌ 授权非交互式")
            case .matchedExcludedCredential:
                errorMessage_baseswiftui = "Matched excluded credential"
                print("❌ 该凭证属于被排除的范围")
            case .credentialImport:
                errorMessage_baseswiftui = "Credential import"
                print("❌ 凭证导入")
            case .credentialExport:
                errorMessage_baseswiftui = "Credential export"
                print("❌ 凭证导出")
            case .preferSignInWithApple:
                errorMessage_baseswiftui = "Prefer sign in with Apple"
                print("❌ 偏好使用Apple登录")
            case .deviceNotConfiguredForPasskeyCreation:
                errorMessage_baseswiftui = "Device not configured for Passkey creation"
                print("❌ 设备未配置用于创建Passkey")
            @unknown default:
                errorMessage_baseswiftui = "Unknown error"
                print("❌ 授权其他原因")
            }
            
            // 调用失败回调
            onFailure_baseswiftui(errorMessage_baseswiftui)
        }
    }
}

// MARK: - 自定义 Apple 登录按钮（可选）

/// 自定义样式的 Apple 登录按钮
struct CustomAppleLoginButton_baseswiftui: View {
    
    /// 成功回调
    let onSuccess_baseswiftui: (String) -> Void
    
    /// 失败回调
    let onFailure_baseswiftui: (String) -> Void
    
    @State private var isPressed_baseswiftui: Bool = false
    
    var body: some View {
        Button(action: {
            // 使用系统的 Apple 登录按钮
        }) {
            HStack(spacing: 12) {
                Image(systemName: "apple.logo")
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text("Continue with Apple")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(12)
            .scaleEffect(isPressed_baseswiftui ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed_baseswiftui)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed_baseswiftui = true
                }
                .onEnded { _ in
                    isPressed_baseswiftui = false
                }
        )
        .overlay(
            // 使用透明的 SignInWithAppleButton 覆盖
            AppleLoginButton_baseswiftui(
                onSuccess_baseswiftui: onSuccess_baseswiftui,
                onFailure_baseswiftui: onFailure_baseswiftui
            )
            .opacity(0.001)
            .allowsHitTesting(true)
        )
    }
}
