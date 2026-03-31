import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Flick: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Flick: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Flick: UIView = {
        let view_Flick = UIView()
        view_Flick.backgroundColor = .black
        view_Flick.layer.cornerRadius = 12
        view_Flick.layer.masksToBounds = true
        return view_Flick
    }()
    
    /// 苹果图标
    private let appleIconView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.image = UIImage(systemName: "apple.logo")
        imageView_Flick.tintColor = .white
        imageView_Flick.contentMode = .scaleAspectFit
        return imageView_Flick
    }()
    
    /// 文字标签
    private let titleLabel_Flick: UILabel = {
        let label_Flick = UILabel()
        label_Flick.text = "Continue with Apple"
        label_Flick.textColor = .white
        label_Flick.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Flick.textAlignment = .center
        return label_Flick
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Flick: UIStackView = {
        let stack_Flick = UIStackView()
        stack_Flick.axis = .horizontal
        stack_Flick.alignment = .center
        stack_Flick.spacing = 10
        stack_Flick.isUserInteractionEnabled = false
        return stack_Flick
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Flick: @escaping () -> Void) {
        self.onTap_Flick = onTap_Flick
        super.init(frame: .zero)
        setupUI_Flick()
        setupGesture_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Flick() {
        addSubview(containerView_Flick)
        containerView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Flick.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Flick.addArrangedSubview(appleIconView_Flick)
        contentStack_Flick.addArrangedSubview(titleLabel_Flick)

        containerView_Flick.addSubview(contentStack_Flick)
        contentStack_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Flick() {
        let tapGesture_Flick = UITapGestureRecognizer(target: self, action: #selector(handleTap_Flick))
        containerView_Flick.addGestureRecognizer(tapGesture_Flick)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Flick() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Flick.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Flick.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Flick?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Flick: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Flick: UIViewController?
    
    /// 成功回调
    private var successCallback_Flick: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Flick: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Flick: UIViewController) {
        self.viewController_Flick = viewController_Flick
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Flick(
        success_Flick: @escaping (String) -> Void,
        failure_Flick: @escaping (String) -> Void
    ) {
        self.successCallback_Flick = success_Flick
        self.failureCallback_Flick = failure_Flick
        
        // 创建Apple ID授权请求
        let appleIDProvider_Flick = ASAuthorizationAppleIDProvider()
        let request_Flick = appleIDProvider_Flick.createRequest()
        request_Flick.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Flick = ASAuthorizationController(authorizationRequests: [request_Flick])
        authorizationController_Flick.delegate = self
        authorizationController_Flick.presentationContextProvider = self
        authorizationController_Flick.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Flick: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Flick as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Flick = appleIDCredential_Flick.email
                
                // 生成用户账号
                var userAcc_Flick = ""
                if email_Flick == nil || email_Flick == "" {
                    userAcc_Flick = "appleId"
                } else {
                    userAcc_Flick = email_Flick ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Flick)")
                
                // 调用成功回调
                successCallback_Flick?(userAcc_Flick)
                
            case let userCredential_Flick as ASPasswordCredential:
                // 密码凭证
                let user_Flick = userCredential_Flick.user
                _ = userCredential_Flick.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Flick)")
                
                // 调用成功回调
                successCallback_Flick?(user_Flick)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Flick?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Flick = error as? ASAuthorizationError {
                
                var errorMessage_Flick = ""

                switch authError_Flick.code {
                case .unknown:
                    errorMessage_Flick = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Flick = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Flick = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Flick = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Flick = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Flick = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Flick = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Flick = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Flick = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Flick = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Flick = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Flick = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Flick?(errorMessage_Flick)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Flick: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Flick = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Flick = windowScene_Flick.windows.first(where: { $0.isKeyWindow }) {
            return window_Flick
        }
        
        // 备选方案：返回第一个窗口
        if let window_Flick = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Flick
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
