import Foundation
import UIKit

// MARK: 背景配置

/// 背景渐变配置类
/// 功能：为不同页面提供统一风格的渐变背景
/// 设计理念：柔和、梦幻、温暖的色彩过渡
struct BackgroundConfig_Wanderbell {
    
    // MARK: - 渐变色配置
    
    /// 首页渐变色（生机、温暖、梦幻）
    static let homeGradientColors_Wanderbell: [CGColor] = [
        UIColor(hexstring_Wanderbell: "#E8F5E9").cgColor,  // 极浅绿
        UIColor(hexstring_Wanderbell: "#FFF9C4").cgColor,  // 极浅黄
        UIColor(hexstring_Wanderbell: "#F3E5F5").cgColor   // 极浅紫
    ]
    
    /// 发现页渐变色（明亮、梦幻、清新）
    static let discoverGradientColors_Wanderbell: [CGColor] = [
        UIColor(hexstring_Wanderbell: "#FFF9C4").cgColor,  // 极浅黄
        UIColor(hexstring_Wanderbell: "#F3E5F5").cgColor,  // 极浅紫
        UIColor(hexstring_Wanderbell: "#E0F2F1").cgColor   // 极浅青
    ]
    
    /// 消息页渐变色（温暖、交流、活力）
    static let messageGradientColors_Wanderbell: [CGColor] = [
        UIColor(hexstring_Wanderbell: "#FFF5F7").cgColor,  // 极浅粉
        UIColor(hexstring_Wanderbell: "#F0F9FF").cgColor,  // 极浅蓝
        UIColor(hexstring_Wanderbell: "#FEFCE8").cgColor   // 极浅黄
    ]
    
    /// 我的页面渐变色（个性、优雅、独特）
    static let profileGradientColors_Wanderbell: [CGColor] = [
        UIColor(hexstring_Wanderbell: "#F5F3FF").cgColor,  // 极浅紫
        UIColor(hexstring_Wanderbell: "#FDF2F8").cgColor,  // 极浅粉
        UIColor(hexstring_Wanderbell: "#ECFDF5").cgColor   // 极浅绿
    ]
    
    /// 发布页渐变色（创作、灵感、表达）
    static let publishGradientColors_Wanderbell: [CGColor] = [
        UIColor(hexstring_Wanderbell: "#FFF0F5").cgColor,  // 极浅玫瑰
        UIColor(hexstring_Wanderbell: "#F0F4FF").cgColor,  // 极浅蓝紫
        UIColor(hexstring_Wanderbell: "#FFFAF0").cgColor   // 极浅杏色
    ]
    
    // MARK: - 渐变位置
    
    static let gradientLocations_Wanderbell: [NSNumber] = [0.0, 0.5, 1.0]
    static let gradientStartPoint_Wanderbell = CGPoint(x: 0, y: 0)
    static let gradientEndPoint_Wanderbell = CGPoint(x: 1, y: 1)
}

// MARK: - UIView扩展 - 背景渐变

extension UIView {
    
    /// 添加页面背景渐变
    /// 功能：为视图添加指定的渐变背景图层
    /// 参数：
    /// - colors_wanderbell: 渐变颜色数组
    /// 返回值：CAGradientLayer - 创建的渐变图层
    @discardableResult
    func addPageBackgroundGradient_Wanderbell(colors_wanderbell: [CGColor]) -> CAGradientLayer {
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = bounds
        gradientLayer_wanderbell.colors = colors_wanderbell
        gradientLayer_wanderbell.locations = BackgroundConfig_Wanderbell.gradientLocations_Wanderbell
        gradientLayer_wanderbell.startPoint = BackgroundConfig_Wanderbell.gradientStartPoint_Wanderbell
        gradientLayer_wanderbell.endPoint = BackgroundConfig_Wanderbell.gradientEndPoint_Wanderbell
        layer.insertSublayer(gradientLayer_wanderbell, at: 0)
        return gradientLayer_wanderbell
    }
    
    /// 添加首页背景渐变
    @discardableResult
    func addHomeBackgroundGradient_Wanderbell() -> CAGradientLayer {
        return addPageBackgroundGradient_Wanderbell(colors_wanderbell: BackgroundConfig_Wanderbell.homeGradientColors_Wanderbell)
    }
    
    /// 添加发现页背景渐变
    @discardableResult
    func addDiscoverBackgroundGradient_Wanderbell() -> CAGradientLayer {
        return addPageBackgroundGradient_Wanderbell(colors_wanderbell: BackgroundConfig_Wanderbell.discoverGradientColors_Wanderbell)
    }
    
    /// 添加消息页背景渐变
    @discardableResult
    func addMessageBackgroundGradient_Wanderbell() -> CAGradientLayer {
        return addPageBackgroundGradient_Wanderbell(colors_wanderbell: BackgroundConfig_Wanderbell.messageGradientColors_Wanderbell)
    }
    
    /// 添加我的页面背景渐变
    @discardableResult
    func addProfileBackgroundGradient_Wanderbell() -> CAGradientLayer {
        return addPageBackgroundGradient_Wanderbell(colors_wanderbell: BackgroundConfig_Wanderbell.profileGradientColors_Wanderbell)
    }
    
    /// 添加发布页背景渐变
    @discardableResult
    func addPublishBackgroundGradient_Wanderbell() -> CAGradientLayer {
        return addPageBackgroundGradient_Wanderbell(colors_wanderbell: BackgroundConfig_Wanderbell.publishGradientColors_Wanderbell)
    }
}
