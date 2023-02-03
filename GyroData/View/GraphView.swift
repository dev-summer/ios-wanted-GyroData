//
//  GraphView.swift
//  GyroData
//
//  Created by Jiyoung Lee on 2023/02/01.
//

import UIKit

class GraphView: UIView {
    private var xLayer = CAShapeLayer()
    private var yLayer = CAShapeLayer()
    private var zLayer = CAShapeLayer()
    private let maxCount: Double = 600
    // scale이 변하면 currentX의 y값도 스케일에 맞춰서 변해야 한다.
    private lazy var currentX: CGPoint = CGPoint(x: .zero, y: self.frame.height / 2)
    private lazy var currentY: CGPoint = CGPoint(x: .zero, y: self.frame.height / 2)
    private lazy var currentZ: CGPoint = CGPoint(x: .zero, y: self.frame.height / 2)
    private var count: Double = 0
    private var maxValue: Double = 10 {
        didSet {
            scale = oldValue / maxValue
            print(scale)
        }
    }
    private var scale: CGFloat = 1.0 {
        didSet {
            layer.sublayerTransform = CATransform3DMakeScale(1, scale, 1)
            currentX.y = currentX.y * scale
            currentY.y = currentY.y * scale
            currentZ.y = currentZ.y * scale
        }
    }
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(xLayer)
        drawGrid()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1
//        drawGrid(rect)
    }
    
    private func drawGrid() {
        let width: Int = Int(bounds.width)
        let fraction: Int = Int(bounds.width) / 8
        let path = UIBezierPath()
        for i in 1..<8 {
            path.move(to: CGPoint(x: .zero, y: fraction * i))
            path.addLine(to: CGPoint(x: width, y: fraction * i))
            path.move(to: CGPoint(x: fraction * i, y: .zero))
            path.addLine(to: CGPoint(x: fraction * i, y: width))
        }

        let gridLayer = CAShapeLayer()
        gridLayer.lineWidth = 1
        gridLayer.frame = bounds
        gridLayer.path = path.cgPath
        gridLayer.strokeColor = UIColor.systemGray.cgColor
        self.layer.addSublayer(gridLayer)
        gridLayer.masksToBounds = true
    }

    private func calculateY(_ y: Double) -> CGFloat {
        let height = frame.height
        let centerY = height / 2
        let axisRange = maxValue * 2
        let calculatedY = centerY + CGFloat(y) / axisRange * height
        return calculatedY
    }
    
    private func drawBezier(from start: CGPoint, to end: CGPoint, color: CGColor) {
        let path: UIBezierPath
        if let currentPath = xLayer.path {
            path = UIBezierPath(cgPath: currentPath)
        } else {
            path = UIBezierPath()
        }
        path.move(to: start)
        path.addLine(to: end)
        xLayer.lineWidth = 1
        xLayer.lineCap = .round
        xLayer.frame = bounds
        xLayer.path = path.cgPath
        xLayer.strokeColor = color
        xLayer.masksToBounds = true

        self.setNeedsDisplay()
    }

    private func axisRangeNeedsUpdate(_ coordinate: Coordinate) {
        var maxValue = max(coordinate.x, coordinate.y, coordinate.z)
        let minValue = min(coordinate.x, coordinate.y, coordinate.z)
        maxValue = max(maxValue, abs(minValue))
        if maxValue > self.maxValue { self.maxValue = maxValue }
    }
    
    private func calculateScale(_ oldValue: Double) -> CGFloat {
        return maxValue / oldValue
    }
    
    func clearGraph() {
        layer.sublayers?.removeAll()
    }
    
    func drawChartLine(_ coordinate: Coordinate) {
        count += 1
        axisRangeNeedsUpdate(coordinate)
        
        let pointX = CGPoint(
            x: count / maxCount * frame.width,
            y: calculateY(coordinate.x)
        )
//        let pointY = CGPoint(
//            x: count / maxCount * frame.width,
//            y: calculateY(coordinate.y)
//        )
//        let pointZ = CGPoint(
//            x: count / maxCount * frame.width,
//            y: calculateY(coordinate.z)
//        )
        
        drawBezier(
            from: currentX,
            to: pointX,
            color: UIColor.systemRed.cgColor
        )
//        drawBezier(
//            from: currentY,
//            to: pointY,
//            color: UIColor.systemGreen.cgColor
//        )
//        drawBezier(from: currentZ,
//                   to: pointZ,
//                   color: UIColor.systemBlue.cgColor
//        )

        self.currentX = pointX
//        self.currentY = pointY
//        self.currentZ = pointZ
    }
}
