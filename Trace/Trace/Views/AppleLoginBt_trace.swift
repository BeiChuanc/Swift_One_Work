import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
/// 核心作用：封装 Apple 登录的完整 UI 与逻辑（内部管理 AppleLoginManager_Trace），
///          外部只需传入所在 ViewController 及成功/失败回调，无需在业务页面中处理任何 Apple 登录细节
/// 关键属性：
///   - viewController_Trace：用于呈现 Apple 授权界面的宿主控制器
///   - success_Trace：授权成功回调，参数为用户账号标识（邮箱或 appleId）
///   - failure_Trace：授权失败回调，参数为错误描述
@MainActor
class AppleLoginBt_Trace: UIView {

    // MARK: - 私有属性

    /// Apple 登录管理器（组件内部持有，无需外部管理）
    private var appleLoginManager_Trace: AppleLoginManager_Trace?

    /// 宿主控制器（弱引用，避免循环引用）
    private weak var viewController_Trace: UIViewController?

    /// 授权成功回调
    private var success_Trace: ((String) -> Void)?

    /// 授权失败回调
    private var failure_Trace: ((String) -> Void)?

    // MARK: - UI 组件

    /// 容器视图
    private let containerView_Trace: UIView = {
        let view_Trace = UIView()
        view_Trace.backgroundColor = .black
        view_Trace.layer.cornerRadius = 12
        view_Trace.layer.masksToBounds = true
        return view_Trace
    }()

    /// 苹果图标
    private let appleIconView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.image = UIImage(systemName: "apple.logo")
        imageView_Trace.tintColor = .white
        imageView_Trace.contentMode = .scaleAspectFit
        return imageView_Trace
    }()

    /// 文字标签
    private let titleLabel_Trace: UILabel = {
        let label_Trace = UILabel()
        label_Trace.text = "Continue with Apple"
        label_Trace.textColor = .white
        label_Trace.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Trace.textAlignment = .center
        return label_Trace
    }()

    // MARK: - 初始化

    /// 初始化 Apple 登录按钮
    /// - Parameters:
    ///   - viewController_Trace: 用于呈现 Apple 授权 UI 的宿主控制器
    ///   - success_Trace: 授权成功回调，返回用户账号标识字符串
    ///   - failure_Trace: 授权失败回调，返回错误描述字符串
    init(
        from viewController_Trace: UIViewController,
        success_Trace: @escaping (String) -> Void,
        failure_Trace: @escaping (String) -> Void
    ) {
        self.viewController_Trace = viewController_Trace
        self.success_Trace = success_Trace
        self.failure_Trace = failure_Trace
        super.init(frame: .zero)
        setupUI_Trace()
        setupGesture_Trace()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 设置

    private func setupUI_Trace() {
        // 用水平 StackView 包裹图标与文字，整体居中对齐
        let contentStack_Trace = UIStackView(arrangedSubviews: [appleIconView_Trace, titleLabel_Trace])
        contentStack_Trace.axis = .horizontal
        contentStack_Trace.spacing = 10
        contentStack_Trace.alignment = .center
        contentStack_Trace.isUserInteractionEnabled = false

        addSubview(containerView_Trace)
        containerView_Trace.addSubview(contentStack_Trace)

        containerView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        appleIconView_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // StackView 整体水平垂直居中
        contentStack_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupGesture_Trace() {
        let tap_Trace = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        containerView_Trace.addGestureRecognizer(tap_Trace)
    }

    // MARK: - 事件处理

    /// 处理点击：执行按压动画，然后启动 Apple 登录流程
    @objc private func handleTap_Trace() {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Trace.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Trace.transform = .identity
            }
        }
        startAppleLogin_Trace()
    }

    /// 启动 Apple 登录授权流程（内部调用，外部无需感知）
    private func startAppleLogin_Trace() {
        guard let vc_Trace = viewController_Trace else { return }
        appleLoginManager_Trace = AppleLoginManager_Trace(viewController_Trace: vc_Trace)
        appleLoginManager_Trace?.startAppleLogin_Trace(
            success_Trace: { [weak self] account_Trace in
                self?.success_Trace?(account_Trace)
            },
            failure_Trace: { [weak self] error_Trace in
                self?.failure_Trace?(error_Trace)
            }
        )
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Trace: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Trace: UIViewController?
    
    /// 成功回调
    private var successCallback_Trace: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Trace: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Trace: UIViewController) {
        self.viewController_Trace = viewController_Trace
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Trace(
        success_Trace: @escaping (String) -> Void,
        failure_Trace: @escaping (String) -> Void
    ) {
        self.successCallback_Trace = success_Trace
        self.failureCallback_Trace = failure_Trace
        
        // 创建Apple ID授权请求
        let appleIDProvider_Trace = ASAuthorizationAppleIDProvider()
        let request_Trace = appleIDProvider_Trace.createRequest()
        request_Trace.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Trace = ASAuthorizationController(authorizationRequests: [request_Trace])
        authorizationController_Trace.delegate = self
        authorizationController_Trace.presentationContextProvider = self
        authorizationController_Trace.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Trace: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Trace as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Trace = appleIDCredential_Trace.email
                
                // 生成用户账号
                var userAcc_Trace = ""
                if email_Trace == nil || email_Trace == "" {
                    userAcc_Trace = "appleId"
                } else {
                    userAcc_Trace = email_Trace ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Trace)")
                
                // 调用成功回调
                successCallback_Trace?(userAcc_Trace)
                
            case let userCredential_Trace as ASPasswordCredential:
                // 密码凭证
                let user_Trace = userCredential_Trace.user
                _ = userCredential_Trace.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Trace)")
                
                // 调用成功回调
                successCallback_Trace?(user_Trace)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Trace?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Trace = error as? ASAuthorizationError {
                
                var errorMessage_Trace = ""

                switch authError_Trace.code {
                case .unknown:
                    errorMessage_Trace = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Trace = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Trace = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Trace = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Trace = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Trace = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Trace = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Trace = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Trace = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Trace = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Trace = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Trace = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Trace?(errorMessage_Trace)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Trace: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Trace = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Trace = windowScene_Trace.windows.first(where: { $0.isKeyWindow }) {
            return window_Trace
        }
        
        // 备选方案：返回第一个窗口
        if let window_Trace = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Trace
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
