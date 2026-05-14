import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Echd {
    /// 个人聊天
    case personal_echd
    /// 群聊
    case group_echd
    /// AI聊天
    case ai_echd
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Echd {
    
    /// 单例
    static let shared_Echd = MessageViewModel_Echd()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Echd = Notification.Name("MessageStateDidChange_Echd")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Echd: [Int: [MessageModel_Echd]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Echd: [Int: GroupChatInfo_Echd] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Echd: [MessageModel_Echd] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Echd: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Echd() {
        userMesMap_Echd = [:]
        aiChats_Echd = []
        notifyStateChange_Echd()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Echd() -> [Int: GroupChatInfo_Echd] {
        return groupChats_Echd
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Echd(userId_echd: Int) -> [MessageModel_Echd] {
        return userMesMap_Echd[userId_echd] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Echd() -> [PrewUserModel_Echd] {
        let userIds_echd = userMesMap_Echd.keys
        return LocalData_Echd.shared_Echd.userList_Echd.filter { user in
            guard let userId = user.userId_Echd else { return false }
            return userIds_echd.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Echd() -> [MessageModel_Echd] {
        return aiChats_Echd
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Echd(groupId_echd: Int) -> [MessageModel_Echd] {
        return groupChats_Echd[groupId_echd]?.messages_echd ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Echd(userId_echd: Int) -> MessageModel_Echd? {
        return userMesMap_Echd[userId_echd]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Echd(message_echd: String, chatType_echd: ChatType_Echd, id_echd: Int) {
        let currentTime_echd = getCurrentTime_Echd()
        
        let chatMessage_echd = MessageModel_Echd(
            messageId_echd: Int(Date().timeIntervalSince1970 * 1000),
            content_echd: message_echd,
            userHead_echd: "current_user_head", // 这里应该从UserViewModel获取
            isMine_echd: true,
            time_echd: currentTime_echd
        )
        
        switch chatType_echd {
        case .personal_echd:
            // 个人聊天
            if userMesMap_Echd[id_echd] == nil {
                userMesMap_Echd[id_echd] = []
            }
            userMesMap_Echd[id_echd]?.append(chatMessage_echd)
            handleMessage_Echd(message_echd: chatMessage_echd, id_echd: id_echd, chatType_echd: chatType_echd)
            
        case .group_echd:
            // 群聊
            if var groupInfo_echd = groupChats_Echd[id_echd] {
                groupInfo_echd.messages_echd.append(chatMessage_echd)
                groupChats_Echd[id_echd] = groupInfo_echd
            } else {
                groupChats_Echd[id_echd] = GroupChatInfo_Echd(
                    gid_echd: id_echd,
                    intro_echd: "",
                    cover_echd: "",
                    join_echd: "",
                    messages_echd: [chatMessage_echd]
                )
            }
            
        case .ai_echd:
            // AI聊天
            aiChats_Echd.append(chatMessage_echd)
            handleMessage_Echd(message_echd: chatMessage_echd, id_echd: id_echd, chatType_echd: chatType_echd)
        }
        
        notifyStateChange_Echd()
    }
    
    /// 处理消息回复
    private func handleMessage_Echd(message_echd: MessageModel_Echd, id_echd: Int, chatType_echd: ChatType_Echd) {
        Task {
            let response_echd = await chatService_Echd(
                userId_echd: 0, // 这里应该从UserViewModel获取
                message_echd: message_echd.content_Echd ?? ""
            )
            
            let replyMessage_echd = MessageModel_Echd(
                messageId_echd: Int(Date().timeIntervalSince1970 * 1000),
                content_echd: response_echd ?? "Server error",
                userHead_echd: "",
                isMine_echd: false,
                time_echd: getCurrentTime_Echd()
            )
            
            switch chatType_echd {
            case .ai_echd:
                aiChats_Echd.append(replyMessage_echd)
                
            case .personal_echd:
                if userMesMap_Echd[id_echd] == nil {
                    userMesMap_Echd[id_echd] = []
                }
                userMesMap_Echd[id_echd]?.append(replyMessage_echd)
                
            case .group_echd:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Echd()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Echd(groupId_echd: Int) {
        if var groupInfo_echd = groupChats_Echd[groupId_echd] {
            groupInfo_echd.messages_echd = []
            groupChats_Echd[groupId_echd] = groupInfo_echd
            notifyStateChange_Echd()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Echd(groupId_echd: Int) {
        groupChats_Echd.removeValue(forKey: groupId_echd)
        notifyStateChange_Echd()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Echd() {
        aiChats_Echd = []
        notifyStateChange_Echd()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Echd(userId_echd: Int) {
        userMesMap_Echd.removeValue(forKey: userId_echd)
        notifyStateChange_Echd()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Echd() {
        userMesMap_Echd = [:]
        groupChats_Echd = [:]
        aiChats_Echd = []
        notifyStateChange_Echd()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Echd() -> String {
        let formatter_echd = DateFormatter()
        formatter_echd.dateFormat = "HH:mm"
        return formatter_echd.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Echd() {
        NotificationCenter.default.post(
            name: MessageViewModel_Echd.messageStateDidChangeNotification_Echd,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Echd(userId_echd: Int, message_echd: String) async -> String? {
        do {
            let bundleId_echd = "com.echd.app"
            let timestamp_echd = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_echd = generateRandomString_Echd(length_echd: 16)
            let sessionId_echd = "\(timestamp_echd)_\(randomString_echd)"
            
            // 解密URL
            let urlString_echd = decryptUrl_Echd(encryptedCodes_echd: MessageViewModel_Echd.chatService_Echd)
            guard let url_echd = URL(string: urlString_echd) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_echd = URLRequest(url: url_echd)
            request_echd.httpMethod = "POST"
            request_echd.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_echd: [String: Any] = [
                "bundle_id": bundleId_echd,
                "session_id": sessionId_echd,
                "content_type": "text",
                "content": message_echd
            ]
            
            request_echd.httpBody = try JSONSerialization.data(withJSONObject: body_echd)
            
            let (data_echd, response_echd) = try await URLSession.shared.data(for: request_echd)
            
            if let httpResponse_echd = response_echd as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_echd.statusCode)")
                
                if httpResponse_echd.statusCode == 200 {
                    if let json_echd = try JSONSerialization.jsonObject(with: data_echd) as? [String: Any],
                       let code_echd = json_echd["code"] as? Int,
                       code_echd == 1003,
                       let data_echd = json_echd["data"] as? [String: Any],
                       let answer_echd = data_echd["answer"] as? String,
                       !answer_echd.isEmpty {
                        return answer_echd
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Echd(plainUrl_Echd: String) -> [Int] {
        let xorKey_Echd = 20 // 异或密钥
        let offset_Echd = 23 // 字符偏移量
        
        var result_Echd: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Echd in plainUrl_Echd.unicodeScalars {
            let charCode_Echd = Int(char_Echd.value) + offset_Echd
            result_Echd.append(charCode_Echd)
        }
        
        // 第二层：异或加密
        var finalResult_Echd: [Int] = []
        for code_Echd in result_Echd {
            finalResult_Echd.append(code_Echd ^ xorKey_Echd)
        }
        
        print("✅ URL加密结果: \(finalResult_Echd)")
        return finalResult_Echd
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Echd(encryptedCodes_echd: [Int]) -> String {
        let xorKey_echd = 20 // 异或密钥
        let offset_echd = 23 // 字符偏移量
        
        var result_echd = ""
        
        // 第一层：异或解密
        for code_echd in encryptedCodes_echd {
            let charCode_echd = code_echd ^ xorKey_echd
            if let scalar_echd = UnicodeScalar(charCode_echd) {
                result_echd.append(Character(scalar_echd))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_echd = ""
        for char_echd in result_echd.unicodeScalars {
            let charCode_echd = Int(char_echd.value) - offset_echd
            if let scalar_echd = UnicodeScalar(charCode_echd) {
                finalResult_echd.append(Character(scalar_echd))
            }
        }
        
        return finalResult_echd
    }
    
    /// 生成随机字符串
    private func generateRandomString_Echd(length_echd: Int) -> String {
        let letters_echd = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_echd).map { _ in letters_echd.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Echd {
    /// 群组ID
    var gid_echd: Int
    /// 群组简介
    var intro_echd: String
    /// 群组封面
    var cover_echd: String
    /// 加入信息
    var join_echd: String
    /// 消息列表
    var messages_echd: [MessageModel_Echd]
}
