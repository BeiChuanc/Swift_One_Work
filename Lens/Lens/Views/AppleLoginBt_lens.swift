import Foundation
import UIKit
import AuthenticationServices
import SnapKit

// MARK: - Apple登录按钮组件

/// Apple登录按钮组件（重构版）
/// 核心作用：展示 Apple 登录入口并回调点击事件
/// 设计思路：圆角胶囊 + 细边框 + 点击缩放反馈
class AppleLoginBt_Lens: UIView {
    
    // MARK: - 回调闭包
    
    /// 点击回调
    private var onTap_Lens: (() -> Void)?
    
    // MARK: - UI组件
    
    /// 容器视图
    private let containerView_Lens: UIView = {
        let view_Lens = UIView()
        view_Lens.backgroundColor = UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.85)
        view_Lens.layer.cornerRadius = 26
        view_Lens.layer.masksToBounds = true
        view_Lens.layer.borderWidth = 1
        view_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12).cgColor
        return view_Lens
    }()
    
    /// 苹果图标
    private let appleIconView_Lens: UIImageView = {
        let imageView_Lens = UIImageView()
        imageView_Lens.image = UIImage(systemName: "apple.logo")
        imageView_Lens.tintColor = .white
        imageView_Lens.contentMode = .scaleAspectFit
        return imageView_Lens
    }()
    
    /// 文字标签
    private let titleLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.text = "Continue with Apple"
        label_Lens.textColor = .white
        label_Lens.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Lens.textAlignment = .center
        return label_Lens
    }()

    /// 图标+文字水平居中容器
    private let contentStack_Lens: UIStackView = {
        let stack_Lens = UIStackView()
        stack_Lens.axis = .horizontal
        stack_Lens.alignment = .center
        stack_Lens.spacing = 10
        stack_Lens.isUserInteractionEnabled = false
        return stack_Lens
    }()
    
    // MARK: - 初始化
    
    /// 初始化方法
    init(onTap_Lens: @escaping () -> Void) {
        self.onTap_Lens = onTap_Lens
        super.init(frame: .zero)
        setupUI_Lens()
        setupGesture_Lens()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Lens() {
        addSubview(containerView_Lens)
        containerView_Lens.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(52)
        }

        // 图标固定尺寸
        appleIconView_Lens.snp.makeConstraints { make in
            make.width.height.equalTo(22)
        }

        // 将图标与文字放入 StackView，整体居中
        contentStack_Lens.addArrangedSubview(appleIconView_Lens)
        contentStack_Lens.addArrangedSubview(titleLabel_Lens)

        containerView_Lens.addSubview(contentStack_Lens)
        contentStack_Lens.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    /// 设置手势
    private func setupGesture_Lens() {
        let tapGesture_Lens = UITapGestureRecognizer(target: self, action: #selector(handleTap_Lens))
        containerView_Lens.addGestureRecognizer(tapGesture_Lens)
    }
    
    // MARK: - 事件处理
    
    /// 处理点击事件
    @objc private func handleTap_Lens() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView_Lens.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView_Lens.transform = .identity
            }
        }
        
        // 调用回调
        onTap_Lens?()
    }
}

// MARK: - Apple登录管理器

/// Apple登录管理器
@MainActor
class AppleLoginManager_Lens: NSObject {
    
    // MARK: - 属性
    
    /// 当前视图控制器
    private weak var viewController_Lens: UIViewController?
    
    /// 成功回调
    private var successCallback_Lens: ((String) -> Void)?
    
    /// 失败回调
    private var failureCallback_Lens: ((String) -> Void)?
    
    // MARK: - 初始化
    
    /// 初始化
    init(viewController_Lens: UIViewController) {
        self.viewController_Lens = viewController_Lens
        super.init()
    }
    
    // MARK: - 公共方法
    func startAppleLogin_Lens(
        success_Lens: @escaping (String) -> Void,
        failure_Lens: @escaping (String) -> Void
    ) {
        self.successCallback_Lens = success_Lens
        self.failureCallback_Lens = failure_Lens
        
        // 创建Apple ID授权请求
        let appleIDProvider_Lens = ASAuthorizationAppleIDProvider()
        let request_Lens = appleIDProvider_Lens.createRequest()
        request_Lens.requestedScopes = [.fullName, .email]
        
        // 创建授权控制器
        let authorizationController_Lens = ASAuthorizationController(authorizationRequests: [request_Lens])
        authorizationController_Lens.delegate = self
        authorizationController_Lens.presentationContextProvider = self
        authorizationController_Lens.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleLoginManager_Lens: ASAuthorizationControllerDelegate {
    
    /// 授权成功
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            switch authorization.credential {
                
            case let appleIDCredential_Lens as ASAuthorizationAppleIDCredential:
                // 获取邮箱
                let email_Lens = appleIDCredential_Lens.email
                
                // 生成用户账号
                var userAcc_Lens = ""
                if email_Lens == nil || email_Lens == "" {
                    userAcc_Lens = "appleId"
                } else {
                    userAcc_Lens = email_Lens ?? ""
                }
                
                print("✅ Apple登录成功，用户账号：\(userAcc_Lens)")
                
                // 调用成功回调
                successCallback_Lens?(userAcc_Lens)
                
            case let userCredential_Lens as ASPasswordCredential:
                // 密码凭证
                let user_Lens = userCredential_Lens.user
                _ = userCredential_Lens.password
                
                print("✅ 密码凭证登录成功，用户：\(user_Lens)")
                
                // 调用成功回调
                successCallback_Lens?(user_Lens)
                
            default:
                print("❌ 未知授权类型")
                failureCallback_Lens?("Unknown authorization type")
            }
        }
    }
    
    /// 授权失败
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            if let authError_Lens = error as? ASAuthorizationError {
                
                var errorMessage_Lens = ""

                switch authError_Lens.code {
                case .unknown:
                    errorMessage_Lens = "Unknown error"
                    print("❌ 授权未知错误")
                case .canceled:
                    errorMessage_Lens = "Authorization canceled"
                    print("⚠️ 授权取消")
                case .invalidResponse:
                    errorMessage_Lens = "Invalid response"
                    print("❌ 授权无效请求")
                case .notHandled:
                    errorMessage_Lens = "Not handled"
                    print("❌ 授权未能处理")
                case .failed:
                    errorMessage_Lens = "Authorization failed"
                    print("❌ 授权失败")
                case .notInteractive:
                    errorMessage_Lens = "Not interactive"
                    print("❌ 授权非交互式")
                case .matchedExcludedCredential:
                    errorMessage_Lens = "Matched excluded credential"
                    print("❌ 该凭证属于被排除的范围")
                case .credentialImport:
                    errorMessage_Lens = "Credential import"
                    print("❌ 凭证导入")
                case .credentialExport:
                    errorMessage_Lens = "Credential export"
                    print("❌ 凭证导出")
                case .preferSignInWithApple:
                    errorMessage_Lens = "Prefer sign in with Apple"
                    print("❌ 偏好使用Apple登录")
                case .deviceNotConfiguredForPasskeyCreation:
                    errorMessage_Lens = "Device not configured for Passkey creation"
                    print("❌ 设备未配置用于创建Passkey")
                @unknown default:
                    errorMessage_Lens = "Unknown error"
                    print("❌ 授权其他原因")
                }
                
                // 调用失败回调
                failureCallback_Lens?(errorMessage_Lens)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleLoginManager_Lens: ASAuthorizationControllerPresentationContextProviding {
    
    /// 提供展示窗口
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 获取当前的 keyWindow
        if let windowScene_Lens = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window_Lens = windowScene_Lens.windows.first(where: { $0.isKeyWindow }) {
            return window_Lens
        }
        
        // 备选方案：返回第一个窗口
        if let window_Lens = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first {
            return window_Lens
        }
        
        // 最终备选方案
        return ASPresentationAnchor()
    }
}
