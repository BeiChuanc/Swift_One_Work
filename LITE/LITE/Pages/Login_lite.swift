import SwiftUI

// MARK: - 登录页
// 核心作用：用户登录界面
// 设计思路：现代化设计，强调视觉吸引力和品牌感
// 关键功能：用户名密码登录、Apple登录、跳转注册、协议展示

/// 登录页
struct Login_lite: View {
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var username_lite = ""
    @State private var password_lite = ""
    @State private var showPassword_lite = false
    @State private var isLoggingIn_lite = false
    @State private var showTerms_lite = false
    @State private var showPrivacy_lite = false
    
    @FocusState private var usernameFieldFocused_lite: Bool
    @FocusState private var passwordFieldFocused_lite: Bool
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            animatedBackground_lite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 关闭按钮
                closeButton_lite
                    .padding(.horizontal, 20.w_lite)
                    .padding(.top, 12.h_lite)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32.h_lite) {
                        // Logo 和标题区域
                        headerSection_lite
                            .padding(.top, 40.h_lite)
                        
                        // 输入表单区域
                        formSection_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 登录按钮
                        loginButton_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // Apple 登录
                        appleLoginSection_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 注册入口
                        registerPrompt_lite
                        
                        // 协议
                        protocolSection_lite
                            .padding(.horizontal, 30.w_lite)
                            .padding(.bottom, 40.h_lite)
                    }
                }
            }
        }
        .onTapGesture {
            usernameFieldFocused_lite = false
            passwordFieldFocused_lite = false
        }
        .sheet(isPresented: $showTerms_lite) {
            NavigationStack {
                ProtocolContentView_lite(
                    type_lite: .terms_lite,
                    content_lite: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_lite = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_lite) {
            NavigationStack {
                ProtocolContentView_lite(
                    type_lite: .privacy_lite,
                    content_lite: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_lite = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 动态背景
    
    /// 动态渐变背景
    private var animatedBackground_lite: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2"),
                    Color(hex: "f093fb")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰圆圈
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300.w_lite, height: 300.h_lite)
                .offset(x: -100.w_lite, y: -200.h_lite)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 250.w_lite, height: 250.h_lite)
                .offset(x: UIScreen.main.bounds.width - 80.w_lite, y: UIScreen.main.bounds.height - 200.h_lite)
                .blur(radius: 35)
        }
    }
    
    // MARK: - 关闭按钮
    
    /// 关闭按钮
    private var closeButton_lite: some View {
        HStack {
            Spacer()
            
            Button {
                router_lite.dismissFullScreen_lite()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40.w_lite, height: 40.h_lite)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 16.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle_lite())
        }
    }
    
    // MARK: - Logo 和标题
    
    /// Logo 和标题区域
    private var headerSection_lite: some View {
        VStack(spacing: 20.h_lite) {
            // Logo
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 100.w_lite, height: 100.h_lite)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 90.w_lite, height: 90.h_lite)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 40.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "f093fb")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 10)
            }
            
            // 标题
            VStack(spacing: 12.h_lite) {
                Text("Welcome Back")
                    .font(.system(size: 36.sp_lite, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text("Sign in to continue your style journey")
                    .font(.system(size: 15.sp_lite, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
    
    // MARK: - 输入表单
    
    /// 输入表单区域
    private var formSection_lite: some View {
        VStack(spacing: 16.h_lite) {
            // 用户名输入框
            InputField_lite(
                icon_lite: "person.fill",
                placeholder_lite: "Username",
                text_lite: $username_lite,
                isFocused_lite: $usernameFieldFocused_lite,
                isSecure_lite: false
            )
            
            // 密码输入框
            SecureInputField_lite(
                icon_lite: "lock.fill",
                placeholder_lite: "Password",
                text_lite: $password_lite,
                isFocused_lite: $passwordFieldFocused_lite,
                showPassword_lite: $showPassword_lite
            )
        }
    }
    
    // MARK: - 登录按钮
    
    /// 登录按钮
    private var loginButton_lite: some View {
        Button {
            handleLogin_lite()
        } label: {
            HStack(spacing: 10.w_lite) {
                if isLoggingIn_lite {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "667eea")))
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 24.sp_lite, weight: .bold))
                }
                
                Text(isLoggingIn_lite ? "Signing in..." : "Sign In")
                    .font(.system(size: 18.sp_lite, weight: .bold))
            }
            .foregroundColor(canLogin_lite ? Color(hex: "667eea") : Color(hex: "ADB5BD"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18.h_lite)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 25.w_lite)
                        .fill(Color.white)
                    
                    if canLogin_lite {
                        RoundedRectangle(cornerRadius: 25.w_lite)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.8), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25.w_lite)
                    .stroke(
                        canLogin_lite ?
                            LinearGradient(
                                colors: [Color(hex: "667eea").opacity(0.5), Color(hex: "764ba2").opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "E9ECEF"), Color(hex: "E9ECEF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: canLogin_lite ? Color.white.opacity(0.8) : Color.black.opacity(0.1),
                radius: canLogin_lite ? 25 : 15,
                x: 0,
                y: canLogin_lite ? 15 : 8
            )
        }
        .buttonStyle(ScaleButtonStyle_lite())
    }
    
    // MARK: - Apple 登录
    
    /// Apple 登录区域
    private var appleLoginSection_lite: some View {
        VStack(spacing: 16.h_lite) {
            // 分隔线
            HStack(spacing: 12.w_lite) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.system(size: 13.sp_lite, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Apple 登录按钮
            AppleLoginButton_lite(
                onSuccess_lite: { userId_lite in
                    print("✅ Apple登录成功: \(userId_lite)")
                    userVM_lite.loginById_lite(userId_lite: Int.random(in: 10...100))
                },
                onFailure_lite: { error_lite in
                    print("❌ Apple登录失败: \(error_lite)")
                    Utils_lite.showError_lite(message_lite: "Apple Sign In failed")
                }
            )
        }
    }
    
    // MARK: - 注册入口
    
    /// 注册提示
    private var registerPrompt_lite: some View {
        HStack(spacing: 6.w_lite) {
            Text("Don't have an account?")
                .font(.system(size: 15.sp_lite, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Button {
                handleGoToRegister_lite()
            } label: {
                Text("Sign Up")
                    .font(.system(size: 15.sp_lite, weight: .bold))
                    .foregroundColor(.white)
                    .underline()
            }
        }
    }
    
    /// 处理跳转到注册页
    private func handleGoToRegister_lite() {
        // 先关闭登录页
        router_lite.dismissFullScreen_lite()
        
        // 延迟打开注册页（等待登录页关闭动画完成）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            router_lite.toRegister_lite()
        }
    }
    
    // MARK: - 协议
    
    /// 协议区域
    private var protocolSection_lite: some View {
        (
            Text("By continuing, you agree to our ")
                .font(.system(size: 12.sp_lite))
                .foregroundColor(.white.opacity(0.8)) +
            
            Text("Terms of Service")
                .font(.system(size: 12.sp_lite, weight: .medium))
                .foregroundColor(.white)
                .underline() +
            
            Text(" & ")
                .font(.system(size: 12.sp_lite))
                .foregroundColor(.white.opacity(0.8)) +
            
            Text("Privacy Policy")
                .font(.system(size: 12.sp_lite, weight: .medium))
                .foregroundColor(.white)
                .underline() +
            
            Text(".")
                .font(.system(size: 12.sp_lite))
                .foregroundColor(.white.opacity(0.8))
        )
        .multilineTextAlignment(.center)
        .onTapGesture { coordinate_lite in
            // 根据点击位置判断
            if coordinate_lite.x > UIScreen.main.bounds.width / 2 {
                showTerms_lite = true
            } else {
                showPrivacy_lite = true
            }
        }
    }
    
    // MARK: - 辅助方法
    
    /// 是否可以登录
    private var canLogin_lite: Bool {
        return !username_lite.isEmpty && !password_lite.isEmpty && !isLoggingIn_lite
    }
    
    /// 处理登录
    private func handleLogin_lite() {
        // 判断用户名和密码是否为空
        guard !username_lite.isEmpty && !password_lite.isEmpty else {
            if username_lite.isEmpty {
                Utils_lite.showWarning_lite(message_lite: "Username cannot be empty")
            } else if password_lite.isEmpty {
                Utils_lite.showWarning_lite(message_lite: "Password cannot be empty")
            }
            return
        }
        
        guard !isLoggingIn_lite else { return }
        
        isLoggingIn_lite = true
        
        // 模拟登录延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 使用随机ID模拟登录
            userVM_lite.loginById_lite(userId_lite: Int.random(in: 10...100))
            isLoggingIn_lite = false
        }
    }
}

// MARK: - 输入框组件

/// 普通输入框
struct InputField_lite: View {
    
    let icon_lite: String
    let placeholder_lite: String
    @Binding var text_lite: String
    var isFocused_lite: FocusState<Bool>.Binding
    let isSecure_lite: Bool
    
    var body: some View {
        HStack(spacing: 14.w_lite) {
            Image(systemName: icon_lite)
                .font(.system(size: 18.sp_lite, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24.w_lite)
            
            TextField(placeholder_lite, text: $text_lite)
                .font(.system(size: 17.sp_lite, weight: .medium))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused(isFocused_lite)
        }
        .padding(.horizontal, 20.w_lite)
        .padding(.vertical, 18.h_lite)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .fill(Color.white.opacity(0.15))
                
                if isFocused_lite.wrappedValue {
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20.w_lite)
                .stroke(
                    Color.white.opacity(isFocused_lite.wrappedValue ? 0.5 : 0.2),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isFocused_lite.wrappedValue ? Color.white.opacity(0.3) : Color.black.opacity(0.1),
            radius: isFocused_lite.wrappedValue ? 15 : 10,
            x: 0,
            y: 6
        )
    }
}

/// 密码输入框
struct SecureInputField_lite: View {
    
    let icon_lite: String
    let placeholder_lite: String
    @Binding var text_lite: String
    var isFocused_lite: FocusState<Bool>.Binding
    @Binding var showPassword_lite: Bool
    
    var body: some View {
        HStack(spacing: 14.w_lite) {
            Image(systemName: icon_lite)
                .font(.system(size: 18.sp_lite, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 24.w_lite)
            
            if showPassword_lite {
                TextField(placeholder_lite, text: $text_lite)
                    .font(.system(size: 17.sp_lite, weight: .medium))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused(isFocused_lite)
            } else {
                SecureField(placeholder_lite, text: $text_lite)
                    .font(.system(size: 17.sp_lite, weight: .medium))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused(isFocused_lite)
            }
            
            Button {
                showPassword_lite.toggle()
            } label: {
                Image(systemName: showPassword_lite ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 16.sp_lite, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 20.w_lite)
        .padding(.vertical, 18.h_lite)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20.w_lite)
                    .fill(Color.white.opacity(0.15))
                
                if isFocused_lite.wrappedValue {
                    RoundedRectangle(cornerRadius: 20.w_lite)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20.w_lite)
                .stroke(
                    Color.white.opacity(isFocused_lite.wrappedValue ? 0.5 : 0.2),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isFocused_lite.wrappedValue ? Color.white.opacity(0.3) : Color.black.opacity(0.1),
            radius: isFocused_lite.wrappedValue ? 15 : 10,
            x: 0,
            y: 6
        )
    }
}
