import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
/// 核心功能：展示黑色底色 "Continue with Apple" 样式按钮，点击后触发传入的回调
/// 设计思路：容器视图 + StackView 居中排列苹果图标与文字，手势识别触发动画与回调
/// 关键属性：onTap_Clara - 外部注入的点击回调闭包
/// 关键方法：setupUI_Clara / setupGesture_Clara / handleTap_Clara
class AppleLoginBt_Clara: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Clara: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.backgroundColor = .black
        view_Clara.layer.cornerRadius = 22
        view_Clara.layer.masksToBounds = true
        return view_Clara
    }()
    
    /// 苹果图标
    private let appleIconView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.image = UIImage(systemName: "apple.logo")
        imageView_Clara.tintColor = .white
        imageView_Clara.contentMode = .scaleAspectFit
        return imageView_Clara
    }()
    
    /// 文字标签
    private let titleLabel_Clara: UILabel = {
        let label_Clara = UILabel()
        label_Clara.text = "Continue with Apple"
        label_Clara.textColor = .white
        label_Clara.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Clara.textAlignment = .center
        return label_Clara
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Clara: UIStackView = {
        let stack_Clara = UIStackView()
        stack_Clara.axis = .horizontal
        stack_Clara.alignment = .center
        stack_Clara.spacing = 10
        stack_Clara.isUserInteractionEnabled = false
        return stack_Clara
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    /// - Parameter onTap_Clara: 点击时触发的回调闭包
    init(onTap_Clara: @escaping () -> Void) {
        self.onTap_Clara = onTap_Clara
        super.init(frame: .zero)
        setupUI_Clara()
        setupGesture_Clara()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 构建内部布局
    private func setupUI_Clara() {
        addSubview(containerView_Clara)
        containerView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        appleIconView_Clara.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        contentStack_Clara.addArrangedSubview(appleIconView_Clara)
        contentStack_Clara.addArrangedSubview(titleLabel_Clara)

        containerView_Clara.addSubview(contentStack_Clara)
        contentStack_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 注册点击手势
    private func setupGesture_Clara() {
        let tapGesture_Clara = UITapGestureRecognizer(target: self, action: #selector(handleTap_Clara))
        containerView_Clara.addGestureRecognizer(tapGesture_Clara)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件：播放缩放动画后调用外部回调
    @objc private func handleTap_Clara() {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Clara.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Clara.transform = .identity
            }
        }
        onTap_Clara?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
/// 核心功能：封装 ASAuthorization 授权流程，通过成功/失败回调将结果回传给调用方
/// 设计思路：持有弱引用 VC 作为展示锚点，通过 delegate 回调解耦授权结果处理
/// 关键方法：startAppleLogin_Clara - 发起授权请求
@MainActor
class AppleLoginManager_Clara: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器（弱引用，防止循环引用）
    private weak var viewController_Clara: UIViewController?
    
    /// 授权成功回调，参数为用户账号标识
    private var successCallback_Clara: ((String) -> Void)?
    
    /// 授权失败回调，参数为错误描述
    private var failureCallback_Clara: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// - Parameter viewController_Clara: 发起授权的宿主控制器
    init(viewController_Clara: UIViewController) {
        self.viewController_Clara = viewController_Clara
        super.init()
    }
    
    // MARK: - 公共方法
    
    /// 发起 Apple ID 授权请求
    /// - Parameters:
    ///   - success_Clara: 授权成功回调，返回用户账号标识
    ///   - failure_Clara: 授权失败回调，返回错误描述
    func startAppleLogin_Clara(
        success_Clara: @escaping (String) -> Void,
        failure_Clara: @escaping (String) -> Void
    ) {
        self.successCallback_Clara = success_Clara
        self.failureCallback_Clara = failure_Clara
        
        let appleIDProvider_Clara = ASAuthorizationAppleIDProvider()
        let request_Clara = appleIDProvider_Clara.createRequest()
        request_Clara.requestedScopes = [.fullName, .email]
        
        let authorizationController_Clara = ASAuthorizationController(authorizationRequests: [request_Clara])
        authorizationController_Clara.delegate = self
        authorizationController_Clara.presentationContextProvider = self
        authorizationController_Clara.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Clara: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Clara as ASAuthorizationAppleIDCredential:
                let email_Clara = appleIDCredential_Clara.email
                let userAcc_Clara: String
                if let email = email_Clara, !email.isEmpty {
                    userAcc_Clara = email
                } else {
                    userAcc_Clara = "appleId"
                }
                print("✅ Apple登录成功，用户账号：\(userAcc_Clara)")
                self.successCallback_Clara?(userAcc_Clara)
                
            case let userCredential_Clara as ASPasswordCredential:
                let user_Clara = userCredential_Clara.user
                print("✅ 密码凭证登录成功，用户：\(user_Clara)")
                self.successCallback_Clara?(user_Clara)
                
            default:
                print("❌ 未知授权类型")
                self.failureCallback_Clara?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            guard let authError_Clara = error as? ASAuthorizationError else { return }
            
            var errorMessage_Clara = ""
            switch authError_Clara.code {
            case .unknown:
                errorMessage_Clara = "Unknown error"
                print("❌ 授权未知错误")
            case .canceled:
                errorMessage_Clara = "Authorization canceled"
                print("⚠️ 授权取消")
            case .invalidResponse:
                errorMessage_Clara = "Invalid response"
                print("❌ 授权无效请求")
            case .notHandled:
                errorMessage_Clara = "Not handled"
                print("❌ 授权未能处理")
            case .failed:
                errorMessage_Clara = "Authorization failed"
                print("❌ 授权失败")
            case .notInteractive:
                errorMessage_Clara = "Not interactive"
                print("❌ 授权非交互式")
            case .matchedExcludedCredential:
                errorMessage_Clara = "Matched excluded credential"
                print("❌ 该凭证属于被排除的范围")
            case .credentialImport:
                errorMessage_Clara = "Credential import"
                print("❌ 凭证导入")
            case .credentialExport:
                errorMessage_Clara = "Credential export"
                print("❌ 凭证导出")
            case .preferSignInWithApple:
                errorMessage_Clara = "Prefer sign in with Apple"
                print("❌ 偏好使用Apple登录")
            case .deviceNotConfiguredForPasskeyCreation:
                errorMessage_Clara = "Device not configured for Passkey creation"
                print("❌ 设备未配置用于创建Passkey")
            @unknown default:
                errorMessage_Clara = "Unknown error"
                print("❌ 授权其他原因")
            }
            self.failureCallback_Clara?(errorMessage_Clara)
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Clara: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene_Clara = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Clara = windowScene_Clara.windows.first(where: { $0.isKeyWindow }) {
            return window_Clara
        }
        if let window_Clara = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Clara
        }
        return ASPresentationAnchor()
    }
}
