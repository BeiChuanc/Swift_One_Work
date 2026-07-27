import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件
class AppleLoginBt_Orna: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Orna: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Orna: UIView = {
        let view_Orna = UIView()
        view_Orna.backgroundColor = .black
        view_Orna.layer.cornerRadius = 12
        view_Orna.layer.masksToBounds = true
        return view_Orna
    }()
    
    /// 苹果图标
    private let appleIconView_Orna: UIImageView = {
        let imageView_Orna = UIImageView()
        imageView_Orna.image = UIImage(systemName: "apple.logo")
        imageView_Orna.tintColor = .white
        imageView_Orna.contentMode = .scaleAspectFit
        return imageView_Orna
    }()
    
    /// 文字标签
    private let titleLabel_Orna: UILabel = {
        let label_Orna = UILabel()
        label_Orna.text = "Continue with Apple"
        label_Orna.textColor = .white
        label_Orna.font = UIFont.funFont_Orna(ofSize: 16, weight: .semibold)
        label_Orna.textAlignment = .center
        return label_Orna
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Orna: UIStackView = {
        let stack_Orna = UIStackView()
        stack_Orna.axis = .horizontal
        stack_Orna.alignment = .center
        stack_Orna.spacing = 10
        stack_Orna.isUserInteractionEnabled = false
        return stack_Orna
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Orna: @escaping () -> Void) {
        self.onTap_Orna = onTap_Orna
        super.init(frame: .zero)
        setupUI_Orna()
        setupGesture_Orna()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Orna() {
        addSubview(containerView_Orna)
        containerView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }

        // 图标固定尺寸
        appleIconView_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Orna.addArrangedSubview(appleIconView_Orna)
        contentStack_Orna.addArrangedSubview(titleLabel_Orna)

        containerView_Orna.addSubview(contentStack_Orna)
        contentStack_Orna.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Orna() {
        let tapGesture_Orna = UITapGestureRecognizer(target: self, action: #selector(handleTap_Orna))
        containerView_Orna.addGestureRecognizer(tapGesture_Orna)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Orna() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Orna.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Orna.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Orna?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Orna: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Orna: UIViewController?
    
    /// 成功回调
    private var successCallback_Orna: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Orna: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Orna: UIViewController) {
        self.viewController_Orna = viewController_Orna
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Orna(
        success_Orna: @escaping (String) -> Void,
        failure_Orna: @escaping (String) -> Void
    ) {
        self.successCallback_Orna = success_Orna
        self.failureCallback_Orna = failure_Orna
        
        // 创建Apple ID授权请求
        let appleIDProvider_Orna = ASAuthorizationAppleIDProvider()
        let request_Orna = appleIDProvider_Orna.createRequest()
        request_Orna.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Orna = ASAuthorizationController(authorizationRequests: [request_Orna])
        authorizationController_Orna.delegate = self
        authorizationController_Orna.presentationContextProvider = self
        authorizationController_Orna.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Orna: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Orna as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Orna = appleIDCredential_Orna.email
                
                // 生成用户账号
                var userAcc_Orna = ""
                if email_Orna == nil || email_Orna == "" {
                    userAcc_Orna = "appleId"
                } else {
                    userAcc_Orna = email_Orna ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Orna)")
                
                // 调用成功回调
                successCallback_Orna?(userAcc_Orna)
                
            case let userCredential_Orna as ASPasswordCredential:
                // 密码凭证
                let user_Orna = userCredential_Orna.user
                _ = userCredential_Orna.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Orna)")
                
                // 调用成功回调
                successCallback_Orna?(user_Orna)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Orna?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Orna = error as? ASAuthorizationError {
                
                var errorMessage_Orna = ""

                switch authError_Orna.code {
                case .unknown:
                    errorMessage_Orna = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Orna = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Orna = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Orna = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Orna = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Orna = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Orna = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Orna = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Orna = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Orna = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Orna = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Orna = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Orna?(errorMessage_Orna)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Orna: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Orna = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Orna = windowScene_Orna.windows.first(where: { $0.isKeyWindow }) {
            return window_Orna
        }
        
        // 备选方案：返回第一个窗口
        if let window_Orna = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Orna
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
