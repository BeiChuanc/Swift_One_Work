import Foundation
import UIKit
import SnapKit

// MARK: 页面头部视图

/// 页面头部视图
/// 功能：展示页面标题和描述，带艺术字体和装饰元素
/// 设计：大标题、副标题、装饰图标、动画效果
class PageHeaderView_Wanderbell: UIView {
    
    // MARK: - UI组件
    
    /// 主标题
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.rounded_Wanderbell(ofSize: 38, weight_wanderbell: .bold)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 副标题
    private let subtitleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = UIFont.rounded_Wanderbell(ofSize: 15, weight_wanderbell: .medium)
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 2
        return label_wanderbell
    }()
    
    /// 装饰图标
    private let decorIconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    /// 装饰线条
    private let decorLineView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.layer.cornerRadius = 2
        return view_wanderbell
    }()
    
    // MARK: - 初始化
    
    init(title_wanderbell: String, subtitle_wanderbell: String, iconName_wanderbell: String, iconColor_wanderbell: UIColor) {
        super.init(frame: .zero)
        
        titleLabel_Wanderbell.text = title_wanderbell
        subtitleLabel_Wanderbell.text = subtitle_wanderbell
        decorIconView_Wanderbell.image = UIImage(systemName: iconName_wanderbell)
        decorIconView_Wanderbell.tintColor = iconColor_wanderbell
        decorLineView_Wanderbell.backgroundColor = iconColor_wanderbell
        
        setupUI_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        addSubview(decorIconView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(subtitleLabel_Wanderbell)
        addSubview(decorLineView_Wanderbell)
        
        decorIconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(44)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(decorIconView_Wanderbell.snp.right).offset(12)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        subtitleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(4)
            make.right.equalToSuperview()
        }
        
        decorLineView_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Wanderbell)
            make.top.equalTo(subtitleLabel_Wanderbell.snp.bottom).offset(8)
            make.width.equalTo(60)
            make.height.equalTo(4)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 添加呼吸动画
    func startBreathingAnimation_Wanderbell() {
        UIView.animate(
            withDuration: 2.0,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: { [weak self] in
                self?.decorIconView_Wanderbell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self?.decorIconView_Wanderbell.alpha = 0.7
            }
        )
    }
}
