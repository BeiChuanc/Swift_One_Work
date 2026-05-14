import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Nest: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Nest: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.backgroundColor = .black
        view_Nest.layer.cornerRadius = 12
        view_Nest.layer.masksToBounds = true
        return view_Nest
    }()
    
    /// 苹果图标
    private let appleIconView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.image = UIImage(systemName: "apple.logo")
        imageView_Nest.tintColor = .white
        imageView_Nest.contentMode = .scaleAspectFit
        return imageView_Nest
    }()
    
    /// 文字标签
    private let titleLabel_Nest: UILabel = {
        let label_Nest = UILabel()
        label_Nest.text = "Continue with Apple"
        label_Nest.textColor = .white
        label_Nest.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Nest.textAlignment = .center
        return label_Nest
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Nest: UIStackView = {
        let stack_Nest = UIStackView()
        stack_Nest.axis = .horizontal
        stack_Nest.alignment = .center
        stack_Nest.spacing = 10
        stack_Nest.isUserInteractionEnabled = false
        return stack_Nest
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Nest: @escaping () -> Void) {
        self.onTap_Nest = onTap_Nest
        super.init(frame: .zero)
        setupUI_Nest()
        setupGesture_Nest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Nest() {
        addSubview(containerView_Nest)
        containerView_Nest.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Nest.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Nest.addArrangedSubview(appleIconView_Nest)
        contentStack_Nest.addArrangedSubview(titleLabel_Nest)

        containerView_Nest.addSubview(contentStack_Nest)
        contentStack_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Nest() {
        let tapGesture_Nest = UITapGestureRecognizer(target: self, action: #selector(handleTap_Nest))
        containerView_Nest.addGestureRecognizer(tapGesture_Nest)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Nest() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Nest.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Nest.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Nest?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Nest: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Nest: UIViewController?
    
    /// 成功回调
    private var successCallback_Nest: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Nest: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Nest: UIViewController) {
        self.viewController_Nest = viewController_Nest
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Nest(
        success_Nest: @escaping (String) -> Void,
        failure_Nest: @escaping (String) -> Void
    ) {
        self.successCallback_Nest = success_Nest
        self.failureCallback_Nest = failure_Nest
        
        // 创建Apple ID授权请求
        let appleIDProvider_Nest = ASAuthorizationAppleIDProvider()
        let request_Nest = appleIDProvider_Nest.createRequest()
        request_Nest.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Nest = ASAuthorizationController(authorizationRequests: [request_Nest])
        authorizationController_Nest.delegate = self
        authorizationController_Nest.presentationContextProvider = self
        authorizationController_Nest.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Nest: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Nest as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Nest = appleIDCredential_Nest.email
                
                // 生成用户账号
                var userAcc_Nest = ""
                if email_Nest == nil || email_Nest == "" {
                    userAcc_Nest = "appleId"
                } else {
                    userAcc_Nest = email_Nest ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Nest)")
                
                // 调用成功回调
                successCallback_Nest?(userAcc_Nest)
                
            case let userCredential_Nest as ASPasswordCredential:
                // 密码凭证
                let user_Nest = userCredential_Nest.user
                _ = userCredential_Nest.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Nest)")
                
                // 调用成功回调
                successCallback_Nest?(user_Nest)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Nest?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Nest = error as? ASAuthorizationError {
                
                var errorMessage_Nest = ""

                switch authError_Nest.code {
                case .unknown:
                    errorMessage_Nest = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Nest = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Nest = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Nest = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Nest = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Nest = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Nest = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Nest = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Nest = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Nest = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Nest = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Nest = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Nest?(errorMessage_Nest)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Nest: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Nest = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Nest = windowScene_Nest.windows.first(where: { $0.isKeyWindow }) {
            return window_Nest
        }
        
        // 备选方案：返回第一个窗口
        if let window_Nest = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Nest
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
