import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Hush: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Hush: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Hush: UIView = {
        let view_Hush = UIView()
        view_Hush.backgroundColor = .black
        view_Hush.layer.cornerRadius = 12
        view_Hush.layer.masksToBounds = true
        return view_Hush
    }()
    
    /// 苹果图标
    private let appleIconView_Hush: UIImageView = {
        let imageView_Hush = UIImageView()
        imageView_Hush.image = UIImage(systemName: "apple.logo")
        imageView_Hush.tintColor = .white
        imageView_Hush.contentMode = .scaleAspectFit
        return imageView_Hush
    }()
    
    /// 文字标签
    private let titleLabel_Hush: UILabel = {
        let label_Hush = UILabel()
        label_Hush.text = "Continue with Apple"
        label_Hush.textColor = .white
        label_Hush.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Hush.textAlignment = .center
        return label_Hush
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Hush: UIStackView = {
        let stack_Hush = UIStackView()
        stack_Hush.axis = .horizontal
        stack_Hush.alignment = .center
        stack_Hush.spacing = 10
        stack_Hush.isUserInteractionEnabled = false
        return stack_Hush
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Hush: @escaping () -> Void) {
        self.onTap_Hush = onTap_Hush
        super.init(frame: .zero)
        setupUI_Hush()
        setupGesture_Hush()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Hush() {
        addSubview(containerView_Hush)
        containerView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Hush.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Hush.addArrangedSubview(appleIconView_Hush)
        contentStack_Hush.addArrangedSubview(titleLabel_Hush)

        containerView_Hush.addSubview(contentStack_Hush)
        contentStack_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Hush() {
        let tapGesture_Hush = UITapGestureRecognizer(target: self, action: #selector(handleTap_Hush))
        containerView_Hush.addGestureRecognizer(tapGesture_Hush)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Hush() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Hush.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Hush.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Hush?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Hush: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Hush: UIViewController?
    
    /// 成功回调
    private var successCallback_Hush: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Hush: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Hush: UIViewController) {
        self.viewController_Hush = viewController_Hush
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Hush(
        success_Hush: @escaping (String) -> Void,
        failure_Hush: @escaping (String) -> Void
    ) {
        self.successCallback_Hush = success_Hush
        self.failureCallback_Hush = failure_Hush
        
        // 创建Apple ID授权请求
        let appleIDProvider_Hush = ASAuthorizationAppleIDProvider()
        let request_Hush = appleIDProvider_Hush.createRequest()
        request_Hush.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Hush = ASAuthorizationController(authorizationRequests: [request_Hush])
        authorizationController_Hush.delegate = self
        authorizationController_Hush.presentationContextProvider = self
        authorizationController_Hush.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Hush: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Hush as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Hush = appleIDCredential_Hush.email
                
                // 生成用户账号
                var userAcc_Hush = ""
                if email_Hush == nil || email_Hush == "" {
                    userAcc_Hush = "appleId"
                } else {
                    userAcc_Hush = email_Hush ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Hush)")
                
                // 调用成功回调
                successCallback_Hush?(userAcc_Hush)
                
            case let userCredential_Hush as ASPasswordCredential:
                // 密码凭证
                let user_Hush = userCredential_Hush.user
                _ = userCredential_Hush.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Hush)")
                
                // 调用成功回调
                successCallback_Hush?(user_Hush)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Hush?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Hush = error as? ASAuthorizationError {
                
                var errorMessage_Hush = ""

                switch authError_Hush.code {
                case .unknown:
                    errorMessage_Hush = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Hush = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Hush = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Hush = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Hush = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Hush = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Hush = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Hush = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Hush = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Hush = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Hush = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Hush = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Hush?(errorMessage_Hush)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Hush: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Hush = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Hush = windowScene_Hush.windows.first(where: { $0.isKeyWindow }) {
            return window_Hush
        }
        
        // 备选方案：返回第一个窗口
        if let window_Hush = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Hush
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
