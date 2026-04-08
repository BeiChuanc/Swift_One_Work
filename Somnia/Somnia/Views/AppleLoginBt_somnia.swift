import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Somnia: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Somnia: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Somnia: UIView = {
        let view_Somnia = UIView()
        view_Somnia.backgroundColor = .black
        view_Somnia.layer.cornerRadius = 12
        view_Somnia.layer.masksToBounds = true
        return view_Somnia
    }()
    
    /// 苹果图标
    private let appleIconView_Somnia: UIImageView = {
        let imageView_Somnia = UIImageView()
        imageView_Somnia.image = UIImage(systemName: "apple.logo")
        imageView_Somnia.tintColor = .white
        imageView_Somnia.contentMode = .scaleAspectFit
        return imageView_Somnia
    }()
    
    /// 文字标签
    private let titleLabel_Somnia: UILabel = {
        let label_Somnia = UILabel()
        label_Somnia.text = "Continue with Apple"
        label_Somnia.textColor = .white
        label_Somnia.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Somnia.textAlignment = .center
        return label_Somnia
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Somnia: UIStackView = {
        let stack_Somnia = UIStackView()
        stack_Somnia.axis = .horizontal
        stack_Somnia.alignment = .center
        stack_Somnia.spacing = 10
        stack_Somnia.isUserInteractionEnabled = false
        return stack_Somnia
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Somnia: @escaping () -> Void) {
        self.onTap_Somnia = onTap_Somnia
        super.init(frame: .zero)
        setupUI_Somnia()
        setupGesture_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Somnia() {
        addSubview(containerView_Somnia)
        containerView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Somnia.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Somnia.addArrangedSubview(appleIconView_Somnia)
        contentStack_Somnia.addArrangedSubview(titleLabel_Somnia)

        containerView_Somnia.addSubview(contentStack_Somnia)
        contentStack_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Somnia() {
        let tapGesture_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        containerView_Somnia.addGestureRecognizer(tapGesture_Somnia)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Somnia() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Somnia.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Somnia.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Somnia?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Somnia: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Somnia: UIViewController?
    
    /// 成功回调
    private var successCallback_Somnia: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Somnia: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Somnia: UIViewController) {
        self.viewController_Somnia = viewController_Somnia
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Somnia(
        success_Somnia: @escaping (String) -> Void,
        failure_Somnia: @escaping (String) -> Void
    ) {
        self.successCallback_Somnia = success_Somnia
        self.failureCallback_Somnia = failure_Somnia
        
        // 创建Apple ID授权请求
        let appleIDProvider_Somnia = ASAuthorizationAppleIDProvider()
        let request_Somnia = appleIDProvider_Somnia.createRequest()
        request_Somnia.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Somnia = ASAuthorizationController(authorizationRequests: [request_Somnia])
        authorizationController_Somnia.delegate = self
        authorizationController_Somnia.presentationContextProvider = self
        authorizationController_Somnia.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Somnia: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Somnia as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Somnia = appleIDCredential_Somnia.email
                
                // 生成用户账号
                var userAcc_Somnia = ""
                if email_Somnia == nil || email_Somnia == "" {
                    userAcc_Somnia = "appleId"
                } else {
                    userAcc_Somnia = email_Somnia ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Somnia)")
                
                // 调用成功回调
                successCallback_Somnia?(userAcc_Somnia)
                
            case let userCredential_Somnia as ASPasswordCredential:
                // 密码凭证
                let user_Somnia = userCredential_Somnia.user
                _ = userCredential_Somnia.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Somnia)")
                
                // 调用成功回调
                successCallback_Somnia?(user_Somnia)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Somnia?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Somnia = error as? ASAuthorizationError {
                
                var errorMessage_Somnia = ""

                switch authError_Somnia.code {
                case .unknown:
                    errorMessage_Somnia = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Somnia = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Somnia = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Somnia = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Somnia = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Somnia = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Somnia = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Somnia = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Somnia = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Somnia = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Somnia = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Somnia = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Somnia?(errorMessage_Somnia)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Somnia: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Somnia = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Somnia = windowScene_Somnia.windows.first(where: { $0.isKeyWindow }) {
            return window_Somnia
        }
        
        // 备选方案：返回第一个窗口
        if let window_Somnia = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Somnia
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
