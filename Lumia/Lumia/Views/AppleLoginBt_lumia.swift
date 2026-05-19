import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Lumia: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Lumia: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Lumia: UIView = {
        let view_Lumia = UIView()
        view_Lumia.backgroundColor = .black
        view_Lumia.layer.cornerRadius = 12
        view_Lumia.layer.masksToBounds = true
        return view_Lumia
    }()
    
    /// 苹果图标
    private let appleIconView_Lumia: UIImageView = {
        let imageView_Lumia = UIImageView()
        imageView_Lumia.image = UIImage(systemName: "apple.logo")
        imageView_Lumia.tintColor = .white
        imageView_Lumia.contentMode = .scaleAspectFit
        return imageView_Lumia
    }()
    
    /// 文字标签
    private let titleLabel_Lumia: UILabel = {
        let label_Lumia = UILabel()
        label_Lumia.text = "Continue with Apple"
        label_Lumia.textColor = .white
        label_Lumia.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Lumia.textAlignment = .center
        return label_Lumia
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Lumia: UIStackView = {
        let stack_Lumia = UIStackView()
        stack_Lumia.axis = .horizontal
        stack_Lumia.alignment = .center
        stack_Lumia.spacing = 10
        stack_Lumia.isUserInteractionEnabled = false
        return stack_Lumia
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Lumia: @escaping () -> Void) {
        self.onTap_Lumia = onTap_Lumia
        super.init(frame: .zero)
        setupUI_Lumia()
        setupGesture_Lumia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Lumia() {
        addSubview(containerView_Lumia)
        containerView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Lumia.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Lumia.addArrangedSubview(appleIconView_Lumia)
        contentStack_Lumia.addArrangedSubview(titleLabel_Lumia)

        containerView_Lumia.addSubview(contentStack_Lumia)
        contentStack_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Lumia() {
        let tapGesture_Lumia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia))
        containerView_Lumia.addGestureRecognizer(tapGesture_Lumia)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Lumia() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Lumia.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Lumia.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Lumia?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Lumia: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Lumia: UIViewController?
    
    /// 成功回调
    private var successCallback_Lumia: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Lumia: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Lumia: UIViewController) {
        self.viewController_Lumia = viewController_Lumia
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Lumia(
        success_Lumia: @escaping (String) -> Void,
        failure_Lumia: @escaping (String) -> Void
    ) {
        self.successCallback_Lumia = success_Lumia
        self.failureCallback_Lumia = failure_Lumia
        
        // 创建Apple ID授权请求
        let appleIDProvider_Lumia = ASAuthorizationAppleIDProvider()
        let request_Lumia = appleIDProvider_Lumia.createRequest()
        request_Lumia.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Lumia = ASAuthorizationController(authorizationRequests: [request_Lumia])
        authorizationController_Lumia.delegate = self
        authorizationController_Lumia.presentationContextProvider = self
        authorizationController_Lumia.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Lumia: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Lumia as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Lumia = appleIDCredential_Lumia.email
                
                // 生成用户账号
                var userAcc_Lumia = ""
                if email_Lumia == nil || email_Lumia == "" {
                    userAcc_Lumia = "appleId"
                } else {
                    userAcc_Lumia = email_Lumia ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Lumia)")
                
                // 调用成功回调
                successCallback_Lumia?(userAcc_Lumia)
                
            case let userCredential_Lumia as ASPasswordCredential:
                // 密码凭证
                let user_Lumia = userCredential_Lumia.user
                _ = userCredential_Lumia.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Lumia)")
                
                // 调用成功回调
                successCallback_Lumia?(user_Lumia)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Lumia?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Lumia = error as? ASAuthorizationError {
                
                var errorMessage_Lumia = ""

                switch authError_Lumia.code {
                case .unknown:
                    errorMessage_Lumia = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Lumia = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Lumia = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Lumia = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Lumia = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Lumia = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Lumia = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Lumia = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Lumia = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Lumia = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Lumia = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Lumia = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Lumia?(errorMessage_Lumia)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Lumia: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Lumia = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Lumia = windowScene_Lumia.windows.first(where: { $0.isKeyWindow }) {
            return window_Lumia
        }
        
        // 备选方案：返回第一个窗口
        if let window_Lumia = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Lumia
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
