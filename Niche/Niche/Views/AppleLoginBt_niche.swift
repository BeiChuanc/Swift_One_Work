import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Niche: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Niche: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.backgroundColor = .black
        view_Niche.layer.cornerRadius = 12
        view_Niche.layer.masksToBounds = true
        return view_Niche
    }()
    
    /// 苹果图标
    private let appleIconView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.image = UIImage(systemName: "apple.logo")
        imageView_Niche.tintColor = .white
        imageView_Niche.contentMode = .scaleAspectFit
        return imageView_Niche
    }()
    
    /// 文字标签
    private let titleLabel_Niche: UILabel = {
        let label_Niche = UILabel()
        label_Niche.text = "Continue with Apple"
        label_Niche.textColor = .white
        label_Niche.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Niche.textAlignment = .center
        return label_Niche
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Niche: UIStackView = {
        let stack_Niche = UIStackView()
        stack_Niche.axis = .horizontal
        stack_Niche.alignment = .center
        stack_Niche.spacing = 10
        stack_Niche.isUserInteractionEnabled = false
        return stack_Niche
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Niche: @escaping () -> Void) {
        self.onTap_Niche = onTap_Niche
        super.init(frame: .zero)
        setupUI_Niche()
        setupGesture_Niche()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Niche() {
        addSubview(containerView_Niche)
        containerView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Niche.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Niche.addArrangedSubview(appleIconView_Niche)
        contentStack_Niche.addArrangedSubview(titleLabel_Niche)

        containerView_Niche.addSubview(contentStack_Niche)
        contentStack_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Niche() {
        let tapGesture_Niche = UITapGestureRecognizer(target: self, action: #selector(handleTap_Niche))
        containerView_Niche.addGestureRecognizer(tapGesture_Niche)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Niche() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Niche.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Niche.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Niche?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Niche: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Niche: UIViewController?
    
    /// 成功回调
    private var successCallback_Niche: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Niche: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Niche: UIViewController) {
        self.viewController_Niche = viewController_Niche
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Niche(
        success_Niche: @escaping (String) -> Void,
        failure_Niche: @escaping (String) -> Void
    ) {
        self.successCallback_Niche = success_Niche
        self.failureCallback_Niche = failure_Niche
        
        // 创建Apple ID授权请求
        let appleIDProvider_Niche = ASAuthorizationAppleIDProvider()
        let request_Niche = appleIDProvider_Niche.createRequest()
        request_Niche.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Niche = ASAuthorizationController(authorizationRequests: [request_Niche])
        authorizationController_Niche.delegate = self
        authorizationController_Niche.presentationContextProvider = self
        authorizationController_Niche.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Niche: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Niche as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Niche = appleIDCredential_Niche.email
                
                // 生成用户账号
                var userAcc_Niche = ""
                if email_Niche == nil || email_Niche == "" {
                    userAcc_Niche = "appleId"
                } else {
                    userAcc_Niche = email_Niche ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Niche)")
                
                // 调用成功回调
                successCallback_Niche?(userAcc_Niche)
                
            case let userCredential_Niche as ASPasswordCredential:
                // 密码凭证
                let user_Niche = userCredential_Niche.user
                _ = userCredential_Niche.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Niche)")
                
                // 调用成功回调
                successCallback_Niche?(user_Niche)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Niche?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Niche = error as? ASAuthorizationError {
                
                var errorMessage_Niche = ""

                switch authError_Niche.code {
                case .unknown:
                    errorMessage_Niche = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Niche = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Niche = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Niche = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Niche = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Niche = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Niche = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Niche = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Niche = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Niche = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Niche = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Niche = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Niche?(errorMessage_Niche)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Niche: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Niche = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Niche = windowScene_Niche.windows.first(where: { $0.isKeyWindow }) {
            return window_Niche
        }
        
        // 备选方案：返回第一个窗口
        if let window_Niche = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Niche
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
