import UIKit
import SnapKit

// MARK: 花卉百科二列格子单元格

/// 发现页花卉百科网格单元格
/// 功能：以渐变圆角卡片形式展示单种花卉的关键信息
/// 特性：点击触发 spring 缩放动画，花期月份色块显示
class FlowerGridCell_Sprig: UICollectionViewCell {
    
    static let reuseId_Sprig = "FlowerGridCell_Sprig"
    
    // MARK: - 私有 UI
    
    /// 渐变背景图层
    private let gradientLayer_Sprig = CAGradientLayer()
    
    /// 装饰光圈
    private let decorCircle_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        return v
    }()
    
    /// 花卉 emoji
    private let emojiLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 38)
        l.textAlignment = .center
        return l
    }()
    
    /// 花卉英文名
    private let nameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        return l
    }()
    
    /// 花期描述
    private let bloomLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.textAlignment = .center
        return l
    }()
    
    /// 难度点点行（●●○）
    private let difficultyStack_Sprig: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()
    
    /// 场景标签（Indoor / Outdoor / Both）
    private let placementBadge_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        v.layer.cornerRadius = 8
        return v
    }()
    
    private let placementLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = .white
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Sprig.frame = contentView.bounds
        decorCircle_Sprig.layer.cornerRadius = decorCircle_Sprig.bounds.width / 2
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Sprig() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        // 阴影（设置在外层）
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        layer.cornerRadius = 16
        
        contentView.layer.insertSublayer(gradientLayer_Sprig, at: 0)
        
        contentView.addSubview(decorCircle_Sprig)
        contentView.addSubview(emojiLabel_Sprig)
        contentView.addSubview(nameLabel_Sprig)
        contentView.addSubview(bloomLabel_Sprig)
        contentView.addSubview(difficultyStack_Sprig)
        contentView.addSubview(placementBadge_Sprig)
        placementBadge_Sprig.addSubview(placementLabel_Sprig)
        
        decorCircle_Sprig.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.top.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(20)
        }
        
        emojiLabel_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(46)
        }
        
        nameLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel_Sprig.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(8)
        }
        
        bloomLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Sprig.snp.bottom).offset(3)
            make.left.right.equalToSuperview().inset(8)
        }
        
        difficultyStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bloomLabel_Sprig.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        placementBadge_Sprig.snp.makeConstraints { make in
            make.top.equalTo(difficultyStack_Sprig.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        placementLabel_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }
    }
    
    // MARK: - 数据填充
    
    /// 填充花卉数据
    /// 参数：
    /// - flower_sprig: 花卉模型
    /// - bloomDesc_sprig: 花期描述（由 DiscoverViewModel 生成）
    func configure_Sprig(flower_sprig: FlowerModel_Sprig, bloomDesc_sprig: String) {
        emojiLabel_Sprig.text = flower_sprig.flowerEmoji_Sprig
        nameLabel_Sprig.text = flower_sprig.flowerName_Sprig
        bloomLabel_Sprig.text = "🗓 \(bloomDesc_sprig)"
        placementLabel_Sprig.text = flower_sprig.placement_Sprig
        
        // 渐变背景
        let base_sprig = UIColor(hexstring_Sprig: flower_sprig.flowerHexColor_Sprig)
        gradientLayer_Sprig.colors = [
            base_sprig.withAlphaComponent(0.65).cgColor,
            base_sprig.cgColor
        ]
        gradientLayer_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Sprig.endPoint = CGPoint(x: 1, y: 1)
        
        // 难度点点
        difficultyStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i_sprig in 1...3 {
            let dot_sprig = UIView()
            let filled_sprig = i_sprig <= flower_sprig.careLevel_Sprig
            dot_sprig.backgroundColor = filled_sprig
                ? UIColor.white
                : UIColor.white.withAlphaComponent(0.3)
            dot_sprig.layer.cornerRadius = 4
            dot_sprig.snp.makeConstraints { make in
                make.width.height.equalTo(8)
            }
            difficultyStack_Sprig.addArrangedSubview(dot_sprig)
        }
    }
    
    // MARK: - 动画
    
    /// 点击弹性动画
    func animateTap_Sprig() {
        animatePressDown_Sprig {
            self.animatePressUp_Sprig()
        }
    }
}
