import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Echd: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Echd: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .black
        view_Echd.layer.cornerRadius = 12
        view_Echd.layer.masksToBounds = true
        return view_Echd
    }()
    
    /// 苹果图标
    private let appleIconView_Echd: UIImageView = {
        let imageView_Echd = UIImageView()
        imageView_Echd.image = UIImage(systemName: "apple.logo")
        imageView_Echd.tintColor = .white
        imageView_Echd.contentMode = .scaleAspectFit
        return imageView_Echd
    }()
    
    /// 文字标签
    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Continue with Apple"
        label_Echd.textColor = .white
        label_Echd.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Echd: UIStackView = {
        let stack_Echd = UIStackView()
        stack_Echd.axis = .horizontal
        stack_Echd.alignment = .center
        stack_Echd.spacing = 10
        stack_Echd.isUserInteractionEnabled = false
        return stack_Echd
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Echd: @escaping () -> Void) {
        self.onTap_Echd = onTap_Echd
        super.init(frame: .zero)
        setupUI_Echd()
        setupGesture_Echd()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Echd() {
        addSubview(containerView_Echd)
        containerView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Echd.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Echd.addArrangedSubview(appleIconView_Echd)
        contentStack_Echd.addArrangedSubview(titleLabel_Echd)

        containerView_Echd.addSubview(contentStack_Echd)
        contentStack_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Echd() {
        let tapGesture_Echd = UITapGestureRecognizer(target: self, action: #selector(handleTap_Echd))
        containerView_Echd.addGestureRecognizer(tapGesture_Echd)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Echd() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Echd.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Echd.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Echd?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Echd: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Echd: UIViewController?
    
    /// 成功回调
    private var successCallback_Echd: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Echd: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Echd: UIViewController) {
        self.viewController_Echd = viewController_Echd
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Echd(
        success_Echd: @escaping (String) -> Void,
        failure_Echd: @escaping (String) -> Void
    ) {
        self.successCallback_Echd = success_Echd
        self.failureCallback_Echd = failure_Echd
        
        // 创建Apple ID授权请求
        let appleIDProvider_Echd = ASAuthorizationAppleIDProvider()
        let request_Echd = appleIDProvider_Echd.createRequest()
        request_Echd.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Echd = ASAuthorizationController(authorizationRequests: [request_Echd])
        authorizationController_Echd.delegate = self
        authorizationController_Echd.presentationContextProvider = self
        authorizationController_Echd.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Echd: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Echd as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Echd = appleIDCredential_Echd.email
                
                // 生成用户账号
                var userAcc_Echd = ""
                if email_Echd == nil || email_Echd == "" {
                    userAcc_Echd = "appleId"
                } else {
                    userAcc_Echd = email_Echd ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Echd)")
                
                // 调用成功回调
                successCallback_Echd?(userAcc_Echd)
                
            case let userCredential_Echd as ASPasswordCredential:
                // 密码凭证
                let user_Echd = userCredential_Echd.user
                _ = userCredential_Echd.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Echd)")
                
                // 调用成功回调
                successCallback_Echd?(user_Echd)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Echd?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Echd = error as? ASAuthorizationError {
                
                var errorMessage_Echd = ""

                switch authError_Echd.code {
                case .unknown:
                    errorMessage_Echd = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Echd = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Echd = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Echd = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Echd = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Echd = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Echd = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Echd = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Echd = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Echd = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Echd = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Echd = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Echd?(errorMessage_Echd)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Echd: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Echd = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Echd = windowScene_Echd.windows.first(where: { $0.isKeyWindow }) {
            return window_Echd
        }
        
        // 备选方案：返回第一个窗口
        if let window_Echd = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Echd
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
