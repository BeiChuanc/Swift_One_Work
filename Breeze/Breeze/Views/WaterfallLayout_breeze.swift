import Foundation
import UIKit

// MARK: - 瀑布流布局组件

/// 瀑布流布局代理
/// 核心作用：向布局提供每个 item 的高度，从而实现非规则错落排列
protocol WaterfallLayoutDelegate_Breeze: AnyObject {
    /// 返回指定 item 的高度
    /// - Parameters:
    ///   - layout_breeze: 当前布局对象
    ///   - indexPath_breeze: item 索引
    ///   - itemWidth_breeze: item 宽度（由布局根据列数计算后给出）
    /// - Returns: item 高度
    func waterfallLayout_Breeze(_ layout_breeze: WaterfallLayout_Breeze,
                                heightForItemAt indexPath_breeze: IndexPath,
                                itemWidth_breeze: CGFloat) -> CGFloat
}

/// 非规则瀑布流布局
/// 设计思路：固定列数，每个新 item 放入当前最短的一列，从而形成错落的瀑布效果
class WaterfallLayout_Breeze: UICollectionViewLayout {
    
    /// 布局代理
    weak var delegate_Breeze: WaterfallLayoutDelegate_Breeze?
    
    /// 列数
    var columnCount_Breeze: Int = 2
    
    /// 列间距
    var columnSpacing_Breeze: CGFloat = 12
    
    /// 行间距
    var itemSpacing_Breeze: CGFloat = 12
    
    /// 内容内边距
    var sectionInset_Breeze: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    /// 缓存的布局属性
    private var attributesCache_Breeze: [UICollectionViewLayoutAttributes] = []
    
    /// 内容总高度
    private var contentHeight_Breeze: CGFloat = 0
    
    /// 内容宽度
    private var contentWidth_Breeze: CGFloat {
        guard let collectionView_breeze = collectionView else { return 0 }
        return collectionView_breeze.bounds.width
    }
    
    // MARK: - 布局计算
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth_Breeze, height: contentHeight_Breeze)
    }
    
    override func prepare() {
        super.prepare()
        guard let collectionView_breeze = collectionView, attributesCache_Breeze.isEmpty else { return }
        
        // 计算每列宽度
        let totalSpacing_breeze = columnSpacing_Breeze * CGFloat(columnCount_Breeze - 1)
        let availableWidth_breeze = contentWidth_Breeze - sectionInset_Breeze.left - sectionInset_Breeze.right - totalSpacing_breeze
        let itemWidth_breeze = availableWidth_breeze / CGFloat(columnCount_Breeze)
        
        // 每列起始 X 坐标
        var columnX_breeze: [CGFloat] = []
        for column_breeze in 0..<columnCount_Breeze {
            columnX_breeze.append(sectionInset_Breeze.left + CGFloat(column_breeze) * (itemWidth_breeze + columnSpacing_Breeze))
        }
        
        // 每列当前高度（初始为顶部内边距）
        var columnHeights_breeze = [CGFloat](repeating: sectionInset_Breeze.top, count: columnCount_Breeze)
        
        let itemCount_breeze = collectionView_breeze.numberOfItems(inSection: 0)
        for item_breeze in 0..<itemCount_breeze {
            let indexPath_breeze = IndexPath(item: item_breeze, section: 0)
            
            // 选择当前最短的列
            let shortestColumn_breeze = columnHeights_breeze.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            // 取 item 高度
            let itemHeight_breeze = delegate_Breeze?.waterfallLayout_Breeze(self,
                                                                            heightForItemAt: indexPath_breeze,
                                                                            itemWidth_breeze: itemWidth_breeze) ?? itemWidth_breeze
            
            let x_breeze = columnX_breeze[shortestColumn_breeze]
            let y_breeze = columnHeights_breeze[shortestColumn_breeze]
            let frame_breeze = CGRect(x: x_breeze, y: y_breeze, width: itemWidth_breeze, height: itemHeight_breeze)
            
            let attributes_breeze = UICollectionViewLayoutAttributes(forCellWith: indexPath_breeze)
            attributes_breeze.frame = frame_breeze
            attributesCache_Breeze.append(attributes_breeze)
            
            // 更新该列高度
            columnHeights_breeze[shortestColumn_breeze] = y_breeze + itemHeight_breeze + itemSpacing_Breeze
        }
        
        // 内容总高度取最高列
        contentHeight_Breeze = (columnHeights_breeze.max() ?? 0) + sectionInset_Breeze.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesCache_Breeze.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < attributesCache_Breeze.count else { return nil }
        return attributesCache_Breeze[indexPath.item]
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        attributesCache_Breeze.removeAll()
        contentHeight_Breeze = 0
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView_breeze = collectionView else { return false }
        return collectionView_breeze.bounds.width != newBounds.width
    }
}
