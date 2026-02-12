import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_platbell: NSObject {
    
    /// 单例
    static let shared_platbell = Store_platbell()
    
    // 礼物商品列表
    var goodsList_platbell: [StoreModel_platbell] = [
        StoreModel_platbell(
            id_platbell: 1,
            goodsId_platbell: "platbell.pur.x2.1_9",
            goodsName_platbell: "x2",
            goodsPrice_platbell: "$1.99",
            goodIsTop_platbell: true,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 2,
            goodsId_platbell: "platbell.pur.x3.3_9",
            goodsName_platbell: "x3",
            goodsPrice_platbell: "$3.99",
            goodIsTop_platbell: true,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 3,
            goodsId_platbell: "platbell.pur.x5.4_9",
            goodsName_platbell: "x5",
            goodsPrice_platbell: "$4.99",
            goodIsTop_platbell: true,
            goodIsLimit_platbell: true
        ),
        StoreModel_platbell(
            id_platbell: 4,
            goodsId_platbell: "platbell.pur.x1.1_9",
            goodsName_platbell: "x1",
            goodsPrice_platbell: "$1.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: true
        ),
        StoreModel_platbell(
            id_platbell: 5,
            goodsId_platbell: "platbell.pur.x2.2_9",
            goodsName_platbell: "x2",
            goodsPrice_platbell: "$2.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: true
        ),
        StoreModel_platbell(
            id_platbell: 6,
            goodsId_platbell: "platbell.pur.x3.3_9s",
            goodsName_platbell: "x3",
            goodsPrice_platbell: "$3.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 7,
            goodsId_platbell: "platbell.pur.x4.4_9",
            goodsName_platbell: "x4",
            goodsPrice_platbell: "$4.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 8,
            goodsId_platbell: "platbell.pur.x5.6_9",
            goodsName_platbell: "x5",
            goodsPrice_platbell: "$6.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 9,
            goodsId_platbell: "platbell.pur.x10.9_9",
            goodsName_platbell: "x10",
            goodsPrice_platbell: "$9.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 10,
            goodsId_platbell: "platbell.pur.x20.19_9",
            goodsName_platbell: "x20",
            goodsPrice_platbell: "$19.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 11,
            goodsId_platbell: "platbell.pur.x30.29_9",
            goodsName_platbell: "x30",
            goodsPrice_platbell: "$29.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 12,
            goodsId_platbell: "platbell.pur.x50.49_9",
            goodsName_platbell: "x50",
            goodsPrice_platbell: "$49.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 13,
            goodsId_platbell: "platbell.pur.x70.69_9",
            goodsName_platbell: "x70",
            goodsPrice_platbell: "$69.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        ),
        StoreModel_platbell(
            id_platbell: 14,
            goodsId_platbell: "platbell.pur.x100.99_9",
            goodsName_platbell: "x100",
            goodsPrice_platbell: "$99.99",
            goodIsTop_platbell: false,
            goodIsLimit_platbell: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_platbell {
    
    // 内购商品
    func PurchaseStoreGift_platbell(gid_platbell: String, completion_platbell: @escaping() -> Void) {
        Utils_platbell.showLoading_platbell()
        
        let products: Set = [gid_platbell]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_platbell) { SKPaymentTransaction in
                Utils_platbell.dismissLoading_platbell()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_platbell.showSuccess_platbell(message_platbell: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_platbell()
                }else{
                    print("取消支付")
                    Utils_platbell.showError_platbell(message_platbell: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_platbell.showError_platbell(message_platbell: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_platbell.showError_platbell(message_platbell: "Invalid product information")
        }
    }
    
}
