import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Vestir: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Vestir: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Vestir: UIView = {
        let view_Vestir = UIView()
        view_Vestir.backgroundColor = .black
        view_Vestir.layer.cornerRadius = 12
        view_Vestir.layer.masksToBounds = true
        return view_Vestir
    }()
    
    /// 苹果图标
    private let appleIconView_Vestir: UIImageView = {
        let imageView_Vestir = UIImageView()
        imageView_Vestir.image = UIImage(systemName: "apple.logo")
        imageView_Vestir.tintColor = .white
        imageView_Vestir.contentMode = .scaleAspectFit
        return imageView_Vestir
    }()
    
    /// 文字标签
    private let titleLabel_Vestir: UILabel = {
        let label_Vestir = UILabel()
        label_Vestir.text = "Continue with Apple"
        label_Vestir.textColor = .white
        label_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Vestir.textAlignment = .center
        return label_Vestir
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Vestir: UIStackView = {
        let stack_Vestir = UIStackView()
        stack_Vestir.axis = .horizontal
        stack_Vestir.alignment = .center
        stack_Vestir.spacing = 10
        stack_Vestir.isUserInteractionEnabled = false
        return stack_Vestir
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Vestir: @escaping () -> Void) {
        self.onTap_Vestir = onTap_Vestir
        super.init(frame: .zero)
        setupUI_Vestir()
        setupGesture_Vestir()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Vestir() {
        addSubview(containerView_Vestir)
        containerView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Vestir.addArrangedSubview(appleIconView_Vestir)
        contentStack_Vestir.addArrangedSubview(titleLabel_Vestir)

        containerView_Vestir.addSubview(contentStack_Vestir)
        contentStack_Vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Vestir() {
        let tapGesture_Vestir = UITapGestureRecognizer(target: self, action: #selector(handleTap_Vestir))
        containerView_Vestir.addGestureRecognizer(tapGesture_Vestir)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Vestir() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Vestir.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Vestir.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Vestir?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Vestir: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Vestir: UIViewController?
    
    /// 成功回调
    private var successCallback_Vestir: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Vestir: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Vestir: UIViewController) {
        self.viewController_Vestir = viewController_Vestir
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Vestir(
        success_Vestir: @escaping (String) -> Void,
        failure_Vestir: @escaping (String) -> Void
    ) {
        self.successCallback_Vestir = success_Vestir
        self.failureCallback_Vestir = failure_Vestir
        
        // 创建Apple ID授权请求
        let appleIDProvider_Vestir = ASAuthorizationAppleIDProvider()
        let request_Vestir = appleIDProvider_Vestir.createRequest()
        request_Vestir.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Vestir = ASAuthorizationController(authorizationRequests: [request_Vestir])
        authorizationController_Vestir.delegate = self
        authorizationController_Vestir.presentationContextProvider = self
        authorizationController_Vestir.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Vestir: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Vestir as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Vestir = appleIDCredential_Vestir.email
                
                // 生成用户账号
                var userAcc_Vestir = ""
                if email_Vestir == nil || email_Vestir == "" {
                    userAcc_Vestir = "appleId"
                } else {
                    userAcc_Vestir = email_Vestir ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Vestir)")
                
                // 调用成功回调
                successCallback_Vestir?(userAcc_Vestir)
                
            case let userCredential_Vestir as ASPasswordCredential:
                // 密码凭证
                let user_Vestir = userCredential_Vestir.user
                _ = userCredential_Vestir.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Vestir)")
                
                // 调用成功回调
                successCallback_Vestir?(user_Vestir)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Vestir?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Vestir = error as? ASAuthorizationError {
                
                var errorMessage_Vestir = ""

                switch authError_Vestir.code {
                case .unknown:
                    errorMessage_Vestir = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Vestir = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Vestir = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Vestir = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Vestir = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Vestir = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Vestir = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Vestir = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Vestir = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Vestir = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Vestir = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Vestir = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Vestir?(errorMessage_Vestir)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Vestir: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Vestir = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Vestir = windowScene_Vestir.windows.first(where: { $0.isKeyWindow }) {
            return window_Vestir
        }
        
        // 备选方案：返回第一个窗口
        if let window_Vestir = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Vestir
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
