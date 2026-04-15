import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Epoch: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Epoch: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = .black
        view_Epoch.layer.cornerRadius = 12
        view_Epoch.layer.masksToBounds = true
        return view_Epoch
    }()
    
    /// 苹果图标
    private let appleIconView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.image = UIImage(systemName: "apple.logo")
        imageView_Epoch.tintColor = .white
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()
    
    /// 文字标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Continue with Apple"
        label_Epoch.textColor = .white
        label_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Epoch.textAlignment = .center
        return label_Epoch
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Epoch: UIStackView = {
        let stack_Epoch = UIStackView()
        stack_Epoch.axis = .horizontal
        stack_Epoch.alignment = .center
        stack_Epoch.spacing = 10
        stack_Epoch.isUserInteractionEnabled = false
        return stack_Epoch
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Epoch: @escaping () -> Void) {
        self.onTap_Epoch = onTap_Epoch
        super.init(frame: .zero)
        setupUI_Epoch()
        setupGesture_Epoch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Epoch() {
        addSubview(containerView_Epoch)
        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Epoch.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Epoch.addArrangedSubview(appleIconView_Epoch)
        contentStack_Epoch.addArrangedSubview(titleLabel_Epoch)

        containerView_Epoch.addSubview(contentStack_Epoch)
        contentStack_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Epoch() {
        let tapGesture_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleTap_Epoch))
        containerView_Epoch.addGestureRecognizer(tapGesture_Epoch)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Epoch() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Epoch.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Epoch.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Epoch?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Epoch: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Epoch: UIViewController?
    
    /// 成功回调
    private var successCallback_Epoch: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Epoch: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Epoch: UIViewController) {
        self.viewController_Epoch = viewController_Epoch
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Epoch(
        success_Epoch: @escaping (String) -> Void,
        failure_Epoch: @escaping (String) -> Void
    ) {
        self.successCallback_Epoch = success_Epoch
        self.failureCallback_Epoch = failure_Epoch
        
        // 创建Apple ID授权请求
        let appleIDProvider_Epoch = ASAuthorizationAppleIDProvider()
        let request_Epoch = appleIDProvider_Epoch.createRequest()
        request_Epoch.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Epoch = ASAuthorizationController(authorizationRequests: [request_Epoch])
        authorizationController_Epoch.delegate = self
        authorizationController_Epoch.presentationContextProvider = self
        authorizationController_Epoch.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Epoch: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Epoch as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Epoch = appleIDCredential_Epoch.email
                
                // 生成用户账号
                var userAcc_Epoch = ""
                if email_Epoch == nil || email_Epoch == "" {
                    userAcc_Epoch = "appleId"
                } else {
                    userAcc_Epoch = email_Epoch ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Epoch)")
                
                // 调用成功回调
                successCallback_Epoch?(userAcc_Epoch)
                
            case let userCredential_Epoch as ASPasswordCredential:
                // 密码凭证
                let user_Epoch = userCredential_Epoch.user
                _ = userCredential_Epoch.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Epoch)")
                
                // 调用成功回调
                successCallback_Epoch?(user_Epoch)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Epoch?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Epoch = error as? ASAuthorizationError {
                
                var errorMessage_Epoch = ""

                switch authError_Epoch.code {
                case .unknown:
                    errorMessage_Epoch = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Epoch = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Epoch = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Epoch = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Epoch = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Epoch = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Epoch = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Epoch = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Epoch = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Epoch = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Epoch = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Epoch = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Epoch?(errorMessage_Epoch)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Epoch: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Epoch = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Epoch = windowScene_Epoch.windows.first(where: { $0.isKeyWindow }) {
            return window_Epoch
        }
        
        // 备选方案：返回第一个窗口
        if let window_Epoch = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Epoch
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
