import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Pane: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Pane: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Pane: UIView = {
        let view_Pane = UIView()
        view_Pane.backgroundColor = .black
        view_Pane.layer.cornerRadius = 12
        view_Pane.layer.masksToBounds = true
        return view_Pane
    }()
    
    /// 苹果图标
    private let appleIconView_Pane: UIImageView = {
        let imageView_Pane = UIImageView()
        imageView_Pane.image = UIImage(systemName: "apple.logo")
        imageView_Pane.tintColor = .white
        imageView_Pane.contentMode = .scaleAspectFit
        return imageView_Pane
    }()
    
    /// 文字标签
    private let titleLabel_Pane: UILabel = {
        let label_Pane = UILabel()
        label_Pane.text = "Continue with Apple"
        label_Pane.textColor = .white
        label_Pane.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Pane.textAlignment = .center
        return label_Pane
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Pane: UIStackView = {
        let stack_Pane = UIStackView()
        stack_Pane.axis = .horizontal
        stack_Pane.alignment = .center
        stack_Pane.spacing = 10
        stack_Pane.isUserInteractionEnabled = false
        return stack_Pane
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Pane: @escaping () -> Void) {
        self.onTap_Pane = onTap_Pane
        super.init(frame: .zero)
        setupUI_Pane()
        setupGesture_Pane()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Pane() {
        addSubview(containerView_Pane)
        containerView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Pane.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Pane.addArrangedSubview(appleIconView_Pane)
        contentStack_Pane.addArrangedSubview(titleLabel_Pane)

        containerView_Pane.addSubview(contentStack_Pane)
        contentStack_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Pane() {
        let tapGesture_Pane = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        containerView_Pane.addGestureRecognizer(tapGesture_Pane)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Pane() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Pane.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Pane.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Pane?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Pane: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Pane: UIViewController?
    
    /// 成功回调
    private var successCallback_Pane: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Pane: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Pane: UIViewController) {
        self.viewController_Pane = viewController_Pane
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Pane(
        success_Pane: @escaping (String) -> Void,
        failure_Pane: @escaping (String) -> Void
    ) {
        self.successCallback_Pane = success_Pane
        self.failureCallback_Pane = failure_Pane
        
        // 创建Apple ID授权请求
        let appleIDProvider_Pane = ASAuthorizationAppleIDProvider()
        let request_Pane = appleIDProvider_Pane.createRequest()
        request_Pane.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Pane = ASAuthorizationController(authorizationRequests: [request_Pane])
        authorizationController_Pane.delegate = self
        authorizationController_Pane.presentationContextProvider = self
        authorizationController_Pane.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Pane: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Pane as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Pane = appleIDCredential_Pane.email
                
                // 生成用户账号
                var userAcc_Pane = ""
                if email_Pane == nil || email_Pane == "" {
                    userAcc_Pane = "appleId"
                } else {
                    userAcc_Pane = email_Pane ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Pane)")
                
                // 调用成功回调
                successCallback_Pane?(userAcc_Pane)
                
            case let userCredential_Pane as ASPasswordCredential:
                // 密码凭证
                let user_Pane = userCredential_Pane.user
                _ = userCredential_Pane.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Pane)")
                
                // 调用成功回调
                successCallback_Pane?(user_Pane)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Pane?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Pane = error as? ASAuthorizationError {
                
                var errorMessage_Pane = ""

                switch authError_Pane.code {
                case .unknown:
                    errorMessage_Pane = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Pane = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Pane = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Pane = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Pane = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Pane = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Pane = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Pane = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Pane = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Pane = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Pane = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Pane = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Pane?(errorMessage_Pane)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Pane: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Pane = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Pane = windowScene_Pane.windows.first(where: { $0.isKeyWindow }) {
            return window_Pane
        }
        
        // 备选方案：返回第一个窗口
        if let window_Pane = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Pane
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
