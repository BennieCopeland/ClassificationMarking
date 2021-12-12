module DoDM_520001_Volume_2_Effective_2020_07_28.Marking_Properties.``Banner Line``

open Xunit
open FsCheck
open Common
open Types

[<ClassificationProperty>]
let ``All banner line markings use capital letters - Enclosure 3 (5.a.4)`` (bannerLine: BannerLine) =
    let actual = bannerLine.asString
    
    actual === actual.ToUpper()

[<ClassificationProperty>]
let ``All banner line markings for documents that are unclassified and bear no control markings will be marked "UNCLASSIFIED" - Enclosure 3 (5.e)`` (classifications: UnclassifiedMarking list) =
    let output =
        classifications
        |> List.map UnclassifiedMarking.op_Explicit
        |> BannerLine.create
        |> TestHelpers.bannerLineStr
    
    output === "UNCLASSIFIED"

[<ClassificationProperty>]
let ``TEMPORARY TEST NAME`` (classifications: UnclassifiedMarking list) (NonFGIOriginalClassification classifiedMarking) =
    result {
        let! output =
            classifications
            |> List.map UnclassifiedMarking.op_Explicit
            |> fun tail -> classifiedMarking :: tail
            |> BannerLine.create
        
        let! expected = BannerLine.create [ classifiedMarking ]
        
        return output === expected
    } |> function
        | Ok prop -> prop
        | Error (CreateBannerLineError.AmbiguousMerger (c, m)) -> false |@ $"Error merging {c} and {m}"
        | Error _ -> false |@ "Error"

[<ClassificationProperty>]
let ``A banner line created from an empty list will be marked "UNCLASSIFIED"`` () =
    BannerLine.create [ Unclassified ] = BannerLine.create []

[<ClassificationProperty>]
let ``A banner line can not be created from a list containing Originally Marked FGI`` (classifications: UnclassifiedMarking list) =
    let omfgi =
        OriginalMarking "Diffusion Restreinte"
        |> Foreign
        |> Classified
    
    let output =
        classifications
        |> List.map UnclassifiedMarking.op_Explicit
        |> fun tail -> omfgi :: tail
        |> BannerLine.create
    
    match output with
    | Error CreateBannerLineError.ForeignMarkingPresent -> true |@ "Foreign Marking Present"
    | _ -> false |@ "Expected Foreign Marking Present error"


[<ClassificationProperty>]
let ``US Marked FGI banner lines match the required banner line format - Enclosure 4 (4.a.1)`` (ForeignClassificationUSMarking classification) =
    let output = BannerLine.create [ classification ] |> TestHelpers.bannerLineStr

    output .* TestHelpers.fgiBannerFormat

[<ClassificationProperty>]
let ``US Marked FGI banner lines contain the correct foreign designator full name - Enclosure 4 (4.a.2)`` (countryCode: CountryCode) (designator: ForeignDesignator) =
    let classification =
        {
            Country = countryCode
            Designator = designator
        }
        |> USMarking
        |> Foreign
        |> Classified
    
    let bannerLineStr = BannerLine.create [ classification ] |> TestHelpers.bannerLineStr
    
    let matchedDesignator =
        match bannerLineStr with
        | Regex TestHelpers.fgiBannerFormat [_; _; designator] -> designator
        | _ -> "Banner line format invalid"
    
    let expectedDesignator = ForeignDesignator.fullName designator
    matchedDesignator === expectedDesignator

[<ClassificationProperty>]
let ``US Marked FGI banner lines contain the correct country code - Enclosure 4 (4.a.2)`` (countryCode: CountryCode) (designator: ForeignDesignator) =
    let classification =
        {
            Country = countryCode
            Designator = designator
        }
        |> USMarking
        |> Foreign
        |> Classified
    
    let bannerLineString = BannerLine.create [ classification ] |> TestHelpers.bannerLineStr
    
    let matchedCountryCode =
        match bannerLineString with
        | Regex TestHelpers.fgiBannerFormat [_; countryCode; _] -> countryCode
        | _ -> "Banner line format invalid"
    
    let expectedCountryCode = CountryCode.asString countryCode
    matchedCountryCode === expectedCountryCode

[<ClassificationProperty>]
let ``All classification markings of NATO match the required banner line format - Enclosure 4 (f.b) Figure 28`` (NatoClassificationMarking classification) =
    let output =
        BannerLine.create [ classification ]
        |> TestHelpers.bannerLineStr
    
    output .* TestHelpers.natoBannerFormat

[<ClassificationProperty>]
let ``Documents consisting entirely of NATO information shall have a banner line consisting only of NATO markings - Enclosure 4 (4.b.2)`` (classifications: NatoClassificationMarking list) =
    classifications.Length > 0 ==>
    let output =
        classifications
        |> List.map NatoClassificationMarking.op_Explicit
        |> BannerLine.create
    
    match output with
    | Ok bannerLine ->
        bannerLine.asString .* TestHelpers.natoBannerFormat
    | Error _ -> false |@ ""