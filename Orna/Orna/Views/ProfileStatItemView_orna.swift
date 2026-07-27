import Foundation
import UIKit
import SnapKit

// MARK: - 资料数据统计单元视图

/// 个人资料数据统计单元视图
/// 核心作用：以数字 + 标题纵向排列展示单项统计数据（如关注数、粉丝数、发布数），
///           供"我的"与"用户中心"等资料页复用
class ProfileStatItemView_Orna: UIView {

    private let countLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countLabel_Orna)
        addSubview(titleLabel_Orna)
        countLabel_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(countLabel_Orna.snp.bottom).offset(2)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置统计数值与标题
    /// 参数：
    /// - count_orna: 统计数值
    /// - title_orna: 统计项标题
    func configure_Orna(count_orna: Int, title_orna: String) {
        countLabel_Orna.text = "\(count_orna)"
        titleLabel_Orna.text = title_orna
    }
}
