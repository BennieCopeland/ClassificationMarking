namespace ClassificationMarking


module Say =
    let hello name =
        printfn "Hello %s" name

// trigraphs ISO 3166 reference N defined outside system
// tetragraphs defined outside system

// requirements
// overall classification
// indentification of the specific classified information in the document and its level of classification
// component, office of origin, date of origin
// basis for classification and OCA or derivative classifier
// declassification instructions
// identification of special access, dissemination control, and handling or safeguarding requirements

// banner line
// portion mark

    // double slashes separate
    type Trigraph = Trigraph of string
    type Tetragraph = Tetragraph of string
    
    
    
    
    
    
    type NATODesignator =
        | CosmicTopSecretBohemia
        | CosmicTopSecret
        | NatoSecret
        | NatoConfidential
        | NatoRestricted
        | NatoUnclassified
    
    type NATOClassification = {
        Designator: NATODesignator
    }
    
    
    
    
    

    

    

        
    
    
//    type SCIControlSystem =
//        | HCS
//        | SI
//        | TK
//        | Unpublished of string

    
    
    
    
    
    type SCI = SCI of string
    type SAP = SAP of string
    type AEA = AEA of string
    type FGI = FGI of string
        
    type DisseminationMarking =
        | NOFORN of string
    
    type ControlMarking =
        | SCI of SCI
        | SAP of SAP
        | AEA of AEA
        | FGI of FGI
        | Dissemination of DisseminationMarking
    
    type Marking = {
        Classification : string
        ControllerMarkings : ControlMarking list
    }    
        
    type BannerLine = BannerLine of string
    type PortionMark = PortionMark of string
    
    type Identifier =
        | PositionTitle of string
        | Personal of string
    
    type ClassifiyingOrganization = {
        DoDComponent: string
        OfficeOfOrigin: string
    }
    
    type Date = {
        Year: int
        Month: int
        Day: int
    }

    
    let DateToString d =
        sprintf "%04i%02i%02i" d.Year d.Month d.Day
    
    type ClassifiedBy = {
        Name : string
        Identifier: Identifier
        ClassifyingOrganization : ClassifiyingOrganization option
    }
    
    type OriginalClassification = {
        ClassifiedBy : ClassifiedBy
    }
    
    type ClassificationAuthorityBlock =
        | OriginalClassification of OriginalClassification
        | DerivativeClassification of string
    
    let CreateBannerLine s =
        // Review Enclosure 3 section 5
        ""
    
    let CreatePortionMark s =
        // Review Enclosure 3 section 6
        "({classification}//{control markings})"
        
    let CreateSpecialNoticies =
        "value"
        
    let CreateClassificationAuthorityBlock =
        // if (RD || FRD) && NSI, "Declassify On:" = "Not Applicable (or N/A) to RD/FRD portions. See source list for NSI portions."
        // if (RD || FRD) && !NSI, Do not mark with declassification instructions
        "value"
        
    type ClassificationDto = {
        Designator: string
        ControlMarkings: string list
        Owners: string list
        ReleasableTo: string list
        FgiCodes: string list
        DisplayOnlyCodes: string list
        ClassifiedOn: string
        ClassifiedBy: string
        ClassificationReasons: string list
        SciControlSystems: string list
        DerivedFrom: string
        DowngradeTo: string
        DowngradeOn: string
        DeclassifyOn: string
        AdditionalReason: string
        Banner: string
        Portion: string
    }
    