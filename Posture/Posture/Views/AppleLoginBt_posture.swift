import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Posture: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Posture: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Posture: UIView = {
        let view_Posture = UIView()
        view_Posture.backgroundColor = .black
        view_Posture.layer.cornerRadius = 12
        view_Posture.layer.masksToBounds = true
        return view_Posture
    }()
    
    /// 苹果图标
    private let appleIconView_Posture: UIImageView = {
        let imageView_Posture = UIImageView()
        imageView_Posture.image = UIImage(systemName: "apple.logo")
        imageView_Posture.tintColor = .white
        imageView_Posture.contentMode = .scaleAspectFit
        return imageView_Posture
    }()
    
    /// 文字标签
    private let titleLabel_Posture: UILabel = {
        let label_Posture = UILabel()
        label_Posture.text = "Continue with Apple"
        label_Posture.textColor = .white
        label_Posture.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Posture.textAlignment = .center
        return label_Posture
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Posture: UIStackView = {
        let stack_Posture = UIStackView()
        stack_Posture.axis = .horizontal
        stack_Posture.alignment = .center
        stack_Posture.spacing = 10
        stack_Posture.isUserInteractionEnabled = false
        return stack_Posture
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Posture: @escaping () -> Void) {
        self.onTap_Posture = onTap_Posture
        super.init(frame: .zero)
        setupUI_Posture()
        setupGesture_Posture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Posture() {
        addSubview(containerView_Posture)
        containerView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Posture.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Posture.addArrangedSubview(appleIconView_Posture)
        contentStack_Posture.addArrangedSubview(titleLabel_Posture)

        containerView_Posture.addSubview(contentStack_Posture)
        contentStack_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Posture() {
        let tapGesture_Posture = UITapGestureRecognizer(target: self, action: #selector(handleTap_Posture))
        containerView_Posture.addGestureRecognizer(tapGesture_Posture)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Posture() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Posture.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Posture.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Posture?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Posture: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Posture: UIViewController?
    
    /// 成功回调
    private var successCallback_Posture: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Posture: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Posture: UIViewController) {
        self.viewController_Posture = viewController_Posture
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Posture(
        success_Posture: @escaping (String) -> Void,
        failure_Posture: @escaping (String) -> Void
    ) {
        self.successCallback_Posture = success_Posture
        self.failureCallback_Posture = failure_Posture
        
        // 创建Apple ID授权请求
        let appleIDProvider_Posture = ASAuthorizationAppleIDProvider()
        let request_Posture = appleIDProvider_Posture.createRequest()
        request_Posture.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Posture = ASAuthorizationController(authorizationRequests: [request_Posture])
        authorizationController_Posture.delegate = self
        authorizationController_Posture.presentationContextProvider = self
        authorizationController_Posture.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Posture: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Posture as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Posture = appleIDCredential_Posture.email
                
                // 生成用户账号
                var userAcc_Posture = ""
                if email_Posture == nil || email_Posture == "" {
                    userAcc_Posture = "appleId"
                } else {
                    userAcc_Posture = email_Posture ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Posture)")
                
                // 调用成功回调
                successCallback_Posture?(userAcc_Posture)
                
            case let userCredential_Posture as ASPasswordCredential:
                // 密码凭证
                let user_Posture = userCredential_Posture.user
                _ = userCredential_Posture.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Posture)")
                
                // 调用成功回调
                successCallback_Posture?(user_Posture)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Posture?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Posture = error as? ASAuthorizationError {
                
                var errorMessage_Posture = ""

                switch authError_Posture.code {
                case .unknown:
                    errorMessage_Posture = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Posture = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Posture = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Posture = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Posture = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Posture = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Posture = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Posture = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Posture = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Posture = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Posture = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Posture = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Posture?(errorMessage_Posture)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Posture: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Posture = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Posture = windowScene_Posture.windows.first(where: { $0.isKeyWindow }) {
            return window_Posture
        }
        
        // 备选方案：返回第一个窗口
        if let window_Posture = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Posture
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
