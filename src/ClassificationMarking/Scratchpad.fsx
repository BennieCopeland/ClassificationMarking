
// Temporary placeholder

module Classification =
    open System

    type todo = unit
    let todo () = ()

    type Classification = todo

    let CAB_DATE_FORMAT = "YYYYMMDD"
    
    type DateOrEvent =
        | Date of DateTime
        | Event of string

    module DateOrEvent =
        let toString doe =
            match doe with
            | Date date -> date.ToString("YYYYMMDD")
            | Event e -> e

    type ExemptionCategory =
        | X1
        | X2
        | X3
        | X4
        | X5
        | X6
        | X7
        | X8
        | X9
        
    module ExemptionCategory =
        let toString category =
            match category with
            | X1 -> "X1"
            | X2 -> "X2"
            | X3 -> "X3"
            | X4 -> "X4"
            | X5 -> "X5"
            | X6 -> "X6"
            | X7 -> "X7"
            | X8 -> "X8"
            | X9 -> "X9"

    // DoD 5200.01 Volume 1
    type ISCAPExemption =
        | TwentyFive of ExemptionCategory * DateOrEvent
        | FiftyX1HUM
        | FiftyX2WMD
        | Fifty of ExemptionCategory * DateOrEvent
        | SeventyFive of ExemptionCategory * DateOrEvent
        
    type OCADeclassificationInstruction =
        | Date of DateTime
        | Event of string
        | TwentyFive of ExemptionCategory * DateOrEvent
        | FiftyX1HUM
        | FiftyX2WMD

    module OCADeclassificationInstruction =
        let toString exemption =
            match exemption with
            | Date date                   -> date.ToString(CAB_DATE_FORMAT)
            | Event e                     -> e
            | TwentyFive (category, doe)  -> sprintf "25%s, %s" (ExemptionCategory.toString category) (DateOrEvent.toString doe)
            | FiftyX1HUM                  -> "50X1-HUM"
            | FiftyX2WMD                  -> "50X2-WMD"
//    | Fifty (category, doe) ->
//        print "50" category doe
//    | SeventyFive (category, doe) ->
//        print "75" category doe

    type ClassificationCategory =
        | A
        | B
        | C
        | D
        | E
        | F
        | G
        | H

    module ClassificationCategory =
        let toString category =
            match category with
            | A -> "1.4(a)"
            | B -> "1.4(b)"
            | C -> "1.4(c)"
            | D -> "1.4(d)"
            | E -> "1.4(e)"
            | F -> "1.4(f)"
            | G -> "1.4(g)"
            | H -> "1.4(h)"
        
        let fromString str =
            match str with
            | "A" | "a" | "1.4(a)" -> Some A 
            | "B" | "b" | "1.4(b)" -> Some B 
            | "C" | "c" | "1.4(c)" -> Some C 
            | "D" | "d" | "1.4(d)" -> Some D 
            | "E" | "e" | "1.4(e)" -> Some E 
            | "F" | "f" | "1.4(f)" -> Some F 
            | "G" | "g" | "1.4(g)" -> Some G 
            | "H" | "h" | "1.4(h)" -> Some H
            | _ -> None

    type ClassificationReason =
        private ClassificationReason of ClassificationCategory * ClassificationCategory list

    module ClassificationReason =
        let create reason additionalReasons : ClassificationReason =
            reason :: additionalReasons
            |> List.distinct
            |> fun list -> ClassificationReason (list.Head, list.Tail)

        let toString (ClassificationReason (head, tail)) =
            head :: tail
            |> List.map ClassificationCategory.toString
            |> List.sort
            |> fun list -> String.Join(", ", list)
        
        let toList (ClassificationReason (head, tail)) = head :: tail
        
        let add (ClassificationReason (head, tail)) x =
            create head (tail @ toList x)
    
    type ClassifierDetails = {
        Name : string
        Position : string
        Component : string
        OfficeOfOrigin : string
    }
    
    type OriginalClassifier = OriginalClassifier of ClassifierDetails
    type DerivativeClassifier = DerivativeClassifier of ClassifierDetails
    
    type Classifier =
        | Original of OriginalClassifier
        | Derivative of DerivativeClassifier
    
    type DowngradeTo = DowngradeTo of (Classification * DateOrEvent)
    
//    module DowngradeTo =
//        let add (left: DowngradeTo option) (right: DowngradeTo option) =
//            match left, right with
//            | Some (DowngradeTo (lclassification,  ldoe)), Some (DowngradeTo (rclassification, rdoe)) ->
//                // Grab most restrictive classification
//                // Grab most restrictive date
//                
//                
//                
//            | _, _ -> None // Most restrictive is not to downgrade if a portion is not marked as downgradeable
//        
//        let reduce xs =
//            match xs with
//            | head :: tail ->
//                let blah =
//                    List.fold (fun acc (DowngradeTo (classification, doe)) ->
//                        
//                        
//                        acc
//                        ) (DateTime.MinValue, Set.empty)
//                
//            | [] -> None
    
    type OriginalClassification = {
        OriginalClassifier: OriginalClassifier
        Reason: ClassificationReason
        DowngradeTo: DowngradeTo option
        DeclassifyOn : OCADeclassificationInstruction
    }
    
    type Source = {
        Title : string
        Component : string
        Office : string option
        DocumentType : string option
        Subject : string option
        Date : DateTime option
//        DowngradeTo: (Classification * DateOrEvent) option
//        DeclassifyOn : todo
    }
    
    type DerivedFrom = private DerivedFrom of Source * Source list
    
    module DerivedFrom =
        let toString (DerivedFrom (head, tail)) =
            match head, tail with
            | _, [] -> head.Title
            | _, _ :: _ -> "Multiple Sources"
        
        let toList (DerivedFrom (head, tail)) = head :: tail

    type DerivedClassification = {
        DerivativeClassifier : Classifier
        DerivedFrom : DerivedFrom
        // carried forward from source documents, security classification guide instructions, or other guidance
        DowngradeTo: DowngradeTo option
        // carried forward from source documents, security classification guide instructions, or other guidance
        DeclassifyOn : todo
    }
    
//    module DerivedClassification =
//        let create classifier derivedFrom =
//            {
//                DerivativeClassifier = classifier
//                DerivedFrom = derivedFrom
//            }
            
    
    type ClassificationAuthority =
        | Original of OriginalClassification
        | Derived of DerivedClassification
    
    let caReduce head tail =
        List.fold (fun state ca -> state) head tail
    
//    let caJoin (classifier: Classifier) fst snd =
//        match fst, snd with
//        | Original l, Original r when l.OriginalClassifier = r.OriginalClassifier ->
//            {
//                OriginalClassifier = l.OriginalClassifier
//                Reason = ClassificationReason.add l.Reason r.Reason
//                DowngradeTo
//                DeclassifyOn
//            }
//        | Original l, Original r -> ()
//        | Derived l, Original r -> ()
//        | Derived l, Original r -> ()
//        | Original l, Derived r -> ()
//        | Original l, Derived r -> ()
//        | Derived l, Derived r -> ()
//        | Derived l, Derived r -> ()
        
    
//    let reduce a =
//        match a with
//        | [b] -> b
//        | _ -> 

    let bannerLine classifications = todo

    let portionMark classifications = todo

    let classificationAuthorityBlock = todo
    
    let createUsDocument portionMarks = todo
    
    let createJointDocument portionMarks = todo
    
    let createForeignDocument portionMarks = todo
    
    let create owners =
        match owners with
        | 

open Classification

let classifications = [
    Original {
        OriginalClassifier = OriginalClassifier {
            Name = "Copeland, Bennie"
            Position = "Software Engineer"
            Component = "USEUCOM"
            OfficeOfOrigin = "ECJ6"
        }
        Reason = ClassificationReason.create A []
        DowngradeTo = None
        DeclassifyOn = Date (System.DateTime.UtcNow)
    }
    Original {
        OriginalClassifier = OriginalClassifier {
            Name = "Copeland, Bennie"
            Position = "Software Engineer"
            Component = "USEUCOM"
            OfficeOfOrigin = "ECJ6"
        }
        Reason = ClassificationReason.create A [D; C]
        DowngradeTo = None
        DeclassifyOn = Event "Hell freezes over"
    }
]

