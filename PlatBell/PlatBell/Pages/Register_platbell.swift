import SwiftUI

// MARK: - 注册页
// 核心作用：用户注册界面
// 设计思路：现代化设计 + 动态背景 + 输入验证 + 密码一致性检查
// 关键功能：用户名密码注册、密码确认、协议展示、输入验证

/// 注册页
struct Register_platbell: View {
    
    @ObservedObject var userVM_platbell = UserViewModel_platbell.shared_platbell
    @ObservedObject var router_platbell = Router_platbell.shared_platbell
    
    /// 用户名
    @State private var username_platbell: String = ""
    
    /// 密码
    @State private var password_platbell: String = ""
    
    /// 确认密码
    @State private var confirmPassword_platbell: String = ""
    
    /// 是否显示密码
    @State private var showPassword_platbell: Bool = false
    
    /// 是否显示确认密码
    @State private var showConfirmPassword_platbell: Bool = false
    
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
        case confirmPassword_platbell
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
                        .frame(height: 80)
                    
                    // Logo区域
                    logoSection_platbell
                        .padding(.bottom, 40)
                    
                    // 输入区域
                    inputSection_platbell
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    
                    // 注册按钮
                    registerButton_platbell
                        .padding(.horizontal, 24)
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
                        router_platbell.pop_platbell()
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
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
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
                    ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                    ThemeColors_platbell.accentGreenStart_platbell.opacity(0.2),
                    ThemeColors_platbell.primaryStart_platbell.opacity(0.15),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 动态光晕
            RadialGradient(
                colors: [
                    ThemeColors_platbell.accentGreenStart_platbell.opacity(logoAnimating_platbell ? 0.2 : 0.1),
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
                        ThemeColors_platbell.allEndColors_platbell[index_platbell].opacity(0.08)
                    )
                    .frame(
                        width: CGFloat(100 + index_platbell * 50),
                        height: CGFloat(100 + index_platbell * 50)
                    )
                    .offset(
                        x: CGFloat([130, -140, 110][index_platbell]),
                        y: CGFloat([250, 500, 700][index_platbell])
                    )
                    .blur(radius: 20)
                    .breathing_platbell(
                        isEnabled_platbell: true,
                        duration_platbell: 4.5 + Double(index_platbell),
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
                                ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
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
                        ThemeColors_platbell.gradient_platbell(at: 1).opacity(0.2)
                    )
                    .frame(width: 100, height: 100)
                
                // Logo图标
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(ThemeColors_platbell.gradient_platbell(at: 1))
                    .scaleEffect(logoAnimating_platbell ? 1.05 : 0.95)
            }
            .shadow(
                color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.3),
                radius: 20,
                x: 0,
                y: 10
            )
            
            // 标题
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold))
                    .gradientText_platbell(gradientIndex_platbell: 1)
                
                Text("Join us and start your journey")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    /// 输入区域
    private var inputSection_platbell: some View {
        VStack(spacing: 16) {
            // 用户名输入框
            RegisterInputField_platbell(
                icon_platbell: "person.fill",
                placeholder_platbell: "Username",
                text_platbell: $username_platbell,
                isSecure_platbell: false,
                gradientIndex_platbell: 0
            )
            .focused($focusedField_platbell, equals: .username_platbell)
            
            // 密码输入框
            RegisterInputField_platbell(
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
            
            // 确认密码输入框
            RegisterInputField_platbell(
                icon_platbell: "lock.fill",
                placeholder_platbell: "Confirm Password",
                text_platbell: $confirmPassword_platbell,
                isSecure_platbell: !showConfirmPassword_platbell,
                gradientIndex_platbell: 2,
                rightButton_platbell: {
                    Button(action: {
                        showConfirmPassword_platbell.toggle()
                    }) {
                        Image(systemName: showConfirmPassword_platbell ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                },
                validationIcon_platbell: {
                    if !confirmPassword_platbell.isEmpty {
                        if passwordsMatch_platbell {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                }
            )
            .focused($focusedField_platbell, equals: .confirmPassword_platbell)
        }
    }
    
    /// 注册按钮
    private var registerButton_platbell: some View {
        Button(action: handleRegister_platbell) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                
                Text("Create Account")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeColors_platbell.gradient_platbell(at: 1))
                    
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
                color: ThemeColors_platbell.secondaryStart_platbell.opacity(0.4),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .disabled(!canRegister_platbell)
        .opacity(canRegister_platbell ? 1.0 : 0.5)
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
    
    /// 是否可以注册
    private var canRegister_platbell: Bool {
        !username_platbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password_platbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !confirmPassword_platbell.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        passwordsMatch_platbell
    }
    
    /// 密码是否匹配
    private var passwordsMatch_platbell: Bool {
        !password_platbell.isEmpty &&
        !confirmPassword_platbell.isEmpty &&
        password_platbell == confirmPassword_platbell
    }
    
    // MARK: - 事件处理
    
    /// 处理注册
    private func handleRegister_platbell() {
        // 隐藏键盘
        focusedField_platbell = nil
        
        // 验证输入
        let trimmedUsername_platbell = username_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword_platbell = password_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmPassword_platbell = confirmPassword_platbell.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
        
        guard !trimmedConfirmPassword_platbell.isEmpty else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Please confirm password",
                delay_platbell: 2.0
            )
            return
        }
        
        guard trimmedPassword_platbell == trimmedConfirmPassword_platbell else {
            Utils_platbell.showWarning_platbell(
                message_platbell: "Passwords do not match",
                delay_platbell: 2.0
            )
            return
        }
        
        // 显示加载
        Utils_platbell.showLoading_platbell(message_platbell: "Creating account...")
        
        // 模拟注册延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 执行注册
            let success_platbell = userVM_platbell.register_platbell(
                userName_platbell: trimmedUsername_platbell,
                passWord_platbell: trimmedPassword_platbell
            )
            
            Utils_platbell.dismissLoading_platbell()
            
            if success_platbell {
                Utils_platbell.showSuccess_platbell(
                    message_platbell: "Account created successfully!",
                    delay_platbell: 1.5
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    router_platbell.pop_platbell()
                }
            } else {
                Utils_platbell.showError_platbell(
                    message_platbell: "Username already exists",
                    delay_platbell: 2.0
                )
            }
        }
    }
}

// MARK: - 注册输入框组件

/// 注册页自定义输入框组件
struct RegisterInputField_platbell: View {
    
    let icon_platbell: String
    let placeholder_platbell: String
    @Binding var text_platbell: String
    var isSecure_platbell: Bool = false
    let gradientIndex_platbell: Int
    var rightButton_platbell: AnyView? = nil
    var validationIcon_platbell: AnyView? = nil
    
    init(
        icon_platbell: String,
        placeholder_platbell: String,
        text_platbell: Binding<String>,
        isSecure_platbell: Bool = false,
        gradientIndex_platbell: Int,
        @ViewBuilder rightButton_platbell: @escaping () -> some View = { EmptyView() },
        @ViewBuilder validationIcon_platbell: @escaping () -> some View = { EmptyView() }
    ) {
        self.icon_platbell = icon_platbell
        self.placeholder_platbell = placeholder_platbell
        self._text_platbell = text_platbell
        self.isSecure_platbell = isSecure_platbell
        self.gradientIndex_platbell = gradientIndex_platbell
        
        let rightView = rightButton_platbell()
        self.rightButton_platbell = rightView is EmptyView ? nil : AnyView(rightView)
        
        let validationView = validationIcon_platbell()
        self.validationIcon_platbell = validationView is EmptyView ? nil : AnyView(validationView)
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
            
            // 验证图标（可选）
            if let validationIcon = validationIcon_platbell {
                validationIcon
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
