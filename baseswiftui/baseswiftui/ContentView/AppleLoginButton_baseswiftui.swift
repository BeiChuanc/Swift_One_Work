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
        Button {
            // 触发 Apple 登录流程
            performAppleLogin_baseswiftui()
        } label: {
            HStack(spacing: 12) {
                // 苹果图标（调大）
                Image("apple")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                // 登录文本（小一号）
                Text("Sign in with Apple")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Apple 登录流程
    
    /// 执行 Apple 登录
    private func performAppleLogin_baseswiftui() {
        // 触觉反馈
        handleButtonTap_baseswiftui()
        
        // 创建 Apple ID 授权请求
        let request_baseswiftui = ASAuthorizationAppleIDProvider().createRequest()
        request_baseswiftui.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let controller_baseswiftui = ASAuthorizationController(authorizationRequests: [request_baseswiftui])
        
        // 创建代理对象
        let delegate_baseswiftui = AppleLoginDelegate_baseswiftui(
            onSuccess: onSuccess_baseswiftui,
            onFailure: onFailure_baseswiftui,
            handleResult: handleResult_baseswiftui
        )
        
        // 设置代理
        controller_baseswiftui.delegate = delegate_baseswiftui
        
        // 执行授权请求
        controller_baseswiftui.performRequests()
        
        // 保持代理对象在内存中
        objc_setAssociatedObject(controller_baseswiftui, "delegate", delegate_baseswiftui, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: - 点击事件处理
    
    /// 处理按钮点击
    private func handleButtonTap_baseswiftui() {
        // 触觉反馈
        let generator_baseswiftui = UIImpactFeedbackGenerator(style: .medium)
        generator_baseswiftui.impactOccurred()
        
        print("🔵 Apple登录按钮被点击")
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

// MARK: - Apple 登录代理

/// Apple 登录授权代理
class AppleLoginDelegate_baseswiftui: NSObject, ASAuthorizationControllerDelegate {
    
    /// 成功回调
    let onSuccess: (String) -> Void
    
    /// 失败回调
    let onFailure: (String) -> Void
    
    /// 结果处理方法
    let handleResult: (Result<ASAuthorization, Error>) -> Void
    
    /// 初始化
    init(onSuccess: @escaping (String) -> Void,
         onFailure: @escaping (String) -> Void,
         handleResult: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.handleResult = handleResult
    }
    
    /// 授权成功
    func authorizationController(controller: ASAuthorizationController,
                                didCompleteWithAuthorization authorization: ASAuthorization) {
        handleResult(.success(authorization))
    }
    
    /// 授权失败
    func authorizationController(controller: ASAuthorizationController,
                                didCompleteWithError error: Error) {
        handleResult(.failure(error))
    }
}
