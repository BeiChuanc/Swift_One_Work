import SwiftUI

// MARK: - 瀑布流布局组件
// 核心作用：实现标签的自适应瀑布流布局
// 设计思路：动态计算每个标签的宽度，自动换行
// 关键功能：自适应宽度、自动换行、靠左对齐

/// 瀑布流布局容器
struct FlowLayout_platbell<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    
    /// 数据源
    let data_platbell: Data
    
    /// 间距
    let spacing_platbell: CGFloat
    
    /// 内容生成器
    let content_platbell: (Data.Element) -> Content
    
    /// 初始化方法
    /// - Parameters:
    ///   - data_platbell: 数据源
    ///   - spacing_platbell: 标签间距
    ///   - content_platbell: 内容生成闭包
    init(
        data_platbell: Data,
        spacing_platbell: CGFloat = 8,
        @ViewBuilder content_platbell: @escaping (Data.Element) -> Content
    ) {
        self.data_platbell = data_platbell
        self.spacing_platbell = spacing_platbell
        self.content_platbell = content_platbell
    }
    
    var body: some View {
        GeometryReader { geometry_platbell in
            self.generateContent_platbell(in: geometry_platbell)
        }
    }
    
    /// 生成内容
    private func generateContent_platbell(in geometry_platbell: GeometryProxy) -> some View {
        var width_platbell = CGFloat.zero
        var height_platbell = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data_platbell.enumerated()), id: \.offset) { index_platbell, item_platbell in
                content_platbell(item_platbell)
                    .padding([.horizontal, .vertical], spacing_platbell / 2)
                    .alignmentGuide(.leading, computeValue: { dimension_platbell in
                        if (abs(width_platbell - dimension_platbell.width) > geometry_platbell.size.width) {
                            width_platbell = 0
                            height_platbell -= dimension_platbell.height
                        }
                        let result_platbell = width_platbell
                        if index_platbell == data_platbell.count - 1 {
                            width_platbell = 0
                        } else {
                            width_platbell -= dimension_platbell.width
                        }
                        return result_platbell
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result_platbell = height_platbell
                        if index_platbell == data_platbell.count - 1 {
                            height_platbell = 0
                        }
                        return result_platbell
                    })
            }
        }
    }
}

// MARK: - 标签项模型

/// 标签项模型
struct TagItem_platbell: Identifiable {
    let id = UUID()
    let text_platbell: String
}

// MARK: - 标签云组件

/// 标签云组件（瀑布流布局）
struct TagCloud_platbell: View {
    
    /// 标签数组
    let tags_platbell: [String]
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否可点击
    let isClickable_platbell: Bool
    
    /// 点击回调
    var onTagTapped_platbell: ((String) -> Void)?
    
    /// 是否显示装饰
    var showDecoration_platbell: Bool = false
    
    /// 转换为标签项
    private var tagItems_platbell: [TagItem_platbell] {
        tags_platbell.map { TagItem_platbell(text_platbell: $0) }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 装饰性背景粒子（可选）
            if showDecoration_platbell {
                decorationParticles_platbell
            }
            
            FlowLayout_platbell(
                data_platbell: tagItems_platbell,
                spacing_platbell: 10
            ) { item_platbell in
                let itemIndex_platbell = tags_platbell.firstIndex(of: item_platbell.text_platbell) ?? 0
                
                TagChip_platbell(
                    text_platbell: item_platbell.text_platbell,
                    gradientIndex_platbell: (gradientIndex_platbell + itemIndex_platbell) % ThemeColors_platbell.allGradients_platbell.count,
                    isClickable_platbell: isClickable_platbell,
                    onTapped_platbell: onTagTapped_platbell
                )
            }
        }
    }
    
    /// 装饰性背景粒子
    @ViewBuilder
    private var decorationParticles_platbell: some View {
        ForEach(0..<3, id: \.self) { index_platbell in
            Circle()
                .fill(
                    ThemeColors_platbell.allStartColors_platbell[(gradientIndex_platbell + index_platbell) % ThemeColors_platbell.allStartColors_platbell.count]
                        .opacity(0.05)
                )
                .frame(width: 60, height: 60)
                .offset(
                    x: CGFloat(index_platbell * 80),
                    y: CGFloat(index_platbell * 20)
                )
                .blur(radius: 10)
        }
    }
}

// MARK: - 标签芯片

/// 标签芯片组件
struct TagChip_platbell: View {
    
    /// 标签文字
    let text_platbell: String
    
    /// 渐变色索引
    let gradientIndex_platbell: Int
    
    /// 是否可点击
    let isClickable_platbell: Bool
    
    /// 点击回调
    var onTapped_platbell: ((String) -> Void)?
    
    /// 按压状态
    @State private var isPressed_platbell = false
    
    /// 闪烁状态（用于吸引注意）
    @State private var isGlowing_platbell = false
    
    var body: some View {
        Button(action: {
            if isClickable_platbell {
                handleTap_platbell()
            }
        }) {
            HStack(spacing: 4) {
                // 装饰性小标签图标
                Image(systemName: "number")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                            .opacity(0.7)
                    )
                
                Text(text_platbell)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(
                        ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // 渐变背景
                    Capsule()
                        .fill(
                            ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell)
                                .opacity(0.12)
                        )
                    
                    // 白色高光
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        ThemeColors_platbell.gradient_platbell(at: gradientIndex_platbell),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: ThemeColors_platbell.allStartColors_platbell[gradientIndex_platbell % ThemeColors_platbell.allStartColors_platbell.count]
                    .opacity(isGlowing_platbell ? 0.4 : 0.2),
                radius: isGlowing_platbell ? 8 : 4,
                x: 0,
                y: 2
            )
            .scaleEffect(isPressed_platbell ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isClickable_platbell)
        .onAppear {
            // 添加随机延迟的闪烁效果
            let randomDelay_platbell = Double.random(in: 0...2)
            DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay_platbell) {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isGlowing_platbell = true
                }
            }
        }
    }
    
    /// 处理点击
    private func handleTap_platbell() {
        withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
            isPressed_platbell = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                isPressed_platbell = false
            }
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
        
        onTapped_platbell?(text_platbell)
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 30) {
        Text("Tag Cloud Example")
            .font(.headline)
        
        TagCloud_platbell(
            tags_platbell: ["Design", "UI/UX", "Inspiration", "Creative", "Modern", "Beautiful"],
            gradientIndex_platbell: 0,
            isClickable_platbell: true,
            onTagTapped_platbell: { tag_platbell in
                print("Tapped: \(tag_platbell)")
            }
        )
        .frame(height: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        
        TagCloud_platbell(
            tags_platbell: ["Tech", "Innovation", "Future", "AI", "Mobile"],
            gradientIndex_platbell: 2,
            isClickable_platbell: false
        )
        .frame(height: 80)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    .padding()
}
