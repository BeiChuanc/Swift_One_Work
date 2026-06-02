import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Breeze: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Breeze: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Breeze: UIView = {
        let view_Breeze = UIView()
        view_Breeze.backgroundColor = .black
        view_Breeze.layer.cornerRadius = 12
        view_Breeze.layer.masksToBounds = true
        return view_Breeze
    }()
    
    /// 苹果图标
    private let appleIconView_Breeze: UIImageView = {
        let imageView_Breeze = UIImageView()
        imageView_Breeze.image = UIImage(systemName: "apple.logo")
        imageView_Breeze.tintColor = .white
        imageView_Breeze.contentMode = .scaleAspectFit
        return imageView_Breeze
    }()
    
    /// 文字标签
    private let titleLabel_Breeze: UILabel = {
        let label_Breeze = UILabel()
        label_Breeze.text = "Continue with Apple"
        label_Breeze.textColor = .white
        label_Breeze.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Breeze.textAlignment = .center
        return label_Breeze
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Breeze: UIStackView = {
        let stack_Breeze = UIStackView()
        stack_Breeze.axis = .horizontal
        stack_Breeze.alignment = .center
        stack_Breeze.spacing = 10
        stack_Breeze.isUserInteractionEnabled = false
        return stack_Breeze
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Breeze: @escaping () -> Void) {
        self.onTap_Breeze = onTap_Breeze
        super.init(frame: .zero)
        setupUI_Breeze()
        setupGesture_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Breeze() {
        addSubview(containerView_Breeze)
        containerView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Breeze.addArrangedSubview(appleIconView_Breeze)
        contentStack_Breeze.addArrangedSubview(titleLabel_Breeze)

        containerView_Breeze.addSubview(contentStack_Breeze)
        contentStack_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Breeze() {
        let tapGesture_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        containerView_Breeze.addGestureRecognizer(tapGesture_Breeze)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Breeze() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Breeze.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Breeze.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Breeze?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Breeze: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Breeze: UIViewController?
    
    /// 成功回调
    private var successCallback_Breeze: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Breeze: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Breeze: UIViewController) {
        self.viewController_Breeze = viewController_Breeze
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Breeze(
        success_Breeze: @escaping (String) -> Void,
        failure_Breeze: @escaping (String) -> Void
    ) {
        self.successCallback_Breeze = success_Breeze
        self.failureCallback_Breeze = failure_Breeze
        
        // 创建Apple ID授权请求
        let appleIDProvider_Breeze = ASAuthorizationAppleIDProvider()
        let request_Breeze = appleIDProvider_Breeze.createRequest()
        request_Breeze.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Breeze = ASAuthorizationController(authorizationRequests: [request_Breeze])
        authorizationController_Breeze.delegate = self
        authorizationController_Breeze.presentationContextProvider = self
        authorizationController_Breeze.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Breeze: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Breeze as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Breeze = appleIDCredential_Breeze.email
                
                // 生成用户账号
                var userAcc_Breeze = ""
                if email_Breeze == nil || email_Breeze == "" {
                    userAcc_Breeze = "appleId"
                } else {
                    userAcc_Breeze = email_Breeze ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Breeze)")
                
                // 调用成功回调
                successCallback_Breeze?(userAcc_Breeze)
                
            case let userCredential_Breeze as ASPasswordCredential:
                // 密码凭证
                let user_Breeze = userCredential_Breeze.user
                _ = userCredential_Breeze.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Breeze)")
                
                // 调用成功回调
                successCallback_Breeze?(user_Breeze)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Breeze?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Breeze = error as? ASAuthorizationError {
                
                var errorMessage_Breeze = ""

                switch authError_Breeze.code {
                case .unknown:
                    errorMessage_Breeze = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Breeze = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Breeze = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Breeze = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Breeze = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Breeze = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Breeze = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Breeze = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Breeze = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Breeze = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Breeze = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Breeze = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Breeze?(errorMessage_Breeze)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Breeze: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Breeze = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Breeze = windowScene_Breeze.windows.first(where: { $0.isKeyWindow }) {
            return window_Breeze
        }
        
        // 备选方案：返回第一个窗口
        if let window_Breeze = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Breeze
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
