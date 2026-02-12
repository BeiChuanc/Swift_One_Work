import SwiftUI

// MARK: - 话题标签云组件
// 核心作用：展示热门话题标签，支持横向滚动和选择
// 设计思路：胶囊形状 + 渐变色背景 + 选中状态切换
// 关键功能：标签选择、筛选内容

/// 话题标签模型
struct TopicTag_platbell: Identifiable {
    let id: Int
    let name_platbell: String
    let gradientIndex_platbell: Int
}

/// 话题标签云组件
struct TopicTagCloud_platbell: View {
    
    /// 话题标签列表
    let tags_platbell: [TopicTag_platbell]
    
    /// 选中的标签ID
    @Binding var selectedTagId_platbell: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(tags_platbell) { tag_platbell in
                    TagButton_platbell(
                        tag_platbell: tag_platbell,
                        isSelected_platbell: selectedTagId_platbell == tag_platbell.id,
                        onTap_platbell: {
                            handleTagTap_platbell(tag_platbell: tag_platbell)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: 50)
    }
    
    /// 处理标签点击
    private func handleTagTap_platbell(tag_platbell: TopicTag_platbell) {
        withAnimation(AnimationPresets_platbell.standardSpring_platbell) {
            if selectedTagId_platbell == tag_platbell.id {
                selectedTagId_platbell = nil
            } else {
                selectedTagId_platbell = tag_platbell.id
            }
        }
        
        // 震动反馈
        let impactFeedback_platbell = UIImpactFeedbackGenerator(style: .light)
        impactFeedback_platbell.impactOccurred()
    }
}

// MARK: - 标签按钮

/// 标签按钮
struct TagButton_platbell: View {
    
    /// 标签数据
    let tag_platbell: TopicTag_platbell
    
    /// 是否选中
    let isSelected_platbell: Bool
    
    /// 点击回调
    let onTap_platbell: () -> Void
    
    /// 按压状态
    @State private var isPressed_platbell = false
    
    var body: some View {
        Button(action: onTap_platbell) {
            Text(tag_platbell.name_platbell)
                .tagCapsule_platbell(
                    gradientIndex_platbell: tag_platbell.gradientIndex_platbell,
                    isSelected_platbell: isSelected_platbell
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed_platbell ? 0.95 : 1.0)
        .onTapGesture {
            withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                isPressed_platbell = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(AnimationPresets_platbell.quickSpring_platbell) {
                    isPressed_platbell = false
                }
            }
            onTap_platbell()
        }
    }
}

// MARK: - 预览

#Preview {
    VStack(spacing: 20) {
        // 默认话题标签
        TopicTagCloud_platbell(
            tags_platbell: [
                TopicTag_platbell(id: 0, name_platbell: "Explore", gradientIndex_platbell: 0),
                TopicTag_platbell(id: 1, name_platbell: "Adventure", gradientIndex_platbell: 1),
                TopicTag_platbell(id: 2, name_platbell: "Nature", gradientIndex_platbell: 2),
                TopicTag_platbell(id: 3, name_platbell: "Discovery", gradientIndex_platbell: 3),
                TopicTag_platbell(id: 4, name_platbell: "Journey", gradientIndex_platbell: 4)
            ],
            selectedTagId_platbell: .constant(nil)
        )
        
        Spacer()
    }
    .background(Color(.systemBackground))
}
