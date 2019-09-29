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
    
    
    type USDesignator =
        | TopSecret
        | Secret
        | Confidential
        
    
    
    type CountryCode = CountryCode of string
    
    type ForeignDesignator =
        | TopSecret
        | Secret
        | Confidential
        | Restricted
        | Unclassified
    
    type JointClassification = JointClassification of string 
        
    type USClassification = {
        USDesignator: USDesignator
    }
    
    type ClassifiedDesignator =
        | USClassification of USDesignator
        | ForeignClassification of (CountryCode * ForeignDesignator)
        | JointClassification
        
    type Classification =
        | Unclassified
        | Classified of ClassifiedDesignator
        
    
    
    type SCIControlSystem =
        | HCS
        | SI
        | TK
        | Unpublished of string
    
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
        Classification : Classification
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
    
    let usClassificationAsBannerString c =
        match c with
        | USDesignator.TopSecret -> "TOP SECRET"
        | USDesignator.Secret -> "SECRET"
        | USDesignator.Confidential -> "CONFIDENTIAL"
        
    let classifiedDesignatorToBannerString c =
        match c with
        | USClassification us -> usClassificationAsBannerString us
        | ForeignClassification (countryCode, designator) -> "FOREIGN"
        | JointClassification -> "JOINT"
        
    let classificationToBannerString c =
        match c with
        | Unclassified -> "UNCLASSIFIED"
        | Classified classified -> classifiedDesignatorToBannerString classified
        
    let usClassificationAsPortionString c =
        match c with
        | USDesignator.TopSecret -> "TS"
        | USDesignator.Secret -> "S"
        | USDesignator.Confidential -> "C"
    
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
        sprintf "%s" (classificationToBannerString s)
    
    let CreatePortionMark s =
        // Review Enclosure 3 section 6
        "({classification}//{control markings})"
        
    let CreateSpecialNoticies =
        "value"
        
    let CreateClassificationAuthorityBlock =
        // if (RD || FRD) && NSI, "Declassify On:" = "Not Applicable (or N/A) to RD/FRD portions. See source list for NSI portions."
        // if (RD || FRD) && !NSI, Do not mark with declassification instructions
        "value"
        
    