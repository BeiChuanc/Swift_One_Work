import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Ornit: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Ornit: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Ornit: UIView = {
        let view_Ornit = UIView()
        view_Ornit.backgroundColor = .black
        view_Ornit.layer.cornerRadius = 12
        view_Ornit.layer.masksToBounds = true
        return view_Ornit
    }()
    
    /// 苹果图标
    private let appleIconView_Ornit: UIImageView = {
        let imageView_Ornit = UIImageView()
        imageView_Ornit.image = UIImage(systemName: "apple.logo")
        imageView_Ornit.tintColor = .white
        imageView_Ornit.contentMode = .scaleAspectFit
        return imageView_Ornit
    }()
    
    /// 文字标签
    private let titleLabel_Ornit: UILabel = {
        let label_Ornit = UILabel()
        label_Ornit.text = "Continue with Apple"
        label_Ornit.textColor = .white
        label_Ornit.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Ornit.textAlignment = .center
        return label_Ornit
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Ornit: UIStackView = {
        let stack_Ornit = UIStackView()
        stack_Ornit.axis = .horizontal
        stack_Ornit.alignment = .center
        stack_Ornit.spacing = 10
        stack_Ornit.isUserInteractionEnabled = false
        return stack_Ornit
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Ornit: @escaping () -> Void) {
        self.onTap_Ornit = onTap_Ornit
        super.init(frame: .zero)
        setupUI_Ornit()
        setupGesture_Ornit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Ornit() {
        addSubview(containerView_Ornit)
        containerView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Ornit.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Ornit.addArrangedSubview(appleIconView_Ornit)
        contentStack_Ornit.addArrangedSubview(titleLabel_Ornit)

        containerView_Ornit.addSubview(contentStack_Ornit)
        contentStack_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Ornit() {
        let tapGesture_Ornit = UITapGestureRecognizer(target: self, action: #selector(handleTap_Ornit))
        containerView_Ornit.addGestureRecognizer(tapGesture_Ornit)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Ornit() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Ornit.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Ornit.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Ornit?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Ornit: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Ornit: UIViewController?
    
    /// 成功回调
    private var successCallback_Ornit: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Ornit: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Ornit: UIViewController) {
        self.viewController_Ornit = viewController_Ornit
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Ornit(
        success_Ornit: @escaping (String) -> Void,
        failure_Ornit: @escaping (String) -> Void
    ) {
        self.successCallback_Ornit = success_Ornit
        self.failureCallback_Ornit = failure_Ornit
        
        // 创建Apple ID授权请求
        let appleIDProvider_Ornit = ASAuthorizationAppleIDProvider()
        let request_Ornit = appleIDProvider_Ornit.createRequest()
        request_Ornit.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Ornit = ASAuthorizationController(authorizationRequests: [request_Ornit])
        authorizationController_Ornit.delegate = self
        authorizationController_Ornit.presentationContextProvider = self
        authorizationController_Ornit.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Ornit: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Ornit as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Ornit = appleIDCredential_Ornit.email
                
                // 生成用户账号
                var userAcc_Ornit = ""
                if email_Ornit == nil || email_Ornit == "" {
                    userAcc_Ornit = "appleId"
                } else {
                    userAcc_Ornit = email_Ornit ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Ornit)")
                
                // 调用成功回调
                successCallback_Ornit?(userAcc_Ornit)
                
            case let userCredential_Ornit as ASPasswordCredential:
                // 密码凭证
                let user_Ornit = userCredential_Ornit.user
                _ = userCredential_Ornit.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Ornit)")
                
                // 调用成功回调
                successCallback_Ornit?(user_Ornit)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Ornit?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Ornit = error as? ASAuthorizationError {
                
                var errorMessage_Ornit = ""

                switch authError_Ornit.code {
                case .unknown:
                    errorMessage_Ornit = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Ornit = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Ornit = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Ornit = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Ornit = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Ornit = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Ornit = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Ornit = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Ornit = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Ornit = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Ornit = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Ornit = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Ornit?(errorMessage_Ornit)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Ornit: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Ornit = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Ornit = windowScene_Ornit.windows.first(where: { $0.isKeyWindow }) {
            return window_Ornit
        }
        
        // 备选方案：返回第一个窗口
        if let window_Ornit = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Ornit
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
