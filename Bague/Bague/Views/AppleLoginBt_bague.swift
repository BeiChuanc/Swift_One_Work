import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Bague: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Bague: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Bague: UIView = {
        let view_Bague = UIView()
        view_Bague.backgroundColor = .black
        view_Bague.layer.cornerRadius = 12
        view_Bague.layer.masksToBounds = true
        return view_Bague
    }()
    
    /// 苹果图标
    private let appleIconView_Bague: UIImageView = {
        let imageView_Bague = UIImageView()
        imageView_Bague.image = UIImage(systemName: "apple.logo")
        imageView_Bague.tintColor = .white
        imageView_Bague.contentMode = .scaleAspectFit
        return imageView_Bague
    }()
    
    /// 文字标签
    private let titleLabel_Bague: UILabel = {
        let label_Bague = UILabel()
        label_Bague.text = "Continue with Apple"
        label_Bague.textColor = .white
        label_Bague.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Bague.textAlignment = .center
        return label_Bague
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Bague: UIStackView = {
        let stack_Bague = UIStackView()
        stack_Bague.axis = .horizontal
        stack_Bague.alignment = .center
        stack_Bague.spacing = 10
        stack_Bague.isUserInteractionEnabled = false
        return stack_Bague
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Bague: @escaping () -> Void) {
        self.onTap_Bague = onTap_Bague
        super.init(frame: .zero)
        setupUI_Bague()
        setupGesture_Bague()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Bague() {
        addSubview(containerView_Bague)
        containerView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Bague.addArrangedSubview(appleIconView_Bague)
        contentStack_Bague.addArrangedSubview(titleLabel_Bague)

        containerView_Bague.addSubview(contentStack_Bague)
        contentStack_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Bague() {
        let tapGesture_Bague = UITapGestureRecognizer(target: self, action: #selector(handleTap_Bague))
        containerView_Bague.addGestureRecognizer(tapGesture_Bague)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Bague() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Bague.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Bague.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Bague?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Bague: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Bague: UIViewController?
    
    /// 成功回调
    private var successCallback_Bague: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Bague: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Bague: UIViewController) {
        self.viewController_Bague = viewController_Bague
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Bague(
        success_Bague: @escaping (String) -> Void,
        failure_Bague: @escaping (String) -> Void
    ) {
        self.successCallback_Bague = success_Bague
        self.failureCallback_Bague = failure_Bague
        
        // 创建Apple ID授权请求
        let appleIDProvider_Bague = ASAuthorizationAppleIDProvider()
        let request_Bague = appleIDProvider_Bague.createRequest()
        request_Bague.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Bague = ASAuthorizationController(authorizationRequests: [request_Bague])
        authorizationController_Bague.delegate = self
        authorizationController_Bague.presentationContextProvider = self
        authorizationController_Bague.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Bague: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Bague as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Bague = appleIDCredential_Bague.email
                
                // 生成用户账号
                var userAcc_Bague = ""
                if email_Bague == nil || email_Bague == "" {
                    userAcc_Bague = "appleId"
                } else {
                    userAcc_Bague = email_Bague ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Bague)")
                
                // 调用成功回调
                successCallback_Bague?(userAcc_Bague)
                
            case let userCredential_Bague as ASPasswordCredential:
                // 密码凭证
                let user_Bague = userCredential_Bague.user
                _ = userCredential_Bague.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Bague)")
                
                // 调用成功回调
                successCallback_Bague?(user_Bague)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Bague?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Bague = error as? ASAuthorizationError {
                
                var errorMessage_Bague = ""

                switch authError_Bague.code {
                case .unknown:
                    errorMessage_Bague = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Bague = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Bague = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Bague = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Bague = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Bague = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Bague = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Bague = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Bague = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Bague = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Bague = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Bague = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Bague?(errorMessage_Bague)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Bague: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Bague = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Bague = windowScene_Bague.windows.first(where: { $0.isKeyWindow }) {
            return window_Bague
        }
        
        // 备选方案：返回第一个窗口
        if let window_Bague = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Bague
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
