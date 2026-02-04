import SwiftUI
import AuthenticationServices

// MARK: - Apple 登录按钮组件

/// Apple 登录按钮
struct AppleLoginButton_lite: View {
    
    /// 成功回调
    let onSuccess_lite: (String) -> Void
    
    /// 失败回调
    let onFailure_lite: (String) -> Void
    
    var body: some View {
        Button {
            // 触发 Apple 登录流程
            performAppleLogin_lite()
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
    private func performAppleLogin_lite() {
        // 触觉反馈
        handleButtonTap_lite()
        
        // 创建 Apple ID 授权请求
        let request_lite = ASAuthorizationAppleIDProvider().createRequest()
        request_lite.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let controller_lite = ASAuthorizationController(authorizationRequests: [request_lite])
        
        // 创建代理对象
        let delegate_lite = AppleLoginDelegate_lite(
            onSuccess: onSuccess_lite,
            onFailure: onFailure_lite,
            handleResult: handleResult_lite
        )
        
        // 设置代理
        controller_lite.delegate = delegate_lite
        
        // 执行授权请求
        controller_lite.performRequests()
        
        // 保持代理对象在内存中
        objc_setAssociatedObject(controller_lite, "delegate", delegate_lite, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: - 点击事件处理
    
    /// 处理按钮点击
    private func handleButtonTap_lite() {
        // 触觉反馈
        let generator_lite = UIImpactFeedbackGenerator(style: .medium)
        generator_lite.impactOccurred()
        
        print("🔵 Apple登录按钮被点击")
    }
    
    // MARK: - 处理结果
    
    /// 处理登录结果
    /// - Parameter result_lite: 授权结果
    private func handleResult_lite(_ result_lite: Result<ASAuthorization, Error>) {
        switch result_lite {
        case .success(let authorization_lite):
            handleSuccess_lite(authorization_lite)
            
        case .failure(let error_lite):
            handleFailure_lite(error_lite)
        }
    }
    
    /// 处理成功结果
    /// - Parameter authorization_lite: 授权对象
    private func handleSuccess_lite(_ authorization_lite: ASAuthorization) {
        switch authorization_lite.credential {
            
        case let appleIDCredential_lite as ASAuthorizationAppleIDCredential:
            // 获取邮箱
            let email_lite = appleIDCredential_lite.email
            
            // 生成用户账号
            var userAcc_lite = ""
            if email_lite == nil || email_lite == "" {
                userAcc_lite = "appleId_\(appleIDCredential_lite.user)"
            } else {
                userAcc_lite = email_lite ?? ""
            }
            
            print("✅ Apple登录成功，用户账号：\(userAcc_lite)")
            
            // 调用成功回调
            onSuccess_lite(userAcc_lite)
            
        case let userCredential_lite as ASPasswordCredential:
            // 密码凭证
            let user_lite = userCredential_lite.user
            _ = userCredential_lite.password
            
            print("✅ 密码凭证登录成功，用户：\(user_lite)")
            
            // 调用成功回调
            onSuccess_lite(user_lite)
            
        default:
            print("❌ 未知授权类型")
            onFailure_lite("Unknown authorization type")
        }
    }
    
    /// 处理失败结果
    private func handleFailure_lite(_ error_lite: Error) {
        if let authError_lite = error_lite as? ASAuthorizationError {
            
            var errorMessage_lite = ""
            
            switch authError_lite.code {
            case .unknown:
                errorMessage_lite = "Unknown error"
                print("❌ 授权未知错误")
            case .canceled:
                errorMessage_lite = "Authorization canceled"
                print("⚠️ 授权取消")
            case .invalidResponse:
                errorMessage_lite = "Invalid response"
                print("❌ 授权无效请求")
            case .notHandled:
                errorMessage_lite = "Not handled"
                print("❌ 授权未能处理")
            case .failed:
                errorMessage_lite = "Authorization failed"
                print("❌ 授权失败")
            case .notInteractive:
                errorMessage_lite = "Not interactive"
                print("❌ 授权非交互式")
            case .matchedExcludedCredential:
                errorMessage_lite = "Matched excluded credential"
                print("❌ 该凭证属于被排除的范围")
            case .credentialImport:
                errorMessage_lite = "Credential import"
                print("❌ 凭证导入")
            case .credentialExport:
                errorMessage_lite = "Credential export"
                print("❌ 凭证导出")
            case .preferSignInWithApple:
                errorMessage_lite = "Prefer sign in with Apple"
                print("❌ 偏好使用Apple登录")
            case .deviceNotConfiguredForPasskeyCreation:
                errorMessage_lite = "Device not configured for Passkey creation"
                print("❌ 设备未配置用于创建Passkey")
            @unknown default:
                errorMessage_lite = "Unknown error"
                print("❌ 授权其他原因")
            }
            
            // 调用失败回调
            onFailure_lite(errorMessage_lite)
        }
    }
}

// MARK: - Apple 登录代理

/// Apple 登录授权代理
class AppleLoginDelegate_lite: NSObject, ASAuthorizationControllerDelegate {
    
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
