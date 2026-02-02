import SwiftUI

// MARK: - 背景选择器组件
// 核心作用：允许用户选择瑜伽垫背景主题
// 设计思路：横向滚动选择器，实时预览效果
// 关键功能：背景切换、预览效果

/// 背景选择器视图
struct BackgroundSelector_blisslink: View {
    
    // MARK: - 属性
    
    /// 当前选中的背景
    @Binding var selectedBackground_blisslink: YogaMatBackground_blisslink
    
    /// 显示选择器
    @Binding var isShowing_blisslink: Bool
    
    /// 动画状态
    @State private var selectedIndex_blisslink: Int = 0
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HStack {
                Text("Choose Your Mat")
                    .font(.system(size: 20.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                        isShowing_blisslink = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24.sp_baseswiftui))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20.w_baseswiftui)
            .padding(.top, 20.h_baseswiftui)
            .padding(.bottom, 16.h_baseswiftui)
            
            // 背景预览
            backgroundPreview_blisslink
                .frame(height: 200.h_baseswiftui)
                .padding(.horizontal, 20.w_baseswiftui)
                .padding(.bottom, 20.h_baseswiftui)
            
            // 背景选项列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16.w_baseswiftui) {
                    ForEach(Array(YogaMatBackground_blisslink.allCases.enumerated()), id: \.element) { index_blisslink, background_blisslink in
                        backgroundOption_blisslink(background_blisslink, isSelected_blisslink: selectedBackground_blisslink == background_blisslink)
                            .onTapGesture {
                                selectBackground_blisslink(background_blisslink)
                            }
                    }
                }
                .padding(.horizontal, 20.w_baseswiftui)
            }
            .padding(.bottom, 125.h_baseswiftui)
        }
        .background(Color.white)
        .cornerRadius(20.w_baseswiftui, corners_blisslink: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
    }
    
    // MARK: - 背景预览
    
    private var backgroundPreview_blisslink: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: selectedBackground_blisslink.gradientColors_blisslink),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16.w_baseswiftui)
            
            // 图标
            Image(systemName: selectedBackground_blisslink.iconName_blisslink)
                .font(.system(size: 60.sp_baseswiftui, weight: .medium))
                .foregroundColor(.white.opacity(0.3))
            
            // 名称
            VStack {
                Spacer()
                Text(selectedBackground_blisslink.rawValue)
                    .font(.system(size: 18.sp_baseswiftui, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20.w_baseswiftui)
                    .padding(.vertical, 12.h_baseswiftui)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .blur(radius: 10)
                    )
                    .padding(.bottom, 20.h_baseswiftui)
            }
        }
    }
    
    // MARK: - 背景选项
    
    private func backgroundOption_blisslink(_ background_blisslink: YogaMatBackground_blisslink, isSelected_blisslink: Bool) -> some View {
        VStack(spacing: 8.h_baseswiftui) {
            
            // 缩略图
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: background_blisslink.gradientColors_blisslink),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 80.w_baseswiftui, height: 80.h_baseswiftui)
                .cornerRadius(12.w_baseswiftui)
                
                Image(systemName: background_blisslink.iconName_blisslink)
                    .font(.system(size: 30.sp_baseswiftui))
                    .foregroundColor(.white.opacity(0.6))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12.w_baseswiftui)
                    .strokeBorder(
                        isSelected_blisslink ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "667EEA"), Color(hex: "764BA2")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3.w_baseswiftui
                    )
            )
            .scaleEffect(isSelected_blisslink ? 1.08 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0), value: isSelected_blisslink)
            .padding(.top, 10.h_baseswiftui)
            
            // 名称
            Text(background_blisslink.rawValue)
                .font(.system(size: 11.sp_baseswiftui, weight: isSelected_blisslink ? .bold : .medium))
                .foregroundColor(isSelected_blisslink ? .primary : .secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80.w_baseswiftui)
        }
    }
    
    // MARK: - 事件处理
    
    /// 选择背景
    private func selectBackground_blisslink(_ background_blisslink: YogaMatBackground_blisslink) {
        // 触觉反馈
        let generator_blisslink = UIImpactFeedbackGenerator(style: .medium)
        generator_blisslink.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
            selectedBackground_blisslink = background_blisslink
        }
        
        Utils_baseswiftui.showSuccess_baseswiftui(
            message_baseswiftui: "Mat theme changed!",
            image_baseswiftui: UIImage(systemName: "checkmark.circle.fill")
        )
    }
}

// MARK: - RoundedCorner 扩展

extension View {
    /// 指定圆角
    func cornerRadius(_ radius_blisslink: CGFloat, corners_blisslink: UIRectCorner) -> some View {
        clipShape(RoundedCorner_blisslink(radius_blisslink: radius_blisslink, corners_blisslink: corners_blisslink))
    }
}

/// 自定义圆角形状
struct RoundedCorner_blisslink: Shape {
    var radius_blisslink: CGFloat = .infinity
    var corners_blisslink: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path_blisslink = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners_blisslink,
            cornerRadii: CGSize(width: radius_blisslink, height: radius_blisslink)
        )
        return Path(path_blisslink.cgPath)
    }
}
