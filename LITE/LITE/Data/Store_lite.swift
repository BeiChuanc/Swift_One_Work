import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_lite: NSObject {
    
    /// 单例
    static let shared_lite = Store_lite()
    
    // 礼物商品列表
    var goodsList_lite: [StoreModel_lite] = [
        StoreModel_lite(
            id_lite: 1,
            goodsId_lite: "lite.purchase.x1.1_9",
            goodsName_lite: "x1",
            goodsPrice_lite: "$1.99",
            goodIsTop_lite: true,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 2,
            goodsId_lite: "lite.purchase.x5.3_9",
            goodsName_lite: "x5",
            goodsPrice_lite: "$3.99",
            goodIsTop_lite: true,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 3,
            goodsId_lite: "lite.purchase.x10.4_9",
            goodsName_lite: "x10",
            goodsPrice_lite: "$4.99",
            goodIsTop_lite: true,
            goodIsLimit_lite: true
        ),
        StoreModel_lite(
            id_lite: 4,
            goodsId_lite: "lite.purchase.x1.1_9s",
            goodsName_lite: "x1",
            goodsPrice_lite: "$1.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: true
        ),
        StoreModel_lite(
            id_lite: 5,
            goodsId_lite: "lite.purchase.x5.2_9",
            goodsName_lite: "x5",
            goodsPrice_lite: "$2.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: true
        ),
        StoreModel_lite(
            id_lite: 6,
            goodsId_lite: "lite.purchase.x10.3_9",
            goodsName_lite: "x10",
            goodsPrice_lite: "$3.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 7,
            goodsId_lite: "lite.purchase.x30.4_9",
            goodsName_lite: "x30",
            goodsPrice_lite: "$4.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 8,
            goodsId_lite: "lite.purchase.x1.6_9",
            goodsName_lite: "x1",
            goodsPrice_lite: "$6.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 9,
            goodsId_lite: "lite.purchase.x5.9_9",
            goodsName_lite: "x5",
            goodsPrice_lite: "$9.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 10,
            goodsId_lite: "lite.purchase.x10.19_9",
            goodsName_lite: "x10",
            goodsPrice_lite: "$19.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 11,
            goodsId_lite: "lite.purchase.x30.29_9",
            goodsName_lite: "x30",
            goodsPrice_lite: "$29.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 12,
            goodsId_lite: "lite.purchase.x1.49_9",
            goodsName_lite: "x1",
            goodsPrice_lite: "$49.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 13,
            goodsId_lite: "lite.purchase.x5.69_9",
            goodsName_lite: "x5",
            goodsPrice_lite: "$69.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        ),
        StoreModel_lite(
            id_lite: 14,
            goodsId_lite: "lite.purchase.x10.99_9",
            goodsName_lite: "x10",
            goodsPrice_lite: "$99.99",
            goodIsTop_lite: false,
            goodIsLimit_lite: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_lite {
    
    // 内购商品
    func PurchaseStoreGift_lite(gid_lite: String, completion_lite: @escaping() -> Void) {
        Utils_lite.showLoading_lite()
        
        let products: Set = [gid_lite]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_lite) { SKPaymentTransaction in
                Utils_lite.dismissLoading_lite()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_lite.showSuccess_lite(message_lite: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_lite()
                }else{
                    print("取消支付")
                    Utils_lite.showError_lite(message_lite: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_lite.showError_lite(message_lite: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_lite.showError_lite(message_lite: "Invalid product information")
        }
    }
    
}
