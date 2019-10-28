namespace ClassificationMarking.Types

    module Trigraph =
        type T = Trigraph of string
        let create (s:string) =
            if s <> null && s.Length <= 3
            then Some (Trigraph s)
            else None
        let apply f (Trigraph s) = f s
        let value s = apply id s
        
    module Tetragraph =
        type T = Tetragraph of string
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
        
    type CountryCode = CountryCode of Trigraph.T
    
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
        
    type Unclassified =
        | Unclassified
        | FOUO
    
    type Classification =
        | Unclassified of Unclassified
        | Classified of Classified