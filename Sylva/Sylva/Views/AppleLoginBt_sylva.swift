import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Sylva: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Sylva: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.backgroundColor = .black
        view_Sylva.layer.cornerRadius = 12
        view_Sylva.layer.masksToBounds = true
        return view_Sylva
    }()
    
    /// 苹果图标
    private let appleIconView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.image = UIImage(systemName: "apple.logo")
        imageView_Sylva.tintColor = .white
        imageView_Sylva.contentMode = .scaleAspectFit
        return imageView_Sylva
    }()
    
    /// 文字标签
    private let titleLabel_Sylva: UILabel = {
        let label_Sylva = UILabel()
        label_Sylva.text = "Continue with Apple"
        label_Sylva.textColor = .white
        label_Sylva.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Sylva.textAlignment = .center
        return label_Sylva
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Sylva: UIStackView = {
        let stack_Sylva = UIStackView()
        stack_Sylva.axis = .horizontal
        stack_Sylva.alignment = .center
        stack_Sylva.spacing = 10
        stack_Sylva.isUserInteractionEnabled = false
        return stack_Sylva
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Sylva: @escaping () -> Void) {
        self.onTap_Sylva = onTap_Sylva
        super.init(frame: .zero)
        setupUI_Sylva()
        setupGesture_Sylva()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Sylva() {
        addSubview(containerView_Sylva)
        containerView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Sylva.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Sylva.addArrangedSubview(appleIconView_Sylva)
        contentStack_Sylva.addArrangedSubview(titleLabel_Sylva)

        containerView_Sylva.addSubview(contentStack_Sylva)
        contentStack_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Sylva() {
        let tapGesture_Sylva = UITapGestureRecognizer(target: self, action: #selector(handleTap_Sylva))
        containerView_Sylva.addGestureRecognizer(tapGesture_Sylva)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Sylva() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Sylva.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Sylva.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Sylva?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Sylva: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Sylva: UIViewController?
    
    /// 成功回调
    private var successCallback_Sylva: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Sylva: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Sylva: UIViewController) {
        self.viewController_Sylva = viewController_Sylva
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Sylva(
        success_Sylva: @escaping (String) -> Void,
        failure_Sylva: @escaping (String) -> Void
    ) {
        self.successCallback_Sylva = success_Sylva
        self.failureCallback_Sylva = failure_Sylva
        
        // 创建Apple ID授权请求
        let appleIDProvider_Sylva = ASAuthorizationAppleIDProvider()
        let request_Sylva = appleIDProvider_Sylva.createRequest()
        request_Sylva.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Sylva = ASAuthorizationController(authorizationRequests: [request_Sylva])
        authorizationController_Sylva.delegate = self
        authorizationController_Sylva.presentationContextProvider = self
        authorizationController_Sylva.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Sylva: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Sylva as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Sylva = appleIDCredential_Sylva.email
                
                // 生成用户账号
                var userAcc_Sylva = ""
                if email_Sylva == nil || email_Sylva == "" {
                    userAcc_Sylva = "appleId"
                } else {
                    userAcc_Sylva = email_Sylva ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Sylva)")
                
                // 调用成功回调
                successCallback_Sylva?(userAcc_Sylva)
                
            case let userCredential_Sylva as ASPasswordCredential:
                // 密码凭证
                let user_Sylva = userCredential_Sylva.user
                _ = userCredential_Sylva.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Sylva)")
                
                // 调用成功回调
                successCallback_Sylva?(user_Sylva)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Sylva?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Sylva = error as? ASAuthorizationError {
                
                var errorMessage_Sylva = ""

                switch authError_Sylva.code {
                case .unknown:
                    errorMessage_Sylva = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Sylva = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Sylva = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Sylva = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Sylva = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Sylva = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Sylva = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Sylva = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Sylva = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Sylva = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Sylva = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Sylva = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Sylva?(errorMessage_Sylva)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Sylva: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Sylva = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Sylva = windowScene_Sylva.windows.first(where: { $0.isKeyWindow }) {
            return window_Sylva
        }
        
        // 备选方案：返回第一个窗口
        if let window_Sylva = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Sylva
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
