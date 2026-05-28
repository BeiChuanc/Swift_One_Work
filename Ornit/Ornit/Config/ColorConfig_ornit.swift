import Foundation
import UIKit

// MARK: 颜色配置

/// 颜色配置类
/// 功能：集中管理应用的主题色、情绪色和渐变色配置
/// 设计理念：柔和渐变、温暖包容、富有疗愈感
struct ColorConfig_Ornit {
    
    // MARK: - 主题渐变色系
    
    /// 主渐变色 - 薰衣草紫
    static let primaryGradientStart_Ornit = UIColor(hexstring_Ornit: "#B794F6")
    
    /// 主渐变色 - 天空蓝
    static let primaryGradientEnd_Ornit = UIColor(hexstring_Ornit: "#90CDF4")
    
    /// 辅助渐变色 - 玫瑰粉
    static let secondaryGradientStart_Ornit = UIColor(hexstring_Ornit: "#FBB6CE")
    
    /// 辅助渐变色 - 珊瑚橙
    static let secondaryGradientEnd_Ornit = UIColor(hexstring_Ornit: "#FED7AA")
    
    // MARK: - 背景色
    
    /// 主背景色 - 极浅灰
    static let backgroundPrimary_Ornit = UIColor(hexstring_Ornit: "#F7FAFC")
    
    /// 次背景色 - 纯白
    static let backgroundSecondary_Ornit = UIColor.white
    
    /// 卡片背景色
    static let cardBackground_Ornit = UIColor.white
    
    // MARK: - 文本色
    
    /// 主文本色 - 深灰
    static let textPrimary_Ornit = UIColor(hexstring_Ornit: "#2D3748")
    
    /// 次文本色 - 中灰
    static let textSecondary_Ornit = UIColor(hexstring_Ornit: "#718096")
    
    /// 占位符文本色 - 浅灰
    static let textPlaceholder_Ornit = UIColor(hexstring_Ornit: "#A0AEC0")
    
    // MARK: - 分割线和边框
    
    /// 分割线颜色
    static let divider_Ornit = UIColor(hexstring_Ornit: "#E2E8F0")
    
    /// 边框颜色
    static let border_Ornit = UIColor(hexstring_Ornit: "#CBD5E0")
    
    // MARK: - 阴影色
    
    /// 卡片阴影色
    static let shadowColor_Ornit = UIColor(hexstring_Ornit: "#000000", alpha_Ornit: 0.1)
    
    // MARK: - 发现页专属自然色系
    
    /// 发现页 Header 渐变起始色 - 深森林绿
    static let discoverGradientStart_Ornit = UIColor(hexstring_Ornit: "#1B5E41")
    
    /// 发现页 Header 渐变结束色 - 清透青绿
    static let discoverGradientEnd_Ornit = UIColor(hexstring_Ornit: "#2DB5A3")
    
    /// 自然主题主色 - 深翠绿（分类选中态、搜索图标）
    static let naturePrimary_Ornit = UIColor(hexstring_Ornit: "#1F6E50")
    
    /// 自然主题辅助色 - 青色（卡片阴影、评论图标）
    static let natureTeal_Ornit = UIColor(hexstring_Ornit: "#2DB5A3")
    
    /// 分类标签未选中背景色 - 薄荷绿
    static let tagBackground_Ornit = UIColor(hexstring_Ornit: "#E8F5F2")
    
    /// 发现页面背景色 - 极浅自然绿白
    static let backgroundNature_Ornit = UIColor(hexstring_Ornit: "#F5FBFA")

    // MARK: - 发布页专属色系

    /// 发布页 Header 渐变起始色 - 深琥珀棕
    static let publishGradientStart_Ornit = UIColor(hexstring_Ornit: "#B7541A")

    /// 发布页 Header 渐变结束色 - 温暖橙琥珀
    static let publishGradientEnd_Ornit = UIColor(hexstring_Ornit: "#E8873A")

    /// 发布页强调色 - 琥珀金（图标、边框、提示）
    static let publishAccent_Ornit = UIColor(hexstring_Ornit: "#D97706")

    /// 发布页面背景色 - 极浅暖白
    static let backgroundWarm_Ornit = UIColor(hexstring_Ornit: "#FFFDF8")

    // MARK: - 消息页专属色系

    /// 消息页 Header 渐变起始色 - 深海军蓝
    static let messageGradientStart_Ornit = UIColor(hexstring_Ornit: "#1E3A8A")

    /// 消息页 Header 渐变结束色 - 明亮蓝
    static let messageGradientEnd_Ornit = UIColor(hexstring_Ornit: "#3B82F6")

    /// 消息页强调色 - 皇家蓝（发送按钮、我的气泡、未读徽标）
    static let messageAccent_Ornit = UIColor(hexstring_Ornit: "#2563EB")

    /// 消息页面背景色 - 极浅蓝白
    static let backgroundMessage_Ornit = UIColor(hexstring_Ornit: "#F0F5FF")

    // MARK: - 我的页面专属色系

    /// 我的页面渐变起始色 - 深紫罗兰
    static let meGradientStart_Ornit = UIColor(hexstring_Ornit: "#5B21B6")

    /// 我的页面渐变结束色 - 鲜亮紫
    static let meGradientEnd_Ornit = UIColor(hexstring_Ornit: "#8B5CF6")

    /// 我的页面强调色 - 中紫（图标、高亮、按钮）
    static let meAccent_Ornit = UIColor(hexstring_Ornit: "#7C3AED")

    /// 我的页面背景色 - 极浅紫白
    static let backgroundMe_Ornit = UIColor(hexstring_Ornit: "#F8F5FF")
}

// MARK: - UIColor扩展 - 便捷访问

extension UIColor {
    
    /// 创建渐变图层（主渐变）
    /// 功能：创建薰衣草紫到天空蓝的渐变图层
    /// 参数：
    /// - frame_Ornit: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createPrimaryGradientLayer_Ornit(frame_Ornit: CGRect) -> CAGradientLayer {
        let gradientLayer_Ornit = CAGradientLayer()
        gradientLayer_Ornit.frame = frame_Ornit
        gradientLayer_Ornit.colors = [
            ColorConfig_Ornit.primaryGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.primaryGradientEnd_Ornit.cgColor
        ]
        gradientLayer_Ornit.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Ornit.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Ornit
    }
    
    /// 创建渐变图层（辅助渐变）
    /// 功能：创建玫瑰粉到珊瑚橙的渐变图层
    /// 参数：
    /// - frame_Ornit: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createSecondaryGradientLayer_Ornit(frame_Ornit: CGRect) -> CAGradientLayer {
        let gradientLayer_Ornit = CAGradientLayer()
        gradientLayer_Ornit.frame = frame_Ornit
        gradientLayer_Ornit.colors = [
            ColorConfig_Ornit.secondaryGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.secondaryGradientEnd_Ornit.cgColor
        ]
        gradientLayer_Ornit.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Ornit.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Ornit
    }
    
    /// 创建渐变图层（发现页自然主题渐变）
    /// 功能：创建深森林绿到青绿色的渐变图层，专用于发现页 Header 与卡片媒体区
    /// 参数：
    /// - frame_Ornit: 渐变图层的尺寸
    /// 返回值：CAGradientLayer - 配置好的渐变图层
    static func createDiscoverGradientLayer_Ornit(frame_Ornit: CGRect) -> CAGradientLayer {
        let gradientLayer_Ornit = CAGradientLayer()
        gradientLayer_Ornit.frame = frame_Ornit
        gradientLayer_Ornit.colors = [
            ColorConfig_Ornit.discoverGradientStart_Ornit.cgColor,
            ColorConfig_Ornit.discoverGradientEnd_Ornit.cgColor
        ]
        gradientLayer_Ornit.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Ornit.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer_Ornit
    }
}
