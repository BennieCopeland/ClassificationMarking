module Types

open System
open NodaTime

type Trigraph = private Trigraph of string

[<RequireQualifiedAccess>]
type TrigraphError =
    | NullString
    | InvalidLength

module Trigraph =
    let tryCreate (s:string) =
        match s with
        | null -> Error TrigraphError.NullString
        | s when s.Length = 3 -> Ok (Trigraph s)
        | _ -> Error TrigraphError.InvalidLength

    let asString (Trigraph s) = s

type Tetragraph = private Tetragraph of string

[<RequireQualifiedAccess>]
type TetragraphError =
    | NullString
    | InvalidLength

module Tetragraph =
    let tryCreate (s: string) =
        match s with
        | null -> Error TetragraphError.NullString
        | s when s.Length = 4 -> Ok (Tetragraph s)
        | _ -> Error TetragraphError.InvalidLength
    
    let asString (Tetragraph s) = s

type DeclassificationEvent = DeclassificationEvent of string
    
type ExemptionCategory = X1 | X2 | X3 | X4 | X5 | X6 | X7 | X8 | X9

//    type DateOrEvent =
//        | Date of LocalDate
//        | Event of DeclassificationEvent
//        | DateAndEvent of LocalDate * DeclassificationEvent
//        | Exemption of ExemptionCategory

type DateOrEvent =
    | Date of LocalDate
    | Event of DeclassificationEvent

type DeclassificationInstruction =
    | Date of LocalDate
    | Event of DeclassificationEvent
    | TwentyFive of ExemptionCategory * DateOrEvent
    | FiftyX1HUM
    | FiftyX2WMD
    | Fifty of ExemptionCategory * DateOrEvent
    | SeventyFive of ExemptionCategory * DateOrEvent
    
// Consider just making this a string
type Classifier = Classifier of string

type ClassificationCategory = A | B | C | D | E | F | G | H

let classificationCategory = function    
    | A -> "Military plans, weapons systems, or operations"
    | B -> "Foreign government information"
    | C -> "Intelligence activities (including covert action), intelligence sources or methods, or cryptology"
    | D -> "Foreign relations or foreign activities of the United States, including confidential sources"
    | E -> "Scientific, technological, or economic matters relating to the national security"
    | F -> "United States Government programs for safeguarding nuclear materials or facilities"
    | G -> "Vulnerabilities or capabilities of systems, installations, infrastructures, projects, plans, or protection services relating to the national security"
    | H -> "The development, production, or use of weapons of mass destruction"

type DowngradeInstruction =
    {
        Secret : DateOrEvent option
        Confidential : DateOrEvent option
    }

type SourceDocument =
    {
        ComponentOrAgency : string
        OfficeOfOrigin : string option
        DocumentType : string
        Subject : string
        Date : LocalDate
    }

//    type OriginalClassification =
//        {
//            ClassifiedBy: ClassifiedBy
//            Reason: ClassificationCategory
//            DowngradeTo: DowngradeInstruction
//            DeclassifyOn : DeclassificationInstruction
//        }
//    
//    type DerivedClassification =
//        {
//            ClassifiedBy : ClassifiedBy
//            DerivedFrom : SourceDocument * SourceDocument list
//            DowngradeTo: DowngradeInstruction
//            DeclassifyOn : DeclassificationInstruction
//        }
//        
//    type ClassificationAuthorityBlock =
//        | Original of OriginalClassification
//        | Derivative of DerivedClassification

type ClassificationAuthority =
    | Original of ClassificationCategory
    | Derived of SourceDocument * SourceDocument list

type SCIControlMarking =
    | HCS
    | SI
    | TK
    | Unpublished of string


type TopSecret =
    {
        SecretDowngradeOn : DateOrEvent option
        ConfidentialDowngradeOn : DateOrEvent option
        ClassifiedBy : Classifier
        Authority : ClassificationAuthority
        DeclassifyOn : DeclassificationInstruction
    }

type Secret =
    {
        ConfidentialDowngradeOn : DateOrEvent option
        ClassifiedBy : Classifier
        Authority : ClassificationAuthority
        DeclassifyOn : DeclassificationInstruction
    }

type Confidential =
    {
        ClassifiedBy : Classifier
        Authority : ClassificationAuthority
        DeclassifyOn : DeclassificationInstruction
    }

type USClassification =
    | TopSecret
    | Secret
    | Confidential
    
//    type USClassification =
//        {
//            Designator : USDesignator
//            ClassificationAuthorityBlock : ClassificationAuthorityBlock
//        }
//    
//    type JointClassification =
//        {
//            ClassificationAuthorityBlock : ClassificationAuthorityBlock
//        }

module USClassification =
    let priority classification =
        match classification with
        | TopSecret -> 3
        | Secret -> 2
        | Confidential -> 1
    
    let highestClassification c1 c2 =
        if priority c1 >= priority c2
        then c1
        else c2

type CountryCode = private CountryCode of string

type CountryCodeError =
    | InvalidLength
    | NullString

module CountryCode =
    let tryCreate (s: string) =
        match s with
        | null -> Error CountryCodeError.NullString
        | s when s.Length = 3 || s.Length = 4 -> Ok (CountryCode s)
        | _ -> Error CountryCodeError.InvalidLength
    
    let asString (CountryCode s) = s
    

type ForeignDesignator =
    | TopSecret
    | Secret
    | Confidential
    | Restricted
    | Unclassified of providedInConfidence:bool
    with
    static member fullName (designator : ForeignDesignator) =
        match designator with
        | TopSecret -> "TOP SECRET"
        | Secret -> "SECRET"
        | Confidential -> "CONFIDENTIAL"
        | Restricted -> "RESTRICTED"
        | Unclassified _ -> "UNCLASSIFIED"
    
    static member abbreviation (designator : ForeignDesignator) =
        match designator with
        | TopSecret -> "TS"
        | Secret -> "S"
        | Confidential -> "C"
        | Restricted -> "R"
        | Unclassified _ -> "U"

type USMarking =
    {
        Country : CountryCode
        Designator : ForeignDesignator
    }

type ForeignClassification =
    | OriginalMarking of string
    | USMarking of USMarking

type NatoClassification =
    | CosmicTopSecret
    | CosmicTopSecretBohemia
    | NatoSecret
    | NatoConfidential
    | NatoRestricted
    | NatoUnclassified
    | CosmicTopSecretAtomal
    | SecretAtomal
    | ConfidentialAtomal
    with
    
    static member fullName (classification: NatoClassification) =
        match classification with
        | CosmicTopSecret -> "COSMIC TOP SECRET"
        | CosmicTopSecretBohemia -> "COSMIC TOP SECRET BOHEMIA"
        | NatoSecret -> "NATO SECRET"
        | NatoConfidential -> "NATO CONFIDENTIAL"
        | NatoRestricted -> "NATO RESTRICTED"
        | NatoUnclassified -> "NATO UNCLASSIFIED"
        | CosmicTopSecretAtomal -> "COSMIC TOP SECRET ATOMAL"
        | SecretAtomal -> "SECRET ATOMAL"
        | ConfidentialAtomal -> "CONFIDENTIAL ATOMAL"
        
    static member abbreviation (classification: NatoClassification) =
        match classification with
        | CosmicTopSecret -> "CTS"
        | CosmicTopSecretBohemia -> "CTS-B"
        | NatoSecret -> "NS"
        | NatoConfidential -> "NC"
        | NatoRestricted -> "NR"
        | NatoUnclassified -> "NU"
        | CosmicTopSecretAtomal -> "CTS-A"
        | SecretAtomal -> "NS-A"
        | ConfidentialAtomal -> "NC-A"

type JointClassification =
    {
        Blah : string
    }

type Classified =
    | US of USClassification
    | Foreign of ForeignClassification
    | Nato of NatoClassification
    | Joint of JointClassification

type Classification =
    | Unclassified
    | Classified of Classified

type CreateBannerLineError =
    | AmbiguousMerger of Classification * Classification
    /// Error returned when all classifications use original foreign markings.
    | ForeignMarkingPresent

type BannerLine = private BannerLine of Classification

module BannerLine =
    let create classifications =
        let folder current merging =
            match current with
            | Ok current ->
                match current, merging with
                | _, Classified (Foreign (OriginalMarking _)) -> Error CreateBannerLineError.ForeignMarkingPresent
                | Unclassified, classified -> Ok classified
                | classified, Unclassified -> Ok classified
                | c, m -> Error (CreateBannerLineError.AmbiguousMerger (c, m)) 
            | Error error -> Error error
        
        classifications
        |> List.fold folder (Ok Unclassified)
        |> Result.map BannerLine
    
    let asString (BannerLine classification) =
        match classification with
        | Unclassified -> "UNCLASSIFIED"
        | Classified classified ->
            match classified with
            | US us ->
                match us with
                | USClassification.TopSecret -> "TOP SECRET"
                | USClassification.Secret -> "SECRET"
                | USClassification.Confidential -> "CONFIDENTIAL"
            | Foreign foreign ->
                match foreign with
                | OriginalMarking original -> ""
                | USMarking remarked ->
                    $"//{CountryCode.asString remarked.Country} {ForeignDesignator.fullName remarked.Designator}"
            | Nato nato -> $"//{NatoClassification.fullName nato}"
            | Joint joint -> "//JOINT"

type BannerLine
    with
    member this.asString = BannerLine.asString this

type PortionMark = PortionMark of string

module PortionMark =
    let create bannerLine classification =
        let pm =
            match classification with
            | Unclassified -> ""
            | Classified classified ->
                match classified with
                | US us ->
                    match us with
                    | USClassification.TopSecret -> "TS"
                    | USClassification.Secret -> "S"
                    | USClassification.Confidential -> "C"
                | Foreign foreign ->
                    match foreign with
                    | OriginalMarking original -> ""
                    | USMarking remarked -> $"//{CountryCode.asString remarked.Country} {ForeignDesignator.abbreviation remarked.Designator}"
                | Nato nato -> $"//{NatoClassification.abbreviation nato}"
                | Joint joint -> "//JOINT"
        
        PortionMark $"({pm})"
    
    let asString (PortionMark portionMark) = portionMark

type PortionMark
    with
    member this.asString = PortionMark.asString this

type DocumentMarkings =
    {
        TechnicalData : string option
    }

module DocumentMarkings =
    let create bannerLine =
        {
            TechnicalData = None
        }

//let bannerLine classification =
//    match classification with
//    | Unclassified -> ""
//    | Classified classified ->
//        match classified with
//        | US us ->
//            match us with
//            | USClassification.TopSecret -> "TOP SECRET"
//            | USClassification.Secret -> "SECRET"
//            | USClassification.Confidential -> "CONFIDENTIAL"
//        | Foreign foreign ->
//            match foreign with
//            | OriginalMarking original -> ""
//            | USMarking remarked ->
//                $"//{CountryCode.asString remarked.Country} {ForeignDesignator.fullName remarked.Designator}"
//        | Nato nato -> $"//{NatoClassification.fullName nato}"
//        | Joint joint -> "//JOINT"


// todo the portion mark output will be affected by the over all classification
// This is to allow a banner to be SECRET//FGI GBR//REL TO USA, AUS, CAN, GBR, NZL with a portion (S//REL) pg. 72
let portionMark classification =
    let pm =
        match classification with
        | Unclassified -> ""
        | Classified classified ->
            match classified with
            | US us ->
                match us with
                | USClassification.TopSecret -> "TS"
                | USClassification.Secret -> "S"
                | USClassification.Confidential -> "C"
            | Foreign foreign ->
                match foreign with
                | OriginalMarking original -> ""
                | USMarking remarked -> $"//{CountryCode.asString remarked.Country} {ForeignDesignator.abbreviation remarked.Designator}"
            | Nato nato -> $"//{NatoClassification.abbreviation nato}"
            | Joint joint -> "//JOINT"
    
    $"({pm})"



let secret classifier reason declassifyOn =
    {
        ConfidentialDowngradeOn = None
        ClassifiedBy = classifier
        Authority = reason
        DeclassifyOn = declassifyOn
    }
