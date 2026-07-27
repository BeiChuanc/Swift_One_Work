//
//  CasinoTableView_solva.swift
//  Solva
//
//  牌桌环形座位布局组件。
//  设计思路：取代传统的纵向列表/网格，用三角函数把 5 款游戏的座位卡按五角形
//  均匀环绕摆放在一张椭圆牌桌四周（欧美私人牌室常见的圆桌布局），
//  桌面中心展示品牌花色纹章作为视觉焦点，整体呈现「围桌而坐」的沉浸式大厅场景。
//  关键属性：seats_solva（座位视图 + 位置角标定义）
//
import SwiftUI

struct CasinoTableView_solva<Seat: View>: View {
    let seatCount_solva: Int
    @ViewBuilder let seat_solva: (Int) -> Seat

    var body: some View {
        GeometryReader { geo_solva in
            let seatWidth_solva: CGFloat = min(168, geo_solva.size.width * 0.19)
            let seatHeight_solva: CGFloat = 118
            let center_solva = CGPoint(x: geo_solva.size.width / 2, y: geo_solva.size.height / 2)
            let radiusX_solva = max(80, geo_solva.size.width / 2 - seatWidth_solva / 2 - 6)
            let radiusY_solva = max(60, geo_solva.size.height / 2 - seatHeight_solva / 2 - 2)
            let tableWidth_solva = geo_solva.size.width - seatWidth_solva - 30
            let tableHeight_solva = geo_solva.size.height - seatHeight_solva + 6

            ZStack {
                tableSurface_solva
                    .frame(width: max(0, tableWidth_solva), height: max(0, tableHeight_solva))
                    .position(center_solva)

                centerEmblem_solva
                    .position(center_solva)

                ForEach(0..<seatCount_solva, id: \.self) { index_solva in
                    let angle_solva = Angle(degrees: -90 + Double(index_solva) * (360.0 / Double(seatCount_solva)))
                    let x_solva = center_solva.x + radiusX_solva * CGFloat(cos(angle_solva.radians))
                    let y_solva = center_solva.y + radiusY_solva * CGFloat(sin(angle_solva.radians))
                    seat_solva(index_solva)
                        .position(x: x_solva, y: y_solva)
                }
            }
            .frame(width: geo_solva.size.width, height: geo_solva.size.height)
        }
    }

    /// 椭圆台面：深绒面 + 双层金/木滚边
    private var tableSurface_solva: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(colors: [Palette_solva.feltLight_solva, Palette_solva.feltCore_solva, Palette_solva.feltDeep_solva], center: .center, startRadius: 10, endRadius: 420))
            Ellipse()
                .strokeBorder(Palette_solva.woodBrownLight_solva, lineWidth: 10)
            Ellipse()
                .strokeBorder(Palette_solva.gold_solva.alpha_solva(0.65), lineWidth: 2)
                .padding(6)
            Ellipse()
                .strokeBorder(Color.white.alpha_solva(0.08), lineWidth: 1)
                .padding(10)
        }
        .shadow(color: Color.black.alpha_solva(0.5), radius: 20, y: 10)
    }

    /// 桌面中心的品牌纹章：四花色环绕徽标 + 招牌字样
    private var centerEmblem_solva: some View {
        VStack(spacing: 8) {
            ZStack {
                ForEach(Array(Suit_solva.allCases.enumerated()), id: \.offset) { offset_solva, suit_solva in
                    Text(suit_solva.symbol_solva)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(suit_solva.isRed_solva ? Palette_solva.cardRedSuit_solva.alpha_solva(0.85) : Palette_solva.textPrimary_solva.alpha_solva(0.7))
                        .offset(x: 22 * CGFloat(cos(Double(offset_solva) * .pi / 2)), y: 22 * CGFloat(sin(Double(offset_solva) * .pi / 2)))
                }
                Circle()
                    .strokeBorder(Palette_solva.gold_solva.alpha_solva(0.5), lineWidth: 1.2)
                    .frame(width: 56, height: 56)
            }
            .frame(width: 70, height: 70)

            Text("SOLVA")
                .font(.casinoDisplay_solva(20))
                .casinoTracked_solva(3)
                .foregroundStyle(Palette_solva.textPrimary_solva)

            Text("DEALER'S CHOICE")
                .font(.casinoLabel_solva(9))
                .casinoTracked_solva(2)
                .foregroundStyle(Palette_solva.gold_solva.alpha_solva(0.85))
        }
    }
}
