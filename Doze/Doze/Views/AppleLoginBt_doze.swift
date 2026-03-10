import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Doze: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Doze: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Doze: UIView = {
        let view_Doze = UIView()
        view_Doze.backgroundColor = .black
        view_Doze.layer.cornerRadius = 12
        view_Doze.layer.masksToBounds = true
        return view_Doze
    }()
    
    /// 苹果图标
    private let appleIconView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.image = UIImage(systemName: "apple.logo")
        imageView_Doze.tintColor = .white
        imageView_Doze.contentMode = .scaleAspectFit
        return imageView_Doze
    }()
    
    /// 文字标签
    private let titleLabel_Doze: UILabel = {
        let label_Doze = UILabel()
        label_Doze.text = "Continue with Apple"
        label_Doze.textColor = .white
        label_Doze.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Doze.textAlignment = .center
        return label_Doze
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Doze: @escaping () -> Void) {
        self.onTap_Doze = onTap_Doze
        super.init(frame: .zero)
        setupUI_Doze()
        setupGesture_Doze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Doze() {
        addSubview(containerView_Doze)
        containerView_Doze.addSubview(appleIconView_Doze)
        containerView_Doze.addSubview(titleLabel_Doze)
        
        // 容器视图约束
        containerView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 苹果图标约束
        appleIconView_Doze.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-30)
            make.width.height.equalTo(22)
        }
        
        // 文字标签约束
        titleLabel_Doze.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(appleIconView_Doze.snp.right).offset(10)
        }
    }
    
    /// 设置手势
    private func setupGesture_Doze() {
        let tapGesture_Doze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Doze))
        containerView_Doze.addGestureRecognizer(tapGesture_Doze)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Doze() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Doze.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Doze.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Doze?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Doze: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Doze: UIViewController?
    
    /// 成功回调
    private var successCallback_Doze: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Doze: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Doze: UIViewController) {
        self.viewController_Doze = viewController_Doze
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Doze(
        success_Doze: @escaping (String) -> Void,
        failure_Doze: @escaping (String) -> Void
    ) {
        self.successCallback_Doze = success_Doze
        self.failureCallback_Doze = failure_Doze
        
        // 创建Apple ID授权请求
        let appleIDProvider_Doze = ASAuthorizationAppleIDProvider()
        let request_Doze = appleIDProvider_Doze.createRequest()
        request_Doze.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Doze = ASAuthorizationController(authorizationRequests: [request_Doze])
        authorizationController_Doze.delegate = self
        authorizationController_Doze.presentationContextProvider = self
        authorizationController_Doze.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Doze: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Doze as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Doze = appleIDCredential_Doze.email
                
                // 生成用户账号
                var userAcc_Doze = ""
                if email_Doze == nil || email_Doze == "" {
                    userAcc_Doze = "appleId"
                } else {
                    userAcc_Doze = email_Doze ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Doze)")
                
                // 调用成功回调
                successCallback_Doze?(userAcc_Doze)
                
            case let userCredential_Doze as ASPasswordCredential:
                // 密码凭证
                let user_Doze = userCredential_Doze.user
                _ = userCredential_Doze.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Doze)")
                
                // 调用成功回调
                successCallback_Doze?(user_Doze)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Doze?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Doze = error as? ASAuthorizationError {
                
                var errorMessage_Doze = ""

                switch authError_Doze.code {
                case .unknown:
                    errorMessage_Doze = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Doze = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Doze = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Doze = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Doze = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Doze = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Doze = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Doze = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Doze = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Doze = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Doze = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Doze = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Doze?(errorMessage_Doze)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Doze: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Doze = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Doze = windowScene_Doze.windows.first(where: { $0.isKeyWindow }) {
            return window_Doze
        }
        
        // 备选方案：返回第一个窗口
        if let window_Doze = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Doze
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
