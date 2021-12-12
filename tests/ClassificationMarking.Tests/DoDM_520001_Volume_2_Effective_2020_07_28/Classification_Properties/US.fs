module DoDM_520001_Volume_2_Effective_2020_07_28.Classification_Properties.``US``

open FsCheck
open FsCheck.Xunit
open Common
open Types

let usClassificationGenerator =
    Arb.generate<USClassification>
    |> Gen.map US
    |> Gen.map Classified
    
type USClassificationGenerator =
    inherit ClassificationGenerators

    static member Classification () =
        {new Arbitrary<Classification>() with
            override x.Generator = usClassificationGenerator
        }

type USClassificationPropertyAttribute() =
    inherit PropertyAttribute(Arbitrary = [| typeof<USClassificationGenerator> |])

[<USClassificationProperty>]
let ``Enclosure 2 (1.c.4/8.a.2) - Classification Authority Block date format will be YYYYMMDD`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (4.a) - Technical data will be marked`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (5.f.1) - Banner line classification level is separated from any control markings by double forward slashes (//)`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (5.f.2) - Banner line control markings are separated by a single forward slash (/) when multiple control markings are used`` () =
    false

[<USClassificationProperty>]
let ``U.S classifications will use the appropriate abbreviation in a portion mark - Enclosure 3 (6.c)`` (classification: Classification) =
    let actual =
        (portionMark classification).ToUpper()
        |> trimParenthesis
    
    let expected =
        match classification with
        | Classified (US USClassification.TopSecret) -> "TS"
        | Classified (US USClassification.Secret) -> "S"
        | Classified (US USClassification.Confidential) -> "C"
        | _ -> "Unexpected"
    
    actual.StartsWith expected

[<USClassificationProperty>]
let ``Enclosure 3 (6.d) - Portion mark classification level is separated from any control markings by double forward slashes (//)`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (6.d) - Portion mark control markings are separated by a single forward slash (/) when multiple control markings are used`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (6.d) - Portion mark control markings with sub-controls will will be separated by a hyphen (-)`` () =
    false



[<USClassificationProperty>]
let ``Enclosure 3 (8.a.3) - Classification Authority Block will have "Declassify On" date when not containing RD or FRD`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.a.3) - Classification Authority Block will not have "Declassify On" date when containing RD or FRD`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.a.3) - Classification Authority Block "Declassify On" will display message when containing RD or FRD and is NSI`` () =
    let message1 = "Not Applicable (or N/A) to RD/FRD portions"
    let message2 = "See source list for NSI portions."
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.a.4) - Classification Authority Block may include "Downgrade instructions" when not containing FGI, RD, or FRD`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.a.4) - Classification Authority Block will not include "Downgrade instructions" when containing FGI, RD, or FRD`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.b.1.c) - Classification Authority Block "Downgrade instructions" will be at a lower level than the current classification`` (classification: USClassification) =
    // i.e. A classification of SECRET can't have a downgrade instruction to SECRET
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.b.3) - Classification Authority Block aggregating original and derivative classifications results in derivative overall classification`` () =
    // Classified by is the OCA
    // Derived from is "Multiple Sources"
    // Maintain list of sources
    // One of the sources should be "Originally Classified Information" with a full classification authority block
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.b.5.a.1-4) - Declassification instruction date is 25 years or less from the original classification date with no exemptions`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.b.5.a.7) - Declassification instruction date is between 25 years and 50 years from the original classification date with 25X exemption`` () =
    false

[<USClassificationProperty>]
let ``Enclosure 3 (8.c.2.a) - Derivative Classification Authority Block Derived From line will contain "Multiple Sources" when multiple source documents exist`` () =
    false

[<USClassificationProperty>]
let ``U.S. classifications are not preceded by the double slash (//) in the banner line - Enclosure 4 (3.b)`` (classification: Classification) =
    let output =
        BannerLine.create [ classification ]
        |> TestHelpers.bannerLineStr
    
    not <| output.StartsWith "//"
    
[<USClassificationProperty>]
let ``U.S. classifications are not abbreviated in the banner line - Enclosure 4 (3.b)`` (classification: Classification) =
    let output =
        BannerLine.create [ classification ]
        |> TestHelpers.bannerLineStr
        |> fun str -> str.ToUpper()
    
    let expected =
        match classification with
        | Classified (US USClassification.TopSecret) -> "TOP SECRET"
        | Classified (US USClassification.Secret) -> "SECRET"
        | Classified (US USClassification.Confidential) -> "CONFIDENTIAL"
        | _ -> "Unexpected"
    
    output.StartsWith expected

// Declassify On: 20140803
// Declassify On: Completion of tests
// Declassify On: 25X3, 20200515
// Declassify On: 25X7, Hell freezes over
// = Declassify On: 25X3, 20200515 or 25X7, Hell freezes over, or Completion of tests, whichever is later