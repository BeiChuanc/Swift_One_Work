import SwiftUI
import AuthenticationServices

// MARK: - Apple 登录按钮组件

/// Apple 登录按钮
struct AppleLoginButton_blisslink: View {
    
    /// 成功回调
    let onSuccess_blisslink: (String) -> Void
    
    /// 失败回调
    let onFailure_blisslink: (String) -> Void
    
    var body: some View {
        Button {
            // 触发 Apple 登录流程
            performAppleLogin_blisslink()
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
    private func performAppleLogin_blisslink() {
        // 触觉反馈
        handleButtonTap_blisslink()
        
        // 创建 Apple ID 授权请求
        let request_blisslink = ASAuthorizationAppleIDProvider().createRequest()
        request_blisslink.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let controller_blisslink = ASAuthorizationController(authorizationRequests: [request_blisslink])
        
        // 创建代理对象
        let delegate_blisslink = AppleLoginDelegate_blisslink(
            onSuccess: onSuccess_blisslink,
            onFailure: onFailure_blisslink,
            handleResult: handleResult_blisslink
        )
        
        // 设置代理
        controller_blisslink.delegate = delegate_blisslink
        
        // 执行授权请求
        controller_blisslink.performRequests()
        
        // 保持代理对象在内存中
        objc_setAssociatedObject(controller_blisslink, "delegate", delegate_blisslink, .OBJC_ASSOCIATION_RETAIN)
    }
    
    // MARK: - 点击事件处理
    
    /// 处理按钮点击
    private func handleButtonTap_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        print("🔵 Apple登录按钮被点击")
    }
    
    // MARK: - 处理结果
    
    /// 处理登录结果
    /// - Parameter result_blisslink: 授权结果
    private func handleResult_blisslink(_ result_blisslink: Result<ASAuthorization, Error>) {
        switch result_blisslink {
        case .success(let authorization_blisslink):
            handleSuccess_blisslink(authorization_blisslink)
            
        case .failure(let error_blisslink):
            handleFailure_blisslink(error_blisslink)
        }
    }
    
    /// 处理成功结果
    /// - Parameter authorization_blisslink: 授权对象
    private func handleSuccess_blisslink(_ authorization_blisslink: ASAuthorization) {
        switch authorization_blisslink.credential {
            
        case let appleIDCredential_blisslink as ASAuthorizationAppleIDCredential:
            // 获取邮箱
            let email_blisslink = appleIDCredential_blisslink.email
            
            // 生成用户账号
            var userAcc_blisslink = ""
            if email_blisslink == nil || email_blisslink == "" {
                userAcc_blisslink = "appleId_\(appleIDCredential_blisslink.user)"
            } else {
                userAcc_blisslink = email_blisslink ?? ""
            }
            
            print("✅ Apple登录成功，用户账号：\(userAcc_blisslink)")
            
            // 调用成功回调
            onSuccess_blisslink(userAcc_blisslink)
            
        case let userCredential_blisslink as ASPasswordCredential:
            // 密码凭证
            let user_blisslink = userCredential_blisslink.user
            _ = userCredential_blisslink.password
            
            print("✅ 密码凭证登录成功，用户：\(user_blisslink)")
            
            // 调用成功回调
            onSuccess_blisslink(user_blisslink)
            
        default:
            print("❌ 未知授权类型")
            onFailure_blisslink("Unknown authorization type")
        }
    }
    
    /// 处理失败结果
    private func handleFailure_blisslink(_ error_blisslink: Error) {
        if let authError_blisslink = error_blisslink as? ASAuthorizationError {
            
            var errorMessage_blisslink = ""
            
            switch authError_blisslink.code {
            case .unknown:
                errorMessage_blisslink = "Unknown error"
                print("❌ 授权未知错误")
            case .canceled:
                errorMessage_blisslink = "Authorization canceled"
                print("⚠️ 授权取消")
            case .invalidResponse:
                errorMessage_blisslink = "Invalid response"
                print("❌ 授权无效请求")
            case .notHandled:
                errorMessage_blisslink = "Not handled"
                print("❌ 授权未能处理")
            case .failed:
                errorMessage_blisslink = "Authorization failed"
                print("❌ 授权失败")
            case .notInteractive:
                errorMessage_blisslink = "Not interactive"
                print("❌ 授权非交互式")
            case .matchedExcludedCredential:
                errorMessage_blisslink = "Matched excluded credential"
                print("❌ 该凭证属于被排除的范围")
            case .credentialImport:
                errorMessage_blisslink = "Credential import"
                print("❌ 凭证导入")
            case .credentialExport:
                errorMessage_blisslink = "Credential export"
                print("❌ 凭证导出")
            case .preferSignInWithApple:
                errorMessage_blisslink = "Prefer sign in with Apple"
                print("❌ 偏好使用Apple登录")
            case .deviceNotConfiguredForPasskeyCreation:
                errorMessage_blisslink = "Device not configured for Passkey creation"
                print("❌ 设备未配置用于创建Passkey")
            @unknown default:
                errorMessage_blisslink = "Unknown error"
                print("❌ 授权其他原因")
            }
            
            // 调用失败回调
            onFailure_blisslink(errorMessage_blisslink)
        }
    }
}

// MARK: - Apple 登录代理

/// Apple 登录授权代理
class AppleLoginDelegate_blisslink: NSObject, ASAuthorizationControllerDelegate {
    
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
