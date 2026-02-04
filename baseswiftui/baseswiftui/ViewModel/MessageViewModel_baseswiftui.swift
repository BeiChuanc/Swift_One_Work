import Foundation
import Combine

// MARK: - 消息ViewModel

/// 消息类型枚举
enum ChatType_baseswiftui {
    /// 个人聊天
    case personal_baseswiftui
    /// 群聊
    case group_baseswiftui
    /// AI聊天
    case ai_baseswiftui
}

/// 消息状态管理类
class MessageViewModel_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = MessageViewModel_baseswiftui()
    
    // MARK: - 响应式属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    @Published var userMesMap_baseswiftui: [Int: [MessageModel_baseswiftui]] = [:]
    
    /// 群聊信息映射（群组ID -> 群聊信息）
    @Published var groupChats_baseswiftui: [Int: GroupChatInfo_baseswiftui] = [:]
    
    /// AI聊天消息列表
    @Published var aiChats_baseswiftui: [MessageModel_baseswiftui] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_baseswiftui: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    func initChat_baseswiftui() {
        userMesMap_baseswiftui = [:]
        aiChats_baseswiftui = []
        setGroup_baseswiftui()
    }
    
    /// 设置群聊基础信息
    private func setGroup_baseswiftui() {}
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_baseswiftui() -> [Int: GroupChatInfo_baseswiftui] {
        return groupChats_baseswiftui
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_baseswiftui(userId_baseswiftui: Int) -> [MessageModel_baseswiftui] {
        return userMesMap_baseswiftui[userId_baseswiftui] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_baseswiftui() -> [PrewUserModel_baseswiftui] {
        let userIds_baseswiftui = userMesMap_baseswiftui.keys
        return LocalData_baseswiftui.shared_baseswiftui.userList_baseswiftui.filter { user_baseswiftui in
            guard let userId_baseswiftui = user_baseswiftui.userId_baseswiftui else { return false }
            return userIds_baseswiftui.contains(userId_baseswiftui)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_baseswiftui() -> [MessageModel_baseswiftui] {
        return aiChats_baseswiftui
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_baseswiftui(groupId_baseswiftui: Int) -> [MessageModel_baseswiftui] {
        return groupChats_baseswiftui[groupId_baseswiftui]?.messages_baseswiftui ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_baseswiftui(userId_baseswiftui: Int) -> MessageModel_baseswiftui? {
        return userMesMap_baseswiftui[userId_baseswiftui]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_baseswiftui(message_baseswiftui: String, chatType_baseswiftui: ChatType_baseswiftui, id_baseswiftui: Int) {
        let currentTime_baseswiftui = getCurrentTime_baseswiftui()
        
        let chatMessage_baseswiftui = MessageModel_baseswiftui(
            messageId_baseswiftui: Int(Date().timeIntervalSince1970 * 1000),
            content_baseswiftui: message_baseswiftui,
            userHead_baseswiftui: "current_user_head", // 这里应该从UserViewModel获取
            isMine_baseswiftui: true,
            time_baseswiftui: currentTime_baseswiftui
        )
        
        switch chatType_baseswiftui {
        case .personal_baseswiftui:
            // 个人聊天
            if userMesMap_baseswiftui[id_baseswiftui] == nil {
                userMesMap_baseswiftui[id_baseswiftui] = []
            }
            userMesMap_baseswiftui[id_baseswiftui]?.append(chatMessage_baseswiftui)
            handleMessage_baseswiftui(message_baseswiftui: chatMessage_baseswiftui, id_baseswiftui: id_baseswiftui, chatType_baseswiftui: chatType_baseswiftui)
            
        case .group_baseswiftui:
            // 群聊
            if var groupInfo_baseswiftui = groupChats_baseswiftui[id_baseswiftui] {
                groupInfo_baseswiftui.messages_baseswiftui.append(chatMessage_baseswiftui)
                groupChats_baseswiftui[id_baseswiftui] = groupInfo_baseswiftui
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            } else {
                groupChats_baseswiftui[id_baseswiftui] = GroupChatInfo_baseswiftui(
                    gid_baseswiftui: id_baseswiftui,
                    intro_baseswiftui: "",
                    cover_baseswiftui: "",
                    join_baseswiftui: "",
                    messages_baseswiftui: [chatMessage_baseswiftui]
                )
                // 手动触发更新，确保UI及时刷新
                objectWillChange.send()
            }
            
        case .ai_baseswiftui:
            // AI聊天
            aiChats_baseswiftui.append(chatMessage_baseswiftui)
            handleMessage_baseswiftui(message_baseswiftui: chatMessage_baseswiftui, id_baseswiftui: id_baseswiftui, chatType_baseswiftui: chatType_baseswiftui)
        }
    }
    
    /// 处理消息回复
    private func handleMessage_baseswiftui(message_baseswiftui: MessageModel_baseswiftui, id_baseswiftui: Int, chatType_baseswiftui: ChatType_baseswiftui) {
        Task { @MainActor in
            let response_baseswiftui = await chatService_baseswiftui(
                userId_baseswiftui: 0, // 这里应该从UserViewModel获取
                message_baseswiftui: message_baseswiftui.content_baseswiftui ?? ""
            )
            
            let replyMessage_baseswiftui = MessageModel_baseswiftui(
                messageId_baseswiftui: Int(Date().timeIntervalSince1970 * 1000),
                content_baseswiftui: response_baseswiftui ?? "Server error",
                userHead_baseswiftui: "",
                isMine_baseswiftui: false,
                time_baseswiftui: getCurrentTime_baseswiftui()
            )
            
            switch chatType_baseswiftui {
            case .ai_baseswiftui:
                self.aiChats_baseswiftui.append(replyMessage_baseswiftui)
                
            case .personal_baseswiftui:
                if self.userMesMap_baseswiftui[id_baseswiftui] == nil {
                    self.userMesMap_baseswiftui[id_baseswiftui] = []
                }
                self.userMesMap_baseswiftui[id_baseswiftui]?.append(replyMessage_baseswiftui)
                
            case .group_baseswiftui:
                break // 群聊不自动回复
            }
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    
    /// 清空群聊消息
    func clearGroupMessages_baseswiftui(groupId_baseswiftui: Int) {
        if var groupInfo_baseswiftui = groupChats_baseswiftui[groupId_baseswiftui] {
            groupInfo_baseswiftui.messages_baseswiftui = []
            groupChats_baseswiftui[groupId_baseswiftui] = groupInfo_baseswiftui
            // 手动触发更新，确保UI及时刷新
            objectWillChange.send()
        }
    }
    
    /// 移除指定群组
    func removeGroup_baseswiftui(groupId_baseswiftui: Int) {
        groupChats_baseswiftui.removeValue(forKey: groupId_baseswiftui)
    }
    
    /// 清空AI聊天记录
    func clearAiChat_baseswiftui() {
        aiChats_baseswiftui = []
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_baseswiftui(userId_baseswiftui: Int) {
        userMesMap_baseswiftui.removeValue(forKey: userId_baseswiftui)
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_baseswiftui() {
        userMesMap_baseswiftui = [:]
        groupChats_baseswiftui = [:]
        aiChats_baseswiftui = []
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_baseswiftui() -> String {
        let formatter_baseswiftui = DateFormatter()
        formatter_baseswiftui.dateFormat = "HH:mm"
        return formatter_baseswiftui.string(from: Date())
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_baseswiftui(userId_baseswiftui: Int, message_baseswiftui: String) async -> String? {
        do {
            let bundleId_baseswiftui = "com.baseswiftui.app"
            let timestamp_baseswiftui = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_baseswiftui = generateRandomString_baseswiftui(length_baseswiftui: 16)
            let sessionId_baseswiftui = "\(timestamp_baseswiftui)_\(randomString_baseswiftui)"
            
            // 解密URL
            let urlString_baseswiftui = decryptUrl_baseswiftui(encryptedCodes_baseswiftui: MessageViewModel_baseswiftui.chatService_baseswiftui)
            guard let url_baseswiftui = URL(string: urlString_baseswiftui) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_baseswiftui = URLRequest(url: url_baseswiftui)
            request_baseswiftui.httpMethod = "POST"
            request_baseswiftui.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_baseswiftui: [String: Any] = [
                "bundle_id": bundleId_baseswiftui,
                "session_id": sessionId_baseswiftui,
                "content_type": "text",
                "content": message_baseswiftui
            ]
            
            request_baseswiftui.httpBody = try JSONSerialization.data(withJSONObject: body_baseswiftui)
            
            let (data_baseswiftui, response_baseswiftui) = try await URLSession.shared.data(for: request_baseswiftui)
            
            if let httpResponse_baseswiftui = response_baseswiftui as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_baseswiftui.statusCode)")
                
                if httpResponse_baseswiftui.statusCode == 200 {
                    if let json_baseswiftui = try JSONSerialization.jsonObject(with: data_baseswiftui) as? [String: Any],
                       let code_baseswiftui = json_baseswiftui["code"] as? Int,
                       code_baseswiftui == 1003,
                       let data_baseswiftui = json_baseswiftui["data"] as? [String: Any],
                       let answer_baseswiftui = data_baseswiftui["answer"] as? String,
                       !answer_baseswiftui.isEmpty {
                        return answer_baseswiftui
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_baseswiftui(encryptedCodes_baseswiftui: [Int]) -> String {
        let xorKey_baseswiftui = 20 // 异或密钥
        let offset_baseswiftui = 23 // 字符偏移量
        
        var result_baseswiftui = ""
        
        // 第一层：异或解密
        for code_baseswiftui in encryptedCodes_baseswiftui {
            let charCode_baseswiftui = code_baseswiftui ^ xorKey_baseswiftui
            if let scalar_baseswiftui = UnicodeScalar(charCode_baseswiftui) {
                result_baseswiftui.append(Character(scalar_baseswiftui))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_baseswiftui = ""
        for char_baseswiftui in result_baseswiftui.unicodeScalars {
            let charCode_baseswiftui = Int(char_baseswiftui.value) - offset_baseswiftui
            if let scalar_baseswiftui = UnicodeScalar(charCode_baseswiftui) {
                finalResult_baseswiftui.append(Character(scalar_baseswiftui))
            }
        }
        
        return finalResult_baseswiftui
    }
    
    /// 生成随机字符串
    private func generateRandomString_baseswiftui(length_baseswiftui: Int) -> String {
        let letters_baseswiftui = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_baseswiftui).map { _ in letters_baseswiftui.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_baseswiftui {
    /// 群组ID
    var gid_baseswiftui: Int
    /// 群组简介
    var intro_baseswiftui: String
    /// 群组封面
    var cover_baseswiftui: String
    /// 加入信息
    var join_baseswiftui: String
    /// 消息列表
    var messages_baseswiftui: [MessageModel_baseswiftui]
}
