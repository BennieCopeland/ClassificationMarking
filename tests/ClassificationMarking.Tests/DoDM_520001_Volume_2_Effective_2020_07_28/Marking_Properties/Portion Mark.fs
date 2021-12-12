module DoDM_520001_Volume_2_Effective_2020_07_28.Marking_Properties.``Portion Mark``

open Xunit
open Common
open Types

//[<ClassificationProperty>]
//let ``Blah`` () =
//    let bannerLine = BannerLine.create [ classification ]
//    let output = PortionMark.create bannerLine classification

[<ClassificationProperty>]
let ``All portion markings use capital letters - Enclosure 3 (6.e)`` (classification: Classification) =
    let actual = portionMark classification
    
    actual === actual.ToUpper()

[<ClassificationProperty>]
let ``All portion markings are enclosed in parentheses - Enclosure 3 (6.e)`` (classification: Classification) =
    let actual = portionMark classification
    
    actual.StartsWith "(" && actual.EndsWith ")"

[<ClassificationProperty>]
let ``FGI portion markings match the required portion mark format - Enclosure 4 (4.a.1)`` (ForeignClassificationUSMarking classification) =
    let output =
        BannerLine.create [ classification ]
        |> TestHelpers.portionMarkStr classification

    output .* TestHelpers.fgiPortionFormat

[<ClassificationProperty>]
let ``FGI portion markings contain the correct foreign designator abbreviation  - Enclosure 4 (4.a.2)`` (countryCode: CountryCode) (designator: ForeignDesignator) =
    let classification =
        {
            Country = countryCode
            Designator = designator
        }
        |> USMarking
        |> Foreign
        |> Classified
    
    let portionMarkStr =
        BannerLine.create [ classification ]
        |> TestHelpers.portionMarkStr classification
    
    let matchedDesignator =
        match portionMarkStr with
        | Regex TestHelpers.fgiPortionFormat [_; _; designator] -> designator
        | _ -> "Portion mark format invalid"
    
    let expectedDesignator = ForeignDesignator.abbreviation designator
    matchedDesignator === expectedDesignator

[<ClassificationProperty>]
let ``FGI portion markings contain the correct country code - Enclosure 4 (4.a.2)`` (countryCode: CountryCode) (designator: ForeignDesignator) =
    let classification =
        {
            Country = countryCode
            Designator = designator
        }
        |> USMarking
        |> Foreign
        |> Classified
    
    let portionMarkStr =
        BannerLine.create [ classification ]
        |> TestHelpers.portionMarkStr classification
    
    let matchedCountryCode =
        match portionMarkStr with
        | Regex TestHelpers.fgiPortionFormat [_; countryCode; _] -> countryCode
        | _ -> "Banner line format invalid"
    
    let expectedCountryCode = CountryCode.asString countryCode
    matchedCountryCode === expectedCountryCode

[<ClassificationProperty>]
let ``All classification markings of NATO match the required portion mark format - Enclosure 4 (f.b) Figure 28`` (NatoClassificationMarking classification) =
    let output = portionMark classification
    
    output .* TestHelpers.natoPortionFormat