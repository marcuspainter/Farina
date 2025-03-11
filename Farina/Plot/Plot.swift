//
//  Plot.swift
//  Farina
//
//  Created by Marcus Painter on 11/03/2025.
//

import Charts
import SwiftUI

// Plot view that accepts custom modifiers
public struct Plot: View {
    // Data
    private var x: [Double]
    private var plotType: PlotType
    var plotData: [PlotData] = []

    // Annotation
    private var title: String?
    private var xLabel: String?
    private var yLabel: String?
    private var xScaleType: ScaleType
    private var yScaleType: ScaleType

    // Limits
    private var xLimMax: Double
    private var xLimMin: Double
    private var yLimMax: Double
    private var yLimMin: Double

    // Axis Ticks
    private var xTicks: [Double] = []
    private var xTickLabels: [String] = []
    private var yTicks: [Double] = []
    private var yTickLabels: [String] = []

    // Matlab colors: get(gca,'colororder')
    private var plotColors: [Color] = [
        Color(red: 0.0000, green: 0.4470, blue: 0.7410),
        Color(red: 0.8500, green: 0.3250, blue: 0.0980),
        Color(red: 0.9290, green: 0.6940, blue: 0.1250),
        Color(red: 0.4940, green: 0.1840, blue: 0.5560),
        Color(red: 0.4660, green: 0.6740, blue: 0.1880),
        Color(red: 0.3010, green: 0.7450, blue: 0.9330),
        Color(red: 0.6350, green: 0.0780, blue: 0.1840),
    ]
    var legends: [String] { plotData.map { $0.legend } }
    var colors: [Color] { plotData.map { $0.color } }

    private var valid = true
    private var reasons: [String] = []

    public init(_ y: [Double]..., type: PlotType = .plot) {
        self.init(x: nil, yList: y, type: type)
    }

    public init(x: [Double], y: [Double]..., type: PlotType = .plot) {
        self.init(x: x, yList: y, type: type)
    }

    private init(x: [Double]?, yList: [[Double]], type: PlotType = .plot) {
        plotType = type
        switch plotType {
        case .plot:
            xScaleType = .linear
            yScaleType = .linear
        case .semiLogX:
            xScaleType = .log
            yScaleType = .linear
        case .semiLogY:
            xScaleType = .linear
            yScaleType = .log
        case .logLog:
            xScaleType = .log
            yScaleType = .log
        }

        var maxXcount = 0
        var minY = 1e6
        var maxY = -1e6

        for y in yList {
            if maxXcount < y.count {
                maxXcount = y.count
            }
            let maxYY = y.max() ?? 1.0
            if maxY < maxYY {
                maxY = maxYY
            }

            let minYY = y.min() ?? 0.0
            if minY > minYY {
                minY = minYY
            }
        }

        if let x {
            self.x = x
        } else {
            // Create x vector to match largest y series count
            self.x = (0 ..< maxXcount).map { Double($0) }
        }

        xLimMin = self.x.min() ?? 0.0
        xLimMax = self.x.max() ?? 1.0
        yLimMin = minY
        yLimMax = maxY

        for y in yList {
            let n = plotData.count
            let legend = "Data\(n)"
            let color = plotColors[n % plotColors.count]
            let ySafe = y.map { safeValue($0) }

            let data = PlotData(x: self.x,
                                y: ySafe,
                                lineWidth: 1.0,
                                color: color,
                                symbol: .none,
                                symbolSize: 9,
                                legend: legend)

            plotData.append(data)
        }

        // xTicks = niceNumbers(minValue: xLimMin!, maxValue: xLimMax!)
        // yTicks = niceNumbers(minValue: yLimMin!, maxValue: yLimMax!)
    }

    public var body: some View {
        if !valid {
            VStack {
                // Title
                if let title = title {
                    Text(title)
                        .padding(.top)
                } else {
                    Text("Plot")
                        .padding(.top)
                }
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .overlay {
                VStack {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.red)
                        .font(.largeTitle)

                    ForEach(reasons, id: \.self) { reason in
                        Text(reason).padding(.top, 0)
                    }
                }
            }

        } else {
            VStack {
                // Title
                if let title = title {
                    Text(title)
                        .padding(.top)
                }

                // The internal chart logic (hidden from the outside world)
                Chart {
                    ForEach(self.plotData) { data in
                        ForEach(data.y.indices, id: \.self) { index in
                            LineMark(
                                x: .value("x", self.x[index]),
                                y: .value("y", data.y[index])
                                , series: .value("Data", data.legend)
                            )
                            .lineStyle(StrokeStyle(lineWidth: data.lineWidth))
                            .foregroundStyle(data.color)
                            .mask { RectangleMark() }
                            .symbol {
                                if data.symbol != .none {
                                    Image(systemName: data.symbol.rawValue)
                                        .foregroundColor(data.color)
                                        .font(.system(size: data.symbolSize))
                                }
                            }
                        }
                    }
                }
                .chartXScale(domain: [self.xLimMin, self.xLimMax], type: self.xScaleType)
                .chartYScale(domain: [self.yLimMin, self.yLimMax], type: self.yScaleType)

                .ifLet(self.xLabel) { view, label in
                    view.chartXAxisLabel(position: .bottom, alignment: .center) {
                        Text(label).font(.footnote)
                    }
                }
                .ifLet(self.yLabel) { view, label in
                    view.chartYAxisLabel(position: .leading, alignment: .center) {
                        Text(label).font(.footnote)
                            .rotationEffect(.degrees(180), anchor: .center)
                    }
                }

                .chartXAxis {
                    if self.xTicks.count > 0 {
                        AxisMarks(values: self.xTicks) { tick in
                            AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                            AxisValueLabel {
                                if let value = tick.as(Double.self) {
                                    Text(value.formatted())
                                        .font(.caption2)
                                }
                            }
                        }
                    } else {
                        AxisMarks(position: .bottom)
                    }
                }

                .chartYAxis {
                    if self.yTicks.count > 0 {
                        AxisMarks(position: .leading, values: self.yTicks) { tick in
                            AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
                            AxisValueLabel {
                                if let value = tick.as(Double.self) {
                                    Text(value.formatted())
                                        .font(.caption2)
                                }
                            }
                        }
                    } else {
                        AxisMarks(position: .leading)
                    }
                }
                .chartForegroundStyleScale(domain: self.legends, range: self.colors)
                .chartLegend(position: .bottom)
                .chartLegend(self.legends.count > 1 ? .visible : .hidden)
            }
        }
    }

    mutating func validate() {
        (valid, reasons) = validateData()
    }

    private func validateData() -> (valid: Bool, reasons: [String]) {
        var valid = true
        var reasons: [String] = []

        switch plotType {
        case .plot:
            _ = 1
        case .semiLogX:
            let isSafeX = isLogSafe(x)
            if !isSafeX {
                valid = false
                reasons.append("x values must be positive")
            }
            if xLimMin <= 0 || xLimMax <= 0 {
                valid = false
                reasons.append("xLim must be positive")
            }

        case .semiLogY:
            for data in plotData {
                let isSafeY = isLogSafe(data.y)
                if !isSafeY {
                    valid = false
                    reasons.append("\(data.legend) must be positive")
                }
            }
        case .logLog:
            let isSafeX = isLogSafe(x)
            if !isSafeX {
                valid = false
                reasons.append("x must be positive")
            }
            for data in plotData {
                let isSafeY = isLogSafe(data.y)
                if !isSafeY {
                    valid = false
                    reasons.append("\(data.legend) must be positive")
                }
            }
        }

        return (valid, reasons)
    }

    func isLogSafe(_ x: [Double]) -> Bool {
        x.allSatisfy { $0 > 0 }
    }

    func safeValue(_ x: Double) -> Double {
        return x == 0.0 ? 0.0 : x
    }
}

// https://stackoverflow.com/questions/74414598/swiftui-charts-y-axis-title-is-flipped

#Preview("plot (linear)") {
    let y = [1.0, 3.0, 10.0, 4.0, 5.0, 1.0]
    let x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

    Plot(x: x, y: y, type: .plot)
        .title("Signal")
        .xLabel("Time")
        .yLabel("Amplitude")
        // .xLim(1.0, 10.0)
        .lineWidth(2.0, 2.0)
        .color(.green, .blue)
        .marker(.point, .square)
        .legend("Signal", "Reference")
        .frame(height: 300)
        .padding()
}

#Preview("semiLogX") {
    let y = [1.0, 3.0, 10.0, 4.0, 5.0, 1.0]
    let x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

    Plot(x: x, y: y, type: .semiLogX)
        .title("Signal")
        .xLabel("Time")
        .yLabel("Amplitude")
        // .xLim(1.0, 10.0)
        .lineWidth(2.0, 2.0)
        .color(.green, .blue)
        .marker(.point, .square)
        .legend("Signal", "Reference")
        .frame(height: 300)
        .padding()
}

#Preview("semiLogY") {
    let y = [1.0, 3.0, 10.0, 4.0, 5.0, 1.0]
    let x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

    Plot(x: x, y: y, type: .semiLogY)
        .title("Signal")
        .xLabel("Time")
        .yLabel("Amplitude")
        // .xLim(1.0, 10.0)
        .lineWidth(2.0, 2.0)
        .color(.green, .blue)
        .marker(.point, .square)
        .legend("Signal", "Reference")
        .frame(height: 300)
        .padding()
}

#Preview("logLog") {
    let y = [1.0, 3.0, 10.0, 4.0, 5.0, 1.0]
    let x = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

    Plot(x: x, y: y, type: .logLog)
        .title("Signal")
        .xLabel("Time")
        .yLabel("Amplitude")
        // .xLim(1.0, 10.0)
        .lineWidth(2.0, 2.0)
        .color(.green, .blue)
        .marker(.point, .square)
        .legend("Signal", "Reference")
        .frame(height: 300)
        .padding()
}

extension Plot {
    // Custom Modifier for title
    func title(_ title: String) -> Plot {
        var plot = self
        plot.title = title
        return plot
    }

    // Custom Modifier for xLabel
    func xLabel(_ label: String) -> Plot {
        var plot = self
        plot.xLabel = label
        return plot
    }

    // Custom Modifier for yLabel
    func yLabel(_ label: String) -> Plot {
        var plot = self
        plot.yLabel = label
        return plot
    }

    // Custom Modifier for xLim
    func xLim(_ min: Double, _ max: Double) -> Plot {
        var plot = self
        plot.xLimMax = max
        plot.xLimMin = min
        return plot
    }

    // Custom Modifier for yLim
    func yLim(_ min: Double, _ max: Double) -> Plot {
        var plot = self
        plot.yLimMax = max
        plot.yLimMin = min
        return plot
    }

    // Custom Modifier for legend
    func legend(_ legend: String...) -> Plot {
        var plot = self
        for i in 0 ..< plotData.count {
            if i > legend.count - 1 {
                break
            }
            plot.plotData[i].legend = legend[i]
        }
        return plot
    }

    // Custom Modifier for lineWidth
    func lineWidth(_ lineWidth: Double...) -> Plot {
        var plot = self
        for i in 0 ..< plotData.count {
            if i > lineWidth.count - 1 {
                break
            }
            plot.plotData[i].lineWidth = lineWidth[i]
        }
        return plot
    }

    // Custom Modifier for color
    func color(_ color: Color...) -> Plot {
        var plot = self
        for i in 0 ..< plotData.count {
            if i > color.count - 1 {
                break
            }
            plot.plotData[i].color = color[i]
        }
        return plot
    }

    // Custom Modifier for marker
    func marker(_ symbol: PlotMarker...) -> Plot {
        var plot = self
        for i in 0 ..< plotData.count {
            if i > symbol.count - 1 {
                break
            }
            plot.plotData[i].symbol = symbol[i]
        }
        return plot
    }

    // Custom Modifier for xTicks
    func xTicks(_ ticks: [Double]) -> Plot {
        var plot = self
        plot.xTicks = ticks
        return plot
    }

    // Custom Modifier for yTicks
    func yTicks(_ ticks: [Double]) -> Plot {
        var plot = self
        plot.yTicks = ticks
        return plot
    }
}
