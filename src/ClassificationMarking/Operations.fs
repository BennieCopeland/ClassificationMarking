module ClassificationMarking.Operations
open ClassificationMarking.Types



let getBannerLine (classification: Classification) =
    match classification with
    | Unclassified c -> ""
    | Classified c -> ""
