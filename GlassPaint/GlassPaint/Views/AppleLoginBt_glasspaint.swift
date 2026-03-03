import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Glasspaint: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Glasspaint: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .black
        view_Glasspaint.layer.cornerRadius = 12
        view_Glasspaint.layer.masksToBounds = true
        return view_Glasspaint
    }()
    
    /// 内容StackView
    private let contentStackView_Glasspaint: UIStackView = {
        let stackView_Glasspaint = UIStackView()
        stackView_Glasspaint.axis = .horizontal
        stackView_Glasspaint.alignment = .center
        stackView_Glasspaint.distribution = .fill
        stackView_Glasspaint.spacing = 10
        return stackView_Glasspaint
    }()
    
    /// 苹果图标
    private let appleIconView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.image = UIImage(systemName: "apple.logo")
        imageView_Glasspaint.tintColor = .white
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    /// 文字标签
    private let titleLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.text = "Continue with Apple"
        label_Glasspaint.textColor = .white
        label_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Glasspaint.textAlignment = .center
        return label_Glasspaint
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Glasspaint: @escaping () -> Void) {
        self.onTap_Glasspaint = onTap_Glasspaint
        super.init(frame: .zero)
        setupUI_Glasspaint()
        setupGesture_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        addSubview(containerView_Glasspaint)
        containerView_Glasspaint.addSubview(contentStackView_Glasspaint)
        
        // 将图标和文字添加到StackView
        contentStackView_Glasspaint.addArrangedSubview(appleIconView_Glasspaint)
        contentStackView_Glasspaint.addArrangedSubview(titleLabel_Glasspaint)
        
        // 容器视图约束
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // StackView约束（整体居中）
        contentStackView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 苹果图标约束（固定大小）
        appleIconView_Glasspaint.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }
    }
    
    /// 设置手势
    private func setupGesture_Glasspaint() {
        let tapGesture_Glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTap_Glasspaint))
        containerView_Glasspaint.addGestureRecognizer(tapGesture_Glasspaint)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Glasspaint() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Glasspaint.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Glasspaint?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Glasspaint: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Glasspaint: UIViewController?
    
    /// 成功回调
    private var successCallback_Glasspaint: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Glasspaint: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Glasspaint: UIViewController) {
        self.viewController_Glasspaint = viewController_Glasspaint
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Glasspaint(
        success_Glasspaint: @escaping (String) -> Void,
        failure_Glasspaint: @escaping (String) -> Void
    ) {
        self.successCallback_Glasspaint = success_Glasspaint
        self.failureCallback_Glasspaint = failure_Glasspaint
        
        // 创建Apple ID授权请求
        let appleIDProvider_Glasspaint = ASAuthorizationAppleIDProvider()
        let request_Glasspaint = appleIDProvider_Glasspaint.createRequest()
        request_Glasspaint.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Glasspaint = ASAuthorizationController(authorizationRequests: [request_Glasspaint])
        authorizationController_Glasspaint.delegate = self
        authorizationController_Glasspaint.presentationContextProvider = self
        authorizationController_Glasspaint.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Glasspaint: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Glasspaint as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Glasspaint = appleIDCredential_Glasspaint.email
                
                // 生成用户账号
                var userAcc_Glasspaint = ""
                if email_Glasspaint == nil || email_Glasspaint == "" {
                    userAcc_Glasspaint = "appleId"
                } else {
                    userAcc_Glasspaint = email_Glasspaint ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Glasspaint)")
                
                // 调用成功回调
                successCallback_Glasspaint?(userAcc_Glasspaint)
                
            case let userCredential_Glasspaint as ASPasswordCredential:
                // 密码凭证
                let user_Glasspaint = userCredential_Glasspaint.user
                _ = userCredential_Glasspaint.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Glasspaint)")
                
                // 调用成功回调
                successCallback_Glasspaint?(user_Glasspaint)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Glasspaint?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Glasspaint = error as? ASAuthorizationError {
                
                var errorMessage_Glasspaint = ""

                switch authError_Glasspaint.code {
                case .unknown:
                    errorMessage_Glasspaint = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Glasspaint = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Glasspaint = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Glasspaint = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Glasspaint = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Glasspaint = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Glasspaint = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Glasspaint = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Glasspaint = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Glasspaint = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Glasspaint = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Glasspaint = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Glasspaint?(errorMessage_Glasspaint)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Glasspaint: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Glasspaint = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Glasspaint = windowScene_Glasspaint.windows.first(where: { $0.isKeyWindow }) {
            return window_Glasspaint
        }
        
        // 备选方案：返回第一个窗口
        if let window_Glasspaint = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Glasspaint
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
