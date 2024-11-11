//
//  ReplicateFluxProUltraInputSchemaV1_1.swift
//
//
//  Created by Ronald Mannak on 11/10/24.
//

import Foundation

/// Input schema for use with requests to Black Forest Lab's Pro Ultra model:
/// https://replicate.com/black-forest-labs/flux-1.1-pro-ultra/api/schema
public struct ReplicateFluxProUltraInputSchema_v1_1: Encodable {
    // Required

    /// Text prompt for image generation
    public let prompt: String

    // Optional

    /// Aspect ratio of the image between 21:9 and 9:21
    ///
    /// default: 1:1 (BlackForest's default is 16:9)
    public let aspectRatio: String?

    /// Format of the output images.
    ///
    /// Valid choices: jpeg, png
    /// default: jpg
    public let outputFormat: OutputFormat?

    /// Tolerance level for input and output moderation.
    ///
    /// Between 0 and 6, 0 being most strict, 6 being least strict.
    /// Default 2
    public let safetyTolerance: Int?

    /// Random seed. Set for reproducible generation
    public let seed: Int?
        
    /// Generate less processed, more natural-looking images
    /// default: false
    public let raw: Bool?

    private enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case outputFormat = "output_format"        
        case prompt
        case safetyTolerance = "safety_tolerance"
        case seed
        case raw
    }

    // This memberwise initializer is autogenerated.
    // To regenerate, use `cmd-shift-a` > Generate Memberwise Initializer
    // To format, place the cursor in the initializer's parameter list and use `ctrl-m`
    public init(
        prompt: String,
        aspectRatio: String? = nil,
        height: Int? = nil,
        outputFormat: OutputFormat? = nil,
        safetyTolerance: Int? = nil,
        seed: Int? = nil,
        raw: Bool? = nil
    ) {
        self.prompt = prompt
        self.aspectRatio = aspectRatio
        self.outputFormat = outputFormat
        self.safetyTolerance = safetyTolerance
        self.seed = seed
        self.raw = raw
    }
}

// MARK: - InputSchema.OutputFormat
extension ReplicateFluxProUltraInputSchema_v1_1 {
    public enum OutputFormat: String, Encodable {
        case jpg
        case png
    }
}