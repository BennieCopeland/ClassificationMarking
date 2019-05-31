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
    type Designator =
        | TopSecret
        | Secret
        | Confidential
        
    type USClassification = USClassification of Designator
    type ForeignClassification = ForeignClassification of string
    type JointClassification = JointClassification of string 
        
    
    
    type Classified =
        | USClassification
        | ForeignClassification
        | JointClassification
        
    type Classification =
        | Unclassified
        | Classified of Classified
        
    
        
    type ControlMarking = ControlMarking of string
    type ClassificationAuthorityBlock =
        | OriginalClassification of string
        | DerivativeClassification of string
        
    type BannerLine = BannerLine of string
    type PortionMark = PortionMark of string
    
    let CreateBannerLine s =
        // Review Enclosure 3 section 5
        "value"
    
    let CreatePortionMark s =
        // Review Enclosure 3 section 6
        "value"