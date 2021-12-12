module DoDM_520001_Volume_2_Effective_2020_07_28.Classification_Properties.``Joint``
    
open FsCheck
open FsCheck.Xunit
open Common
open Types

type JointClassificationGenerator =
    inherit ClassificationGenerators
    
    static member Classification () =
        {new Arbitrary<Classification>() with
            override x.Generator =
                Arb.generate<JointClassification>
                |> Gen.map Joint
                |> Gen.map Classified}

type JointClassificationPropertyAttribute () =
    inherit PropertyAttribute(Arbitrary = [| typeof<JointClassificationGenerator> |])

[<JointClassificationProperty>]
let ``Joint classifications begin with a double forward slash "//" followed by the word JOINT in the banner line - Enclosure 4 (5.c)`` (classification: Classification) =
    let output =
        BannerLine.create [ classification ]
        |> TestHelpers.bannerLineStr
    
    output.StartsWith "//JOINT"

[<JointClassificationProperty>]
let ``Joint classifications begin with a double forward slash "//" followed by the word JOINT in the portion mark - Enclosure 4 (5.c)`` (classification: Classification) =
    let actual =
        portionMark classification
        |> trimParenthesis
    
    actual.StartsWith "//JOINT"