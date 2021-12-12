module Generators.``FsCheck Generator Tests``

open Types
open Common

// Trigraph Sized String
[<ClassificationProperty>]
let ``Generator creates valid trigraph sized strings`` (str: TrigraphSizedString) =
    TrigraphSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid trigraph sized strings`` (str: TrigraphSizedString) =
    TrigraphSizedString.shrink str |> Seq.forall TrigraphSizedString.valid

// Non-Trigraph Sized String
[<ClassificationProperty>]
let ``Generator creates valid non trigraph sized strings`` (str: NonTrigraphSizedString) =
    NonTrigraphSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid non trigraph sized strings`` (str: NonTrigraphSizedString) =
    NonTrigraphSizedString.shrink str |> Seq.forall NonTrigraphSizedString.valid

// Tetragraph Sized String
[<ClassificationProperty>]
let ``Generator creates valid tetragraph sized strings`` (str: TetragraphSizedString) =
    TetragraphSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid tetragraph sized strings`` (str: TetragraphSizedString) =
    TetragraphSizedString.shrink str |> Seq.forall TetragraphSizedString.valid

// Non-Tetragraph Sized String
[<ClassificationProperty>]
let ``Generator creates valid non tetragraph sized strings`` (str: NonTetragraphSizedString) =
    NonTetragraphSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid non tetragraph sized strings`` (str: NonTetragraphSizedString) =
    NonTetragraphSizedString.shrink str |> Seq.forall NonTetragraphSizedString.valid

// Country Code Sized String
[<ClassificationProperty>]
let ``Generator creates valid country code sized strings`` (str: CountryCodeSizedString) =
    CountryCodeSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid country code sized strings`` (str: CountryCodeSizedString) =
    CountryCodeSizedString.shrink str |> Seq.forall CountryCodeSizedString.valid

// Non-Country Code Sized String
[<ClassificationProperty>]
let ``Generator creates valid non country code sized strings`` (str: NonCountryCodeSizedString) =
    NonCountryCodeSizedString.valid str

[<ClassificationProperty>]
let ``Shrinker creates valid non country code sized strings`` (str: NonCountryCodeSizedString) =
    NonCountryCodeSizedString.shrink str |> Seq.forall NonCountryCodeSizedString.valid

// Country Code
[<ClassificationProperty>]
let ``Generator creates valid country codes`` (countryCode: CountryCode) =
    CountryCode.valid countryCode

[<ClassificationProperty>]
let ``Shrinker creates valid country codes`` (countryCode: CountryCode) =
    CountryCode.shrink countryCode |> Seq.forall CountryCode.valid

// Unclassified Marking
[<ClassificationProperty>]
let ``Generator creates valid unclassified classification`` (classification: UnclassifiedMarking) =
    UnclassifiedMarking.valid classification

[<ClassificationProperty>]
let ``Shrinker creates valid unclassified classification`` (classification: UnclassifiedMarking) =
    UnclassifiedMarking.shrink classification |> Seq.forall UnclassifiedMarking.valid

// Classified Marking
[<ClassificationProperty>]
let ``Generator creates valid classified classification`` (classification: ClassifiedMarking) =
    ClassifiedMarking.valid classification

[<ClassificationProperty>]
let ``Shrinker creates valid classified classification`` (classification: ClassifiedMarking) =
    ClassifiedMarking.shrink classification |> Seq.forall ClassifiedMarking.valid

// Foreign Classification
[<ClassificationProperty>]
let ``Generator creates valid foreign classifications`` (marking: ForeignClassificationUSMarking) =
    ForeignClassificationUSMarking.valid marking

[<ClassificationProperty>]
let ``Shrinker creates valid foreign classification`` (marking: ForeignClassificationUSMarking) =
    ForeignClassificationUSMarking.shrink marking |> Seq.forall ForeignClassificationUSMarking.valid

// Nato Classification
[<ClassificationProperty>]
let ``Generator creates valid nato classifications`` (marking: NatoClassificationMarking) =
    NatoClassificationMarking.valid marking

[<ClassificationProperty>]
let ``Shrinker creates valid nato classifications`` (marking: NatoClassificationMarking) =
    NatoClassificationMarking.shrink marking |> Seq.forall NatoClassificationMarking.valid

// Non FGI Original Classification
[<ClassificationProperty>]
let ``Generator creates valid non FGI original classifications`` (marking: NonFGIOriginalClassification) =
    NonFGIOriginalClassification.valid marking

[<ClassificationProperty>]
let ``Shrinker creates valid non FGI original classifications`` (marking: NonFGIOriginalClassification) =
    NonFGIOriginalClassification.shrink marking |> Seq.forall NonFGIOriginalClassification.valid

// Banner Line
let ``Generator creates valid BannerLines`` (marking: BannerLine) =
    BannerLine.valid marking

[<ClassificationProperty>]
let ``Shrinker creates valid BannerLines`` (marking: BannerLine) =
    BannerLine.shrink marking |> Seq.forall BannerLine.valid