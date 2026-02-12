import SwiftUI
import AuthenticationServices

// MARK: - 登录页
// 核心作用：用户登录界面
// 设计思路：现代化设计 + 动态背景 + 输入验证 + Apple登录
// 关键功能：用户名密码登录、Apple登录、跳转注册、协议展示

/// 登录页
struct Login_platbell: View {
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 用户名
    @State private var username_platbell: String = ""
    
    /// 密码
    @State private var password_platbell: String = ""
    
    /// 是否显示密码
    @State private var showPassword_platbell: Bool = false
    
    /// 是否显示协议
    @State private var showTerms_platbell: Bool = false
    
    /// 是否显示隐私政策
    @State private var showPrivacy_platbell: Bool = false
    
    /// Logo动画状态
    @State private var logoAnimating_platbell: Bool = false
    
    /// 输入框聚焦状态
    @FocusState private var focusedField_platbell: Field_platbell?
    
    /// 输入框类型
    enum Field_platbell {
        case username_platbell
        case password_platbell
    }
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            animatedBackground_platbell
            
            // 装饰性粒子
            decorativeElements_platbell
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 顶部间距
                    Spacer()
                        .frame(height: 60)
                    
                    // Logo区域
                    logoSection_platbell
                        .padding(.bottom, 40)
                    
                    // 输入区域
                    inputSection_platbell
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    
                    // 登录按钮
                    loginButton_platbell
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                    
                    // Apple登录按钮
                    appleLoginButton_platbell
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    
                    // 注册提示
                    registerPrompt_platbell
                        .padding(.bottom, 20)
                    
                    // 协议区域
                    termsSection_platbell
                        .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
            
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        router_platbell.dismissFullScreen_platbell()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .blur(radius: 8)
                            
                            Circle()
                                .fill(Color(.systemBackground).opacity(0.9))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50)
                }
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                logoAnimating_platbell = true
            }
        }
        .sheet(isPresented: $showTerms_platbell) {
            NavigationStack {
                ProtocolContentView_platbell(
                    type_platbell: .terms_platbell,
                    content_platbell: "terms.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showTerms_platbell = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPrivacy_platbell) {
            NavigationStack {
                ProtocolContentView_platbell(
                    type_platbell: .privacy_platbell,
                    content_platbell: "privacy.png"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showPrivacy_platbell = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 子视图
    
    /// 动态渐变背景
    private var animatedBackground_platbell: some View {
        ZStack {
            // 基础渐变
            LinearGradient(
                colors: [
                    ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.2),
                    ThemeColors_platbell.accentBlueStart_platbell.opacity(0.15),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 动态光晕
            RadialGradient(
                colors: [
                    ThemeColors_platbell.warmStart_platbell.opacity(logoAnimating_platbell ? 0.2 : 0.1),
                    Color.clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
    
    /// 装饰性元素
    private var decorativeElements_platbell: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index_platbell in
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[index_platbell].opacity(0.08)
                    )
                    .frame(
                        width: CGFloat(100 + index_platbell * 50),
                        height: CGFloat(100 + index_platbell * 50)
                    )
                    .offset(
                        x: CGFloat([-120, 150, -100][index_platbell]),
                        y: CGFloat([200, 450, 650][index_platbell])
                    )
                    .blur(radius: 20)
                    .breathing_platbell(
                        isEnabled_platbell: true,
                        duration_platbell: 4.0 + Double(index_platbell),
                        scaleRange_platbell: 0.3
                    )
            }
        }
        .allowsHitTesting(false)
    }
    
    /// Logo区域
    private var logoSection_platbell: some View {
        VStack(spacing: 16) {
            // 装饰性图标组
            ZStack {
                // 外圈光晕
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(logoAnimating_platbell ? 1.1 : 0.9)
                
                // 背景圆
                Circle()
                    .fill(
                        ThemeColors_platbell.gradient_platbell(at: 0).opacity(0.2)
                    )
                    .frame(width: 100, height: 100)
                
                // Logo图标
                Image(systemName: "bell.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 0))
                    .rotationEffect(.degrees(logoAnimating_platbell ? 10 : -10))
            }
            .shadow(
                color: ThemeColors_platbell.primaryStart_platbell.opacity(0.3),
                radius: 20,
                x: 0,
                y: 10
            )
            
            // 标题
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                    .gradientText_platbell(gradientIndex_platbell: 0)
                
                Text("Login to continue your journey")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// 输入区域
    private var inputSection_platbell: some View {
        VStack(spacing: 16) {
            // 用户名输入框
            InputField_platbell(
                icon_platbell: "person.fill",
                placeholder_platbell: "Username",
                text_platbell: $username_platbell,
                isSecure_platbell: false,
                gradientIndex_platbell: 0
            )
            .focused($focusedField_platbell, equals: .username_platbell)
            
            // 密码输入框
            InputField_platbell(
                icon_platbell: "lock.fill",
                placeholder_platbell: "Password",
                text_platbell: $password_platbell,
                isSecure_platbell: !showPassword_platbell,
                gradientIndex_platbell: 1,
                rightButton_platbell: {
                    Button(action: {
                        showPassword_platbell.toggle()
                    }) {
                        Image(systemName: showPassword_platbell ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            )
            .focused($focusedField_platbell, equals: .password_platbell)
        }
    }
    
    /// 登录按钮
    private var loginButton_platbell: some View {
        Button(action: handleLogin_platbell) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Login")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeColors_platbell.gradient_platbell(at: 0))
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .shadow(
                color: ThemeColors_platbell.primaryStart_platbell.opacity(0.4),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .disabled(!canLogin_platbell)
        .opacity(canLogin_platbell ? 1.0 : 0.5)
    }
    
    /// Apple登录按钮
    private var appleLoginButton_platbell: some View {
        AppleLoginButton_platbell(
            onSuccess_platbell: { userAccount_platbell in
                handleAppleLoginSuccess_platbell(userAccount_platbell: userAccount_platbell)
            },
            onFailure_platbell: { errorMessage_platbell in
                handleAppleLoginFailure_platbell(errorMessage_platbell: errorMessage_platbell)
            }
        )
        .frame(height: 56)
        .shadow(
            color: Color.black.opacity(0.2),
            radius: 10,
            x: 0,
            y: 5
        )
    }
    
    /// 注册提示
    private var registerPrompt_platbell: some View {
        HStack(spacing: 6) {
            Text("Don't have an account?")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            
            Button(action: {
                // 先关闭登录页，再导航到注册页
                router_platbell.dismissFullScreen_platbell()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router_platbell.navigate_platbell(to: .register_platbell)
                }
            }) {
                Text("Sign up")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 0))
            }
        }
    }
    
    /// 协议区域
    private var termsSection_platbell: some View {
        (
            Text("By continuing, you agree to our ")
                .font(.system(size: 13))
                .foregroundColor(.secondary) +
            
            Text("Terms of Service")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                .underline() +
            
            Text(" & ")
                .font(.system(size: 13))
                .foregroundColor(.secondary) +
            
            Text("Privacy Policy")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ThemeColors_platbell.accentBlueStart_platbell)
                .underline() +
            
            Text(".")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        )
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .onTapGesture { location_platbell in
            // 根据点击位置判断
            // Terms of Service 在左半部分，Privacy Policy 在右半部分
            let screenWidth_platbell = UIScreen.main.bounds.width
            if location_platbell.x > screenWidth_platbell * 0.5 {
                showTerms_platbell = true
            } else {
                showPrivacy_platbell = true
            }
        }
    }
    
    // MARK: - 计算属性
    
    /// 是否可以登录
    private var canLogin_platbell: Bool {
        !username_platbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password_platbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 事件处理
    
    /// 处理登录
    private func handleLogin_platbell() {
        // 隐藏键盘
        focusedField_platbell = nil
        
        // 验证输入
        let trimmedUsername_platbell = username_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword_platbell = password_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedUsername_platbell.isEmpty else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please enter username",
                delay_platbell: 2.0
            )
            return
        }
        
        guard !trimmedPassword_platbell.isEmpty else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please enter password",
                delay_platbell: 2.0
            )
            return
        }
        
        // 显示加载
        Utils_platbell.showLoading_platbell(message_platbell: "Logging in...")
        
        // 模拟登录延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 执行登录
            let success_platbell = userVM_platbell.login_platbell(
                userName_platbell: trimmedUsername_platbell,
                passWord_platbell: trimmedPassword_platbell
            )
            
            Utils_platbell.dismissLoading_platbell()
            
            if success_platbell {
                Utils_platbell.showSuccess_platbell(
                    message_platbell: "Login successful!",
                    delay_platbell: 1.5
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    router_platbell.dismissFullScreen_platbell()
                }
            } else {
                Utils_platbell.showError_platbell(
                    message_platbell: "Invalid username or password",
                    delay_platbell: 2.0
                )
            }
        }
    }
    
    /// 处理Apple登录成功
    private func handleAppleLoginSuccess_platbell(userAccount_platbell: String) {
        Utils_platbell.showLoading_platbell(message_platbell: "Signing in with Apple...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Utils_platbell.dismissLoading_platbell()
            
            // 使用Apple账号进行登录
            let success_platbell = userVM_platbell.login_platbell(
                userName_platbell: userAccount_platbell,
                passWord_platbell: "apple_user"
            )
            
            if success_platbell {
                Utils_platbell.showSuccess_platbell(
                    message_platbell: "Apple login successful!",
                    delay_platbell: 1.5
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    router_platbell.dismissFullScreen_platbell()
                }
            } else {
                Utils_platbell.showError_platbell(
                    message_platbell: "Login failed",
                    delay_platbell: 2.0
                )
            }
        }
    }
    
    /// 处理Apple登录失败
    private func handleAppleLoginFailure_platbell(errorMessage_platbell: String) {
        // 如果是用户取消，不显示错误提示
        if errorMessage_platbell == "Authorization canceled" {
            print("用户取消了Apple登录")
            return
        }
        
        Utils_platbell.showError_platbell(
            message_platbell: "Apple login failed: \(errorMessage_platbell)",
            delay_platbell: 2.0
        )
    }
}

// MARK: - 输入框组件

/// 自定义输入框组件
struct InputField_platbell: View {
    
    let icon_platbell: String
    let placeholder_platbell: String
    @Binding var text_platbell: String
    var isSecure_platbell: Bool = false
    let gradientIndex_platbell: Int
    var rightButton_platbell: AnyView? = nil
    
    init(
        icon_platbell: String,
        placeholder_platbell: String,
        text_platbell: Binding<String>,
        isSecure_platbell: Bool = false,
        gradientIndex_platbell: Int,
        @ViewBuilder rightButton_platbell: @escaping () -> some View = { EmptyView() }
    ) {
        self.icon_platbell = icon_platbell
        self.placeholder_platbell = placeholder_platbell
        self._text_platbell = text_platbell
        self.isSecure_platbell = isSecure_platbell
        self.gradientIndex_platbell = gradientIndex_platbell
        
        let rightView = rightButton_platbell()
        self.rightButton_platbell = rightView is EmptyView ? nil : AnyView(rightView)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // 左侧图标
            ZStack {
                Circle()
                    .fill(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.15)
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon_platbell)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell))
            }
            
            // 输入框
            if isSecure_platbell {
                SecureField(placeholder_platbell, text: $text_platbell)
                    .font(.system(size: 16, weight: .medium))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField(placeholder_platbell, text: $text_platbell)
                    .font(.system(size: 16, weight: .medium))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            // 右侧按钮（可选）
            if let rightButton = rightButton_platbell {
                rightButton
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    text_platbell.isEmpty
                        ? Color.gray.opacity(0.2)
                        : ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.5),
                    lineWidth: 2
                )
        )
        .shadow(
            color: text_platbell.isEmpty ? Color.clear : ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell].opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}
