// The source of the app icon: a padel ball in the accent color on the black canvas, its seam
// cut into it as two dark arcs. It draws the 1024-point square the asset catalog takes for
// watchOS, opaque and without text, and writes it as a PNG. watchOS masks it to a circle, so
// everything that matters stays well inside one.
//
//     swift App/Design/render-app-icon.swift App/PadelScoreWatch/Assets.xcassets/AppIcon.appiconset/AppIcon.png

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let size = 1024
let side = CGFloat(size)

/// Colors from the palette in DESIGN.md: `background.primary`, `accent` and `text.onAccent`.
let canvas = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1)
let ballLight = CGColor(srgbRed: 0xE8 / 255, green: 0xFB / 255, blue: 0xB8 / 255, alpha: 1)
let ballColor = CGColor(srgbRed: 0xDC / 255, green: 0xF7 / 255, blue: 0x9B / 255, alpha: 1)
let ballShade = CGColor(srgbRed: 0xB9 / 255, green: 0xD6 / 255, blue: 0x74 / 255, alpha: 1)
let seamColor = CGColor(srgbRed: 0x18 / 255, green: 0x1E / 255, blue: 0x0E / 255, alpha: 1)

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(Data("usage: render-app-icon.swift OUTPUT.png\n".utf8))
    exit(64)
}
let output = URL(fileURLWithPath: CommandLine.arguments[1])

guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
) else { exit(70) }

context.setFillColor(canvas)
context.fill(CGRect(x: 0, y: 0, width: side, height: side))

let center = CGPoint(x: side / 2, y: side / 2)
let radius = side * 0.405
let ball = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)

// The ball, lit softly from the upper left.
context.saveGState()
context.addEllipse(in: ball)
context.clip()
let gradient = CGGradient(
    colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
    colors: [ballLight, ballColor, ballShade] as CFArray,
    locations: [0, 0.55, 1]
)!
context.drawRadialGradient(
    gradient,
    startCenter: CGPoint(x: center.x - radius * 0.35, y: center.y + radius * 0.4),
    startRadius: 0,
    endCenter: center,
    endRadius: radius * 1.05,
    options: [.drawsAfterEndLocation]
)

// The seam: two arcs of circles centered beyond opposite edges, bulging toward each other,
// turned so the ball reads as moving.
context.translateBy(x: center.x, y: center.y)
context.rotate(by: -.pi / 5)
context.setStrokeColor(seamColor)
context.setLineWidth(radius * 0.1)
context.setLineCap(.round)
let seamRadius = radius * 0.82
let seamOffset = radius * 1.15
for direction in [-1.0, 1.0] {
    context.addArc(
        center: CGPoint(x: direction * seamOffset, y: 0),
        radius: seamRadius,
        startAngle: 0,
        endAngle: .pi * 2,
        clockwise: false
    )
    context.strokePath()
}
context.restoreGState()

guard let image = context.makeImage(),
      let destination = CGImageDestinationCreateWithURL(output as CFURL, UTType.png.identifier as CFString, 1, nil)
else { exit(73) }
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else { exit(73) }
