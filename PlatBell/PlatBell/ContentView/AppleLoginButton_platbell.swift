import SwiftUI
import AuthenticationServices

// MARK: - Apple 登录按钮组件

/// Apple 登录按钮
struct AppleLoginButton_platbell: View {
    
    /// 成功回调
    let onSuccess_platbell: (String) -> Void
    
    /// 失败回调
    let onFailure_platbell: (String) -> Void
    
    var body: some View {
        Button {
            // 触发 Apple 登录流程
            performAppleLogin_platbell()
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
    private func performAppleLogin_platbell() {
        // 触觉反馈
        handleButtonTap_platbell()
        
        // 创建 Apple ID 授权请求
        let request_platbell = ASAuthorizationAppleIDProvider().createRequest()
        request_platbell.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let controller_platbell = ASAuthorizationController(authorizationRequests: [request_platbell])
        
        // 创建代理对象
        let delegate_platbell = AppleLoginDelegate_platbell(
            onSuccess: onSuccess_platbell,
            onFailure: onFailure_platbell,
            handleResult: handleResult_platbell
        )
        
        // 设置代理
        controller_platbell.delegate = delegate_platbell
        
        // 执行授权请求
        controller_platbell.performRequests()
        
        // 保持代理对象在内存中
        objc_setAssociatedObject(controller_platbell, "delegate", delegate_platbell, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: - 点击事件处理
    
    /// 处理按钮点击
    private func handleButtonTap_platbell() {
        // 触觉反馈
        let generator_platbell = UIImpactFeedbackGenerator(style: .medium)
        generator_platbell.impactOccurred()
        
        print("🔵 Apple登录按钮被点击")
    }
    
    // MARK: - 处理结果
    
    /// 处理登录结果
    /// - Parameter result_platbell: 授权结果
    private func handleResult_platbell(_ result_platbell: Result<ASAuthorization, Error>) {
        switch result_platbell {
        case .success(let authorization_platbell):
            handleSuccess_platbell(authorization_platbell)
            
        case .failure(let error_platbell):
            handleFailure_platbell(error_platbell)
        }
    }
    
    /// 处理成功结果
    /// - Parameter authorization_platbell: 授权对象
    private func handleSuccess_platbell(_ authorization_platbell: ASAuthorization) {
        switch authorization_platbell.credential {
            
        case let appleIDCredential_platbell as ASAuthorizationAppleIDCredential:
            // 获取邮箱
            let email_platbell = appleIDCredential_platbell.email
            
            // 生成用户账号
            var userAcc_platbell = ""
            if email_platbell == nil || email_platbell == "" {
                userAcc_platbell = "appleId_\(appleIDCredential_platbell.user)"
            } else {
                userAcc_platbell = email_platbell ?? ""
            }
            
            print("✅ Apple登录成功，用户账号：\(userAcc_platbell)")
            
            // 调用成功回调
            onSuccess_platbell(userAcc_platbell)
            
        case let userCredential_platbell as ASPasswordCredential:
            // 密码凭证
            let user_platbell = userCredential_platbell.user
            _ = userCredential_platbell.password
            
            print("✅ 密码凭证登录成功，用户：\(user_platbell)")
            
            // 调用成功回调
            onSuccess_platbell(user_platbell)
            
        default:
            print("❌ 未知授权类型")
            onFailure_platbell("Unknown authorization type")
        }
    }
    
    /// 处理失败结果
    private func handleFailure_platbell(_ error_platbell: Error) {
        if let authError_platbell = error_platbell as? ASAuthorizationError {
            
            var errorMessage_platbell = ""
            
            switch authError_platbell.code {
            case .unknown:
                errorMessage_platbell = "Unknown error"
                print("❌ 授权未知错误")
            case .canceled:
                errorMessage_platbell = "Authorization canceled"
                print("⚠️ 授权取消")
            case .invalidResponse:
                errorMessage_platbell = "Invalid response"
                print("❌ 授权无效请求")
            case .notHandled:
                errorMessage_platbell = "Not handled"
                print("❌ 授权未能处理")
            case .failed:
                errorMessage_platbell = "Authorization failed"
                print("❌ 授权失败")
            case .notInteractive:
                errorMessage_platbell = "Not interactive"
                print("❌ 授权非交互式")
            case .matchedExcludedCredential:
                errorMessage_platbell = "Matched excluded credential"
                print("❌ 该凭证属于被排除的范围")
            case .credentialImport:
                errorMessage_platbell = "Credential import"
                print("❌ 凭证导入")
            case .credentialExport:
                errorMessage_platbell = "Credential export"
                print("❌ 凭证导出")
            case .preferSignInWithApple:
                errorMessage_platbell = "Prefer sign in with Apple"
                print("❌ 偏好使用Apple登录")
            case .deviceNotConfiguredForPasskeyCreation:
                errorMessage_platbell = "Device not configured for Passkey creation"
                print("❌ 设备未配置用于创建Passkey")
            @unknown default:
                errorMessage_platbell = "Unknown error"
                print("❌ 授权其他原因")
            }
            
            // 调用失败回调
            onFailure_platbell(errorMessage_platbell)
        }
    }
}

// MARK: - Apple 登录代理

/// Apple 登录授权代理
class AppleLoginDelegate_platbell: NSObject, ASAuthorizationControllerDelegate {
    
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
