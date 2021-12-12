module ClassificationMarking.Operations
open ClassificationMarking.Types

let unclassified = Unclassified Uncontrolled


//
//
//
//
//
//
//let getDefault () = Unclassified Uncontrolled
//
//let classify classification =
//    ()
//
//let getBannerLine (classification: Classification) =
//    match classification with
//    | Unclassified c -> ""
//    | Classified c -> ""
//
//module Designation =
//    let private concat sep (strings : seq<string>) =  
//        System.String.Join(sep, strings)
//    
//    let controlledBy (classification: ControlledUnclassifiedInformation) =
//        $"Controlled by: {classification.Designator.ControlledBy}"
//    
//    let categories (classification: ControlledUnclassifiedInformation) =
//        let categories =
//            classification.Categories
//            |> CUICategory.sort
//            |> List.map CUICategory.markingStr
//            |> concat ","
//            
//        $"CUI Categories: {categories}"
//    
//    let distribution (classification: ControlledUnclassifiedInformation) =
//        let toString control =
//            match control with
//            | NOFORN -> "NOFORN"
//            | ``FED ONLY`` -> "FED ONLY"
//            | FEDCON -> "FEDCON"
//            | NOCON -> "NOCON"
//            | ``DL ONLY`` -> "DL ONLY"
//            | ``REL TO`` trigraphs ->
//                let countries =
//                    trigraphs
//                    |> List.map Trigraph.value
//                    |> List.sort
//                    |> concat ","
//                    
//                $"REL TO: {countries}"
//            | ``DISPLAY ONLY`` trigraphs ->
//                let countries =
//                    trigraphs
//                    |> List.map Trigraph.value
//                    |> List.sort
//                    |> concat ","
//                    
//                $"DISPLAY ONLY: {countries}"
//            | ``Attorney-Client`` -> "Attorney-Client"
//            | ``Attorney-WP`` -> "Attorney-WP"
//        
//        let dissem =
//            match classification.Dissemination with
//            | [] -> "N/A"
//            | _ ->
//                classification.Dissemination
//                |> List.map toString
//                |> List.sort
//                |> concat ","
//        
//        $"Distribution/Dissemination Control: {dissem}"
//    
//    let pointOfContact (classification: ControlledUnclassifiedInformation) =
//        $"POC: {classification.Designator.PointOfContact}"