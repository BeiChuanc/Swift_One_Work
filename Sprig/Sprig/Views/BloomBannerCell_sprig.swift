import UIKit
import SnapKit
import FSPagerView

// MARK: 首页花期轮播 Cell

/// 首页今日花期 FSPagerView 单元格
/// 功能：展示单个花卉的渐变卡片，包含 emoji、花名、花期区间、养护难度
/// 设计：全圆角渐变背景，emoji 大号居中，信息分层排列，入场带弹性动画
class BloomBannerCell_Sprig: FSPagerViewCell {
    
    static let reuseId_Sprig = "BloomBannerCell_Sprig"
    
    // MARK: - 私有 UI
    
    /// 渐变背景图层
    private let gradientLayer_Sprig = CAGradientLayer()
    
    /// 装饰光圈（右上角半透明圆）
    private let decorCircle_Sprig = UIView()
    
    /// 花卉 emoji 标签
    private let emojiLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 62)
        l.textAlignment = .center
        return l
    }()
    
    /// 花卉英文名
    private let nameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    /// 花期描述标签
    private let bloomLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        return l
    }()
    
    /// 难度 badge 容器
    private let badgeView_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 10
        return v
    }()
    
    /// 难度标签文字
    private let difficultyLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    /// 浇水信息标签
    private let waterLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        return l
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Sprig()
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Sprig.frame = contentView.bounds
        // 更新装饰圆位置
        decorCircle_Sprig.layer.cornerRadius = decorCircle_Sprig.bounds.width / 2
    }
    
    // MARK: - UI 搭建
    
    /// 搭建单元格 UI 层次
    private func setupUI_Sprig() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        
        // 渐变背景
        gradientLayer_Sprig.cornerRadius = 20
        contentView.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        
        // 装饰圆（右上半透明大圆）
        decorCircle_Sprig.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        decorCircle_Sprig.layer.cornerRadius = 60
        contentView.addSubview(decorCircle_Sprig)
        
        contentView.addSubview(emojiLabel_Sprig)
        contentView.addSubview(nameLabel_Sprig)
        contentView.addSubview(bloomLabel_Sprig)
        contentView.addSubview(badgeView_Sprig)
        badgeView_Sprig.addSubview(difficultyLabel_Sprig)
        contentView.addSubview(waterLabel_Sprig)
        
        // 装饰圆约束
        decorCircle_Sprig.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalToSuperview().offset(-30)
            make.right.equalToSuperview().offset(30)
        }
        
        // emoji 约束
        emojiLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(28)
            make.height.equalTo(72)
        }
        
        // 花名约束
        nameLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emojiLabel_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 花期描述
        bloomLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel_Sprig.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 浇水信息
        waterLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bloomLabel_Sprig.snp.bottom).offset(6)
        }
        
        // 难度 badge
        badgeView_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(waterLabel_Sprig.snp.bottom).offset(8)
            make.height.equalTo(20)
        }
        difficultyLabel_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10))
        }
    }
    
    // MARK: - 数据填充
    
    /// 填充花卉数据
    /// 参数：
    /// - flower_sprig: 花卉模型
    /// - bloomDesc_sprig: 花期描述字符串（由 DiscoverViewModel 生成）
    func configure_Sprig(flower_sprig: FlowerModel_Sprig, bloomDesc_sprig: String) {
        emojiLabel_Sprig.text = flower_sprig.flowerEmoji_Sprig
        nameLabel_Sprig.text = flower_sprig.flowerName_Sprig
        bloomLabel_Sprig.text = "🗓 \(bloomDesc_sprig)"
        waterLabel_Sprig.text = "💧 Water every \(flower_sprig.waterDays_Sprig) days"
        
        let diffVM_sprig = DiscoverViewModel_Sprig.shared_Sprig
        difficultyLabel_Sprig.text = "⚡ \(diffVM_sprig.careLevelDescription_Sprig(level_sprig: flower_sprig.careLevel_Sprig))"
        
        // 更新渐变背景
        let baseColor_sprig = UIColor(hexstring_Sprig: flower_sprig.flowerHexColor_Sprig)
        gradientLayer_Sprig.colors = [
            baseColor_sprig.withAlphaComponent(0.7).cgColor,
            baseColor_sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
    }
}
