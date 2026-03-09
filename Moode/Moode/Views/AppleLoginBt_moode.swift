import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Moode: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Moode: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Moode: UIView = {
        let view_Moode = UIView()
        view_Moode.backgroundColor = .black
        view_Moode.layer.cornerRadius = 12
        view_Moode.layer.masksToBounds = true
        return view_Moode
    }()
    
    /// 苹果图标
    private let appleIconView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.image = UIImage(systemName: "apple.logo")
        imageView_Moode.tintColor = .white
        imageView_Moode.contentMode = .scaleAspectFit
        return imageView_Moode
    }()
    
    /// 文字标签
    private let titleLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Continue with Apple"
        label_Moode.textColor = .white
        label_Moode.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Moode.textAlignment = .center
        return label_Moode
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Moode: @escaping () -> Void) {
        self.onTap_Moode = onTap_Moode
        super.init(frame: .zero)
        setupUI_Moode()
        setupGesture_Moode()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Moode() {
        addSubview(containerView_Moode)
        containerView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 用内容包裹视图将图标+文字整体居中
        let contentWrapper_Moode = UIView()
        contentWrapper_Moode.isUserInteractionEnabled = false
        containerView_Moode.addSubview(contentWrapper_Moode)
        contentWrapper_Moode.addSubview(appleIconView_Moode)
        contentWrapper_Moode.addSubview(titleLabel_Moode)
        
        // 图标约束（在包裹视图内靠左）
        appleIconView_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 文字标签约束（紧跟图标右侧）
        titleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(appleIconView_Moode.snp.right).offset(10)
            make.right.centerY.equalToSuperview()
        }
        
        // 包裹视图整体水平居中
        contentWrapper_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Moode() {
        let tapGesture_Moode = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        containerView_Moode.addGestureRecognizer(tapGesture_Moode)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Moode() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Moode.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Moode.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Moode?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Moode: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Moode: UIViewController?
    
    /// 成功回调
    private var successCallback_Moode: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Moode: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Moode: UIViewController) {
        self.viewController_Moode = viewController_Moode
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Moode(
        success_Moode: @escaping (String) -> Void,
        failure_Moode: @escaping (String) -> Void
    ) {
        self.successCallback_Moode = success_Moode
        self.failureCallback_Moode = failure_Moode
        
        // 创建Apple ID授权请求
        let appleIDProvider_Moode = ASAuthorizationAppleIDProvider()
        let request_Moode = appleIDProvider_Moode.createRequest()
        request_Moode.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Moode = ASAuthorizationController(authorizationRequests: [request_Moode])
        authorizationController_Moode.delegate = self
        authorizationController_Moode.presentationContextProvider = self
        authorizationController_Moode.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Moode: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Moode as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Moode = appleIDCredential_Moode.email
                
                // 生成用户账号
                var userAcc_Moode = ""
                if email_Moode == nil || email_Moode == "" {
                    userAcc_Moode = "appleId"
                } else {
                    userAcc_Moode = email_Moode ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Moode)")
                
                // 调用成功回调
                successCallback_Moode?(userAcc_Moode)
                
            case let userCredential_Moode as ASPasswordCredential:
                // 密码凭证
                let user_Moode = userCredential_Moode.user
                _ = userCredential_Moode.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Moode)")
                
                // 调用成功回调
                successCallback_Moode?(user_Moode)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Moode?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Moode = error as? ASAuthorizationError {
                
                var errorMessage_Moode = ""

                switch authError_Moode.code {
                case .unknown:
                    errorMessage_Moode = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Moode = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Moode = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Moode = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Moode = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Moode = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Moode = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Moode = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Moode = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Moode = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Moode = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Moode = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Moode?(errorMessage_Moode)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Moode: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Moode = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Moode = windowScene_Moode.windows.first(where: { $0.isKeyWindow }) {
            return window_Moode
        }
        
        // 备选方案：返回第一个窗口
        if let window_Moode = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Moode
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
