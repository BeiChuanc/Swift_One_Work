import Foundation
import UIKit
import AuthenticationServices

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
/// 功能：提供苹果登录的UI按钮和交互
/// 设计：黑色背景，白色苹果图标和文字，圆角设计
/// 关键方法：onTap_Wanderbell - 按钮点击回调
class AppleLoginButton_Wanderbell: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Wanderbell: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .black
        view_wanderbell.layer.cornerRadius = 12
        view_wanderbell.layer.masksToBounds = true
        return view_wanderbell
    }()
    
    /// 苹果图标
    private let appleIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "apple.logo")
        imageView_wanderbell.tintColor = .white
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 文字标签
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Continue with Apple"
        label_wanderbell.textColor = .white
        label_wanderbell.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    /// 参数：
    /// - onTap_wanderbell: 点击回调闭包
    init(onTap_wanderbell: @escaping () -> Void) {
        self.onTap_Wanderbell = onTap_wanderbell
        super.init(frame: .zero)
        setupUI_Wanderbell()
        setupGesture_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        addSubview(containerView_Wanderbell)
        containerView_Wanderbell.addSubview(appleIconView_Wanderbell)
        containerView_Wanderbell.addSubview(titleLabel_Wanderbell)
        
        // 容器视图约束
        containerView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 苹果图标约束
        appleIconView_Wanderbell.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(60)
            make.width.height.equalTo(22)
        }
        
        // 文字标签约束
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(appleIconView_Wanderbell.snp.right).offset(10)
        }
    }
    
    /// 设置手势
    private func setupGesture_Wanderbell() {
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(handleTap_Wanderbell))
        containerView_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Wanderbell() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Wanderbell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Wanderbell.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Wanderbell?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
/// 功能：处理Apple登录的授权流程和回调
/// 核心方法：
/// - startAppleLogin_Wanderbell：开始Apple登录流程
/// - 授权成功/失败回调处理
@MainActor
class AppleLoginManager_Wanderbell: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Wanderbell: UIViewController?
    
    /// 成功回调
    private var successCallback_Wanderbell: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Wanderbell: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    /// 参数：
    /// - viewController_wanderbell: 当前视图控制器
    init(viewController_wanderbell: UIViewController) {
        self.viewController_Wanderbell = viewController_wanderbell
        super.init()
    }
    
    // MARK: - 公共方法
    
    /// 开始Apple登录
    /// 参数：
    /// - success_wanderbell: 成功回调（返回用户账号）
    /// - failure_wanderbell: 失败回调（返回错误信息）
    func startAppleLogin_Wanderbell(
        success_wanderbell: @escaping (String) -> Void,
        failure_wanderbell: @escaping (String) -> Void
    ) {
        self.successCallback_Wanderbell = success_wanderbell
        self.failureCallback_Wanderbell = failure_wanderbell
        
        // 创建Apple ID授权请求
        let appleIDProvider_wanderbell = ASAuthorizationAppleIDProvider()
        let request_wanderbell = appleIDProvider_wanderbell.createRequest()
        request_wanderbell.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_wanderbell = ASAuthorizationController(authorizationRequests: [request_wanderbell])
        authorizationController_wanderbell.delegate = self
        authorizationController_wanderbell.presentationContextProvider = self
        authorizationController_wanderbell.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Wanderbell: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    /// 功能：处理授权成功后的凭证信息
    /// 参数：
    /// - controller: 授权控制器
    /// - authorization: 授权信息
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_wanderbell as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_wanderbell = appleIDCredential_wanderbell.email
                
                // 生成用户账号
                var userAcc_wanderbell = ""
                if email_wanderbell == nil || email_wanderbell == "" {
                    userAcc_wanderbell = "appleId"
                } else {
                    userAcc_wanderbell = email_wanderbell ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_wanderbell)")
                
                // 调用成功回调
                successCallback_Wanderbell?(userAcc_wanderbell)
                
            case let userCredential_wanderbell as ASPasswordCredential:
                // 密码凭证
                let user_wanderbell = userCredential_wanderbell.user
                _ = userCredential_wanderbell.password
                
                print("✅ 密码凭证登录成功，用户：\(user_wanderbell)")
                
                // 调用成功回调
                successCallback_Wanderbell?(user_wanderbell)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Wanderbell?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    /// 功能：处理授权失败的各种错误情况
    /// 参数：
    /// - controller: 授权控制器
    /// - error: 错误信息
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_wanderbell = error as? ASAuthorizationError {
                var errorMessage_wanderbell = ""
                
                switch authError_wanderbell.code {
                case .unknown:
                    errorMessage_wanderbell = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_wanderbell = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_wanderbell = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_wanderbell = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_wanderbell = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_wanderbell = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_wanderbell = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    print("❌ 凭证导入")
                case .credentialExport:
                    print("❌ 凭证导出")
                @unknown default:
                    errorMessage_wanderbell = "Other error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Wanderbell?(errorMessage_wanderbell)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Wanderbell: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    /// 功能：返回授权界面展示的窗口
    /// 返回值：ASPresentationAnchor - 展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_wanderbell = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_wanderbell = windowScene_wanderbell.windows.first(where: { $0.isKeyWindow }) {
            return window_wanderbell
        }
        
        // 备选方案：返回第一个窗口
        if let window_wanderbell = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_wanderbell
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
