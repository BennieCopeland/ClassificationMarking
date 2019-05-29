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
        
    type Classification = Classification of string
    type ControlMarking = ControlMarking of string
    type ClassificationAuthorityBlock =
        | OriginalClassification of string
        | DerivativeClassification of string
    
    let BannerLine s =
        // Review Enclosure 3 section 5
        "value"
    
    let PortionMark s =
        // Review Enclosure 3 section 6
        "value"