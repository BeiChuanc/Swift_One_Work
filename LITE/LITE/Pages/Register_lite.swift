import SwiftUI

// MARK: - 注册页
// 核心作用：用户注册界面
// 设计思路：现代化设计，强调安全性和易用性
// 关键功能：用户名密码注册、密码确认、数据验证、协议展示

/// 注册页
struct Register_lite: View {
    
    @ObservedObject private var userVM_lite = UserViewModel_lite.shared_lite
    @ObservedObject private var router_lite = Router_lite.shared_lite
    
    @State private var username_lite = ""
    @State private var password_lite = ""
    @State private var confirmPassword_lite = ""
    @State private var showPassword_lite = false
    @State private var showConfirmPassword_lite = false
    @State private var isRegistering_lite = false
    @State private var showTerms_lite = false
    @State private var showPrivacy_lite = false
    
    @FocusState private var usernameFieldFocused_lite: Bool
    @FocusState private var passwordFieldFocused_lite: Bool
    @FocusState private var confirmPasswordFieldFocused_lite: Bool
    
    var body: some View {
        ZStack {
            // 动态渐变背景
            animatedBackground_lite
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 返回按钮
                backButton_lite
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
                        
                        // 注册按钮
                        registerButton_lite
                            .padding(.horizontal, 20.w_lite)
                        
                        // 协议
                        protocolSection_lite
                            .padding(.horizontal, 30.w_lite)
                            .padding(.bottom, 40.h_lite)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            usernameFieldFocused_lite = false
            passwordFieldFocused_lite = false
            confirmPasswordFieldFocused_lite = false
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
                    Color(hex: "f093fb"),
                    Color(hex: "f5576c"),
                    Color(hex: "667eea")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 装饰圆圈
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 280.w_lite, height: 280.h_lite)
                .offset(x: -80.w_lite, y: -180.h_lite)
                .blur(radius: 40)
            
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 230.w_lite, height: 230.h_lite)
                .offset(x: UIScreen.main.bounds.width - 70.w_lite, y: UIScreen.main.bounds.height - 180.h_lite)
                .blur(radius: 35)
        }
    }
    
    // MARK: - 返回按钮
    
    /// 返回按钮
    private var backButton_lite: some View {
        HStack {
            Button {
                router_lite.pop_lite()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40.w_lite, height: 40.h_lite)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18.sp_lite, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle_lite())
            
            Spacer()
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
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 40.sp_lite, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "f093fb"), Color(hex: "667eea")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 25, x: 0, y: 10)
            }
            
            // 标题
            VStack(spacing: 12.h_lite) {
                Text("Create Account")
                    .font(.system(size: 36.sp_lite, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text("Start your style journey today")
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
            RegisterInputField_lite(
                icon_lite: "person.fill",
                placeholder_lite: "Username",
                text_lite: $username_lite,
                isFocused_lite: $usernameFieldFocused_lite
            )
            .onChange(of: username_lite) { _, newValue_lite in
                // 限制用户名最多20个字符
                if newValue_lite.count > 20 {
                    username_lite = String(newValue_lite.prefix(20))
                }
            }
            
            // 密码输入框
            RegisterSecureField_lite(
                icon_lite: "lock.fill",
                placeholder_lite: "Password",
                text_lite: $password_lite,
                isFocused_lite: $passwordFieldFocused_lite,
                showPassword_lite: $showPassword_lite
            )
            .onChange(of: password_lite) { _, newValue_lite in
                // 限制密码最多30个字符
                if newValue_lite.count > 30 {
                    password_lite = String(newValue_lite.prefix(30))
                }
            }
            
            // 确认密码输入框
            RegisterSecureField_lite(
                icon_lite: "lock.shield.fill",
                placeholder_lite: "Confirm Password",
                text_lite: $confirmPassword_lite,
                isFocused_lite: $confirmPasswordFieldFocused_lite,
                showPassword_lite: $showConfirmPassword_lite
            )
            .onChange(of: confirmPassword_lite) { _, newValue_lite in
                // 限制确认密码最多30个字符
                if newValue_lite.count > 30 {
                    confirmPassword_lite = String(newValue_lite.prefix(30))
                }
            }
            
            // 密码匹配提示
            if !password_lite.isEmpty && !confirmPassword_lite.isEmpty {
                HStack(spacing: 6.w_lite) {
                    Image(systemName: passwordsMatch_lite ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14.sp_lite))
                        .foregroundColor(passwordsMatch_lite ? Color(hex: "43e97b") : Color(hex: "ff9a9e"))
                    
                    Text(passwordsMatch_lite ? "Passwords match" : "Passwords don't match")
                        .font(.system(size: 13.sp_lite, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 20.w_lite)
            }
        }
    }
    
    // MARK: - 注册按钮
    
    /// 注册按钮
    private var registerButton_lite: some View {
        Button {
            handleRegister_lite()
        } label: {
            HStack(spacing: 10.w_lite) {
                if isRegistering_lite {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "f093fb")))
                        .scaleEffect(1.2)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24.sp_lite, weight: .bold))
                }
                
                Text(isRegistering_lite ? "Creating account..." : "Create Account")
                    .font(.system(size: 18.sp_lite, weight: .bold))
            }
            .foregroundColor(canRegister_lite ? Color(hex: "f093fb") : Color(hex: "ADB5BD"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18.h_lite)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 25.w_lite)
                        .fill(Color.white)
                    
                    if canRegister_lite {
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
                        canRegister_lite ?
                            LinearGradient(
                                colors: [Color(hex: "f093fb").opacity(0.5), Color(hex: "f5576c").opacity(0.5)],
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
                color: canRegister_lite ? Color.white.opacity(0.8) : Color.black.opacity(0.1),
                radius: canRegister_lite ? 25 : 15,
                x: 0,
                y: canRegister_lite ? 15 : 8
            )
        }
        .buttonStyle(ScaleButtonStyle_lite())
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
    
    /// 密码是否匹配
    private var passwordsMatch_lite: Bool {
        return password_lite == confirmPassword_lite
    }
    
    /// 是否可以注册
    private var canRegister_lite: Bool {
        return !username_lite.isEmpty &&
               !password_lite.isEmpty &&
               !confirmPassword_lite.isEmpty &&
               passwordsMatch_lite &&
               !isRegistering_lite
    }
    
    /// 处理注册
    private func handleRegister_lite() {
        print("🔘 注册按钮被点击")
        
        // 判断用户名是否为空
        guard !username_lite.isEmpty else {
            Utils_lite.showWarning_lite(message_lite: "Username cannot be empty")
            return
        }
        
        // 判断密码是否为空
        guard !password_lite.isEmpty else {
            Utils_lite.showWarning_lite(message_lite: "Password cannot be empty")
            return
        }
        
        // 判断确认密码是否为空
        guard !confirmPassword_lite.isEmpty else {
            Utils_lite.showWarning_lite(message_lite: "Please confirm your password")
            return
        }
        
        // 判断两次密码是否一致
        guard passwordsMatch_lite else {
            Utils_lite.showWarning_lite(message_lite: "Passwords don't match")
            return
        }
        
        guard !isRegistering_lite else { return }
        
        isRegistering_lite = true
        
        // 模拟注册延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("✅ 注册成功")
            // 注册成功后直接登录
            userVM_lite.loginById_lite(userId_lite: Int.random(in: 10...100))
            isRegistering_lite = false
            
            // 关闭当前页面
            router_lite.pop_lite()
        }
    }
}

// MARK: - 注册页输入框组件

/// 注册页普通输入框
struct RegisterInputField_lite: View {
    
    let icon_lite: String
    let placeholder_lite: String
    @Binding var text_lite: String
    var isFocused_lite: FocusState<Bool>.Binding
    
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

/// 注册页密码输入框
struct RegisterSecureField_lite: View {
    
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
