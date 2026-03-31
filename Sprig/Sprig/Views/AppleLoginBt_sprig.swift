import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Sprig: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Sprig: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = .black
        view_Sprig.layer.cornerRadius = 12
        view_Sprig.layer.masksToBounds = true
        return view_Sprig
    }()
    
    /// 苹果图标
    private let appleIconView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.image = UIImage(systemName: "apple.logo")
        imageView_Sprig.tintColor = .white
        imageView_Sprig.contentMode = .scaleAspectFit
        return imageView_Sprig
    }()
    
    /// 文字标签
    private let titleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Continue with Apple"
        label_Sprig.textColor = .white
        label_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Sprig: UIStackView = {
        let stack_Sprig = UIStackView()
        stack_Sprig.axis = .horizontal
        stack_Sprig.alignment = .center
        stack_Sprig.spacing = 10
        stack_Sprig.isUserInteractionEnabled = false
        return stack_Sprig
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Sprig: @escaping () -> Void) {
        self.onTap_Sprig = onTap_Sprig
        super.init(frame: .zero)
        setupUI_Sprig()
        setupGesture_Sprig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Sprig() {
        addSubview(containerView_Sprig)
        containerView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Sprig.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Sprig.addArrangedSubview(appleIconView_Sprig)
        contentStack_Sprig.addArrangedSubview(titleLabel_Sprig)

        containerView_Sprig.addSubview(contentStack_Sprig)
        contentStack_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Sprig() {
        let tapGesture_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sprig))
        containerView_Sprig.addGestureRecognizer(tapGesture_Sprig)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Sprig() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Sprig.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Sprig.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Sprig?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Sprig: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Sprig: UIViewController?
    
    /// 成功回调
    private var successCallback_Sprig: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Sprig: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Sprig: UIViewController) {
        self.viewController_Sprig = viewController_Sprig
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Sprig(
        success_Sprig: @escaping (String) -> Void,
        failure_Sprig: @escaping (String) -> Void
    ) {
        self.successCallback_Sprig = success_Sprig
        self.failureCallback_Sprig = failure_Sprig
        
        // 创建Apple ID授权请求
        let appleIDProvider_Sprig = ASAuthorizationAppleIDProvider()
        let request_Sprig = appleIDProvider_Sprig.createRequest()
        request_Sprig.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Sprig = ASAuthorizationController(authorizationRequests: [request_Sprig])
        authorizationController_Sprig.delegate = self
        authorizationController_Sprig.presentationContextProvider = self
        authorizationController_Sprig.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Sprig: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Sprig as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Sprig = appleIDCredential_Sprig.email
                
                // 生成用户账号
                var userAcc_Sprig = ""
                if email_Sprig == nil || email_Sprig == "" {
                    userAcc_Sprig = "appleId"
                } else {
                    userAcc_Sprig = email_Sprig ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Sprig)")
                
                // 调用成功回调
                successCallback_Sprig?(userAcc_Sprig)
                
            case let userCredential_Sprig as ASPasswordCredential:
                // 密码凭证
                let user_Sprig = userCredential_Sprig.user
                _ = userCredential_Sprig.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Sprig)")
                
                // 调用成功回调
                successCallback_Sprig?(user_Sprig)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Sprig?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Sprig = error as? ASAuthorizationError {
                
                var errorMessage_Sprig = ""

                switch authError_Sprig.code {
                case .unknown:
                    errorMessage_Sprig = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Sprig = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Sprig = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Sprig = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Sprig = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Sprig = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Sprig = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Sprig = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Sprig = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Sprig = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Sprig = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Sprig = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Sprig?(errorMessage_Sprig)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Sprig: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Sprig = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Sprig = windowScene_Sprig.windows.first(where: { $0.isKeyWindow }) {
            return window_Sprig
        }
        
        // 备选方案：返回第一个窗口
        if let window_Sprig = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Sprig
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
