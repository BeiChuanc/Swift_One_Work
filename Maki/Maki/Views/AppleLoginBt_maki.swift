import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Maki: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Maki: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Maki: UIView = {
        let view_Maki = UIView()
        view_Maki.backgroundColor = .black
        view_Maki.layer.cornerRadius = 12
        view_Maki.layer.masksToBounds = true
        return view_Maki
    }()
    
    /// 苹果图标
    private let appleIconView_Maki: UIImageView = {
        let imageView_Maki = UIImageView()
        imageView_Maki.image = UIImage(systemName: "apple.logo")
        imageView_Maki.tintColor = .white
        imageView_Maki.contentMode = .scaleAspectFit
        return imageView_Maki
    }()
    
    /// 文字标签
    private let titleLabel_Maki: UILabel = {
        let label_Maki = UILabel()
        label_Maki.text = "Continue with Apple"
        label_Maki.textColor = .white
        label_Maki.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Maki.textAlignment = .center
        return label_Maki
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Maki: UIStackView = {
        let stack_Maki = UIStackView()
        stack_Maki.axis = .horizontal
        stack_Maki.alignment = .center
        stack_Maki.spacing = 10
        stack_Maki.isUserInteractionEnabled = false
        return stack_Maki
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Maki: @escaping () -> Void) {
        self.onTap_Maki = onTap_Maki
        super.init(frame: .zero)
        setupUI_Maki()
        setupGesture_Maki()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Maki() {
        addSubview(containerView_Maki)
        containerView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Maki.addArrangedSubview(appleIconView_Maki)
        contentStack_Maki.addArrangedSubview(titleLabel_Maki)

        containerView_Maki.addSubview(contentStack_Maki)
        contentStack_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Maki() {
        let tapGesture_Maki = UITapGestureRecognizer(target: self, action: #selector(handleTap_Maki))
        containerView_Maki.addGestureRecognizer(tapGesture_Maki)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Maki() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Maki.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Maki.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Maki?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Maki: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Maki: UIViewController?
    
    /// 成功回调
    private var successCallback_Maki: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Maki: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Maki: UIViewController) {
        self.viewController_Maki = viewController_Maki
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Maki(
        success_Maki: @escaping (String) -> Void,
        failure_Maki: @escaping (String) -> Void
    ) {
        self.successCallback_Maki = success_Maki
        self.failureCallback_Maki = failure_Maki
        
        // 创建Apple ID授权请求
        let appleIDProvider_Maki = ASAuthorizationAppleIDProvider()
        let request_Maki = appleIDProvider_Maki.createRequest()
        request_Maki.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Maki = ASAuthorizationController(authorizationRequests: [request_Maki])
        authorizationController_Maki.delegate = self
        authorizationController_Maki.presentationContextProvider = self
        authorizationController_Maki.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Maki: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Maki as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Maki = appleIDCredential_Maki.email
                
                // 生成用户账号
                var userAcc_Maki = ""
                if email_Maki == nil || email_Maki == "" {
                    userAcc_Maki = "appleId"
                } else {
                    userAcc_Maki = email_Maki ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Maki)")
                
                // 调用成功回调
                successCallback_Maki?(userAcc_Maki)
                
            case let userCredential_Maki as ASPasswordCredential:
                // 密码凭证
                let user_Maki = userCredential_Maki.user
                _ = userCredential_Maki.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Maki)")
                
                // 调用成功回调
                successCallback_Maki?(user_Maki)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Maki?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Maki = error as? ASAuthorizationError {
                
                var errorMessage_Maki = ""

                switch authError_Maki.code {
                case .unknown:
                    errorMessage_Maki = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Maki = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Maki = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Maki = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Maki = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Maki = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Maki = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Maki = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Maki = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Maki = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Maki = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Maki = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Maki?(errorMessage_Maki)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Maki: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Maki = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Maki = windowScene_Maki.windows.first(where: { $0.isKeyWindow }) {
            return window_Maki
        }
        
        // 备选方案：返回第一个窗口
        if let window_Maki = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Maki
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
