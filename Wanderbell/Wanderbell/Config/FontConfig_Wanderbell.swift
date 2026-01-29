import Foundation
import UIKit

// MARK: 字体配置

/// 字体配置类
/// 功能：管理应用的字体样式，提供艺术字体和标准字体
struct FontConfig_Wanderbell {
    
    // MARK: - 字体名称
    
    /// 标题字体（圆润、现代）
    static let titleFontName_Wanderbell = "AvenirNext-DemiBold"
    
    /// 正文字体（清晰易读）
    static let bodyFontName_Wanderbell = "AvenirNext-Regular"
    
    /// 特殊字体（艺术风格）
    static let displayFontName_Wanderbell = "AvenirNext-Heavy"
    
    // MARK: - 标题字体
    
    /// 大标题（34pt，粗体）
    static func largeTitle_Wanderbell() -> UIFont {
        return UIFont(name: displayFontName_Wanderbell, size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .heavy)
    }
    
    /// 主标题（26pt，半粗）
    static func title1_Wanderbell() -> UIFont {
        return UIFont(name: titleFontName_Wanderbell, size: 26) ?? UIFont.systemFont(ofSize: 26, weight: .semibold)
    }
    
    /// 次标题（22pt，半粗）
    static func title2_Wanderbell() -> UIFont {
        return UIFont(name: titleFontName_Wanderbell, size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .semibold)
    }
    
    /// 小标题（19pt，半粗）
    static func title3_Wanderbell() -> UIFont {
        return UIFont(name: titleFontName_Wanderbell, size: 19) ?? UIFont.systemFont(ofSize: 19, weight: .semibold)
    }
    
    // MARK: - 正文字体
    
    /// 正文（17pt，常规）
    static func body_Wanderbell() -> UIFont {
        return UIFont(name: bodyFontName_Wanderbell, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    /// 小正文（15pt，常规）
    static func subheadline_Wanderbell() -> UIFont {
        return UIFont(name: bodyFontName_Wanderbell, size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .regular)
    }
    
    /// 标注（13pt，常规）
    static func caption_Wanderbell() -> UIFont {
        return UIFont(name: bodyFontName_Wanderbell, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    /// 脚注（14pt，常规）
    static func footnote_Wanderbell() -> UIFont {
        return UIFont(name: bodyFontName_Wanderbell, size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    // MARK: - 特殊字体
    
    /// 数字字体（用于统计数据）
    static func number_Wanderbell(size_wanderbell: CGFloat) -> UIFont {
        return UIFont(name: displayFontName_Wanderbell, size: size_wanderbell) ?? UIFont.systemFont(ofSize: size_wanderbell, weight: .heavy)
    }
}

// MARK: - UIFont扩展

extension UIFont {
    
    /// 创建圆角字体
    /// 功能：返回圆润风格的字体
    static func rounded_Wanderbell(ofSize size_wanderbell: CGFloat, weight_wanderbell: UIFont.Weight) -> UIFont {
        let systemFont_wanderbell = UIFont.systemFont(ofSize: size_wanderbell, weight: weight_wanderbell)
        
        if let descriptor_wanderbell = systemFont_wanderbell.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor_wanderbell, size: size_wanderbell)
        }
        
        return systemFont_wanderbell
    }
}
