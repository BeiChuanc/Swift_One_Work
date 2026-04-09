import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Tidy: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Tidy: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Tidy: UIView = {
        let view_Tidy = UIView()
        view_Tidy.backgroundColor = .black
        view_Tidy.layer.cornerRadius = 12
        view_Tidy.layer.masksToBounds = true
        return view_Tidy
    }()
    
    /// 苹果图标
    private let appleIconView_Tidy: UIImageView = {
        let imageView_Tidy = UIImageView()
        imageView_Tidy.image = UIImage(systemName: "apple.logo")
        imageView_Tidy.tintColor = .white
        imageView_Tidy.contentMode = .scaleAspectFit
        return imageView_Tidy
    }()
    
    /// 文字标签
    private let titleLabel_Tidy: UILabel = {
        let label_Tidy = UILabel()
        label_Tidy.text = "Continue with Apple"
        label_Tidy.textColor = .white
        label_Tidy.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Tidy.textAlignment = .center
        return label_Tidy
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Tidy: UIStackView = {
        let stack_Tidy = UIStackView()
        stack_Tidy.axis = .horizontal
        stack_Tidy.alignment = .center
        stack_Tidy.spacing = 10
        stack_Tidy.isUserInteractionEnabled = false
        return stack_Tidy
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Tidy: @escaping () -> Void) {
        self.onTap_Tidy = onTap_Tidy
        super.init(frame: .zero)
        setupUI_Tidy()
        setupGesture_Tidy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Tidy() {
        addSubview(containerView_Tidy)
        containerView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Tidy.addArrangedSubview(appleIconView_Tidy)
        contentStack_Tidy.addArrangedSubview(titleLabel_Tidy)

        containerView_Tidy.addSubview(contentStack_Tidy)
        contentStack_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Tidy() {
        let tapGesture_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleTap_Tidy))
        containerView_Tidy.addGestureRecognizer(tapGesture_Tidy)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Tidy() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Tidy.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Tidy.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Tidy?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Tidy: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Tidy: UIViewController?
    
    /// 成功回调
    private var successCallback_Tidy: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Tidy: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Tidy: UIViewController) {
        self.viewController_Tidy = viewController_Tidy
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Tidy(
        success_Tidy: @escaping (String) -> Void,
        failure_Tidy: @escaping (String) -> Void
    ) {
        self.successCallback_Tidy = success_Tidy
        self.failureCallback_Tidy = failure_Tidy
        
        // 创建Apple ID授权请求
        let appleIDProvider_Tidy = ASAuthorizationAppleIDProvider()
        let request_Tidy = appleIDProvider_Tidy.createRequest()
        request_Tidy.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Tidy = ASAuthorizationController(authorizationRequests: [request_Tidy])
        authorizationController_Tidy.delegate = self
        authorizationController_Tidy.presentationContextProvider = self
        authorizationController_Tidy.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Tidy: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Tidy as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Tidy = appleIDCredential_Tidy.email
                
                // 生成用户账号
                var userAcc_Tidy = ""
                if email_Tidy == nil || email_Tidy == "" {
                    userAcc_Tidy = "appleId"
                } else {
                    userAcc_Tidy = email_Tidy ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Tidy)")
                
                // 调用成功回调
                successCallback_Tidy?(userAcc_Tidy)
                
            case let userCredential_Tidy as ASPasswordCredential:
                // 密码凭证
                let user_Tidy = userCredential_Tidy.user
                _ = userCredential_Tidy.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Tidy)")
                
                // 调用成功回调
                successCallback_Tidy?(user_Tidy)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Tidy?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Tidy = error as? ASAuthorizationError {
                
                var errorMessage_Tidy = ""

                switch authError_Tidy.code {
                case .unknown:
                    errorMessage_Tidy = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Tidy = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Tidy = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Tidy = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Tidy = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Tidy = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Tidy = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Tidy = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Tidy = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Tidy = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Tidy = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Tidy = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Tidy?(errorMessage_Tidy)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Tidy: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Tidy = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Tidy = windowScene_Tidy.windows.first(where: { $0.isKeyWindow }) {
            return window_Tidy
        }
        
        // 备选方案：返回第一个窗口
        if let window_Tidy = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Tidy
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
