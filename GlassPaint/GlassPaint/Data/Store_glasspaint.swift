import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_Glasspaint: NSObject {
    
    /// 单例
    static let shared_Glasspaint = Store_Glasspaint()
    
    // 礼物商品列表
    var goodsList_Glasspaint: [StoreModel_Glasspaint] = [
        StoreModel_Glasspaint(
            id_Glasspaint: 0,
            goodsId_Glasspaint: "Glasspaint.gift.x2.1_9",
            goodsName_Glasspaint: "x2",
            goodsPrice_Glasspaint: "$1.99",
            goodIsTop_Glasspaint: true,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 1,
            goodsId_Glasspaint: "Glasspaint.gift.x3.3_9",
            goodsName_Glasspaint: "x3",
            goodsPrice_Glasspaint: "$3.99",
            goodIsTop_Glasspaint: true,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 2,
            goodsId_Glasspaint: "Glasspaint.gift.x5.4_9",
            goodsName_Glasspaint: "x5",
            goodsPrice_Glasspaint: "$4.99",
            goodIsTop_Glasspaint: true,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 3,
            goodsId_Glasspaint: "Glasspaint.gift.x1.1_9",
            goodsName_Glasspaint: "x1",
            goodsPrice_Glasspaint: "$1.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 4,
            goodsId_Glasspaint: "Glasspaint.gift.x2.2_9",
            goodsName_Glasspaint: "x2",
            goodsPrice_Glasspaint: "$2.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 5,
            goodsId_Glasspaint: "Glasspaint.gift.x3.3_9_s",
            goodsName_Glasspaint: "x3",
            goodsPrice_Glasspaint: "$3.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 6,
            goodsId_Glasspaint: "Glasspaint.gift.x4.4_9",
            goodsName_Glasspaint: "x4",
            goodsPrice_Glasspaint: "$4.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 7,
            goodsId_Glasspaint: "Glasspaint.gift.x5.6_9",
            goodsName_Glasspaint: "x5",
            goodsPrice_Glasspaint: "$6.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 8,
            goodsId_Glasspaint: "Glasspaint.gift.x10.9_9",
            goodsName_Glasspaint: "x10",
            goodsPrice_Glasspaint: "$9.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 9,
            goodsId_Glasspaint: "Glasspaint.gift.x20.19_9",
            goodsName_Glasspaint: "x20",
            goodsPrice_Glasspaint: "$19.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 10,
            goodsId_Glasspaint: "Glasspaint.gift.x30.29_9",
            goodsName_Glasspaint: "x30",
            goodsPrice_Glasspaint: "$29.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 11,
            goodsId_Glasspaint: "Glasspaint.gift.x50.49_9",
            goodsName_Glasspaint: "x50",
            goodsPrice_Glasspaint: "$49.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 12,
            goodsId_Glasspaint: "Glasspaint.gift.x70.69_9",
            goodsName_Glasspaint: "x70",
            goodsPrice_Glasspaint: "$69.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        ),
        StoreModel_Glasspaint(
            id_Glasspaint: 13,
            goodsId_Glasspaint: "Glasspaint.gift.x100.99_9",
            goodsName_Glasspaint: "x100",
            goodsPrice_Glasspaint: "$99.99",
            goodIsTop_Glasspaint: false,
            goodIsLimit_Glasspaint: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_Glasspaint {
    
    // 内购商品
    func PurchaseStoreGift_Glasspaint(gid_Glasspaint: String, completion_Glasspaint: @escaping() -> Void) {
        Utils_Glasspaint.showLoading_Glasspaint()
        
        let products: Set = [gid_Glasspaint]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_Glasspaint) { SKPaymentTransaction in
                Utils_Glasspaint.dismissLoading_Glasspaint()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_Glasspaint()
                }else{
                    print("取消支付")
                    Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_Glasspaint.showError_Glasspaint(message_Glasspaint: "Invalid product information")
        }
    }
    
}
