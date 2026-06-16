import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Retrs {
    /// 个人聊天
    case personal_retrs
    /// 群聊
    case group_retrs
    /// AI聊天
    case ai_retrs
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Retrs {
    
    /// 单例
    static let shared_Retrs = MessageViewModel_Retrs()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Retrs = Notification.Name("MessageStateDidChange_Retrs")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Retrs: [Int: [MessageModel_Retrs]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Retrs: [Int: GroupChatInfo_Retrs] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Retrs: [MessageModel_Retrs] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Retrs: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Retrs() {
        userMesMap_Retrs = [:]
        aiChats_Retrs = []
        notifyStateChange_Retrs()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Retrs() -> [Int: GroupChatInfo_Retrs] {
        return groupChats_Retrs
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Retrs(userId_retrs: Int) -> [MessageModel_Retrs] {
        return userMesMap_Retrs[userId_retrs] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Retrs() -> [PrewUserModel_Retrs] {
        let userIds_retrs = userMesMap_Retrs.keys
        return LocalData_Retrs.shared_Retrs.userList_Retrs.filter { user in
            guard let userId = user.userId_Retrs else { return false }
            return userIds_retrs.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Retrs() -> [MessageModel_Retrs] {
        return aiChats_Retrs
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Retrs(groupId_retrs: Int) -> [MessageModel_Retrs] {
        return groupChats_Retrs[groupId_retrs]?.messages_retrs ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Retrs(userId_retrs: Int) -> MessageModel_Retrs? {
        return userMesMap_Retrs[userId_retrs]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Retrs(message_retrs: String, chatType_retrs: ChatType_Retrs, id_retrs: Int) {
        let currentTime_retrs = getCurrentTime_Retrs()
        
        let chatMessage_retrs = MessageModel_Retrs(
            messageId_retrs: Int(Date().timeIntervalSince1970 * 1000),
            content_retrs: message_retrs,
            userHead_retrs: "current_user_head", // 这里应该从UserViewModel获取
            isMine_retrs: true,
            time_retrs: currentTime_retrs
        )
        
        switch chatType_retrs {
        case .personal_retrs:
            // 个人聊天
            if userMesMap_Retrs[id_retrs] == nil {
                userMesMap_Retrs[id_retrs] = []
            }
            userMesMap_Retrs[id_retrs]?.append(chatMessage_retrs)
            handleMessage_Retrs(message_retrs: chatMessage_retrs, id_retrs: id_retrs, chatType_retrs: chatType_retrs)
            
        case .group_retrs:
            // 群聊
            if var groupInfo_retrs = groupChats_Retrs[id_retrs] {
                groupInfo_retrs.messages_retrs.append(chatMessage_retrs)
                groupChats_Retrs[id_retrs] = groupInfo_retrs
            } else {
                groupChats_Retrs[id_retrs] = GroupChatInfo_Retrs(
                    gid_retrs: id_retrs,
                    intro_retrs: "",
                    cover_retrs: "",
                    join_retrs: "",
                    messages_retrs: [chatMessage_retrs]
                )
            }
            
        case .ai_retrs:
            // AI聊天
            aiChats_Retrs.append(chatMessage_retrs)
            handleMessage_Retrs(message_retrs: chatMessage_retrs, id_retrs: id_retrs, chatType_retrs: chatType_retrs)
        }
        
        notifyStateChange_Retrs()
    }
    
    /// 处理消息回复
    private func handleMessage_Retrs(message_retrs: MessageModel_Retrs, id_retrs: Int, chatType_retrs: ChatType_Retrs) {
        Task {
            let response_retrs = await chatService_Retrs(
                userId_retrs: 0, // 这里应该从UserViewModel获取
                message_retrs: message_retrs.content_Retrs ?? ""
            )
            
            let replyMessage_retrs = MessageModel_Retrs(
                messageId_retrs: Int(Date().timeIntervalSince1970 * 1000),
                content_retrs: response_retrs ?? "Server error",
                userHead_retrs: "",
                isMine_retrs: false,
                time_retrs: getCurrentTime_Retrs()
            )
            
            switch chatType_retrs {
            case .ai_retrs:
                aiChats_Retrs.append(replyMessage_retrs)
                
            case .personal_retrs:
                if userMesMap_Retrs[id_retrs] == nil {
                    userMesMap_Retrs[id_retrs] = []
                }
                userMesMap_Retrs[id_retrs]?.append(replyMessage_retrs)
                
            case .group_retrs:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Retrs()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Retrs(groupId_retrs: Int) {
        if var groupInfo_retrs = groupChats_Retrs[groupId_retrs] {
            groupInfo_retrs.messages_retrs = []
            groupChats_Retrs[groupId_retrs] = groupInfo_retrs
            notifyStateChange_Retrs()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Retrs(groupId_retrs: Int) {
        groupChats_Retrs.removeValue(forKey: groupId_retrs)
        notifyStateChange_Retrs()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Retrs() {
        aiChats_Retrs = []
        notifyStateChange_Retrs()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Retrs(userId_retrs: Int) {
        userMesMap_Retrs.removeValue(forKey: userId_retrs)
        notifyStateChange_Retrs()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Retrs() {
        userMesMap_Retrs = [:]
        groupChats_Retrs = [:]
        aiChats_Retrs = []
        notifyStateChange_Retrs()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Retrs() -> String {
        let formatter_retrs = DateFormatter()
        formatter_retrs.dateFormat = "HH:mm"
        return formatter_retrs.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Retrs() {
        NotificationCenter.default.post(
            name: MessageViewModel_Retrs.messageStateDidChangeNotification_Retrs,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Retrs(userId_retrs: Int, message_retrs: String) async -> String? {
        do {
            let bundleId_retrs = "com.retrs.app"
            let timestamp_retrs = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_retrs = generateRandomString_Retrs(length_retrs: 16)
            let sessionId_retrs = "\(timestamp_retrs)_\(randomString_retrs)"
            
            // 解密URL
            let urlString_retrs = decryptUrl_Retrs(encryptedCodes_retrs: MessageViewModel_Retrs.chatService_Retrs)
            guard let url_retrs = URL(string: urlString_retrs) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_retrs = URLRequest(url: url_retrs)
            request_retrs.httpMethod = "POST"
            request_retrs.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_retrs: [String: Any] = [
                "bundle_id": bundleId_retrs,
                "session_id": sessionId_retrs,
                "content_type": "text",
                "content": message_retrs
            ]
            
            request_retrs.httpBody = try JSONSerialization.data(withJSONObject: body_retrs)
            
            let (data_retrs, response_retrs) = try await URLSession.shared.data(for: request_retrs)
            
            if let httpResponse_retrs = response_retrs as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_retrs.statusCode)")
                
                if httpResponse_retrs.statusCode == 200 {
                    if let json_retrs = try JSONSerialization.jsonObject(with: data_retrs) as? [String: Any],
                       let code_retrs = json_retrs["code"] as? Int,
                       code_retrs == 1003,
                       let data_retrs = json_retrs["data"] as? [String: Any],
                       let answer_retrs = data_retrs["answer"] as? String,
                       !answer_retrs.isEmpty {
                        return answer_retrs
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
    static func encryptUrl_Retrs(plainUrl_Retrs: String) -> [Int] {
        let xorKey_Retrs = 20 // 异或密钥
        let offset_Retrs = 23 // 字符偏移量
        
        var result_Retrs: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Retrs in plainUrl_Retrs.unicodeScalars {
            let charCode_Retrs = Int(char_Retrs.value) + offset_Retrs
            result_Retrs.append(charCode_Retrs)
        }
        
        // 第二层：异或加密
        var finalResult_Retrs: [Int] = []
        for code_Retrs in result_Retrs {
            finalResult_Retrs.append(code_Retrs ^ xorKey_Retrs)
        }
        
        print("✅ URL加密结果: \(finalResult_Retrs)")
        return finalResult_Retrs
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Retrs(encryptedCodes_retrs: [Int]) -> String {
        let xorKey_retrs = 20 // 异或密钥
        let offset_retrs = 23 // 字符偏移量
        
        var result_retrs = ""
        
        // 第一层：异或解密
        for code_retrs in encryptedCodes_retrs {
            let charCode_retrs = code_retrs ^ xorKey_retrs
            if let scalar_retrs = UnicodeScalar(charCode_retrs) {
                result_retrs.append(Character(scalar_retrs))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_retrs = ""
        for char_retrs in result_retrs.unicodeScalars {
            let charCode_retrs = Int(char_retrs.value) - offset_retrs
            if let scalar_retrs = UnicodeScalar(charCode_retrs) {
                finalResult_retrs.append(Character(scalar_retrs))
            }
        }
        
        return finalResult_retrs
    }
    
    /// 生成随机字符串
    private func generateRandomString_Retrs(length_retrs: Int) -> String {
        let letters_retrs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_retrs).map { _ in letters_retrs.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Retrs {
    /// 群组ID
    var gid_retrs: Int
    /// 群组简介
    var intro_retrs: String
    /// 群组封面
    var cover_retrs: String
    /// 加入信息
    var join_retrs: String
    /// 消息列表
    var messages_retrs: [MessageModel_Retrs]
}
