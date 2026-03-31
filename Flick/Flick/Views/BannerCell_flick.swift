import UIKit
import SnapKit
import FSPagerView

// MARK: - Banner 轮播 Cell

/// FSPagerView 轮播 Cell
/// 核心作用：在首页 Banner 区域展示精选帖子大图、渐变文字遮罩和帖子标题。
/// 设计思路：底部渐变遮罩保证文字可读性，图标+渐变标签体现品牌风格。
class BannerCell_Flick: FSPagerViewCell {
    
    // MARK: - 复用标识
    
    static let reuseId_Flick = "BannerCell_Flick"
    
    // MARK: - UI 组件
    
    /// 背景图视图（媒体图或系统图标占位）
    private let coverImageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    /// 底部渐变遮罩（透明→深色，保证标题可读）
    private let gradientMaskView_Flick: UIView = {
        let v = UIView()
        return v
    }()
    
    private var gradientMaskLayer_Flick: CAGradientLayer?
    
    /// 精选标签
    private let featuredBadge_Flick: UILabel = {
        let l = UILabel()
        l.text = "✦ Featured"
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textColor = .white
        l.backgroundColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.85)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }()
    
    /// 帖子标题标签
    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        l.layer.shadowRadius = 4
        l.layer.shadowOpacity = 0.5
        return l
    }()
    
    /// 点赞数标签
    private let likesLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor.white.withValues(alpha: 0.9)
        return l
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskLayer_Flick?.frame = gradientMaskView_Flick.bounds
        // 刷新圆角
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - UI 布局
    
    /// 搭建 Banner Cell 子视图及约束
    private func setupUI_Flick() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(coverImageView_Flick)
        coverImageView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        contentView.addSubview(gradientMaskView_Flick)
        gradientMaskView_Flick.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        let gradLayer_Flick = CAGradientLayer()
        gradLayer_Flick.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withValues(alpha: 0.65).cgColor
        ]
        gradLayer_Flick.startPoint = CGPoint(x: 0.5, y: 0)
        gradLayer_Flick.endPoint = CGPoint(x: 0.5, y: 1)
        gradientMaskView_Flick.layer.addSublayer(gradLayer_Flick)
        gradientMaskLayer_Flick = gradLayer_Flick
        
        // 精选徽标
        contentView.addSubview(featuredBadge_Flick)
        featuredBadge_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(80)
        }
        // 内边距通过 inset
        featuredBadge_Flick.layer.cornerRadius = 11
        
        // 标题
        contentView.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        // 点赞数
        contentView.addSubview(likesLabel_Flick)
        likesLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(titleLabel_Flick)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    
    // MARK: - 公共配置方法
    
    /// 配置 Banner Cell 内容
    /// - Parameter post_flick: 帖子数据模型
    func configure_Flick(post_flick: TitleModel_Flick) {
        titleLabel_Flick.text = post_flick.title_Flick
        likesLabel_Flick.text = "♥ \(post_flick.likes_Flick)  ·  @\(post_flick.titleUserName_Flick)"
        
        // 尝试从 Assets 加载媒体图
        let mediaName_Flick = post_flick.titleMeidas_Flick.first ?? ""
        if let img_Flick = UIImage(named: mediaName_Flick) {
            coverImageView_Flick.image = img_Flick
        } else {
            // 使用系统图标配合渐变背景作为占位
            applyGradientPlaceholder_Flick(index_Flick: post_flick.titleId_Flick)
        }
    }
    
    // MARK: - 私有方法
    
    /// 应用渐变色占位背景（无媒体图时）
    private func applyGradientPlaceholder_Flick(index_Flick: Int) {
        let palettes_Flick: [(UIColor, UIColor)] = [
            (UIColor(hexstring_Flick: "#B794F6"), UIColor(hexstring_Flick: "#90CDF4")),
            (UIColor(hexstring_Flick: "#FBB6CE"), UIColor(hexstring_Flick: "#FED7AA")),
            (UIColor(hexstring_Flick: "#63B3ED"), UIColor(hexstring_Flick: "#76E4F7")),
            (UIColor(hexstring_Flick: "#F6AD55"), UIColor(hexstring_Flick: "#FC8181")),
        ]
        let pair_Flick = palettes_Flick[index_Flick % palettes_Flick.count]
        
        let size_Flick = CGSize(width: 400, height: 220)
        UIGraphicsBeginImageContextWithOptions(size_Flick, false, 0)
        if let ctx_Flick = UIGraphicsGetCurrentContext() {
            let colors_Flick = [pair_Flick.0.cgColor, pair_Flick.1.cgColor]
            let space_Flick = CGColorSpaceCreateDeviceRGB()
            if let grad_Flick = CGGradient(colorsSpace: space_Flick, colors: colors_Flick as CFArray, locations: nil) {
                ctx_Flick.drawLinearGradient(
                    grad_Flick,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size_Flick.width, y: size_Flick.height),
                    options: []
                )
            }
        }
        let img_Flick = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        coverImageView_Flick.image = img_Flick
    }
}
