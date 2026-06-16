import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Retrs: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Retrs: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = .black
        view_Retrs.layer.cornerRadius = 12
        view_Retrs.layer.masksToBounds = true
        return view_Retrs
    }()
    
    /// 苹果图标
    private let appleIconView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.image = UIImage(systemName: "apple.logo")
        imageView_Retrs.tintColor = .white
        imageView_Retrs.contentMode = .scaleAspectFit
        return imageView_Retrs
    }()
    
    /// 文字标签
    private let titleLabel_Retrs: UILabel = {
        let label_Retrs = UILabel()
        label_Retrs.text = "Continue with Apple"
        label_Retrs.textColor = .white
        label_Retrs.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Retrs.textAlignment = .center
        return label_Retrs
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Retrs: UIStackView = {
        let stack_Retrs = UIStackView()
        stack_Retrs.axis = .horizontal
        stack_Retrs.alignment = .center
        stack_Retrs.spacing = 10
        stack_Retrs.isUserInteractionEnabled = false
        return stack_Retrs
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Retrs: @escaping () -> Void) {
        self.onTap_Retrs = onTap_Retrs
        super.init(frame: .zero)
        setupUI_Retrs()
        setupGesture_Retrs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Retrs() {
        addSubview(containerView_Retrs)
        containerView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Retrs.addArrangedSubview(appleIconView_Retrs)
        contentStack_Retrs.addArrangedSubview(titleLabel_Retrs)

        containerView_Retrs.addSubview(contentStack_Retrs)
        contentStack_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Retrs() {
        let tapGesture_Retrs = UITapGestureRecognizer(target: self, action: #selector(handleTap_Retrs))
        containerView_Retrs.addGestureRecognizer(tapGesture_Retrs)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Retrs() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Retrs.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Retrs.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Retrs?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Retrs: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Retrs: UIViewController?
    
    /// 成功回调
    private var successCallback_Retrs: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Retrs: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Retrs: UIViewController) {
        self.viewController_Retrs = viewController_Retrs
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Retrs(
        success_Retrs: @escaping (String) -> Void,
        failure_Retrs: @escaping (String) -> Void
    ) {
        self.successCallback_Retrs = success_Retrs
        self.failureCallback_Retrs = failure_Retrs
        
        // 创建Apple ID授权请求
        let appleIDProvider_Retrs = ASAuthorizationAppleIDProvider()
        let request_Retrs = appleIDProvider_Retrs.createRequest()
        request_Retrs.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Retrs = ASAuthorizationController(authorizationRequests: [request_Retrs])
        authorizationController_Retrs.delegate = self
        authorizationController_Retrs.presentationContextProvider = self
        authorizationController_Retrs.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Retrs: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Retrs as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Retrs = appleIDCredential_Retrs.email
                
                // 生成用户账号
                var userAcc_Retrs = ""
                if email_Retrs == nil || email_Retrs == "" {
                    userAcc_Retrs = "appleId"
                } else {
                    userAcc_Retrs = email_Retrs ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Retrs)")
                
                // 调用成功回调
                successCallback_Retrs?(userAcc_Retrs)
                
            case let userCredential_Retrs as ASPasswordCredential:
                // 密码凭证
                let user_Retrs = userCredential_Retrs.user
                _ = userCredential_Retrs.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Retrs)")
                
                // 调用成功回调
                successCallback_Retrs?(user_Retrs)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Retrs?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Retrs = error as? ASAuthorizationError {
                
                var errorMessage_Retrs = ""

                switch authError_Retrs.code {
                case .unknown:
                    errorMessage_Retrs = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Retrs = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Retrs = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Retrs = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Retrs = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Retrs = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Retrs = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Retrs = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Retrs = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Retrs = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Retrs = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Retrs = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Retrs?(errorMessage_Retrs)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Retrs: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Retrs = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Retrs = windowScene_Retrs.windows.first(where: { $0.isKeyWindow }) {
            return window_Retrs
        }
        
        // 备选方案：返回第一个窗口
        if let window_Retrs = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Retrs
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
