import SwiftUI

// MARK: - 登录页
// 核心作用：用户登录界面
// 设计思路：现代化设计，验证表单，Apple登录集成，动画自然有趣
// 关键功能：用户名密码登录、Apple登录、跳转注册、协议展示

/// 登录页
struct Login_baseswift: View {
    
    // MARK: - ViewModels
    
    @ObservedObject var userVM_blisslink = UserViewModel_blisslink.shared_blisslink
    @ObservedObject var router_blisslink = Router_blisslink.shared_blisslink
    
    // MARK: - 状态
    
    @State private var username_blisslink: String = ""
    @State private var password_blisslink: String = ""
    @State private var isLoggingIn_blisslink: Bool = false
    @State private var showPassword_blisslink: Bool = false
    @State private var showTerms_blisslink: Bool = false
    @State private var showPrivacy_blisslink: Bool = false
    
    // MARK: - 视图主体
    
    var body: some View {
        ZStack {
            // 背景层
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "667EEA"),
                        Color(hex: "764BA2"),
                        Color(hex: "FA8BFF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // 装饰圆圈
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300.w_blisslink, height: 300.h_blisslink)
                    .offset(x: -150.w_blisslink, y: -200.h_blisslink)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 350.w_blisslink, height: 350.h_blisslink)
                    .offset(x: 170.w_blisslink, y: 400.h_blisslink)
                    .blur(radius: 60)
            }
            .ignoresSafeArea()
            
            // 内容层
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部Logo区域
                    logoSection_blisslink
                        .padding(.top, 80.h_blisslink)
                    
                    // 登录表单卡片
                    loginFormCard_blisslink
                        .padding(.top, 50.h_blisslink)
                    
                    // 注册提示
                    registerPrompt_blisslink
                        .padding(.top, 24.h_blisslink)
                    
                    // 协议文字
                    protocolText_blisslink
                        .padding(.top, 40.h_blisslink)
                        .padding(.bottom, 40.h_blisslink)
                }
                .padding(.horizontal, 20.w_blisslink)
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        router_blisslink.dismissFullScreen_blisslink()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 36.w_blisslink, height: 36.h_blisslink)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16.sp_blisslink, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 50.h_blisslink)
                    .padding(.trailing, 20.w_blisslink)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Logo区域
    
    private var logoSection_blisslink: some View {
        VStack(spacing: 16.h_blisslink) {
            // Logo图标
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 100.w_blisslink, height: 100.h_blisslink)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90.w_blisslink, height: 90.h_blisslink)
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                
                Image(systemName: "figure.yoga")
                    .font(.system(size: 45.sp_blisslink, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .bounceIn_blisslink(delay_blisslink: 0.1)
            
            // 标题
            VStack(spacing: 8.h_blisslink) {
                Text("BlissLink")
                    .font(.system(size: 36.sp_blisslink, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your yoga companion")
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.2)
        }
    }
    
    // MARK: - 登录表单卡片
    
    private var loginFormCard_blisslink: some View {
        VStack(spacing: 20.h_blisslink) {
            // 标题
            VStack(spacing: 8.h_blisslink) {
                Text("Welcome Back")
                    .font(.system(size: 26.sp_blisslink, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Sign in to continue your journey")
                    .font(.system(size: 14.sp_blisslink))
                    .foregroundColor(.secondary)
            }
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.3)
            
            // 用户名输入
            inputField_blisslink(
                icon_blisslink: "person.fill",
                placeholder_blisslink: "Username",
                text_blisslink: $username_blisslink,
                isSecure_blisslink: false
            )
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.35)
            
            // 密码输入
            passwordField_blisslink
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.4)
            
            // 登录按钮
            loginButton_blisslink
                .padding(.top, 10.h_blisslink)
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.45)
            
            // 分隔线
            HStack(spacing: 16.w_blisslink) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1.h_blisslink)
                
                Text("or")
                    .font(.system(size: 14.sp_blisslink, weight: .medium))
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1.h_blisslink)
            }
            .padding(.vertical, 8.h_blisslink)
            .slideIn_blisslink(from: .bottom, delay_blisslink: 0.5)
            
            // Apple登录按钮
            appleLoginButton_blisslink
                .slideIn_blisslink(from: .bottom, delay_blisslink: 0.55)
        }
        .padding(28.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 28.w_blisslink)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .bounceIn_blisslink(delay_blisslink: 0.25)
    }
    
    // MARK: - 输入框
    
    private func inputField_blisslink(
        icon_blisslink: String,
        placeholder_blisslink: String,
        text_blisslink: Binding<String>,
        isSecure_blisslink: Bool
    ) -> some View {
        HStack(spacing: 12.w_blisslink) {
            Image(systemName: icon_blisslink)
                .font(.system(size: 18.sp_blisslink, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24.w_blisslink)
            
            if isSecure_blisslink {
                SecureField(placeholder_blisslink, text: text_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
            } else {
                TextField(placeholder_blisslink, text: text_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
                    .autocapitalization(.none)
            }
        }
        .padding(18.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .stroke(
                    !text_blisslink.wrappedValue.isEmpty ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.w_blisslink
                )
        )
    }
    
    // MARK: - 密码输入框
    
    private var passwordField_blisslink: some View {
        HStack(spacing: 12.w_blisslink) {
            Image(systemName: "lock.fill")
                .font(.system(size: 18.sp_blisslink, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24.w_blisslink)
            
            if showPassword_blisslink {
                TextField("Password", text: $password_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
                    .autocapitalization(.none)
            } else {
                SecureField("Password", text: $password_blisslink)
                    .font(.system(size: 16.sp_blisslink, weight: .medium))
            }
            
            // 显示/隐藏密码按钮
            Button(action: {
                showPassword_blisslink.toggle()
                
                let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
                generator_blisslink.impactOccurred()
            }) {
                Image(systemName: showPassword_blisslink ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 16.sp_blisslink))
                    .foregroundColor(.secondary)
            }
        }
        .padding(18.w_blisslink)
        .background(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .fill(Color.gray.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14.w_blisslink)
                .stroke(
                    !password_blisslink.isEmpty ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "667EEA").opacity(0.5), Color(hex: "764BA2").opacity(0.5)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2.w_blisslink
                )
        )
    }
    
    // MARK: - 登录按钮
    
    private var loginButton_blisslink: some View {
        Button(action: {
            handleLogin_blisslink()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14.w_blisslink)
                    .fill(
                        isValid_blisslink && !isLoggingIn_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 54.h_blisslink)
                
                // 顶部光晕
                if isValid_blisslink && !isLoggingIn_blisslink {
                    VStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 27.h_blisslink)
                        
                        Spacer()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14.w_blisslink))
                }
                
                // 按钮内容
                HStack(spacing: 12.w_blisslink) {
                    if isLoggingIn_blisslink {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text("Logging in...")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20.sp_blisslink))
                        
                        Text("Login")
                            .font(.system(size: 17.sp_blisslink, weight: .bold))
                    }
                }
                .foregroundColor(.white)
            }
            .shadow(
                color: isValid_blisslink && !isLoggingIn_blisslink ? Color(hex: "667EEA").opacity(0.4) : Color.clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .disabled(!isValid_blisslink || isLoggingIn_blisslink)
        .scaleEffect(isValid_blisslink && !isLoggingIn_blisslink ? 1.0 : 0.97)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isValid_blisslink)
    }
    
    // MARK: - Apple登录按钮
    
    private var appleLoginButton_blisslink: some View {
        AppleLoginButton_blisslink(
            onSuccess_blisslink: { userAcc_blisslink in
                handleAppleLoginSuccess_blisslink(userAcc_blisslink: userAcc_blisslink)
            },
            onFailure_blisslink: { errorMsg_blisslink in
                handleAppleLoginFailure_blisslink(errorMsg_blisslink: errorMsg_blisslink)
            }
        )
        .frame(height: 54.h_blisslink)
        .cornerRadius(14.w_blisslink)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - 注册提示
    
    private var registerPrompt_blisslink: some View {
        HStack(spacing: 6.w_blisslink) {
            Text("Don't have an account?")
                .font(.system(size: 15.sp_blisslink))
                .foregroundColor(.white.opacity(0.9))
            
            Button(action: {
                handleGoToRegister_blisslink()
            }) {
                Text("Sign Up")
                    .font(.system(size: 15.sp_blisslink, weight: .bold))
                    .foregroundColor(.white)
                    .underline()
            }
        }
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.6)
    }
    
    // MARK: - 协议文字
    
    private var protocolText_blisslink: some View {
        VStack {
            (
                Text("By continuing, you agree to our ")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8)) +
                
                Text("Terms of Service")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(.white)
                    .underline() +
                
                Text(" & ")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8)) +
                
                Text("Privacy Policy")
                    .font(.system(size: 12.sp_blisslink, weight: .medium))
                    .foregroundColor(.white)
                    .underline() +
                
                Text(".")
                    .font(.system(size: 12.sp_blisslink))
                    .foregroundColor(.white.opacity(0.8))
            )
            .multilineTextAlignment(.center)
            .onTapGesture { coordinate_blisslink in
                handleProtocolTap_blisslink(at: coordinate_blisslink)
            }
        }
        .sheet(isPresented: $showTerms_blisslink) {
            NavigationStack {
                ProtocolContentView_blisslink(
                    type_blisslink: .terms_blisslink,
                    content_blisslink: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_blisslink = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_blisslink) {
            NavigationStack {
                ProtocolContentView_blisslink(
                    type_blisslink: .privacy_blisslink,
                    content_blisslink: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_blisslink = false
                        }
                    }
                }
            }
        }
        .slideIn_blisslink(from: .bottom, delay_blisslink: 0.65)
    }
    
    /// 处理协议文本点击
    private func handleProtocolTap_blisslink(at location_blisslink: CGPoint) {
        // 简单实现：点击左侧显示Terms，右侧显示Privacy
        // 这里可以根据实际需求优化判断逻辑
        showTerms_blisslink = true
    }
    
    // MARK: - 计算属性
    
    /// 验证输入是否有效
    private var isValid_blisslink: Bool {
        let hasUsername_blisslink = !username_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPassword_blisslink = !password_blisslink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return hasUsername_blisslink && hasPassword_blisslink
    }
    
    // MARK: - 事件处理
    
    /// 处理登录
    private func handleLogin_blisslink() {
        // 验证输入
        guard isValid_blisslink else {
            Utils_blisslink.showWarning_blisslink(
                message_blisslink: "Please fill in all fields.",
                delay_blisslink: 1.5
            )
            return
        }
        
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        isLoggingIn_blisslink = true
        
        // 模拟登录过程
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
            
            // 使用用户ID登录（这里简化为ID 1）
            userVM_blisslink.loginById_blisslink(userId_blisslink: 1)
            
            isLoggingIn_blisslink = false
        }
    }
    
    /// 处理Apple登录成功
    /// - Parameter userAcc_blisslink: 用户账号
    private func handleAppleLoginSuccess_blisslink(userAcc_blisslink: String) {
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.success)
        
        // 模拟登录处理
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            
            // 使用用户ID登录（这里简化为ID 2，实际应该根据 userAcc_blisslink 查询或创建用户）
            userVM_blisslink.loginById_blisslink(userId_blisslink: 999)
        }
    }
    
    /// 处理Apple登录失败
    /// - Parameter errorMsg_blisslink: 错误信息
    private func handleAppleLoginFailure_blisslink(errorMsg_blisslink: String) {
        // 触觉反馈
        let generator_blisslink = UINotificationFeedbackGenerator()
        generator_blisslink.notificationOccurred(.error)
        
        // 只有当错误不是用户取消时才显示错误提示
        if errorMsg_blisslink != "Authorization canceled" {
            Utils_blisslink.showError_blisslink(
                message_blisslink: "Apple Sign In failed",
                delay_blisslink: 2.0
            )
        }
    }
    
    /// 处理跳转到注册页
    private func handleGoToRegister_blisslink() {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .light)
        generator_blisslink.impactOccurred()
        
        // 先关闭登录页
        router_blisslink.dismissFullScreen_blisslink()
        
        // 延迟打开注册页（等待登录页关闭动画完成）
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2秒
            router_blisslink.toRegister_blisslink()
        }
    }
}
