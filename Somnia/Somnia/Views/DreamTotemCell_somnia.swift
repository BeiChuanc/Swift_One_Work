import Foundation
import UIKit
import SnapKit

// MARK: - 梦物图腾卡片视图

/// 梦物图腾卡片视图
/// 核心功能：以「集邮徽章」样式展示单个梦物，包含图标、名称、出现次数、类型颜色标识
/// 设计理念：圆形徽章 + 类型主题色 + 计数器，让用户感受到梦物收集的乐趣
/// 使用场景：首页梦物图腾横向滚动区域中的单个卡片
class DreamTotemCell_Somnia: UIView {

    // MARK: - 私有 UI 属性

    /// 外圆（带类型颜色边框）
    private let outerRing_Somnia = UIView()

    /// 图标容器（填充类型浅色背景）
    private let iconContainer_Somnia = UIView()

    /// 梦物 Emoji 或图标标签
    private let iconLabel_Somnia = UILabel()

    /// 梦物名称
    private let nameLabel_Somnia = UILabel()

    /// 出现次数徽章
    private let countBadge_Somnia = UIView()
    private let countLabel_Somnia  = UILabel()

    /// 类型标识角标
    private let typeDot_Somnia = UIView()

    // MARK: - 回调

    /// 点击回调，携带梦物模型
    var onTapped_Somnia: ((DreamTotemModel_Somnia) -> Void)?

    // MARK: - 数据

    private var totemModel_Somnia: DreamTotemModel_Somnia?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Somnia()
    }

    // MARK: - UI 构建

    /// 初始化内部视图结构
    private func setupUI_Somnia() {
        backgroundColor = .clear

        // 外圆环
        outerRing_Somnia.layer.cornerRadius = 34
        outerRing_Somnia.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        outerRing_Somnia.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        outerRing_Somnia.layer.shadowOffset = CGSize(width: 0, height: 3)
        outerRing_Somnia.layer.shadowRadius = 6
        outerRing_Somnia.layer.shadowOpacity = 1
        addSubview(outerRing_Somnia)

        // 图标容器（内圆）
        iconContainer_Somnia.layer.cornerRadius = 26
        iconContainer_Somnia.clipsToBounds = true
        outerRing_Somnia.addSubview(iconContainer_Somnia)

        // Emoji 图标
        iconLabel_Somnia.font = UIFont.systemFont(ofSize: 26)
        iconLabel_Somnia.textAlignment = .center
        iconContainer_Somnia.addSubview(iconLabel_Somnia)

        // 类型角标（右上角小圆点）
        typeDot_Somnia.layer.cornerRadius = 7
        typeDot_Somnia.layer.borderWidth = 2
        typeDot_Somnia.layer.borderColor = ColorConfig_Somnia.backgroundPrimary_Somnia.cgColor
        outerRing_Somnia.addSubview(typeDot_Somnia)

        // 名称标签
        nameLabel_Somnia.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        nameLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        nameLabel_Somnia.textAlignment = .center
        nameLabel_Somnia.numberOfLines = 1
        addSubview(nameLabel_Somnia)

        // 出现次数徽章
        countBadge_Somnia.layer.cornerRadius = 9
        addSubview(countBadge_Somnia)

        countLabel_Somnia.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        countLabel_Somnia.textAlignment = .center
        countBadge_Somnia.addSubview(countLabel_Somnia)

        setupConstraints_Somnia()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap)
    }

    /// 设置约束
    private func setupConstraints_Somnia() {
        outerRing_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(68)
        }

        iconContainer_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(52)
        }

        iconLabel_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        typeDot_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.width.height.equalTo(14)
        }

        nameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(outerRing_Somnia.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        countBadge_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        countLabel_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8))
        }
    }

    // MARK: - 数据配置

    /// 用梦物数据配置卡片显示
    /// - Parameter totem_somnia: 梦物模型
    func configure_Somnia(totem_somnia: DreamTotemModel_Somnia) {
        totemModel_Somnia = totem_somnia
        iconLabel_Somnia.text = totem_somnia.icon_Somnia
        nameLabel_Somnia.text = totem_somnia.name_Somnia
        countLabel_Somnia.text = "×\(totem_somnia.appearCount_Somnia)"

        let typeColor = totemTypeColor_Somnia(type_somnia: totem_somnia.type_Somnia)
        iconContainer_Somnia.backgroundColor = typeColor.withAlphaComponent(0.12)
        outerRing_Somnia.layer.borderWidth = 2
        outerRing_Somnia.layer.borderColor = typeColor.withAlphaComponent(0.3).cgColor
        typeDot_Somnia.backgroundColor = typeColor
        countBadge_Somnia.backgroundColor = typeColor.withAlphaComponent(0.12)
        countLabel_Somnia.textColor = typeColor
    }

    /// 根据梦物类型返回主题颜色
    /// - Parameter type_somnia: 梦物类型枚举
    /// - Returns: 对应 UIColor
    private func totemTypeColor_Somnia(type_somnia: DreamTotemType_Somnia) -> UIColor {
        switch type_somnia {
        case .person_Somnia: return UIColor(hexstring_Somnia: "#90CDF4")
        case .animal_Somnia: return UIColor(hexstring_Somnia: "#68D391")
        case .object_Somnia: return UIColor(hexstring_Somnia: "#F6E05E")
        case .scene_Somnia:  return UIColor(hexstring_Somnia: "#B794F6")
        }
    }

    // MARK: - 交互事件

    @objc private func handleTap_Somnia() {
        guard let model = totemModel_Somnia else { return }
        animatePressDown_Somnia {
            self.animatePressUp_Somnia()
        }
        onTapped_Somnia?(model)
    }
}
