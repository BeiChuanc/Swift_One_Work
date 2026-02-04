import Foundation
import RMStore

// MARK: 商店数据

/// 商店数据
class Store_blisslink: NSObject {
    
    /// 单例
    static let shared_blisslink = Store_blisslink()
    
    // 礼物商品列表
    var goodsList_blisslink: [StoreModel_blisslink] = [
        StoreModel_blisslink(
            id_blisslink: 1,
            goodsId_blisslink: "blisslink.kp.5x.3_9",
            goodsName_blisslink: "5x",
            goodsPrice_blisslink: "$3.99",
            goodIsTop_blisslink: true,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 2,
            goodsId_blisslink: "blisslink.kp.10x.4_9",
            goodsName_blisslink: "10x",
            goodsPrice_blisslink: "$4.99",
            goodIsTop_blisslink: true,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 3,
            goodsId_blisslink: "blisslink.kp.1x.1_9",
            goodsName_blisslink: "1x",
            goodsPrice_blisslink: "$1.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: true
        ),
        StoreModel_blisslink(
            id_blisslink: 4,
            goodsId_blisslink: "blisslink.kp.2x.2_9",
            goodsName_blisslink: "2x",
            goodsPrice_blisslink: "$2.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: true
        ),
        StoreModel_blisslink(
            id_blisslink: 5,
            goodsId_blisslink: "blisslink.kp.3x.3_9",
            goodsName_blisslink: "3x",
            goodsPrice_blisslink: "$3.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: true
        ),
        StoreModel_blisslink(
            id_blisslink: 6,
            goodsId_blisslink: "blisslink.kp.4x.4_9",
            goodsName_blisslink: "4x",
            goodsPrice_blisslink: "$4.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 7,
            goodsId_blisslink: "blisslink.kp.5x.6_9",
            goodsName_blisslink: "5x",
            goodsPrice_blisslink: "$6.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 8,
            goodsId_blisslink: "blisslink.kp.7x.9_9",
            goodsName_blisslink: "7x",
            goodsPrice_blisslink: "$9.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 9,
            goodsId_blisslink: "blisslink.kp.12x.19_9",
            goodsName_blisslink: "12x",
            goodsPrice_blisslink: "$19.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 10,
            goodsId_blisslink: "blisslink.kp.20x.29_9",
            goodsName_blisslink: "20x",
            goodsPrice_blisslink: "$29.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 11,
            goodsId_blisslink: "blisslink.kp.42x.49_9",
            goodsName_blisslink: "42x",
            goodsPrice_blisslink: "$49.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 12,
            goodsId_blisslink: "blisslink.kp.64x.69_9",
            goodsName_blisslink: "64x",
            goodsPrice_blisslink: "$69.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        ),
        StoreModel_blisslink(
            id_blisslink: 13,
            goodsId_blisslink: "blisslink.kp.102x.99_9",
            goodsName_blisslink: "102x",
            goodsPrice_blisslink: "$99.99",
            goodIsTop_blisslink: false,
            goodIsLimit_blisslink: false
        )
    ]
    
    private override init() {
        super.init()
    }
}


extension Store_blisslink {
    
    // 内购商品
    func PurchaseStoreGift_blisslink(gid_blisslink: String, completion_blisslink: @escaping() -> Void) {
        Utils_blisslink.showLoading_blisslink()
        
        let products: Set = [gid_blisslink]
        RMStore.default().requestProducts(products) { success, invalidProductIdentifiers in
            RMStore.default().addPayment(gid_blisslink) { SKPaymentTransaction in
                Utils_blisslink.dismissLoading_blisslink()
                if SKPaymentTransaction?.transactionState == .purchased {
                    print("支付成功")
                    Utils_blisslink.showSuccess_blisslink(message_blisslink: "Payment successful")
                    
                    NotificationCenter.default.post(name: NSNotification.Name("DazzlRefreshGifts"), object: nil)
                    completion_blisslink()
                }else{
                    print("取消支付")
                    Utils_blisslink.showError_blisslink(message_blisslink: "User cancels payment")
                }
                
            } failure: { transaction, error in
                print("商品信息无效")
                Utils_blisslink.showError_blisslink(message_blisslink: "Invalid product information")
            }
        } failure: { error in
            print("商品信息无效")
            Utils_blisslink.showError_blisslink(message_blisslink: "Invalid product information")
        }
    }
    
}
