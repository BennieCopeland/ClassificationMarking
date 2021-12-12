module ClassificationMarking.Types

type Trigraph = private Trigraph of string

module Trigraph =
    let create (s:string) =
        if s <> null && s.Length <= 3
        then Some (Trigraph s)
        else None
    let apply f (Trigraph s) = f s
    let value s = apply id s

type Tetragraph = private Tetragraph of string        

module Tetragraph =
    let create (s:string) =
        if s <> null && s.Length <= 4
        then Some (Tetragraph s)
        else None
    let apply f (Tetragraph s) = f s
    let value s = apply id s

type USDesignator =
    | TopSecret
    | Secret
    | Confidential
    
type ForeignDesignator =
    | TopSecret
    | Secret
    | Confidential
    | Restricted
    | Unclassified
    
type CountryCode = CountryCode of Trigraph

type SubCompartment = SubCompartment of string

type Compartment = {
    Name: string
    SubCompartments: SubCompartment list
}

type HCS = HCS of Compartment list
type SI = SI of Compartment list
type TK = TK of Compartment list

type Unpublished = {
    Name: string
    Compartments: Compartment list
}

type SCIControlSystems = {
    HCS: HCS option
    SI: SI option
    TK: TK option
    Unpublished: Unpublished list
}

type USClassification = {
    Designator: USDesignator
    SCI: SCIControlSystems option
    SAP: string option
    AEA: string option
    FGI: string option
    Dissemination: string option
    OtherDissemination: string option        
}

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


type ForeignClassification = {
    Designator: ForeignDesignator
    Country: CountryCode
}



type JointClassification = {
    Owners: CountryCode list
}

type Classified =
    | US of USClassification
    | Foreign of ForeignClassification
    | Nato of NatoClassification
    | Joint of JointClassification

type OrganizationalIndex = OrganizationalIndex of string

type CUIVariant =
    | Basic
    | Special

type CUICategory = private {
    Marking : string
    Variant : CUIVariant
}

type LimitedDisseminationControl =
    | NOFORN
    | ``FED ONLY``
    | FEDCON
    | NOCON
    | ``DL ONLY``
    | ``REL TO`` of Trigraph list
    | ``DISPLAY ONLY`` of Trigraph list
    | ``Attorney-Client``
    | ``Attorney-WP``

type CUIDesignation = {
    ControlledBy : string
    PointOfContact : string
}

// CUI Basic may be displayed in the banner line where authorized for use by the agency head

type CategoryCollection = CUICategory * CUICategory list

type ControlledUnclassifiedInformation = {
    Categories : CategoryCollection
    Dissemination : LimitedDisseminationControl list
    Designator : CUIDesignation
}

type Unclassified =
    | Uncontrolled
    | Controlled of ControlledUnclassifiedInformation

type Classification =
    | Unclassified of Unclassified
    | Classified of Classified

// Functions

module CUICategory =
    let isSpecial category =
        match category.Variant with
        | Special -> Some category
        | Basic -> None
    
    let (|IsSpecial|_|) = isSpecial
    
    let isBasic category =
        match category.Variant with
        | Special -> None
        | Basic -> Some category
    
    let (|IsBasic|_|) = isBasic
    
    let sort categories =
        let special =
            categories
            |> List.choose isSpecial
            |> List.sortBy (fun c -> c.Marking)
        
        let basic =
            categories
            |> List.choose isBasic
            |> List.sortBy (fun c -> c.Marking)
        
        special @ basic
    
    let markingStr category =
        match category.Variant with
        | Basic -> category.Marking
        | Special -> $"SP-{category.Marking}"